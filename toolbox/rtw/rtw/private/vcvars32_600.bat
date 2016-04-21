@echo off
rem Modified for B&T by J. Ciolfi 11/12/98
rem $Revision: 1.1 $
rem
rem Root of Visual Developer Studio Common files.
rem set VSCommonDir=C:\APPLIC~1\VISUAL~1\Common

rem
rem Root of Visual Developer Studio installed files.
rem
rem set MSDevDir=C:\APPLIC~1\VISUAL~1\Common\msdev98
if "%MSDevDir%" == "" goto usage
if "%MSVCDir%" == "" goto usage
if "%VSCommonDir%" == "" goto usage

rem set VSCommonDir=%MSDevDir%\..

rem
rem Root of Visual C++ installed files.
rem
rem set MSVCDir=C:\APPLIC~1\VISUAL~1\VC98


rem
rem VcOsDir is used to help create either a Windows 95 or Windows NT specific path.
rem
set VcOsDir=WIN95
if "%OS%" == "Windows_NT" set VcOsDir=WINNT

rem
echo Setting environment for using Microsoft Visual C++ tools.
rem

if "%OS%" == "Windows_NT" set PATH=%MSDevDir%\BIN;%MSVCDir%\BIN;%VSCommonDir%\TOOLS\%VcOsDir%;%VSCommonDir%\TOOLS;%PATH%
if "%OS%" == "" set PATH="%MSDevDir%\BIN";"%MSVCDir%\BIN";"%VSCommonDir%\TOOLS\%VcOsDir%";"%VSCommonDir%\TOOLS";"%windir%\SYSTEM";"%PATH%"
set INCLUDE=%MSVCDir%\ATL\INCLUDE;%MSVCDir%\INCLUDE;%MSVCDir%\MFC\INCLUDE;%INCLUDE%
set LIB=%MSVCDir%\LIB;%MSVCDir%\MFC\LIB;%LIB%

set VcOsDir=
set VSCommonDir=

goto done

:usage
echo Usage: vcvars32
echo Requires environment variables MSDevDir, MSVCDir, VSCommonDir

:done
