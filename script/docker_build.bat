@echo off
powershell -ExecutionPolicy Unrestricted -File "%~dp0\docker_build.ps1" %*
