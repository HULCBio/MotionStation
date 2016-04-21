@echo off
rem BCCOPTS.BAT
rem
rem    Compile and link options used for building MEX-files
rem    with the Borland C compiler
rem
rem    $Revision: 1.23.4.1 $  $Date: 2003/01/30 21:27:27 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set BORLAND=%BORLAND%
set PATH=%BORLAND%\BIN;%PATH%
set INCLUDE=%BORLAND%\INCLUDE
set LIB=%BORLAND%\LIB;%BORLAND%\LIB\32BIT

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=bcc32
set COMPFLAGS=-c -3 -P- -w- -pc -a8 -I%INCLUDE% -DMATLAB_MEX_FILE 
set OPTIMFLAGS=-O2 -DNDEBUG
set DEBUGFLAGS=-v
set NAME_OBJECT=-o

rem ********************************************************************
rem Library creation command
rem ********************************************************************
set PRELINK_CMDS1=copy "%MATLAB%\extern\lib\win32\borland\%ENTRYPOINT%.def" "%OUTDIR%%MEX_NAME%.def"

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\borland\bc50
set LINKER=bcc32
set LINKFLAGS=-tWD -L%BORLAND%\lib\32bit -L%BORLAND%\lib -L%LIBLOC% libmx.lib libmex.lib libmat.lib
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=-v
set LINK_FILE=
set LINK_LIB= 
set NAME_OUTPUT=-e%OUTDIR%%MEX_NAME%.dll
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=
set RC_LINKER=brc32  -fo %OUTDIR%mexversion.res

set POSTLINK_CMDS=del "%OUTDIR%%MEX_NAME%.def"
