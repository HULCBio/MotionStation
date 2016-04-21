@echo off
rem BCC56COMPP.BAT
rem
rem    Compile and link options used for building MATLAB compiler
rem    applications with C++ Math Library with the Borland C compiler
rem
rem    $Revision: 1.3.4.5 $  $Date: 2004/05/01 14:34:02 $
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
set COMPFLAGS=-c -3 -a8  -b -w- -WM- -I"%INCLUDE%"
set CPPCOMPFLAGS=-c -3 -a8  -b -w- -WM- -DBORLAND -DIBMPC -DMSWIND -I"%MATLAB%\extern\include\cpp" -I"%INCLUDE%"
set DLLCOMPFLAGS=-c -3 -P- -w- -pc -a8 -I"%INCLUDE%"
set OPTIMFLAGS=-O1 -DNDEBUG
set DEBUGFLAGS=-v
set CPPOPTIMFLAGS=-O1 -DNDEBUG
set CPPDEBUGFLAGS=-v
set NAME_OBJECT=-o

rem ********************************************************************
rem Library creation command
rem ********************************************************************
set DLL_MAKEDEF=type %BASE_EXPORTS_FILE% | %PERL% -e "print \"LIBRARY %MEX_NAME%.dll\nEXPORTS\n\"; while (<>) {print "_" . $_;}" > "%DEF_FILE%"
set DLL_MAKEDEF1=implib "%OUTDIR%%MEX_NAME%.lib" "%DEF_FILE%"

rem ********************************************************************
rem Linker parameters
rem MATLAB_EXTLIB is set automatically by mex.bat
rem ********************************************************************
set LIBLOC=%MATLAB%\extern\lib\win32\borland\bc54
set LINKER=%PERL% %MATLAB_BIN%\link_borland_mex.pl
set LINK_LIBS=mclmcrrt.lib
set LINKFLAGS=-ap -c -Tpe -x -Gn -L\"%BORLAND%\"\lib\32bit -L\"%BORLAND%\"\lib -L\"%LIBLOC%\" %LINK_LIBS%  C0X32.OBJ CW32.LIB IMPORT32.LIB
set CPPLINKFLAGS= %LINK_LIBS%
set DLLLINKFLAGS=-aa -c -Tpd -x -Gn -L\"%BORLAND%\"\lib\32bit -L\"%BORLAND%\"\lib -L\"%LIBLOC%\" %LINK_LIBS% c0d32.obj import32.lib cw32mt.lib %DEF_FILE%
set HGLINKFLAGS=sgl.lib
set LINKOPTIMFLAGS=
set LINKDEBUGFLAGS=-v
set LINK_FILE=
set LINK_LIB= 
set NAME_OUTPUT="%OUTDIR%%MEX_NAME%.exe"
set DLL_NAME_OUTPUT="%OUTDIR%%MEX_NAME%.dll"
set RSP_FILE_INDICATOR=@

rem ********************************************************************
rem Resource compiler parameters
rem ********************************************************************
set RC_COMPILER=brcc32 -w32 -D_NO_VCL -fo"%OUTDIR%%RES_NAME%.res"
set RC_LINKER=

rem ********************************************************************
rem IDL Compiler
rem ********************************************************************
set IDL_COMPILER=midl /I %BORLAND%\include\idl /I "%MATLAB%\extern\include"
set IDL_OUTPUTDIR= /out "%OUTDIRN%"
set IDL_DEBUG_FLAGS= /D "_DEBUG" 
set IDL_OPTIM_FLAGS= /D "NDEBUG" 


set POSTLINK_CMDS1=if exist "%OUTDIR%%MEX_NAME%.def" del "%OUTDIR%%MEX_NAME%.def"
set POSTLINK_CMDS2=if exist "%MEX_NAME%.map" del "%MEX_NAME%.map"

