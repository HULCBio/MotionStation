@echo off
rem MBUILD.BAT
rem
rem    Compile and link script used for building math library 
rem    standalone files.
rem
rem
rem
rem
rem -------------------------------------------------------------------
rem   MATLAB root directory
rem -------------------------------------------------------------------
rem
set MATLAB=C:\Matlab\

rem ------------- Do not modify anything below this line --------------
rem
rem ###################################################################
rem # Set up script location
rem ###################################################################
rem # use the installed location of mex.pl, or %0 if mbuild was called by
rem # full path name, or look for it on the DOS path.
set SCRIPTLOC=""
if not "%MATLAB%" == ""  set SCRIPTLOC="%MATLAB%\bin\win32\mex.pl"
if not exist %SCRIPTLOC% set SCRIPTLOC=%0\..\mex.pl
if not exist %SCRIPTLOC% set SCRIPTLOC=%0\..\win32\mex.pl
if not exist %SCRIPTLOC% set SCRIPTLOC=-S mex.pl

rem ###################################################################
rem # Set up perl location
rem ###################################################################
rem # Either use the installed location of perl,
rem # or use %0 if mbuild was called by full path name,
rem # or search for mbuild.bat on the DOS path
rem # or hope it is on the DOS path.
set PERLLOC=""
if not "%MATLAB%" == "" set PERLLOC="%MATLAB%\sys\perl\win32\bin\perl.exe"
if not exist %PERLLOC% set PERLLOC="%0\..\..\sys\perl\win32\bin\perl.exe"
if not exist %PERLLOC% set PERLLOC="%0\..\..\..\sys\perl\win32\bin\perl.exe"
if not exist %PERLLOC% for %%x in (%PATH%) do if exist "%%x\mbuild.bat" set PERLLOC="%%x\..\..\sys\perl\win32\bin\perl.exe"
if not exist %PERLLOC% set PERLLOC=perl

rem ###################################################################
rem # Set up script arguments (to avoid %9 DOS batch file limit)
rem ###################################################################
rem # Put all arguments into environment variable ARGS.  This
rem # allows us to bypass the 9 parameter limit, but disallows
rem # -DVAR=VALUE and LINKER=mylinker constructions.  These cases
rem # will need to be handled in the mexopts file.
set MEXARGS=-mb 
:getarg
set MEXARGS=%MEXARGS% %1
shift

rem Use X's here so that quotes are legal within %1.
if not X%1X==XX goto getarg
rem ###################################################################
rem # Call Perl with the script name as an argument
rem ###################################################################
set errlvl=
%PERLLOC% %SCRIPTLOC% %MEXARGS%
if errorlevel 1 set errlvl=1

rem ###################################################################
rem # Cleanup environment and exit
rem ###################################################################
set SCRIPTLOC=
set PERLLOC=
set MEXARGS=

rem Although Windows does not give error status back to MATLAB's dos()
rem function properly, other tools such as Make and perl are
rem able to get error status, but this seems to be reliable only if the
rem last command executed was the one to throw the error. That is why
rem the following line appears last in this file.
if X%errlvl% == X1 "%MATLAB%\sys\perl\win32\bin\perl.exe" -e "die \"\n\";"

