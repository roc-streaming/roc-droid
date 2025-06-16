#! /usr/bin/env python3

import argparse
import fileinput
import os
import os.path
import re
import subprocess
import sys
import xml.etree.ElementTree

PUBSPEC_FILE = 'pubspec.yaml'
MANIFEST_FILE = 'android/app/src/main/AndroidManifest.xml'

def run_cmd(args):
    print('running: '+' '.join(args))
    subprocess.check_call(args)

def make_version_code(version):
    major, minor, patch = map(int, version.split('.'))
    return str(1000000*major + 1000*minor + patch)

def parse_version(version):
    if not re.match(r'^v?\d+\.\d+\.\d+$', version):
        print(f'error: version "{version}" is not in correct format,'
              ' expected "N.N.N" or "vN.N.N"')
        exit(1)
    return version.lstrip('v')

def write_version(version):
    version_code = make_version_code(version)

    print(f'writing version {version} to {PUBSPEC_FILE}')

    with fileinput.FileInput(PUBSPEC_FILE, inplace=True) as fp:
        for line in fp:
            line = re.sub(r'^version:\s*\S+\s*$', f'version: {version}\n', line)
            print(line, end='')

    print(f'writing version {version}+{version_code} to {MANIFEST_FILE}')

    with fileinput.FileInput(MANIFEST_FILE, inplace=True) as fp:
        for line in fp:
            line = re.sub(r'\bandroid:versionName=".*"', f'android:versionName="{version}"', line)
            line = re.sub(r'\bandroid:versionCode=".*"', f'android:versionCode="{version_code}"', line)
            print(line, end='')

def check_version(version):
    version_code = make_version_code(version)

    with open(PUBSPEC_FILE) as fp:
        m = re.search(r'^version:\s*(\S+)\s*$', fp.read(), re.MULTILINE)
        spec_version = m.group(1)

        if spec_version != version:
            print(f'error: {PUBSPEC_FILE} defines version {spec_version},'
                  f' but git tag defines version {version}')
            exit(1)

        print(f'{PUBSPEC_FILE} is good')

    with open(MANIFEST_FILE) as fp:
        root = xml.etree.ElementTree.fromstring(fp.read())

        manifest_version_name = root.attrib[
            '{http://schemas.android.com/apk/res/android}versionName']
        manifest_version_code = root.attrib[
            '{http://schemas.android.com/apk/res/android}versionCode']

        if manifest_version_name != version:
            print(f'error: {MANIFEST_FILE} defines version {manifest_version_name},'
                  f' but git tag defines version {version}')
            exit(1)

        if manifest_version_code != version_code:
            print(f'error: {MANIFEST_FILE} defines version code {manifest_version_code},'
                  f' but git tag defines version code {version_code}')
            exit(1)

        print(f'{MANIFEST_FILE} is good')

def commit_version(version):
    run_cmd(['git', 'add',
             'pubspec.yml',
             'android/app/src/main/AndroidManifest.xml'])

    if not subprocess.check_output(['git',
           'diff', '--cached',
           'pubspec.yml',
           'android/app/src/main/AndroidManifest.xml']):
        print('version did not change, nothing to commit')
        return

    run_cmd(['git', 'commit', '-m', f'Release {version}'])

def create_tag(tag, force):
    if force:
        run_cmd(['git', 'tag', '-f', tag])
    else:
        run_cmd(['git', 'tag', tag])

def detect_tag():
    return subprocess.check_output(
        ['git', 'describe', '--tags', '--abbrev=0'],
        stderr=subprocess.STDOUT).decode().strip()

def find_tag(tag):
    try:
        subprocess.check_output(['git', 'rev-parse', tag], stderr=subprocess.STDOUT)
        return True
    except subprocess.CalledProcessError:
        return False

def push_changes(remote, tag, force):
    run_cmd(['git', 'push', remote, 'HEAD'])
    if force:
        run_cmd(['git', 'push', '-f', remote, tag])
    else:
        run_cmd(['git', 'push', remote, tag])

def make_release(version, remote, force):
    tag = f'v{version}'

    if not force and find_tag(tag):
        print(f'error: tag "{tag}" already exists')
        exit(1)

    write_version(version)
    commit_version(version)

    create_tag(tag, force)
    if remote:
        push_changes(remote, tag, force)

def check_release():
    tag = detect_tag()
    version = parse_version(tag)

    check_version(version)

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..'))

parser = argparse.ArgumentParser(description='Project version manager')
subparsers = parser.add_subparsers(dest='command')

make_release_cmd = subparsers.add_parser('make_release')
make_release_cmd.add_argument('--push', metavar='REMOTE', required=False,
                              help='remote to push (e.g. "origin")')
make_release_cmd.add_argument('-f', '--force', action='store_true', required=False,
                              help='force creating and pushing tag, even if it already exists')
make_release_cmd.add_argument('version', metavar='VERSION',
                              help='version to release ("N.N.N" or "vN.N.N")')

check_release_cmd = subparsers.add_parser('check_release')

update_version_cmd = subparsers.add_parser('update_version')
update_version_cmd.add_argument('version', metavar='VERSION',
                                help='version to release ("N.N.N" or "vN.N.N")')

args = parser.parse_args()

if args.command == 'make_release':
    make_release(parse_version(args.version),
                 args.push,
                 args.force)

elif args.command == 'check_release':
    check_release()

elif args.command == 'update_version':
    write_version(
        parse_version(args.version))
