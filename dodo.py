from doit.tools import title_with_actions, LongRunning
import atexit
import os
import shutil
import signal

atexit.register(
    lambda: shutil.rmtree('__pycache__', ignore_errors=True))
if os.name == 'posix':
    signal.signal(signal.SIGINT, lambda s, f: os._exit(0))

DOIT_CONFIG = {
    'default_tasks': ['analyze', 'test'],
    'verbosity': 2,
}

# doit analyze
def task_analyze():
    """run analyzer"""
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

# doit exec
def task_exec():
    """run on device"""
    return {
        'actions': [LongRunning('flutter run --release')],
        'title': title_with_actions,
    }

# doit build_apk
def task_build_apk():
    """build android apk"""
    return {
        'actions': ['flutter build apk --release'],
        'title': title_with_actions,
    }

# doit wipe
def task_wipe():
    """clean build artifacts"""
    return {
        'actions': ['flutter clean'],
        'title': title_with_actions,
    }

# doit gen
def task_gen():
    """run all flutter code generation"""
    return {
        'actions': [get_action(task_gen_model()),
                    get_action(task_gen_agent())],
        'title': title_with_actions,
    }

# doit gen_model
def task_gen_model():
    """run flutter build_runner Model code generation"""
    return {
        'actions': ['dart run build_runner build --delete-conflicting-outputs'],
        'title': title_with_actions,
    }

# doit gen_model_watch
def task_gen_model_watch():
    """run flutter build_runner Moddel code watch generation"""
    return {
        'actions': [LongRunning('dart run build_runner watch --delete-conflicting-outputs')],
        'title': title_with_actions,
    }

# doit gen_agent
def task_gen_agent():
    """run flutter pigeon Agent code generation"""
    return {
        'actions': ['dart run pigeon --input lib/src/agent/android_connector.dart'],
        'title': title_with_actions,
    }

# doit icons
def task_icons():
    """run flutter icons generation (flutter_launcher_icons)"""
    return {
        'actions': ['dart run flutter_launcher_icons'],
        'title': title_with_actions,
    }

# doit splash
def task_splash():
    """run flutter splash screens generation (flutter_native_splash)"""
    return {
        'actions': ['dart run flutter_native_splash:create '],
        'title': title_with_actions,
    }

# Get first doit method 'actions' value
def get_action(dic):
  
    for key, value in dic.items():
        if key == 'actions':
            return value[0]

    return "action doesn't exist"
