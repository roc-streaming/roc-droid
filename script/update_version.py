#! /usr/bin/env python3

import fileinput
import os
import re
import sys
import yaml

PUBSPEC_FILE = 'pubspec.yaml'
MANIFEST_FILE = 'android/app/src/main/AndroidManifest.xml'

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

if len(sys.argv) != 2:
    print(f'Usage: script/update_version.py 1.2.3')
    exit(1)

version = sys.argv[1]
major, minor, patch = map(int, version.split('.'))
version_code = 1000000*major + 1000*minor + patch

print(f'Version: {version}, version code: {version_code}')

print(f'Updating {PUBSPEC_FILE}')

with fileinput.FileInput(PUBSPEC_FILE, inplace=True) as fp:
    for line in fp:
        line = re.sub(r'^version:\s*\S+\s*$', f'version: {version}\n', line)
        print(line, end='')

print(f'Updating {MANIFEST_FILE}')

with fileinput.FileInput(MANIFEST_FILE, inplace=True) as fp:
    for line in fp:
        line = re.sub(r'\bandroid:versionName=".*"', f'android:versionName="{version}"', line)
        line = re.sub(r'\bandroid:versionCode=".*"', f'android:versionCode="{version_code}"', line)
        print(line, end='')

print(f'Done.')
