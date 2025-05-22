from doit import get_var
from doit.action import CmdAction
from doit.tools import title_with_actions, Interactive
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

class _Launcher(Interactive):
    def __init__(self, cmd, cleanup_cmd=''):
        if isinstance(cmd, list):
            cmd = shlex.join(cmd)
        super().__init__(cmd)
        self._cmd = cmd
        self._cleanup_cmd = cleanup_cmd

    def execute(self, *args, **kw):
        if os.name == 'posix':
            # execvp() replaces doit process with given command
            os.execvp(sys.executable, [
                sys.executable, 'script/wrap_command.py',
                '--command', self._cmd,
                '--cleanup', self._cleanup_cmd,
                '--timeout', '2',
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

DOIT_CONFIG = {
    'default_tasks': ['desktop:check', 'desktop:test'],
    'verbosity': 2,
}

VARIANT = get_var('variant', 'release')

# doit desktop:check
def task_desktop_check():
    """run dart analyzer"""
    return {
        'basename': 'desktop:check',
        'actions': [
            'flutter analyze',
        ],
        'title': _color_title,
    }

# doit desktop:test
def task_desktop_test():
    """run desktop_check, then run unit tests locally"""
    return {
        'basename': 'desktop:test',
        'task_dep': ['desktop:check'],
        'actions': [
            'flutter test -r github',
        ],
        'title': _color_title,
    }

# doit desktop:build [variant=debug|release]
def task_desktop_build():
    """run desktop_check, then build desktop app bundle"""
    return {
        'basename': 'desktop:build',
        'task_dep': ['desktop:check'],
        'actions': [
            f'flutter build {_platform()} --{VARIANT}',
        ],
        'title': _color_title,
    }

# doit desktop:launch [variant=debug|release]
def task_desktop_launch():
    """build desktop app, then launch it locally"""
    def _launch_app():
        device = _device(_platform())
        command = f'flutter run --{VARIANT} -d "{device}"'
        print(f'Running: {command}', file=sys.stderr)
        return _Launcher(command).execute()

    return {
        'basename': 'desktop:launch',
        'task_dep': ['desktop:build'],
        'actions': [
            _launch_app,
        ],
        'title': _color_title,
    }

# doit android:check
def task_android_check():
    """run dart analyzer and kotlin compiler"""
    yield {
        'basename': 'android:check',
        'name': 'dart',
        'actions': [
            'flutter analyze',
        ],
        'title': _color_title,
    }
    yield {
        'basename': 'android:check',
        'name': 'kotlin',
        'actions': [
            f'cd android && {_gradlew()} compileDebugJavaWithJavac',
        ],
        'title': _color_title,
    }

# doit android:test
def task_android_test():
    """run android_check, then run unit tests locally"""
    return {
        'basename': 'android:test',
        'task_dep': ['android:check'],
        'actions': [
            'flutter test -r github',
        ],
        'title': _color_title,
    }

# doit android:build [variant=debug|release]
def task_android_build():
    """run android_check, then build android apk"""
    return {
        'basename': 'android:build',
        'task_dep': ['android:check'],
        'actions': [
            f'flutter build apk --{VARIANT}',
        ],
        'title': _color_title,
    }

# doit android:install [variant=debug|release]
def task_android_install():
    """build android apk, then install it on connected device"""
    def _install_app():
        device = _device('android')
        command = f'flutter install --{VARIANT} -d "{device}"'
        print(f'Running: {command}', file=sys.stderr)
        return Interactive(command).execute()

    return {
        'basename': 'android:install',
        'task_dep': ['android:build'],
        'actions': [
            _install_app,
        ],
        'title': _color_title,
    }

# doit android:launch [variant=debug|release]
def task_android_launch():
    """build android apk, then launch it on connected device"""
    def _launch_app():
        device = _device('android')
        command = f'flutter run --{VARIANT} -d "{device}"'
        cleanup = 'adb shell am force-stop org.rocstreaming.rocdroid'
        print(f'Running: {command}', file=sys.stderr)
        return _Launcher(command, cleanup).execute()

    return {
        'basename': 'android:launch',
        'task_dep': ['android:build'],
        'actions': [
            _launch_app,
        ],
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

# doit gen
def task_gen():
    """run all code generation (but not resource generation)"""
    return {
        'basename': 'gen',
        'actions': [],
        'task_dep': ['gen:build_runner', 'gen:pigeon', 'gen:l10n'],
    }

# doit gen:build_runner
def task_gen_build_runner():
    """run flutter build_runner Model code generation"""
    return {
        'basename': 'gen:build_runner',
        'actions': [
            f'dart run build_runner build --delete-conflicting-outputs',
        ],
        'title': _color_title,
    }

# doit gen:pigeon
def task_gen_pigeon():
    """run flutter pigeon Agent code generation"""
    return {
        'basename': 'gen:pigeon',
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
            [sys.executable, 'script/generate_dependencies.py'],
        ],
        'title': _color_title,
    }

# doit gen:icons
def task_gen_icons():
    """run flutter icons generation (flutter_launcher_icons)"""
    return {
        'basename': 'gen:icons',
        'actions': [
            'dart run flutter_launcher_icons',
        ],
        'title': _color_title,
    }

# doit gen:splash
def task_gen_splash():
    """run flutter splash screens generation (flutter_native_splash)"""
    return {
        'basename': 'gen:splash',
        'actions': [
            'dart run flutter_native_splash:create',
        ],
        'title': _color_title,
    }

# doit docs:site
def task_docs_site():
    """generate html documentation"""
    return {
        'basename': 'docs:site',
        'actions': [
            'mkdocs build',
        ],
        'title': _color_title,
    }

# doit docs:md
def task_docs_md():
    """generate markdown files"""
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
        'actions': [],
        'task_dep': ['fmt:dart', 'fmt:kotlin'],
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
        'actions': [
            f'cd android && {_gradlew()} spotlessApply',
        ],
        'title': _color_title,
    }
