@rem Modified from tools\vsvars32.bat for Mathworks use
@rem
@rem Instead of having them hardcoded for a particular installation, this 
@rem version of this batch file expects the following variables to be 
@rem "passed" in:
@rem
@rem    VSINSTALLDIR
@rem    VCINSTALLDIR
@rem    FrameworkDir
@rem    FrameworkSDKDir
@rem 
@rem $Revision: 1.1 $

@goto :skip_hardcoded_paths1
@SET VSINSTALLDIR=F:\Program Files\Microsoft Visual Studio .NET\Common7\IDE
@SET VCINSTALLDIR=F:\Program Files\Microsoft Visual Studio .NET
@SET FrameworkDir=C:\WINNT\Microsoft.NET\Framework
:skip_hardcoded_paths1

@SET FrameworkVersion=v1.0.3705

@goto :skip_hardcoded_paths2
@SET FrameworkSDKDir=F:\Program Files\Microsoft Visual Studio .NET\FrameworkSDK
:skip_hardcoded_paths2

@rem Root of Visual Studio common files.

@if "%VSINSTALLDIR%"=="" goto Usage
@if "%VCINSTALLDIR%"=="" set VCINSTALLDIR=%VSINSTALLDIR%

@rem
@rem Root of Visual Studio ide installed files.
@rem
@set DevEnvDir=%VSINSTALLDIR%

@rem
@rem Root of Visual C++ installed files.
@rem
@set MSVCDir=%VCINSTALLDIR%\VC7

@rem
@echo Setting environment for using Microsoft Visual Studio .NET tools.
@echo (If you also have Visual C++ 6.0 installed and wish to use its tools
@echo from the command line, run vcvars32.bat for Visual C++ 6.0.)
@rem

@REM %VCINSTALLDIR%\Common7\Tools dir is added only for real setup.

@set PATH=%DevEnvDir%;%MSVCDir%\BIN;%VCINSTALLDIR%\Common7\Tools;%VCINSTALLDIR%\Common7\Tools\bin\prerelease;%VCINSTALLDIR%\Common7\Tools\bin;%FrameworkSDKDir%\bin;%FrameworkDir%\%FrameworkVersion%;%PATH%;
@set INCLUDE=%MSVCDir%\ATLMFC\INCLUDE;%MSVCDir%\INCLUDE;%MSVCDir%\PlatformSDK\include\prerelease;%MSVCDir%\PlatformSDK\include;%FrameworkSDKDir%\include;%INCLUDE%
@set LIB=%MSVCDir%\ATLMFC\LIB;%MSVCDir%\LIB;%MSVCDir%\PlatformSDK\lib\prerelease;%MSVCDir%\PlatformSDK\lib;%FrameworkSDKDir%\lib;%LIB%

@goto end

:Usage

@echo. VSINSTALLDIR variable is not set. 
@echo.
@echo SYNTAX: %0

@goto end

:end
