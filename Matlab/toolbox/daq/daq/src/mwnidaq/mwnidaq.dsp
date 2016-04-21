# Microsoft Developer Studio Project File - Name="mwnidaq" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=mwnidaq - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mwnidaq.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mwnidaq.mak" CFG="mwnidaq - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mwnidaq - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mwnidaq - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Development/toolbox/daq/daq/src/mwnidaq", XOAAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "mwnidaq - Win32 Debug"

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
# ADD BASE CPP /nologo /MTd /W3 /Gm /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_USRDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MTd /W3 /Gm /GR /GX /ZI /Od /I "..\include" /I "DllApi" /D "_ATL_STATIC_REGISTRY" /D "_WINDOWS" /D "_USRDLL" /D "WIN32" /D "_DEBUG" /D "NOREGTRACE" /FR /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /I "..\include" /D "_DEBUG" /o "NUL" /win32
# SUBTRACT MTL /mktyplib203
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /i "DllApi" /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib nidaq32.lib /nologo /subsystem:windows /dll /map /debug /machine:I386 /def:".\mwnidaq.def" /pdbtype:sept /libpath:"DllApi"
# SUBTRACT LINK32 /pdb:none
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Debug
TargetName=mwnidaq
InputPath=.\Debug\mwnidaq.dll
SOURCE="$(InputPath)"

BuildCmds= \
	call ..\include\copynreg $(TargetDir) $(TargetName) $(ProjDir)

"..\..\private\$(TargetName).dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"..\..\private\$(TargetName).ini" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ELSEIF  "$(CFG)" == "mwnidaq - Win32 Release"

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
# ADD BASE CPP /nologo /MT /W3 /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" /D "_ATL_STATIC_REGISTRY" /D "_ATL_MIN_CRT" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O1 /I "..\include" /I "DllApi" /D "_ATL_STATIC_REGISTRY" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_USRDLL" /FR /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /I "..\include" /D "NDEBUG" /o "NUL" /win32
# SUBTRACT MTL /nologo
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /i "DllApi" /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 odbc32.lib odbccp32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib nidaq32.lib /nologo /subsystem:windows /dll /machine:I386 /libpath:"DllApi"
# SUBTRACT LINK32 /incremental:yes /map
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Release
TargetName=mwnidaq
InputPath=.\Release\mwnidaq.dll
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

# Name "mwnidaq - Win32 Debug"
# Name "mwnidaq - Win32 Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\include\AdaptorKit.cpp
# End Source File
# Begin Source File

SOURCE=.\evtmsg.cpp
# End Source File
# Begin Source File

SOURCE=.\labio.cpp
# End Source File
# Begin Source File

SOURCE=.\mwnidaq.cpp
# End Source File
# Begin Source File

SOURCE=.\mwnidaq.def

!IF  "$(CFG)" == "mwnidaq - Win32 Debug"

# PROP Exclude_From_Build 1

!ELSEIF  "$(CFG)" == "mwnidaq - Win32 Release"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\mwnidaq.idl
# ADD MTL /tlb ".\mwnidaq.tlb" /h "mwnidaq.h" /iid "mwnidaq_i.c" /Oicf
# End Source File
# Begin Source File

SOURCE=.\mwnidaq.rc
# End Source File
# Begin Source File

SOURCE=.\Nia2d.cpp
# End Source File
# Begin Source File

SOURCE=.\nid2a.cpp
# End Source File
# Begin Source File

SOURCE=.\niDIO.cpp
# End Source File
# Begin Source File

SOURCE=.\niDisp.cpp
# End Source File
# Begin Source File

SOURCE=.\niutil.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\include\cirbuf.h
# End Source File
# Begin Source File

SOURCE=.\daqtypes.h
# End Source File
# Begin Source File

SOURCE=.\messagew.h
# End Source File
# Begin Source File

SOURCE=.\nia2d.h
# End Source File
# Begin Source File

SOURCE=.\nid2a.h
# End Source File
# Begin Source File

SOURCE=.\niDIO.h
# End Source File
# Begin Source File

SOURCE=.\niDisp.h
# End Source File
# Begin Source File

SOURCE=.\Niutil.h
# End Source File
# Begin Source File

SOURCE=.\Resource.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\errors.h
# End Source File
# Begin Source File

SOURCE=.\Errors.rci
# End Source File
# Begin Source File

SOURCE=.\mwnidaq.rci
# End Source File
# End Group
# Begin Source File

SOURCE=.\niDisp.rgs
# End Source File
# End Target
# End Project
