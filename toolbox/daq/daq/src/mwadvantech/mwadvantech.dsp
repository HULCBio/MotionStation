# Microsoft Developer Studio Project File - Name="mwadvantech" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=mwadvantech - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mwadvantech.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mwadvantech.mak" CFG="mwadvantech - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mwadvantech - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mwadvantech - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Development/toolbox/daq/daq/src/Advantech", WPDCAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "mwadvantech - Win32 Debug"

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
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\include" /I "DllApi" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /FR /Yu"stdafx.h" /FD /GZ /c
# SUBTRACT CPP /X
# ADD MTL /I "..\include" /I "DllApi" /Oicf
# ADD BASE RSC /l 0x1c09 /d "_DEBUG"
# ADD RSC /l 0x409 /i "..\include" /i "DllApi" /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Adsapi32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept /libpath:"DllApi" /libpath:"..\include"
# SUBTRACT LINK32 /pdb:none
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Debug
TargetName=mwadvantech
InputPath=.\Debug\mwadvantech.dll
SOURCE="$(InputPath)"

BuildCmds= \
	call ..\include\copynreg $(TargetDir) $(TargetName) $(ProjDir)

"..\..\private\$(TargetName).dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"..\..\private\$(TargetName).ini" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ELSEIF  "$(CFG)" == "mwadvantech - Win32 Release"

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
# ADD CPP /nologo /MT /W3 /GX /O1 /I "..\include" /I "DllApi" /D "_MBCS" /D "_ATL_STATIC_REGISTRY" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" /FR /Yu"stdafx.h" /FD /c
# ADD MTL /I "..\include" /I "DllApi" /Oicf
# ADD BASE RSC /l 0x1c09 /d "NDEBUG"
# ADD RSC /l 0x409 /i "..\include" /i "DllApi" /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib Adsapi32.lib /nologo /subsystem:windows /dll /machine:I386 /libpath:"..\include" /libpath:"DllApi"
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Release
TargetName=mwadvantech
InputPath=.\Release\mwadvantech.dll
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

# Name "mwadvantech - Win32 Debug"
# Name "mwadvantech - Win32 Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\include\AdaptorKit.cpp
# End Source File
# Begin Source File

SOURCE=.\advantechadapt.cpp
# End Source File
# Begin Source File

SOURCE=.\advantechain.cpp
# End Source File
# Begin Source File

SOURCE=.\advantechaout.cpp
# End Source File
# Begin Source File

SOURCE=.\advantechdio.cpp
# End Source File
# Begin Source File

SOURCE=.\advantechUtil.cpp
# End Source File
# Begin Source File

SOURCE=.\mwadvantech.cpp
# End Source File
# Begin Source File

SOURCE=.\mwadvantech.def
# End Source File
# Begin Source File

SOURCE=.\mwadvantech.idl
# ADD MTL /tlb ".\mwadvantech.tlb" /h "mwadvantech.h" /iid "mwadvantech_i.c" /Oicf
# End Source File
# Begin Source File

SOURCE=.\mwadvantech.ini
# End Source File
# Begin Source File

SOURCE=.\mwadvantech.rc
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\advantechadapt.h
# End Source File
# Begin Source File

SOURCE=.\advantechain.h
# End Source File
# Begin Source File

SOURCE=.\advantechaout.h
# End Source File
# Begin Source File

SOURCE=.\advantechBuffer.h
# End Source File
# Begin Source File

SOURCE=.\advantechdio.h
# End Source File
# Begin Source File

SOURCE=.\advantecherr.h
# End Source File
# Begin Source File

SOURCE=.\advantechpropdef.h
# End Source File
# Begin Source File

SOURCE=.\advantechUtil.h
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
# End Group
# Begin Source File

SOURCE=.\startup.m
# End Source File
# End Target
# End Project
