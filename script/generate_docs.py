#! /usr/bin/env python3

import os
import platform
import subprocess

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

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

subprocess.check_call([
    *docker_run,
    'rocstreaming/env-sphinx',
    'mkdocs', 'build',
])
