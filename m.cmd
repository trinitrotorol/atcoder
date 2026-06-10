@echo off
setlocal

set "DISTRO=%ATCODER_WSL_DISTRO%"
if "%DISTRO%"=="" set "DISTRO=Ubuntu"
set "ENV_NAME=%ATCODER_ENV_NAME%"
if "%ENV_NAME%"=="" set "ENV_NAME=atcoder-cpp23"

for /f "usebackq delims=" %%I in (`wsl -d %DISTRO% -- wslpath -a "%cd%"`) do set "WSL_CWD=%%I"

wsl -d %DISTRO% -- bash -lc "cd '%WSL_CWD%' && if [ -d '.micromamba/envs/%ENV_NAME%' ]; then CONDA_PREFIX='%WSL_CWD%/.micromamba/envs/%ENV_NAME%'; PATH='%WSL_CWD%/.micromamba/envs/%ENV_NAME%/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'; export CONDA_PREFIX PATH; fi; make %*"
exit /b %ERRORLEVEL%
