@echo off
rem INTELC71OPTS.BAT
rem
rem    Compile and link options used for building MEX-files
rem    using the Intel C 71 compiler 
rem
rem    $Revision: 1.1.12.1 $  $Date: 2003/11/26 17:22:30 $
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
set COMPFLAGS=-c -Zp8 -G5 -W3 -DMATLAB_MEX_FILE -nologo
set OPTIMFLAGS=/MD -O2 -Oy- -DNDEBUG
set DEBUGFLAGS=/MDd -Zi -Fd"%OUTDIR%%MEX_NAME%.pdb"
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\microsoft\msvc60
set LINKER=xilink
set LINKFLAGS=/dll /export:%ENTRYPOINT% /MAP /LIBPATH:"%LIBLOC%" libmx.lib libmex.lib libmat.lib /implib:%LIB_NAME%.x
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=/debug
set LINK_FILE=
set LINK_LIB=
set NAME_OUTPUT=/out:"%OUTDIR%%MEX_NAME%.dll"
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=rc /fo "%OUTDIR%mexversion.res"
set RC_LINKER=

set POSTLINK_CMDS=del "%OUTDIR%%MEX_NAME%.map"
set POSTLINK_CMDS1=del %LIB_NAME%.x
