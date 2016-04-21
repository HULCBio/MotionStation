@echo off
rem MATLAB.BAT
rem
rem    Startup script for launching MATLAB on Windows platforms.
rem
rem    Copyright 1984-2004 The MathWorks, Inc.
rem    $Revision: 1.3.6.4 $  $Date: 2004/04/19 01:08:16 $
rem  __________________________________________________________________________
rem

setlocal

set RCSREVISIONLINE=$Revision: 1.3.6.4 $
set RCSREVISION=%RCSREVISIONLINE:$Revision:=%
set RCSREVISION=%RCSREVISION:$=%

if "%USERNAME%" == "batserve" echo on
set MATLAB_ARGS=
set MATLAB_VERBOSE=

if defined MATLAB (
  set MATLAB_BIN_DIR=%MATLAB%\bin
) else (
  set MATLAB_BIN_DIR=%~dp0
)

rem Fix MATLAB_ARCH for AMD64 when time comes
rem

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set MATLAB_ARCH=win32
) else (
  set MATLAB_ARCH=win32
)

:loop
if "%1" == ""   goto start:
set opt=%1
set opt=%opt:/=-%
if "%opt%" == "-check_malloc" (
  set MATLAB_MEM_MGR=debug
) else if "%opt%" == "-memmgr" (
  goto memmgr:
) else if "%opt%" == "-help" (
  goto showhelp:
) else if "%opt%" == "-h" (
  goto showhelp:
) else if "%opt%" == "-?" (
  goto showhelp:
) else if "%opt%" == "-timing" (
  for /F %%i in ('"%MATLAB_BIN_DIR%\%MATLAB_ARCH%\cpucount"') do set MATLAB_CPUCOUNT=%%i
) else if "%opt%" == "-verbose" (
  set MATLAB_VERBOSE=1
) else if "%opt%" == "-wait" (
  set START_WAIT=/wait
) else (
  set MATLAB_ARGS=%MATLAB_ARGS% %1
)
shift
goto loop:

rem extra memory managers are for support and MathWorks use
rem

:memmgr
if not "%2" == "" ( 
  for %%i in (debug;cache;compact;fast;system;compact_track) do if .%%i==.%2 set MATLAB_MEM_MGR=%2
) else (
  goto showhelp:
)
if not .%MATLAB_MEM_MGR%==.%2 (
  echo.
  echo Warning: Unsupported memory manager "%2". Set to "cache".
  echo.
  set MATLAB_MEM_MGR=cache
)
shift
shift
goto loop:

:showhelp
rem echo on
echo.
echo matlab [-? ^| -h ^| -help]
echo        [-c licensefile]
echo        [-nosplash]
echo        [-nodesktop ^| -nojvm]
echo        [-memmgr manager ^| -check_malloc]
echo        [-r MATLAB_command]
echo        [-logfile log] [-timing]
echo        [-noFigureWindows]
echo        [-automation] [-regserver] [-unregserver]
echo.
echo     -?^|-h^|-help          - Display arguments. Do not start MATLAB.
echo     -c licensefile       - Set location of the license file that MATLAB
echo                            should use. It can have the form port@host.
echo                            The LM_LICENSE_FILE and MLM_LICENSE_FILE
echo                            environment variables will be ignored.
echo     -nosplash            - Do not display the splash screen during startup.
echo     -nodesktop           - Do not start the MATLAB desktop. Use V5 MATLAB
echo                            command window for commands. The Java virtual
echo                            machine will be started.
echo     -nojvm               - Shut off all Java support by not starting the
echo                            Java virtual machine. In particular the MATLAB
echo                            desktop will not be started.
echo     -memmgr manager      - Set MATLAB_MEM_MGR to manager.
echo                            manager - cache  (default)
echo                                    - fast   for large models or MATLAB code
echo                                             that uses many structure or
echo                                             object variables. Is not helpful
echo                                             for large arrays.
echo                                    - debug  does memory integrity checking.
echo                                             Useful for debugging memory
echo                                             problems caused by user mex
echo                                             files.
echo     -check_malloc        - same as '-memmgr debug'.
echo     -r MATLAB_command    - Start MATLAB and execute the MATLAB_command.
echo                            Any "M" file must be on the MATLAB path.
echo     -logfile log         - Make a copy of any output to the command window
echo                            in file log. This includes all crash reports.
echo     -timing              - Print a summary of startup time to the command
echo                            window. It is also recorded in a timing log,
echo                            the name of which is printed to the MATLAB
echo                            command window.
echo     -noFigureWindows     - Never display a figure window
echo     -automation          - Start MATLAB as an automation server,
echo                            minimized and without the MATLAB splash screen.
echo     -regserver           - Register MATLAB as a COM server
echo     -unregserver         - Remove MATLAB COM server registry entries.
echo.
echo     Revision #: %RCSREVISION%
echo. 
goto end:


:start
if defined MATLAB_CPUCOUNT (
  set MATLAB_ARGS=%MATLAB_ARGS% -timing %MATLAB_CPUCOUNT% %MATLAB_CPUCOUNT%
)
if defined MATLAB_VERBOSE (
  echo start "MATLAB" %START_WAIT% "%MATLAB_BIN_DIR%\%MATLAB_ARCH%\matlab" %MATLAB_ARGS%
)
start "MATLAB" %START_WAIT% "%MATLAB_BIN_DIR%\%MATLAB_ARCH%\matlab" %MATLAB_ARGS%

:end
