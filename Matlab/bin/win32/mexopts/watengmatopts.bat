@echo off
rem WATENGMATOPTS.BAT
rem
rem    Compile and link options used for building MAT and engine standalone files
rem
rem    $Revision: 1.13 $  $Date: 2000/04/17 18:48:55 $
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
set COMPFLAGS= -c -7 -e25 -3s -zp8 -ei -bm -fr= -zq 
set OPTIMFLAGS=-ox -DNDEBUG
set DEBUGFLAGS=-d2
set NAME_OBJECT=-fo=

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\watcom\wc106
set LINKER=wlink
set LINKFLAGS=format windows nt option quiet libpath %LIBLOC% library libmx.lib, libmat.lib, libeng.lib
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=debug all
set LINK_FILE=file
set LINK_LIB=library  
set NAME_OUTPUT=name %OUTDIR%%MEX_NAME%.exe
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=
set RC_LINKER=
