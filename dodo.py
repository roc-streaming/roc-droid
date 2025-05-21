from doit import get_var
from doit.action import CmdAction
from doit.tools import title_with_actions, LongRunning, Interactive
import atexit
import fnmatch
import functools
import glob
import json
import os
import pathlib
import platform
import shlex
import shutil
import signal
import subprocess
import sys

atexit.register(
    lambda: shutil.rmtree('__pycache__', ignore_errors=True))
if os.name == 'posix':
    signal.signal(signal.SIGINT, lambda s, f: exit(1))

sys.stdin.reconfigure(encoding='utf-8')
sys.stdout.reconfigure(encoding='utf-8')

DOIT_CONFIG = {
    'default_tasks': ['check:desktop', 'test:desktop'],
    'verbosity': 2,
}

VARIANT = get_var('variant', 'release')

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
    _die(f'No {platform} device found!')

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
def _colors_supported():
    try:
        import colorama
        if sys.stderr.isatty():
            colorama.init(autoreset=False)
            return True
    except ImportError:
        pass
    return False

@functools.cache
def _colorize(text, color):
    if _colors_supported():
        import colorama
        text = getattr(colorama.Fore, color.upper(), '') + \
            text + colorama.Style.RESET_ALL
    return text

def _color_title(task):
    text = title_with_actions(task)
    if '=>' in text:
        name, title = text.split('=>')
        return '{}=>{}'.format(
            _colorize(name, 'blue'), _colorize(title, 'yellow'))
    else:
        return _colorize(text, 'blue')

def _die(msg):
    msg = _colorize(msg, 'lightred_ex')
    print(f'error: {msg}', file=sys.stderr)
    sys.exit(1)

class _InteractiveCmd(Interactive):
    def __init__(self, cmd, cleanup_cmd=None):
        super().__init__(cmd)
        self._cmd = cmd
        self._cleanup_cmd = cleanup_cmd

    def execute(self, *args, **kw):
        print(f'Running: {self._cmd}', file=sys.stderr)

        if platform.system() == 'posix':
            # execvp() replaces doit process with given command
            os.execvp(sys.executable, [
                sys.executable, 'script/wrap_command.py',
                '--command', self._cmd,
                '--cleanup', self._cleanup_cmd,
                '--timeout', 2,
            ])

        if self._cleanup_cmd:
            atexit.register(
                lambda: subprocess.call(self._cleanup_cmd, shell=True))

        super().execute(*args, **kw)

class _HugeCmd(CmdAction):
    def __init__(self, func, title):
        super().__init__(self._make_cmd)
        self._func = func
        self._title = title

    def _make_cmd(self):
        return ' '.join(map(shlex.quote, self._func()))

    def __str__(self):
        return 'Cmd: ' + self._title

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

# TODO
# doit install:deskop [variant=debug|release]
def todo_install_desktop():
    pass

# doit install:android [variant=debug|release]
def task_install_android():
    """build android apk, then install it on connected device"""
    def _install_app():
        device = _device('android')
        cmd = f'flutter install --{VARIANT} -d "{device}"'
        print(f'Running: {cmd}', file=sys.stderr)
        return LongRunning(cmd).execute()

    return {
        'basename': 'install:android',
        'task_dep': ['build:android'],
        'actions': [
            _install_app,
        ],
        'title': _color_title,
    }

# doit launch:desktop [variant=debug|release]
def task_launch_desktop():
    """build desktop app, then launch it locally"""
    def _launch_app():
        device = _device(_platform())
        cmd = f'flutter run --{VARIANT} -d "{device}"'
        return _InteractiveCmd(cmd).execute()

    return {
        'basename': 'launch:desktop',
        'task_dep': ['build:desktop'],
        'actions': [
            _launch_app,
        ],
        'title': _color_title,
    }

# doit launch:android [variant=debug|release]
def task_launch_android():
    """build android apk, then launch it on connected device"""
    def _launch_app():
        device = _device('android')
        cmd = f'flutter run --{VARIANT} -d "{device}"'
        cleanup = 'adb shell am force-stop org.rocstreaming.rocdroid'
        return _InteractiveCmd(cmd, cleanup).execute()

    return {
        'basename': 'launch:android',
        'task_dep': ['build:android'],
        'actions': [
            _launch_app,
        ],
        'title': _color_title,
    }

# doit gen
def task_gen():
    """run all code generation (but not resource generation)"""
    return {
        'basename': 'gen',
        'task_dep': ['gen:model', 'gen:agent', 'gen:l10n'],
        'actions': None,
    }

# doit gen:model [watch=true|false]
def task_gen_model():
    """run flutter build_runner Model code generation"""
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

# doit gen:l10n
def task_gen_l10n():
    """run flutter localization generation"""
    return {
        'basename': 'gen:l10n',
        'actions': [
            'flutter gen-l10n',
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

# doit docs:build
def task_docs_build():
    """build html documentation"""
    return {
        'basename': 'docs:build',
        'actions': [
            f'{sys.executable} script/generate_docs.py build',
        ],
        'title': _color_title,
    }

# doit docs:serve
def task_docs_serve():
    """serve html documentation on localhost"""
    return {
        'basename': 'docs:serve',
        'actions': [
            _InteractiveCmd(f'{sys.executable} script/generate_docs.py serve'),
        ],
        'title': _color_title,
    }

# doit docs:authors
def task_docs_md():
    """re-generate authors list"""
    return {
        'basename': 'docs:md',
        'actions': [
            'md-authors -a -f "{index}. {name} ([{login}]({profile}))" docs/authors.md'
        ],
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

    def _make_command():
        files = list(sorted(
            map(str,
                filter(lambda x: not _is_ignored(x),
                       pathlib.Path('lib').rglob('*.dart')))))
        return ['dart', 'format', *files]

    return {
        'basename': 'fmt:dart',
        'actions': [
            _HugeCmd(func=_make_command, title='dart format'),
        ],
        'title': _color_title,
    }

# doit fmt:kotlin
def task_fmt_kotlin():
    """run spotless formatter"""
    return {
        'basename': 'fmt:kotlin',
        'actions': [f'cd android && {_gradlew()} spotlessApply'],
        'title': _color_title,
    }
