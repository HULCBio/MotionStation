@echo off
rem BCC54ENGMATOPTS.BAT
rem
rem    Compile and link options used for building engine and MAT-API
rem    applications with the Borland C compiler.
rem
rem    $Revision: 1.3 $  $Date: 2000/10/01 14:33:24 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set BORLAND=%BORLAND%\CBuilder4
set PATH=%BORLAND%\BIN;%PATH%
set INCLUDE=%BORLAND%\INCLUDE
set LIB=%BORLAND%\LIB

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=bcc32
set COMPFLAGS=-c -3 -a8 -w- -b -g30 -I"%INCLUDE%"
set OPTIMFLAGS=-O1 -DNDEBUG
set DEBUGFLAGS=-v
set NAME_OBJECT=-o

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\borland\bc54
set LINKER=bcc32
rem The Borland compiler requires you to specify whether an application
rem is a console application or a Windows application. This file is
rem configured to build Windows applications. The MAT-API examples 
rem shipped with MATLAB are console applications. To build one, you
rem must edit this file and change the -tWE to a -tWC in the line 
rem below.
set LINKFLAGS=-tWE -L"%BORLAND%"\lib\32bit -L"%BORLAND%"\lib
set LINKFLAGS=%LINKFLAGS% -L"%LIBLOC%" libmx.lib libmat.lib libeng.lib
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=-v
set LINK_FILE=
set LINK_LIB= 
set NAME_OUTPUT=-e"%OUTDIR%%MEX_NAME%".exe
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=
set RC_LINKER=
