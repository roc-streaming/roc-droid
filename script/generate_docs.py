#! /usr/bin/env python3
import os
import signal
import subprocess
import sys

def print_cmd(cmd):
    args = []
    for arg in cmd:
        if ' ' in arg:
            args.append(f'"{arg}"')
        else:
            args.append(arg)
    print('Running: ' + ' '.join(args), file=sys.stderr)

if os.name == 'posix':
    signal.signal(signal.SIGINT, lambda s, f: exit(1))

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

if len(sys.argv) > 1 and sys.argv[1] not in ['build', 'serve']:
    print('Usage: generate_docs.py [build|serve]', file=sys.stderr)
    sys.exit(1)

docker_run = [
    'docker', 'run',
    '--rm',
    '-v', f'{os.getcwd()}:{os.getcwd()}',
    '-w', os.getcwd(),
]
if os.name == 'posix' and not os.environ.get('CI'):
    docker_run += [
        '-u', f'{os.getuid()}:{os.getgid()}',
    ]

if len(sys.argv) <= 1 or sys.argv[1] == 'build':
    cmd = [
        *docker_run,
        'rocstreaming/env-docs',
        'mkdocs', 'build',
    ]
    print_cmd(cmd)
    subprocess.check_call(cmd)
elif sys.argv[1] == 'serve':
    if os.name == 'posix':
        rm_cmd = [
            'docker', 'rm', '-f', 'rocd_docs',
        ]
        print_cmd(rm_cmd)
        subprocess.run(rm_cmd, stderr=subprocess.DEVNULL)
        run_cmd = [
            *docker_run, '-i',
            '--net', 'host',
            '--init',
            '--name', 'rocd_docs',
            'rocstreaming/env-docs',
            'entr', '-drzns',
            'mkdocs serve --no-livereload',
        ]
        print_cmd(run_cmd)
        while True:
            file_list = []
            for root, dirs, files in os.walk('docs'):
                for path in files:
                    file_list.append(os.path.join(root, path))

            proc = subprocess.Popen(run_cmd, stdin=subprocess.PIPE)
            proc.communicate(input='\n'.join(file_list).encode())
    else:
        cmd = [
            *docker_run,
            '--net', 'host',
            '--init',
            'rocstreaming/env-docs',
            'mkdocs', 'serve',
            '-w', 'docs',
            '-w', 'mkdocs.yml',
        ]
        print_cmd(cmd)
        subprocess.run(cmd)
