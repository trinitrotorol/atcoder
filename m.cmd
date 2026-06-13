@echo off
setlocal EnableExtensions

set "DISTRO=%ATCODER_WSL_DISTRO%"
if "%DISTRO%"=="" set "DISTRO=Ubuntu"
set "ENV_NAME=%ATCODER_ENV_NAME%"
if "%ENV_NAME%"=="" set "ENV_NAME=atcoder-cpp23"
set "MAKE_ARGS="

:parse_args
if "%~1"=="" goto run_make

if /I "%~1"=="-h" goto print_help
if /I "%~1"=="--help" goto print_help
if /I "%~1"=="-b" goto parse_build
if /I "%~1"=="--build" goto parse_build
if /I "%~1"=="-r" goto parse_run
if /I "%~1"=="--run" goto parse_run
if /I "%~1"=="-s" goto parse_sample
if /I "%~1"=="--sample" goto parse_sample
if /I "%~1"=="-p" goto parse_problem
if /I "%~1"=="--problem" goto parse_problem
if /I "%~1"=="-t" goto parse_test
if /I "%~1"=="--test" goto parse_test
if /I "%~1"=="-u" goto parse_setup
if /I "%~1"=="--setup" goto parse_setup
if /I "%~1"=="-x" goto parse_clean
if /I "%~1"=="--clean" goto parse_clean
if /I "%~1"=="-l" goto parse_path
if /I "%~1"=="--path" goto parse_path
if /I "%~1"=="-i" goto parse_input
if /I "%~1"=="--input" goto parse_input
if /I "%~1"=="-o" goto parse_output
if /I "%~1"=="--out" goto parse_output
if /I "%~1"=="--create" goto parse_create
if /I "%~1"=="create" goto parse_create
if /I "%~1"=="init" goto parse_create
if /I "%~1"=="use" goto parse_use
if /I "%~1"=="current" goto parse_current
if /I "%~1"=="debug" goto parse_debug
if /I "%~1"=="--debug" goto parse_debug
if "%~1"=="-C" goto parse_contest
if /I "%~1"=="--contest" goto parse_contest
if "%~1"=="-U" goto parse_url
if /I "%~1"=="--url" goto parse_url

set "MAKE_ARGS=%MAKE_ARGS% %~1"
shift
goto parse_args

:parse_build
set "MAKE_ARGS=%MAKE_ARGS% build"
shift
goto parse_optional_problem

