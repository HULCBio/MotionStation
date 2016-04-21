@echo off
rem DF66OPTS.BAT
rem
rem    Compile and link options used for building MEX-files
rem    using the Compaq Visual Fortran compiler version 6.6 
rem
rem    $Revision: 1.1 $  $Date: 2002/06/03 12:17:13 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set DF_ROOT=%DF_ROOT%
set VCDir=%DF_ROOT%\VC98
set MSDevDir=%DF_ROOT%\Common\msdev98
set DFDir=%DF_ROOT%\DF98
set PATH=%MSDevDir%\bin;%DFDir%\BIN;%VCDir%\BIN;%PATH%
set INCLUDE=%DFDir%\INCLUDE;%INCLUDE%
set LIB=%DFDir%\LIB;%VCDir%\LIB;%LIB%

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=fl32
set COMPFLAGS=/fpp:"/m /S%MATLAB%/extern/include" -c -nokeep -G5 -nologo -DMATLAB_MEX_FILE /fixed
set OPTIMFLAGS=/MD -Ox -DNDEBUG
set DEBUGFLAGS=/MDd -Zi
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\digital\df60
set LINKER=link
set LINKFLAGS=/DLL /EXPORT:_MEXFUNCTION@16 /LIBPATH:"%LIBLOC%" libmx.lib libmex.lib libmat.lib /implib:%LIB_NAME%.lib /NOLOGO
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=/debug
set LINK_FILE=
set LINK_LIB=
set NAME_OUTPUT="/out:%OUTDIR%%MEX_NAME%.dll"
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=rc /fo "%OUTDIR%mexversion.res"
set RC_LINKER=
