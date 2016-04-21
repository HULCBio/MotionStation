@echo off  
rem DF60ENGMATOPTS.BAT
rem
rem    Compile and link options used for building standalone MAT programs
rem    with DEC Fortran 6.0 compiler
rem    
rem    $Revision: 1.2 $  $Date: 2000/04/04 17:07:31 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set DF_ROOT=%DF_ROOT%
set PATH=%DF_ROOT%\Common\msdev98\bin;%DF_ROOT%\DF98\BIN;%DF_ROOT%\VC98\BIN;%PATH%
set INCLUDE=%DF_ROOT%\DF98\INCLUDE;%INCLUDE%
set LIB=%DF_ROOT%\DF98\LIB;%DF_ROOT%\VC98\LIB;%LIB%

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=fl32
set OPTIMFLAGS=-Oxp -DNDEBUG
set DEBUGFLAGS=-Zi
set COMPFLAGS=-c -G5 -4R8 -nologo 
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\digital\df60
set LINKER=link
set LINKFLAGS=/LIBPATH:"%LIBLOC%" libmx.lib libmat.lib libeng.lib
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=/debug
set LINK_FILE=
set LINK_LIB=
set NAME_OUTPUT="/out:%OUTDIR%%MEX_NAME%.exe"
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=
set RC_LINKER= 