:parse_run
shift
if "%~1"=="" (
    set "MAKE_ARGS=%MAKE_ARGS% run"
    goto parse_args
)
set "NEXT_ARG=%~1"
if "%NEXT_ARG:~0,1%"=="-" (
    set "MAKE_ARGS=%MAKE_ARGS% run"
    goto parse_args
)
echo(%NEXT_ARG% | findstr "=" >nul
if not errorlevel 1 (
    set "MAKE_ARGS=%MAKE_ARGS% run"
    goto parse_args
)
set "MAKE_ARGS=%MAKE_ARGS% %~1"
shift
goto parse_args

:parse_sample
set "MAKE_ARGS=%MAKE_ARGS% sample"
shift
goto parse_optional_problem

:parse_create
set "MAKE_ARGS=%MAKE_ARGS% create"
shift
goto parse_optional_contest

:parse_use
set "MAKE_ARGS=%MAKE_ARGS% use"
shift
goto parse_optional_contest

:parse_current
set "MAKE_ARGS=%MAKE_ARGS% current"
shift
goto parse_args

:parse_debug
shift
if "%~1"=="" (
    set "MAKE_ARGS=%MAKE_ARGS% debug"
    goto parse_args
)
if /I "%~1"=="status" (
    set "MAKE_ARGS=%MAKE_ARGS% debug"
    shift
    goto parse_args
)
if /I "%~1"=="on" (
    set "MAKE_ARGS=%MAKE_ARGS% debug-on"
    shift
    goto parse_args
)
if /I "%~1"=="off" (
    set "MAKE_ARGS=%MAKE_ARGS% debug-off"
    shift
    goto parse_args
)
if /I "%~1"=="toggle" (
    set "MAKE_ARGS=%MAKE_ARGS% debug-toggle"
    shift
    goto parse_args
)
echo unknown debug command: %~1
echo use: .\m debug on, .\m debug off, .\m debug toggle
exit /b 2

:parse_problem
shift
if "%~1"=="" (
    echo missing value for -p
    exit /b 2
)
set "MAKE_ARGS=%MAKE_ARGS% PROBLEM=%~1"
shift
goto parse_args

:parse_test
set "MAKE_ARGS=%MAKE_ARGS% test"
shift
goto parse_optional_problem

:parse_setup
set "MAKE_ARGS=%MAKE_ARGS% setup"
shift
goto parse_args

:parse_clean
set "MAKE_ARGS=%MAKE_ARGS% clean"
shift
goto parse_args

:parse_path
set "MAKE_ARGS=%MAKE_ARGS% path"
shift
goto parse_optional_problem

:parse_input
shift
if "%~1"=="" (
    echo missing value for -i
    exit /b 2
)
set "MAKE_ARGS=%MAKE_ARGS% INPUT=%~1"
shift
goto parse_args

:parse_output
shift
if "%~1"=="" (
    echo missing value for -o
    exit /b 2
)
set "MAKE_ARGS=%MAKE_ARGS% OUT=%~1"
shift
goto parse_args

:parse_contest
shift
if "%~1"=="" (
    echo missing value for -C
    exit /b 2
)
set "MAKE_ARGS=%MAKE_ARGS% CONTEST=%~1"
shift
goto parse_args

:parse_url
shift
if "%~1"=="" (
    echo missing value for -U
    exit /b 2
)
set "MAKE_ARGS=%MAKE_ARGS% URL=%~1"
shift
goto parse_args

:parse_optional_contest
if "%~1"=="" goto parse_args
set "NEXT_ARG=%~1"
if "%NEXT_ARG:~0,1%"=="-" goto parse_args
echo(%NEXT_ARG% | findstr "=" >nul
if not errorlevel 1 goto parse_args
set "MAKE_ARGS=%MAKE_ARGS% CONTEST=%~1"
shift
goto parse_args

:parse_optional_problem
if "%~1"=="" goto parse_args
set "NEXT_ARG=%~1"
if "%NEXT_ARG:~0,1%"=="-" goto parse_args
echo(%NEXT_ARG% | findstr "=" >nul
if not errorlevel 1 goto parse_args
set "MAKE_ARGS=%MAKE_ARGS% PROBLEM=%~1"
shift
goto parse_args

:print_help
echo Usage:
echo   .\m a                 Run problem a
echo   .\m -r c              Run problem c
echo   .\m -b c              Build problem c
echo   .\m -t c              Test all samples for problem c
echo   .\m -s                Download samples for the current contest
echo   .\m -s c              Download samples for problem c
echo   .\m create abc462     Create a-g.cpp for contest abc462
echo   .\m use abc462        Set current contest
echo   .\m current           Show current contest
echo   .\m debug on          Enable LOCAL debug builds
echo   .\m debug off         Disable LOCAL debug builds
echo   .\m -l c              Show detected paths for problem c
echo   .\m -u                Setup the WSL environment
echo   .\m -x                Clean build outputs
echo Options:
echo   -p, --problem VALUE   Set PROBLEM
echo   -C, --contest VALUE   Set CONTEST
echo   -i, --input PATH      Set INPUT
echo   -o, --out PATH        Set OUT
echo   -U, --url URL         Set URL
exit /b 0

:run_make
for /f "usebackq delims=" %%I in (`wsl -d %DISTRO% -- wslpath -a "%cd%"`) do set "WSL_CWD=%%I"

wsl -d %DISTRO% -- bash -lc "cd '%WSL_CWD%' && if [ -d '.micromamba/envs/%ENV_NAME%' ]; then CONDA_PREFIX='%WSL_CWD%/.micromamba/envs/%ENV_NAME%'; PATH='%WSL_CWD%/.micromamba/envs/%ENV_NAME%/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'; export CONDA_PREFIX PATH; fi; make %MAKE_ARGS%"
exit /b %ERRORLEVEL%
