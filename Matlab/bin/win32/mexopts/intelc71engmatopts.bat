@echo off
rem INTELC71ENGMATOPTS.BAT
rem
rem    Compile and link options used for building standalone engine or MAT programs
rem    using the Intel C 71 compiler 
rem
rem    $Revision: 1.1.6.1 $  $Date: 2004/03/22 23:28:04 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
rem Need to setup some MSVC environments for headers and libraries

set MATLAB=%MATLAB%
set MSVCDir=%MSVCDir%
set MSDevDir=%MSVCDir%\..\Common\msdev98
set INCLUDE=%MSVCDir%\INCLUDE;%MSVCDir%\MFC\INCLUDE;%MSVCDir%\ATL\INCLUDE;%INCLUDE%
set LIB=%MSVCDir%\LIB;%LIB%
set INTEL=%INTELC71%\Compiler70\IA32
set PATH=%INTEL%\BIN;%PATH%
set INCLUDE=%INTEL%\Include;%INCLUDE%
set LIB=%INTEL%\LIB;%LIB%

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=icl
set OPTIMFLAGS=-O2 -DNDEBUG
set DEBUGFLAGS=-Zi -Fd"%OUTDIR%%MEX_NAME%.pdb"
set COMPFLAGS=-c -Zp8 -G5 -W3 -nologo
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\microsoft\msvc60
set LINKER=xilink
set LINKFLAGS= kernel32.lib user32.lib gdi32.lib /LIBPATH:"%LIBLOC%" libmx.lib libmat.lib libeng.lib /nologo
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

