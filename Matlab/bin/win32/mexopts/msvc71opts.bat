@echo off
rem MSVC71OPTS.BAT
rem
rem    Compile and link options used for building MEX-files
rem    using the Microsoft Visual C++ compiler version 7.1 
rem
rem    $Revision: 1.1.6.4 $  $Date: 2004/04/20 21:26:45 $
rem
rem ********************************************************************
rem General parameters
rem ********************************************************************

set MATLAB=%MATLAB%
set MSVCDir=%MSVCDir%
set DevEnvDir=%MSVCDir%\..\Common7\Tools
set PATH=%MSVCDir%\BIN;%DevEnvDir%;%DevEnvDir%\bin;%MSVCDir%\..\Common7\IDE;%MATLAB_BIN%;%PATH%;
set INCLUDE=%MSVCDir%\ATLMFC\INCLUDE;%MSVCDir%\INCLUDE;%MSVCDir%\PlatformSDK\include;%INCLUDE%
set LIB=%MSVCDir%\ATLMFC\LIB;%MSVCDir%\LIB;%MSVCDir%\PlatformSDK\lib;%MATLAB%\extern\lib\win32;%LIB%

rem ********************************************************************
rem Compiler parameters
rem ********************************************************************
set COMPILER=cl
set COMPFLAGS=-c -Zp8 -G5 -GR -W3 -DMATLAB_MEX_FILE -nologo
set OPTIMFLAGS=/MD -O2 -Oy- -DNDEBUG
set DEBUGFLAGS=/MDd -Zi -Fd"%OUTDIR%%MEX_NAME%.pdb"
set NAME_OBJECT=/Fo

rem ********************************************************************
rem Linker parameters
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\microsoft\msvc71
set LINKER=link
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
