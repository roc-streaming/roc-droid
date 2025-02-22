from doit import get_var
from doit.tools import title_with_actions, LongRunning, Interactive
import atexit
import fnmatch
import functools
import glob
import json
import os
import pathlib
import platform
import shutil
import signal
import subprocess
import sys

atexit.register(
    lambda: shutil.rmtree('__pycache__', ignore_errors=True))
if os.name == 'posix':
    signal.signal(signal.SIGINT, lambda s, f: exit(1))

DOIT_CONFIG = {
    'default_tasks': ['check', 'test'],
    'verbosity': 2,
}

VARIANT = get_var('variant', 'release')
WATCH = get_var('watch', 'false')

def _platform():
    if platform.system() == 'Linux':
        return 'linux'
    if platform.system() == 'Darwin':
        return 'macos'
    elif platform.system() == 'Windows':
        return 'windows'

def _device(platform):
    out = subprocess.check_output(['flutter', 'devices', '--machine'])
    if out:
        for dev in json.loads(out):
            if dev['isSupported'] and dev['targetPlatform'].startswith(platform):
                return dev['id']
    return ''

def _gradlew():
    if platform.system() == 'Windows':
        return 'gradlew.bat'
    else:
        return './gradlew'

def _truish(s):
    return s.lower() in ['true', 'yes', 'on', '1']

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

@functools.cache
def _colorize(text, color):
    try:
        import colorama
        if sys.stderr.isatty():
            return getattr(colorama.Fore, color.upper(), '') + \
                text + colorama.Style.RESET_ALL
    except ImportError:
        pass
    return text

def _color_title(task):
    name, title = title_with_actions(task).split('=>')
    return '{}=>{}'.format(
        _colorize(name, 'blue'), _colorize(title, 'yellow'))

# doit check:desktop
def task_check_desktop():
    """run dart analyzer"""
    return {
        'basename': 'check:desktop',
        'actions': [
            'flutter analyze',
        ],
        'title': _color_title,
    }

# doit check:android
def task_check_android():
    """run dart analyzer, kotlin compiler, and spotless linter"""
    yield {
        'basename': 'check:android',
        'name': 'dart',
        'actions': [
            'flutter analyze',
        ],
        'title': _color_title,
    }
    yield {
        'basename': 'check:android',
        'name': 'kotlin',
        'actions': [
            f'cd android && {_gradlew()} compileDebugJavaWithJavac',
        ],
        'title': _color_title,
    }
    yield {
        'basename': 'check:android',
        'name': 'spotless',
        'actions': [
            f'cd android && {_gradlew()} spotlessCheck',
        ],
        'title': _color_title,
    }

# doit test:desktop
def task_test_desktop():
    """run check:desktop, then run unit tests locally"""
    return {
        'basename': 'test:desktop',
        'task_dep': ['check:desktop'],
        'actions': [
            'flutter test -j1 -r github',
        ],
        'title': _color_title,
    }

# doit test:android
def task_test_android():
    """run check:android, then run unit tests locally"""
    return {
        'basename': 'test:android',
        'task_dep': ['check:android'],
        'actions': [
            'flutter test -j1 -r github',
        ],
        'title': _color_title,
    }

# doit build:desktop [variant=debug|release]
def task_build_desktop():
    """run check:desktop, then build desktop app bundle"""
    return {
        'basename': 'build:desktop',
        'task_dep': ['check:desktop'],
        'actions': [f'flutter build {_platform()} --{VARIANT}'],
        'title': _color_title,
    }

# doit build:android [variant=debug|release]
def task_build_android():
    """run check:android, then build android apk"""
    return {
        'basename': 'build:android',
        'task_dep': ['check:android'],
        'actions': [f'flutter build apk --{VARIANT}'],
        'title': _color_title,
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
            _delete_files('dist'),
            _delete_files('site'),
        ],
        'title': _color_title,
    }

# doit install:android [variant=debug|release]
def task_install_android():
    """build android apk, then install it on connected device"""
    return {
        'basename': 'install:android',
        'task_dep': ['build:android'],
        'actions': [
            f'flutter install --{VARIANT}',
        ],
        'title': _color_title,
    }

# doit launch:desktop [variant=debug|release]
def task_launch_desktop():
    """build desktop app, then launch it locally"""
    def _run_app():
        cmd = f'flutter run --{VARIANT} -d "{_device(_platform())}"'
        print(f'Running: {cmd}', file=sys.stderr)
        return Interactive(cmd).execute()
    return {
        'basename': 'launch:desktop',
        'task_dep': ['build:desktop'],
        'actions': [
            _run_app,
        ],
        'title': _color_title,
    }

# doit launch:android [variant=debug|release]
def task_launch_android():
    """build android apk, then launch it on connected device"""
    def _register_cleanup():
        atexit.register(lambda: subprocess.call(
            'adb shell am force-stop org.rocstreaming.rocdroid',
            shell=True))
    def _run_app():
        cmd = f'flutter run --{VARIANT} -d "{_device("android")}"'
        print(f'Running: {cmd}', file=sys.stderr)
        return Interactive(cmd).execute()
    return {
        'basename': 'launch:android',
        'task_dep': ['build:android'],
        'actions': [
            _register_cleanup,
            _run_app,
        ],
        'title': _color_title,
    }

# doit gen
def task_gen():
    """run all code generation (but not resource generation)"""
    return {
        'basename': 'gen',
        'task_dep': ['gen:model', 'gen:agent'],
        'actions': None,
    }

# doit gen:model [watch=true|false]
def task_gen_model():
    """run flutter build_runner Model code generation"""
    if _truish(WATCH):
        return {
            'basename': 'gen:model',
            'actions': [
                LongRunning(f'dart run build_runner watch --delete-conflicting-outputs'),
            ],
            'title': _color_title,
        }
    else:
        return {
            'basename': 'gen:model',
            'actions': [
                f'dart run build_runner build --delete-conflicting-outputs',
            ],
            'title': _color_title,
        }

# doit gen:agent
def task_gen_agent():
    """run flutter pigeon Agent code generation"""
    return {
        'basename': 'gen:agent',
        'actions': [
            'dart run pigeon --input lib/src/agent/android_bridge.decl.dart',
        ],
        'title': _color_title,
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
        'title': _color_title,
    }

# doit gen:icons
def task_gen_icons():
    """run flutter icons generation (flutter_launcher_icons)"""
    return {
        'basename': 'gen:icons',
        'actions': ['dart run flutter_launcher_icons'],
        'title': _color_title,
    }

# doit gen:splash
def task_gen_splash():
    """run flutter splash screens generation (flutter_native_splash)"""
    return {
        'basename': 'gen:splash',
        'actions': ['dart run flutter_native_splash:create'],
        'title': _color_title,
    }

# doit fmt
def task_fmt():
    """run all code formatters"""
    return {
        'basename': 'fmt',
        'task_dep': ['fmt:dart', 'fmt:kotlin'],
        'actions': None,
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
