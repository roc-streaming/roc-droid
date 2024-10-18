param (
    [ValidateSet("android")]
    [string]$Target = "android"
)

function Project-Version {
    $content = Get-Content -Path "pubspec.yaml" -Raw
    $match = [regex]::Match($content, "^version:\s*(\S+)\s*$", "Multiline")
    return $match.Groups[1].Value
}

function Print-Msg ($msg) {
    Write-Host "$msg" -ForegroundColor Blue
}

function Print-Err ($msg) {
    Write-Host "$msg" -ForegroundColor Red
}

function Run-Cmd ($cmd) {
    Write-Host ($cmd -join " ")

    $proc = Start-Process -FilePath $cmd[0] -ArgumentList $cmd[1..$cmd.Length] `
      -PassThru -Wait -NoNewWindow

    if ($proc.ExitCode -ne 0) {
        Print-Err "Command failed with code $($proc.ExitCode)"
        Exit 1
    }
}

docker info >$null 2>&1
if ($LASTEXITCODE -ne 0) {
    Print-Err "Docker Engine is not running"
    Exit 1
}

Set-Location -Path (
    Split-Path -Parent (Split-Path -Parent (Resolve-Path $PSScriptRoot)))

$cwd = Get-Location

if ($Target -eq "android") {
    $workDir = "/root/build" # container
    $cacheDirs = @{
        # host: container
        "${cwd}\build\dockercache\pub" = "/root/.pub-cache"
        "${cwd}\build\dockercache\gradle" = "/root/.gradle"
        "${cwd}\build\dockercache\android" = "/root/.android/cache"
    }
}

$dockerCmd = @(
    "docker", "run",
    "--rm", "-t",
    "-w", $workDir,
    "-v", "${cwd}:${workDir}"
)

foreach ($pair in $cacheDirs.GetEnumerator()) {
    $hostDir = $pair.Key
    $containerDir = $pair.Value
    New-Item -Path $hostDir -ItemType Directory -Force | Out-Null
    $dockerCmd += @(
        "-v", "${hostDir}:${containerDir}"
    )
}

$dockerCmd += @(
    "rocstreaming/env-flutter:${Target}"
)

if ($Target -eq "android") {
    $dockerCmd += @(
        "flutter", "build", "apk", "--release"
    )
}

Print-Msg "Running ${Target} build in docker"
Run-Cmd $dockerCmd

if ($Target -eq "android") {
    $appType = "apk"
    $appFile = "roc-droid-$(Project-Version).apk"
}

Print-Msg
Print-Msg "Copied ${Target} ${appType} to dist\${Target}\release\${appFile}"
Get-ChildItem "dist\${Target}\release"
