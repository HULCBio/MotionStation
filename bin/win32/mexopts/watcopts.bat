@echo off
rem WATCOPTS.BAT
rem
rem    Compile and link options used for building MEX-files with
rem    the WATCOM C compiler
rem
rem    $Revision: 1.17 $  $Date: 2000/08/26 05:29:18 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set WATCOM=%WATCOM%
set PATH=%WATCOM%\BINNT;%WATCOM%\BINW;%PATH%
set INCLUDE=%WATCOM%\H;%WATCOM%\H\NT;%INCLUDE%
set LIB=%WATCOM%\LIB386;%WATCOM%\LIB386\NT;%LIB%

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=wcl386
set COMPFLAGS= -c -7 -3s -e25 -zp8 -ei -bd -zq -DMATLAB_MEX_FILE -fr# 
set OPTIMFLAGS=-ox -DNDEBUG
set DEBUGFLAGS=-d2
set NAME_OBJECT=/fo#

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\watcom\wc106
set LINKER=wlink
set LINKFLAGS=format windows nt dll export %ENTRYPOINT% option caseexact,quiet file %MATLAB_EXTLIB%\stat_tls.obj libpath %LIBLOC% library libmx.lib, libmex.lib, libmat.lib
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

