#! /usr/bin/env python3

from colorama import Fore, Back
import colorama
import functools
import hashlib
import os
import re
import signal
import subprocess

LEVEL_COLORS = {
    'E': Back.RED,
    'W': Back.YELLOW,
    'I': Back.GREEN,
    'D': Back.LIGHTBLACK_EX,
    'V': Back.RESET,
}

TAG_COLORS =  [
    Fore.RED,
    Fore.LIGHTRED_EX,
    Fore.GREEN,
    Fore.LIGHTGREEN_EX,
    Fore.YELLOW,
    Fore.LIGHTYELLOW_EX,
    Fore.BLUE,
    Fore.LIGHTBLUE_EX,
    Fore.MAGENTA,
    Fore.LIGHTMAGENTA_EX,
    Fore.CYAN,
    Fore.LIGHTCYAN_EX,
]

PIDS = set()

def persist_hash(s):
    b = hashlib.md5(s.encode()).hexdigest()
    return int(b, 16)

def match_line(pid, level, tag, msg):
    if re.search(r'^(ViewRoot|SurfaceView|BLAST|OpenGL|Insets|Input|TextInput|RemoteInput|Ime)', tag):
        return False

    if pid in PIDS:
        return True
    if tag.startswith('rocdroid.'):
        PIDS.add(pid)
        return True
    if re.search(r'flutter|AudioTrack|AudioRecord|MediaProjection', tag):
        return True
    if re.search(r'ActivityManager', tag) and re.search(r'rocdroid', msg):
        return True

    return False

@functools.cache
def format_pid_tid(pid, tid):
    return f'{Fore.LIGHTBLACK_EX}[{pid:05}:{tid:05}]{Fore.RESET}'

@functools.cache
def format_level(level):
    color = LEVEL_COLORS[level]
    return f'{color} {level} {Back.RESET}'

@functools.cache
def format_tag(tag):
    color = TAG_COLORS[persist_hash(tag) % len(TAG_COLORS)]
    return f'[{color}{tag}{Fore.RESET}]'

colorama.init()

if os.name == 'posix':
    signal.signal(signal.SIGINT, lambda s, f: exit(0))

cmd = ['adb', 'logcat', '-v', 'threadtime', '-T', '1']
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)

while True:
    line = proc.stdout.readline()
    if not line:
        break

    m = re.match(
        r'^\s*(?P<date>\S+)\s+(?P<time>\S+)\s+(?P<pid>\S+)\s+(?P<tid>\S+)\s+(?P<level>\S+)\s+'
        r'(?P<tag>\S+)\s*:\s?(?P<msg>.*)$',
        line.decode().rstrip())
    if not m:
        continue

    date, time, pid, tid, level, tag, msg = m.group('date'), m.group('time'), \
        m.group('pid'), m.group('tid'), m.group('level'), m.group('tag'), m.group('msg')

    if not match_line(pid, level, tag, msg):
        continue

    pid_tid = format_pid_tid(pid, tid)
    level = format_level(level)
    tag = format_tag(tag)

    print(f'{time} {pid_tid} {level} {tag} {msg}')
