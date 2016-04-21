@echo off
rem BCC56OPTS.BAT
rem
rem    Compile and link options used for building MEX-files
rem    with the Borland C compiler
rem
rem    $Revision: 1.2.4.1 $  $Date: 2003/01/30 21:27:26 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set BORLAND=%BORLAND%\CBuilder6
set PATH=%BORLAND%\BIN;%MATLAB_BIN%;%PATH%
set INCLUDE=%BORLAND%\INCLUDE
set LIB=%BORLAND%\LIB
set PERL="%MATLAB%\sys\perl\win32\bin\perl.exe"

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=bcc32
set COMPFLAGS=-c -3 -P- -w- -pc -a8 -I"%INCLUDE%" -DMATLAB_MEX_FILE 
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
set LIBLOC=%MATLAB%\extern\lib\win32\borland\bc54
set LINKER=%PERL% %MATLAB_BIN%\link_borland_mex.pl
set LINKFLAGS=-aa -c -Tpd -x -Gn -L\"%BORLAND%\"\lib\32bit -L\"%BORLAND%\"\lib -L\"%LIBLOC%\" libmx.lib libmex.lib libmat.lib c0d32.obj import32.lib cw32mt.lib "%OUTDIR%%MEX_NAME%.def"
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=-v
set LINK_FILE=
set LINK_LIB= 
set NAME_OUTPUT="%OUTDIR%%MEX_NAME%".dll
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=brcc32 -w32 -D_NO_VCL -fomexversion.res
set RC_LINKER=

set POSTLINK_CMDS=del "%OUTDIR%%MEX_NAME%.def"
