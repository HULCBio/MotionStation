# Microsoft Developer Studio Project File - Name="#$demo$#" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=#$demo$# - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "#$Demo$#.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "#$Demo$#.mak" CFG="#$demo$# - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "#$demo$# - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "#$demo$# - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "#$demo$# - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "#$tbxsrc$#" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD MTL /I "#$tbxsrc$#"
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /pdbtype:sept
# Begin Custom Build - Performing registration
OutDir=.\Debug
TargetPath=.\Debug\#$Demo$#.dll
InputPath=.\Debug\#$Demo$#.dll
SOURCE="$(InputPath)"

"$(OutDir)\regsvr32.trg" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	regsvr32 /s /c "$(TargetPath)" 
	echo regsvr32 exec. time > "$(OutDir)\regsvr32.trg" 
	
# End Custom Build


!ELSEIF  "$(CFG)" == "#$demo$# - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "_ATL_STATIC_REGISTRY" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O1 /I "#$tbxsrc$#" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "_ATL_STATIC_REGISTRY" /Yu"stdafx.h" /FD /c
# ADD MTL /I "#$tbxsrc$#"
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /i "./Release" /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# Begin Custom Build - Performing registration
OutDir=.\Release
TargetPath=.\Release\#$Demo$#.dll
InputPath=.\Release\#$Demo$#.dll
SOURCE="$(InputPath)"

"$(OutDir)\regsvr32.trg" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	regsvr32 /s /c "$(TargetPath)" 
	echo regsvr32 exec. time > "$(OutDir)\regsvr32.trg" 
	
# End Custom Build


!ENDIF 

# Begin Target

# Name "#$demo$# - Win32 Debug"
# Name "#$demo$# - Win32 Release"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=#$tbxsrc$#\AdaptorKit.cpp
# End Source File
# Begin Source File

SOURCE=.\#$Demo$#.cpp
# End Source File
# Begin Source File

SOURCE=.\#$Demo$#.def
# End Source File
# Begin Source File

SOURCE=.\#$Demo$#.idl

!IF  "$(CFG)" == "#$demo$# - Win32 Debug"

# ADD MTL /tlb ".\#$Demo$#.tlb" /h "#$Demo$#.h" /iid "#$Demo$#_i.c" /Oicf

!ELSEIF  "$(CFG)" == "#$demo$# - Win32 Release"

# ADD MTL /I "..\include" /tlb ".\#$Demo$#.tlb" /h "#$Demo$#.h" /iid "#$Demo$#_i.c" /Oicf

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\#$Demo$#.rc
# End Source File
# Begin Source File

SOURCE=.\#$Demo$#Adapt.cpp
# End Source File

#$StartAICut$#
# Begin Source File
SOURCE=.\#$Demo$#Ain.cpp
# End Source File
#$EndAICut$#

#$StartAOCut$#
# Begin Source File
SOURCE=.\#$Demo$#Aout.cpp
# End Source File
#$EndAOCut$#

#$StartDIOCut$#
# Begin Source File
SOURCE=.\#$Demo$#DIO.cpp
# End Source File
#$EndDIOCut$#

# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /I "#$tbxsrc$#" /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File
SOURCE=.\#$Demo$#adapt.h
# End Source File
# Begin Source File

SOURCE=.\#$Demo$#PropDefs.h
# End Source File

#$StartAICut$#
# Begin Source File
SOURCE=.\#$Demo$#Ain.h
# End Source File
#$EndAICut$#

#$StartAOCut$# 
# Begin Source File
SOURCE=.\#$Demo$#Aout.h
# End Source File
#$EndAOCut$#

#$StartDIOCut$#
# Begin Source File
SOURCE=.\#$Demo$#DIO.h
# End Source File
#$EndDIOCut$#


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
SOURCE=.\#$Demo$#adaptor.rgs
# End Source File

#$StartAICut$#
# Begin Source File
SOURCE=.\#$Demo$#AI.rgs
# End Source File
#$EndAICut$#

#$StartAOCut$# 
# Begin Source File
SOURCE=.\#$Demo$#AO.rgs
# End Source File
#$EndAOCut$#

#$StartDIOCut$#
# Begin Source File
SOURCE=.\#$Demo$#DIO.rgs
# End Source File
#$EndDIOCut$#

# End Group
# End Target
# End Project

