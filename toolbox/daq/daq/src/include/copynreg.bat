rem @echo off
REM copynreg.bat
REM usage: copynreg targetdir filename projdir
REM Copies targetdir\filename.dll and sourcedir\filename.ini file to the proper directory 
REM    and registers the adaptor.
REM
REM $Revision: 1.1.6.2 $ $Date: 2004/01/16 19:58:18 $

if .%1.==.. goto usage
if .%2.==.. goto usage
if .%3.==.. goto usage

REM Copy dll
if exist ..\..\private\%2.dll attrib -r ..\..\private\%2.dll
copy %1\%2.dll ..\..\private
REM Copy ini
if not exist %3\%2.ini goto register
if exist ..\..\private\%2.ini attrib -r ..\..\private\%2.ini
copy %3\%2.ini ..\..\private

:register
if .%DAQNOREG%==. goto regsvr
goto end

:regsvr
REM /s = silent
REM /c = 
regsvr32 /s /c ..\..\private\%2.dll
REM clears the leftover %ERRORLEVEL% if you attempt to register a DLL for a board that's
REM not installed.
dir > nul

goto end

:usage
echo Usage: copynreg targetdir filename sourcedir
echo        copynreg .\Release mwwinsound .

:end
