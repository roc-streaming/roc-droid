from doit.tools import title_with_actions

# doit gen
def task_gen():
    """run flutter build_runner code generation"""
    return {
        'actions': ['dart run build_runner build --delete-conflicting-outputs'],
        'title': title_with_actions,
        'verbosity': 2,
    }

# doit gen_watch
def task_gen_watch():
    """run flutter build_runner code watch generation"""
    return {
        'actions': ['dart run build_runner watch --delete-conflicting-outputs'],
        'title': title_with_actions,
        'verbosity': 2,
    }

# doit icons
def task_icons():
    """run flutter icons generation (flutter_launcher_icons)"""
    return {
        'actions': ['dart run flutter_launcher_icons'],
        'title': title_with_actions,
        'verbosity': 2,
    }

# doit splash
def task_splash():
    """run flutter splash screens generation (flutter_native_splash)"""
    return {
        'actions': ['dart run flutter_native_splash:create '],
        'title': title_with_actions,
        'verbosity': 2,
    }