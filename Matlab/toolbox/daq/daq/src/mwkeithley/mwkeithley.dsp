# Microsoft Developer Studio Project File - Name="mwkeithley" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=mwkeithley - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mwkeithley.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mwkeithley.mak" CFG="mwkeithley - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mwkeithley - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mwkeithley - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Development/toolbox/daq/daq/src/mwkeithley", SIEAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "mwkeithley - Win32 Debug"

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
# ADD CPP /nologo /MTd /W3 /GX /ZI /Od /I "..\Lib" /I ".\dlapi" /I "..\include" /I "DllApi" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /FR /Yu"stdafx.h" /FD /c
# ADD MTL /I "..\include" /I "DllApi" /Oicf
# ADD BASE RSC /l 0x1c09 /d "_DEBUG"
# ADD RSC /l 0x409 /i "..\include" /i "DllApi" /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 DRVLNX32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib VERSION.lib /nologo /version:1.1 /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept /libpath:"..\include" /libpath:"DllApi"
# SUBTRACT LINK32 /nodefaultlib /force
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Debug
TargetName=mwkeithley
InputPath=.\Debug\mwkeithley.dll
SOURCE="$(InputPath)"

BuildCmds= \
	call ..\include\copynreg $(TargetDir) $(TargetName) $(ProjDir)

"..\..\private\$(TargetName).dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"..\..\private\$(TargetName).ini" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ELSEIF  "$(CFG)" == "mwkeithley - Win32 Release"

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
# ADD CPP /nologo /MT /W3 /GX /O1 /I "..\include" /I "DllApi" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "_ATL_STATIC_REGISTRY" /D "_ATL_MIN_CRT" /FR /Yu"stdafx.h" /FD /c
# ADD MTL /I "..\include" /I "DllApi" /Oicf
# ADD BASE RSC /l 0x1c09 /d "NDEBUG"
# ADD RSC /l 0x409 /i "..\include" /i "DllApi" /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 DRVLNX32.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib VERSION.lib /nologo /subsystem:windows /dll /machine:I386 /nodefaultlib:"atlmincrt.lib" /libpath:"..\include" /libpath:"DllApi"
# SUBTRACT LINK32 /nodefaultlib
# Begin Custom Build - Copying files and Performing registration
ProjDir=.
TargetDir=.\Release
TargetName=mwkeithley
InputPath=.\Release\mwkeithley.dll
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

# Name "mwkeithley - Win32 Debug"
# Name "mwkeithley - Win32 Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\include\AdaptorKit.cpp
# End Source File
# Begin Source File

SOURCE=.\evtmsg.cpp
# End Source File
# Begin Source File

SOURCE=.\keithleyadapt.cpp
# End Source File
# Begin Source File

SOURCE=.\keithleyain.cpp
# End Source File
# Begin Source File

SOURCE=.\keithleyaout.cpp
# End Source File
# Begin Source File

SOURCE=.\keithleydio.cpp
# End Source File
# Begin Source File

SOURCE=.\keithleyUtil.cpp
# End Source File
# Begin Source File

SOURCE=.\mwkeithley.cpp
# End Source File
# Begin Source File

SOURCE=.\mwkeithley.def
# End Source File
# Begin Source File

SOURCE=.\mwkeithley.idl

!IF  "$(CFG)" == "mwkeithley - Win32 Debug"

# ADD MTL /nologo /D "_DEBUG" /tlb ".\mwkeithley.tlb" /h "mwkeithley.h" /iid "mwkeithley_i.c"

!ELSEIF  "$(CFG)" == "mwkeithley - Win32 Release"

# ADD MTL /D "NDEBUG" /tlb ".\mwkeithley.tlb" /h "mwkeithley.h" /iid "mwkeithley_i.c"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\mwkeithley.ini
# End Source File
# Begin Source File

SOURCE=.\mwkeithley.rc
# End Source File
# Begin Source File

SOURCE=.\ONSDrvLINX.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\keithleyadapt.h
# End Source File
# Begin Source File

SOURCE=.\keithleyain.h
# End Source File
# Begin Source File

SOURCE=.\keithleyaout.h
# End Source File
# Begin Source File

SOURCE=.\keithleydio.h
# End Source File
# Begin Source File

SOURCE=.\keithleypropdef.h
# End Source File
# Begin Source File

SOURCE=.\keithleyUtil.h
# End Source File
# Begin Source File

SOURCE=.\messagew.h
# End Source File
# Begin Source File

SOURCE=.\ONSDrvLINX.h
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
# End Target
# End Project
