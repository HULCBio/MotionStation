# Microsoft Developer Studio Project File - Name="mwparallel" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=mwparallel - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mwparallel.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mwparallel.mak" CFG="mwparallel - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mwparallel - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mwparallel - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Data Acquisition/mwparallel", CQVAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "mwparallel - Win32 Debug"

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
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "..\include" /I "WinIo" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /FR /Yu"stdafx.h" /FD /GZ /c
# ADD MTL /I "..\include" /I "WinIO" /Oicf
# SUBTRACT MTL /nologo
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /i "..\include" /i "WinIO" /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winio.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept /libpath:"WinIo" /libpath:"..\include"
# SUBTRACT LINK32 /pdb:none
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Debug
TargetName=mwparallel
InputPath=.\Debug\mwparallel.dll
SOURCE="$(InputPath)"

"..\..\private\$(TargetName).dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	call ..\include\copynreg $(TargetDir) $(TargetName) $(ProjDir)

# End Custom Build

!ELSEIF  "$(CFG)" == "mwparallel - Win32 Release"

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
# ADD CPP /nologo /MT /W3 /GX /O1 /I "..\include" /I "WinIo" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "_ATL_STATIC_REGISTRY" /D "WINIO_DLL" /FR /Yu"stdafx.h" /FD /c
# ADD MTL /I "..\include" /I "WinIO" /Oicf
# SUBTRACT MTL /nologo
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /i "..\include" /i "WinIO" /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winio.lib /nologo /subsystem:windows /dll /machine:I386 /libpath:"WinIo" /libpath:"..\include"
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Release
TargetName=mwparallel
InputPath=.\Release\mwparallel.dll
SOURCE="$(InputPath)"

"..\..\private\$(TargetName).dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	call ..\include\copynreg $(TargetDir) $(TargetName) $(ProjDir)

# End Custom Build

!ENDIF 

# Begin Target

# Name "mwparallel - Win32 Debug"
# Name "mwparallel - Win32 Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\include\AdaptorKit.cpp
# End Source File
# Begin Source File

SOURCE=.\mwparallel.cpp
# End Source File
# Begin Source File

SOURCE=.\mwparallel.def
# End Source File
# Begin Source File

SOURCE=.\mwparallel.idl
# ADD MTL /nologo /tlb ".\mwparallel.tlb" /h "mwparallel.h" /iid "mwparallel_i.c"
# End Source File
# Begin Source File

SOURCE=.\mwparallel.rc
# End Source File
# Begin Source File

SOURCE=.\ParallelAdapt.cpp
# End Source File
# Begin Source File

SOURCE=.\ParallelDio.cpp
# End Source File
# Begin Source File

SOURCE=.\ParallelDriver.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\ParallelAdapt.h
# End Source File
# Begin Source File

SOURCE=.\ParallelDio.h
# End Source File
# Begin Source File

SOURCE=.\ParallelDriver.h
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

SOURCE=.\ParallelAdapt.rgs
# End Source File
# Begin Source File

SOURCE=.\ParallelDio.rgs
# End Source File
# End Group
# End Target
# End Project
