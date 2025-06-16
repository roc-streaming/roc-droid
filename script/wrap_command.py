#! /usr/bin/env python3
import argparse
import os
import signal
import subprocess
import sys

def forward_exit_status(retcode):
    if retcode >= 0:
        os._exit(retcode)
    else:
        signum = -retcode
        signal.signal(signum, signal.SIG_DFL)
        signal.raise_signal(signum)

class SignalException:
    def __init__(self, signum):
        self.signum = signum

def handle_signal(signum, frame):
    raise SignalException(signum)

parser = argparse.ArgumentParser(description='Run a command with cleanup')
parser.add_argument('--command', type=str, required=True, help='Main command')
parser.add_argument('--cleanup', type=str, required=True, help='Cleanup command')
parser.add_argument('--timeout', type=int, default=5000,
                    help='Timeout in seconds to wait for graceful exit')
args = parser.parse_args()

# close inherited descriptors to ensure we drop all file locks held by doit
for fd in range(3, 1024+1):
    try:
        os.close(fd)
    except OSError:
        pass

# start command
proc = subprocess.Popen(args.command, shell=True)

# close tty descriptors to ensure we don't interfer with the command
sys.stdin.close()
sys.stdout.close()
sys.stderr.close()

# convert signals to exception
for sig in [signal.SIGINT, signal.SIGQUIT, signal.SIGHUP, signal.SIGTERM]:
    signal.signal(sig, handle_signal)

try:
    # wait command
    main_code = proc.wait()
except SignalException as e:
    # ask command to exit
    proc.send_signal(e.signum)
    try:
        # wait it exited
        main_code = proc.wait(args.timeout)
    except TimeoutExpired:
        # kill command forcibly and wait again
        proc.send_signal(signal.SIGKILL)
        main_code = proc.wait()

# run cleanup
if args.cleanup:
    cleanup_code = subprocess.run(args.cleanup, shell=True).returncode
else:
    cleanup_code = 0

# forward exit code or signal
if main_code != 0:
    forward_exit_status(main_code)
else:
    forward_exit_status(cleanup_code)
