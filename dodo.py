from doit import get_var
from doit.tools import title_with_actions, LongRunning, Interactive
import atexit
import glob
import os
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
    'default_tasks': ['analyze', 'test'],
    'verbosity': 2,
}

VARIANT = get_var('variant', 'release')
WATCH = get_var('watch', 'false')

# Delete all files matching glob pattern.
def _delete_files(pattern):
    def task():
        for path in glob.glob(pattern):
            print(f'Removing {path}', file=sys.stderr)
            if os.path.isdir(path):
                shutil.rmtree(path)
            else:
                os.remove(path)
    return task

# doit analyze
def task_analyze():
    """run dart analyzer"""
    return {
        'actions': ['flutter analyze --fatal-infos --fatal-warnings'],
        'title': title_with_actions,
    }

# doit test
def task_test():
    """run tests"""
    return {
        'actions': ['flutter test -j1 -r github'],
        'title': title_with_actions,
    }

# doit launch [variant=debug|release]
def task_launch():
    """deploy and run on device"""
    def do_cleanup():
        subprocess.call(
            'adb shell am force-stop org.rocstreaming.rocdroid',
            shell=True)
    def register_cleanup():
        atexit.register(do_cleanup)
    return {
        'actions': [
            register_cleanup,
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
        'actions': [f'flutter build apk --{VARIANT}'],
        'title': title_with_actions,
    }

# doit wipe
def task_wipe():
    """remove all build artifacts"""
    return {
        'actions': [
            'flutter clean',
            _delete_files('android/.gradle'),
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
        'actions': ['dart run flutter_native_splash:create '],
        'title': title_with_actions,
    }
