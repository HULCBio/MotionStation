# Microsoft Developer Studio Project File - Name="mwmcc" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=mwmcc - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mwmcc.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mwmcc.mak" CFG="mwmcc - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mwmcc - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mwmcc - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Development/toolbox/daq/daq/src/ComputerBoards", EAIAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "mwmcc - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /I "..\include" /I "DllApi" /D "_ATL_STATIC_REGISTRY" /D "_MBCS" /D "_WINDOWS" /D "_USRDLL" /D "WIN32" /D "_DEBUG" /D "NOREGTRACE" /FR /Yu"stdafx.h" /FD /GZ /c
# ADD MTL /nologo /I "..\include" /D "_DEBUG"
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 winmm.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib cbw32.lib version.lib /nologo /subsystem:windows /dll /map /debug /machine:I386 /pdbtype:sept /libpath:".\DllApi"
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Debug
TargetName=mwmcc
InputPath=.\Debug\mwmcc.dll
SOURCE="$(InputPath)"

BuildCmds= \
	call ..\include\copynreg $(TargetDir) $(TargetName) $(ProjDir)

"..\..\private\$(TargetName).dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"..\..\private\$(TargetName).ini" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ELSEIF  "$(CFG)" == "mwmcc - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "_ATL_STATIC_REGISTRY" /D "_ATL_MIN_CRT" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O1 /I "..\include" /I "DllApi" /D "_ATL_STATIC_REGISTRY" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /FR /Yu"stdafx.h" /FD /c
# ADD MTL /I "..\include" /D "NDEBUG"
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib cbw32.lib winmm.lib version.lib /nologo /subsystem:windows /dll /machine:I386 /libpath:".\DllApi"
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Release
TargetName=mwmcc
InputPath=.\Release\mwmcc.dll
SOURCE="$(InputPath)"

BuildCmds= \
	call ..\include\copynreg $(TargetDir) $(TargetName) $(ProjDir)

"..\..\private\$(TargetName).dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"..\..\private\$(TargetName).ini" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ENDIF 

# Begin Target

# Name "mwmcc - Win32 Debug"
# Name "mwmcc - Win32 Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\include\AdaptorKit.cpp
# End Source File
# Begin Source File

SOURCE=.\Ain.cpp
# End Source File
# Begin Source File

SOURCE=.\Aout.cpp
# End Source File
# Begin Source File

SOURCE=.\cbUtil.cpp
# End Source File
# Begin Source File

SOURCE=.\Dio.cpp
# End Source File
# Begin Source File

SOURCE=.\mwmcc.cpp
# End Source File
# Begin Source File

SOURCE=.\mwmcc.def
# End Source File
# Begin Source File

SOURCE=.\mwmcc.idl
# ADD MTL /tlb ".\mwmcc.tlb" /h "mwmcc.h" /iid "mwmcc_i.c" /Oicf
# End Source File
# Begin Source File

SOURCE=.\mwmcc.rc
# End Source File
# Begin Source File

SOURCE=.\mwmcc.rci
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\Ain.h
# End Source File
# Begin Source File

SOURCE=.\Aout.h
# End Source File
# Begin Source File

SOURCE=.\cbUtil.h
# End Source File
# Begin Source File

SOURCE=.\Dio.h
# End Source File
# Begin Source File

SOURCE=.\Resource.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\Ain.rgs
# End Source File
# Begin Source File

SOURCE=.\Aout.rgs
# End Source File
# Begin Source File

SOURCE=.\Dio.rgs
# End Source File
# End Group
# End Target
# End Project
