@echo off
rem MSVC60ENGMATOPTS.BAT
rem
rem    Compile and link options used for building standalone engine or MAT programs
rem    with Microsoft Visual C++ compiler version 6.0
rem
rem    $Revision: 1.5 $  $Date: 2000/05/23 18:31:32 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************
set MATLAB=%MATLAB%
set MSVCDir=%MSVCDir%
set MSDevDir=%MSVCDir%\..\Common\msdev98
set PATH=%MSVCDir%\BIN;%MSDevDir%\bin;%PATH%
set INCLUDE=%MSVCDir%\INCLUDE;%MSVCDir%\MFC\INCLUDE;%MSVCDir%\ATL\INCLUDE;%INCLUDE%
set LIB=%MSVCDir%\LIB;%MSVCDir%\MFC\LIB;%LIB%

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=cl
set OPTIMFLAGS=-O2 -DNDEBUG
set DEBUGFLAGS=-Zi -Fd"%OUTDIR%%MEX_NAME%.pdb"
set COMPFLAGS=-c -Zp8 -G5 -W3 -nologo 
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\microsoft\msvc60
set LINKER=link
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
