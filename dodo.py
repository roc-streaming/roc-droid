from doit import get_var
from doit.tools import title_with_actions, LongRunning, Interactive
import atexit
import fnmatch
import glob
import os
import pathlib
import platform
import platform
import shutil
import signal
import subprocess
import sys
import xml.etree.ElementTree

atexit.register(
    lambda: shutil.rmtree('__pycache__', ignore_errors=True))
if os.name == 'posix':
    signal.signal(signal.SIGINT, lambda s, f: exit(1))

DOIT_CONFIG = {
    'default_tasks': ['lint', 'test'],
    'verbosity': 2,
}

VARIANT = get_var('variant', 'release')
WATCH = get_var('watch', 'false')

def _pubspec_version():
    with open('pubspec.yaml') as fp:
        m = re.search(r'^version:\s*(\S+)\s*$', fp.read(), re.MULTILINE)
        return m.group(1)

def _android_version():
    with open('android/app/src/main/AndroidManifest.xml') as fp:
        root = xml.etree.ElementTree.fromstring(fp.read())
        return root.attrib['{http://schemas.android.com/apk/res/android}versionName']

def _gradlew():
    if platform.system() == 'Windows':
        return 'gradlew.bat'
    else:
        return './gradlew'

def _copy_file(src, dst):
    def task():
        print(f'\nCopying {src}\n     to {dst}', file=sys.stderr)
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copy2(src, dst)
    return task

def _delete_files(pattern):
    def task():
        for path in glob.glob(pattern):
            print(f'Removing {path}', file=sys.stderr)
            if os.path.isdir(path):
                shutil.rmtree(path)
            else:
                os.remove(path)
    return task

# doit lint
def task_lint():
    """run all linters"""
    return {
        'basename': 'lint',
        'actions': None,
        'task_dep': ['lint:dart', 'lint:kotlin'],
    }

# doit lint:dart
def task_lint_dart():
    """run dart analyzer"""
    return {
        'basename': 'lint:dart',
        'actions': ['flutter analyze --fatal-infos --fatal-warnings'],
        'title': title_with_actions,
    }

# doit lint:kotlin
def task_lint_kotlin():
    """run spotless linter"""
    return {
        'basename': 'lint:kotlin',
        'actions': [f'cd android && {_gradlew()} spotlessCheck'],
    }

# doit test
def task_test():
    """run tests"""
    return {
        'basename': 'test',
        'actions': ['flutter test -j1 -r expanded'],
        'title': title_with_actions,
    }

# doit launch [variant=debug|release]
def task_launch():
    """deploy and run on device"""
    def _do_cleanup():
        subprocess.call(
            'adb shell am force-stop org.rocstreaming.rocdroid',
            shell=True)
    def _register_cleanup():
        atexit.register(_do_cleanup)
    return {
        'basename': 'launch',
        'actions': [
            _register_cleanup,
            Interactive(f'flutter run --{VARIANT}'),
        ],
        'title': title_with_actions,
    }

# doit build [variant=debug|release]
def task_build():
    """build for all platforms"""
    return {
        'basename': 'build',
        'actions': None,
        'task_dep': ['build:apk'],
    }

# doit build:apk [variant=debug|release]
def task_build_apk():
    """build android apk"""
    return {
        'basename': 'build:apk',
        'actions': [
            f'flutter build apk --{VARIANT}',
            _copy_file(
                f'build/app/outputs/flutter-apk/app-{VARIANT}.apk',
                f'dist/android/{VARIANT}/roc-droid-{_android_version()}.apk'
            ),
        ],
        'title': title_with_actions,
    }

# doit wipe
def task_wipe():
    """remove all build artifacts"""
    return {
        'basename': 'wipe',
        'actions': [
            'flutter clean',
            _delete_files('android/.gradle'),
            _delete_files('android/build'),
        ],
        'title': title_with_actions,
    }

# doit gen
def task_gen():
    """run all code generators"""
    return {
        'basename': 'gen',
        'actions': None,
        'task_dep': ['gen:model', 'gen:agent'],
    }

# doit gen:model [watch=true|false]
def task_gen_model():
    """run flutter build_runner Model code generation"""
    if WATCH == 'true':
        subcmd = 'watch'
    else:
        subcmd = 'build'
    return {
        'basename': 'gen:model',
        'actions': [f'dart run build_runner {subcmd} --delete-conflicting-outputs'],
        'title': title_with_actions,
    }

# doit gen:agent
def task_gen_agent():
    """run flutter pigeon Agent code generation"""
    return {
        'basename': 'gen:agent',
        'actions': ['dart run pigeon --input lib/src/agent/android_bridge.decl.dart'],
        'title': title_with_actions,
    }

# doit gen:deps
def task_gen_deps():
    """collect dependencies and their licenses"""
    return {
        'basename': 'gen:deps',
        'actions': [
            # generate build/android_licenses.json
            f'cd android && {_gradlew()} generateLicenseReport',
            # generate build/flutter_licenses.json
            'flutter pub get',
            'flutter pub run flutter_oss_licenses:generate.dart '+
                '--json -o build/flutter_licenses.json',
            # generate metadata/dependencies.json
            f'{sys.executable} script/generate_dependencies.py',
        ],
        'title': title_with_actions,
    }

# doit gen:icons
def task_gen_icons():
    """run flutter icons generation (flutter_launcher_icons)"""
    return {
        'basename': 'gen:icons',
        'actions': ['dart run flutter_launcher_icons'],
        'title': title_with_actions,
    }

# doit gen:splash
def task_gen_splash():
    """run flutter splash screens generation (flutter_native_splash)"""
    return {
        'basename': 'gen:splash',
        'actions': ['dart run flutter_native_splash:create'],
        'title': title_with_actions,
    }

# doit fmt
def task_fmt():
    """run all code formatters"""
    return {
        'basename': 'fmt',
        'actions': None,
        'task_dep': ['fmt:dart', 'fmt:kotlin'],
    }

# doit fmt:dart
def task_fmt_dart():
    """run dart code formatter"""
    def _is_ignored(path):
        if fnmatch.fnmatch(path.name, '*.g.dart'):
            return True
        return False
    files = list(sorted(
        map(str,
            filter(lambda x: not _is_ignored(x),
                   pathlib.Path('lib').rglob('*.dart')))))
    return {
        'basename': 'fmt:dart',
        'actions': [['dart', 'format', *files]],
    }

# doit fmt:kotlin
def task_fmt_kotlin():
    """run spotless formatter"""
    return {
        'basename': 'fmt:kotlin',
        'actions': [f'cd android && {_gradlew()} spotlessApply'],
    }
