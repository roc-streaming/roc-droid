#! /usr/bin/env python3

import argparse
import os
import platform
import re
import subprocess
import sys

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

# We have docker_build.bat that is a windows-specific version of docker_build.py.
# It exists so that docker build doesn't require python on windows.
#
# But if the user still runs docker_build.py on windows, we redirect call to
# docker_build.bat, as we don't want duplicating windows-specific logic in two scripts.
#
# The rest of the script assumes that we're on a Unix-like system.
if platform.system() == 'Windows':
    try:
        subprocess.check_call(
            ['script/docker_build.bat'] + sys.argv[1:], shell=False)
        exit(0)
    except:
        exit(1)

def project_version():
    with open('pubspec.yaml') as fp:
        m = re.search(r'^version:\s*(\S+)\s*$', fp.read(), re.MULTILINE)
        return m.group(1)

def print_msg(msg=''):
    print(f'\033[1;34m{msg}\033[0m', file=sys.stderr)

def print_err(msg=''):
    print(f'\033[1;31m{msg}\033[0m', file=sys.stderr)

def run_cmd(cmd):
    print(' '.join(cmd), file=sys.stderr)
    try:
        subprocess.check_call(cmd)
    except subprocess.CalledProcessError as e:
        print_err(f'Command failed with code {e.returncode}')
        exit(1)
    except KeyboardInterrupt:
        exit(1)

parser = argparse.ArgumentParser()
parser.add_argument('target',
                    nargs='?',
                    choices=['android'], default='android')

args = parser.parse_args()

try:
    subprocess.check_output(['docker', 'info'], stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print_err('Docker Daemon is not running')
    exit(1)

cwd = os.path.abspath(os.getcwd())
uid = os.getuid()
gid = os.getgid()

work_dir = None
cache_dirs = {}

if args.target == 'android':
    work_dir = '/root/build' # container
    cache_dirs = {
        # host: container
        f'{cwd}/build/dockercache/pub': '/root/.pub-cache',
        f'{cwd}/build/dockercache/gradle': '/root/.gradle',
        f'{cwd}/build/dockercache/android': '/root/.android/cache',
    }

docker_cmd = [
    'docker', 'run',
    '--rm', '-t',
    '-u', f'{uid}:{gid}',
    '-w', work_dir,
    '-v', f'{cwd}:{work_dir}',
]

for host_dir, container_dir in cache_dirs.items():
    os.makedirs(host_dir, exist_ok=True)
    docker_cmd += [
        '-v', f'{host_dir}:{container_dir}',
    ]

docker_cmd += [
    f'rocstreaming/env-flutter:{args.target}',
]

if args.target == 'android':
    docker_cmd += [
        'flutter', 'build', 'apk', '--release',
    ]

print_msg(f'Running {args.target} build in docker')
run_cmd(docker_cmd)

if args.target == 'android':
    app_type = 'apk'
    app_file = f'roc-droid-{project_version()}.apk'

print_msg()

print_msg(f'Copied {args.target} {app_type} to dist/{args.target}/release/{app_file}')
run_cmd(['ls', '-lh', f'dist/{args.target}/release'])
