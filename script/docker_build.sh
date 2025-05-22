#!/usr/bin/env bash

cd "$(dirname "$0")/.."

function project_version() {
    grep -E '^version:\s*(\S+)\s*$' pubspec.yaml | sed -E 's/^version:\s*(\S+)\s*$/\1/'
}

function print_msg() {
    echo -e "\033[1;34m$1\033[0m" >&2
}

function print_err() {
    echo -e "\033[1;31m$1\033[0m" >&2
}

function run_cmd() {
    echo "$*" >&2
    if ! "$@"; then
        print_err "Command failed with code $?"
        exit 1
    fi
}

target=${1:-android}

if [ "$target" != "android" ]; then
    echo "Invalid target. Only 'android' is supported."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    print_err "Docker Daemon is not running"
    exit 1
fi

cwd=$(pwd)
uid=$(id -u)
gid=$(id -g)

if [[ "$target" == "android" ]]; then
    work_dir="/root/build"
    cache_dirs=(
        # <host_dir>:<container_dir>
        "$cwd/build/dockercache/pub:/root/.pub-cache"
        "$cwd/build/dockercache/gradle:/root/.gradle"
        "$cwd/build/dockercache/android:/root/.android/cache"
    )
fi

docker_cmd=(
    "docker" "run"
    "--rm" "-t"
    "-u" "${uid}:${gid}"
    "-w" "${work_dir}"
    "-v" "${cwd}:${work_dir}"
)

for dir_pair in "${cache_dirs[@]}"; do
    host_dir=$(echo $dir_pair | cut -d: -f1)
    mkdir -p "$host_dir"
    docker_cmd+=(
        "-v" "$dir_pair"
    )
done

docker_cmd+=(
    "rocstreaming/env-flutter:${target}"
    "flutter" "build" "apk" "--release"
)

print_msg "Running ${target} build in docker"
run_cmd "${docker_cmd[@]}"

if [[ "$target" == "android" ]]; then
    app_type="apk"
    app_file="roc-droid-$(project_version).apk"
fi

print_msg
print_msg "Copied ${target} ${app_type} to dist/${target}/release/${app_file}"
run_cmd ls -lh "dist/${target}/release"
