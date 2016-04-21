@echo off
rem WAT11COPTS.BAT
rem
rem    Compile and link options used for building MEX-files with
rem    the WATCOM C compiler  version 11.0
rem
rem    $Revision: 1.23 $  $Date: 2000/08/26 05:29:17 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set WATCOM=%WATCOM%
set PATH=%WATCOM%\BINNT;%WATCOM%\BINW;%PATH%
set INCLUDE=%WATCOM%\H;%WATCOM%\mfc\include;%WATCOM%\H\nt;%INCLUDE%
set LIB=%WATCOM%\LIB386\nt;%WATCOM%\LIB386;%LIB%
set EDPATH=%WATCOM%\eddat

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=wcl386
set COMPFLAGS=-c -bd -3s -br -e25 -ei -fpi87 -zp8 -zq -fr# -DMATLAB_MEX_FILE 
set OPTIMFLAGS=-ox -DNDEBUG
set DEBUGFLAGS=-d2
set NAME_OBJECT=/fo#

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\watcom\wc110
set LINKER=wlink
set LINKFLAGS=system nt_dll export %ENTRYPOINT% option caseexact,quiet libpath %LIBLOC% library libmx.lib, libmex.lib, libmat.lib, user32.lib
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=debug all
set LINK_FILE=file
set LINK_LIB=library 
set NAME_OUTPUT=name %OUTDIR%%MEX_NAME%.dll
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=
set RC_LINKER=wrc /q  /fo=%OUTDIR%mexversion.res

