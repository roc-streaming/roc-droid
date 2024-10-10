#! /usr/bin/env python3

import os
import platform
import subprocess

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

docker = [
    'docker', 'run',
    '--rm', '-it',
    '-v', f'{os.getcwd()}:/docs',
]

if platform.system() != 'Windows':
    docker += [
        '-u', f'{os.getuid()}:{os.getgid()}',
    ]

subprocess.check_call(
    docker +
    ['squidfunk/mkdocs-material', 'build'])
