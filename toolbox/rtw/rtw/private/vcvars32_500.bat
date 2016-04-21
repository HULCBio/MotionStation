@echo off
rem Modified for B&T by J. Ciolfi 11/12/98
rem Note, there is a path fix for Win95 systems.
rem $Revision: 1.7 $
rem
rem Root of Visual Developer Studio installed files.
rem
rem set MSDevDir=g:\microsoft\msdev.500\SharedIDE
if "%MSDevDir%" == "" goto usage
if "%MSVCDir%" == "" goto usage

rem
rem Root of Visual C++ installed files.
rem
rem set MSVCDir=g:\microsoft\msdev.500\VC

rem
rem Root of Visual C++ files on cd-rom.
rem Remove "set vcsource=" if you don't want include cdrom in Visual C++ environment.
rem
rem set vcsource=whereever

rem
rem VcOsDir is used to help create either a Windows 95 or Windows NT specific path.
rem
set VcOsDir=WIN95
if "%OS%" == "Windows_NT" set VcOsDir=WINNT

rem
echo Setting environment for using Microsoft Visual C++ tools.
rem
if "%vcsource%" == "" goto main
rem
rem Include cdrom files in environment.
rem

if "%OS%" == "Windows_NT" set PATH=%vcsource%\VC\BIN;%vcsource%\VC\BIN\%VcOsDir%;%PATH%
if "%OS%" == "" set PATH="%vcsource%\VC\BIN";"%vcsource%\VC\BIN\%VcOsDir%";"%PATH%"
set INCLUDE=%vcsource%\VC\INCLUDE;%vcsource%\VC\MFC\INCLUDE;%vcsource%\VC\ATL\INCLUDE;%INCLUDE%
set LIB=%vcsource%\VC\LIB;%vcsource%\VC\MFC\LIB;%LIB%
set vcsource=

:main
if "%OS%" == "Windows_NT" set PATH=%MSDevDir%\BIN;%MSVCDir%\BIN;%MSVCDir%\BIN\%VcOsDir%;%PATH%
if "%OS%" == "" set PATH="%MSDevDir%\BIN";"%MSVCDir%\BIN";"%MSVCDir%\BIN\%VcOsDir%";"%PATH%"
set INCLUDE=%MSVCDir%\INCLUDE;%MSVCDir%\MFC\INCLUDE;%MSVCDir%\ATL\INCLUDE;%INCLUDE%
set LIB=%MSVCDir%\LIB;%MSVCDir%\MFC\LIB;%LIB%

set VcOsDir=

goto done

:usage
echo Usage: vcvars32 
echo Requires environment variables MSDevDir & MSVCDir

:done