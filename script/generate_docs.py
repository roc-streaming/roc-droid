#! /usr/bin/env python3
import os
import platform
import signal
import subprocess
import sys

if os.name == 'posix':
    signal.signal(signal.SIGINT, lambda s, f: exit(1))

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

if len(sys.argv) > 1 and sys.argv[1] not in ['build', 'serve']:
    print('Usage: generate_docs.py [build|serve]', file=sys.stderr)
    sys.exit(1)

docker_run = [
    'docker', 'run',
    '--rm', '-t',
    '-v', f'{os.getcwd()}:{os.getcwd()}',
    '-w', os.getcwd(),
]

if platform.system() != 'Windows':
    docker_run += [
        '-u', f'{os.getuid()}:{os.getgid()}',
    ]

if len(sys.argv) <= 1 or sys.argv[1] == 'build':
    subprocess.check_call([
        *docker_run,
        'rocstreaming/env-sphinx',
        'mkdocs', 'build',
    ])
elif sys.argv[1] == 'serve':
    while True:
        if platform.system() != 'Windows':
            file_list = ['mkdocs.yml']
            for root, dirs, files in os.walk('docs'):
                for path in files:
                    file_list.append(os.path.join(root, path))

            cmd = [
                'entr', '-drn',
                *docker_run,
                '--net', 'host',
                '--init',
                'rocstreaming/env-sphinx',
                'mkdocs', 'serve', '--no-livereload',
            ]
        else:
            cmd = [
                *docker_run,
                '--net', 'host',
                '--init',
                'rocstreaming/env-sphinx',
                'mkdocs', 'serve',
                '-w', 'docs',
                '-w', 'mkdocs.yml',
            ]

        proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
        proc.communicate(input='\n'.join(file_list).encode())
