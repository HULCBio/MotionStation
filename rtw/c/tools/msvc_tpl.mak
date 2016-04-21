# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=|>ModelName<| - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to |>ModelName<| - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "|>ModelName<| - Win32 Release" && "$(CFG)" != "|>ModelName<| - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "|>ModelName<|.mak" CFG="|>ModelName<| - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "|>ModelName<| - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "|>ModelName<| - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "|>ModelName<| - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "|>ModelName<| - Win32 Release"

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
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\|>ModelName<|.exe"

CLEAN : 
|>EraseObjList<|
	-@erase "$(OUTDIR)\|>ModelName<|.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /GX /O2  |>IncludeDirs<| /D "NDEBUG" /D "WIN32" /D "_CONSOLE"  |>RequiredDefines<| /YX /c
CPP_PROJ=/nologo /ML /W3 /GX /O2\
  |>IncludeDirs<|\
  /D "NDEBUG" /D "WIN32" /D "_CONSOLE"\
  |>RequiredDefines<|\
  /Fp"$(INTDIR)/|>ModelName<|.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/|>ModelName<|.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib |>AdditionalLibs<| /nologo /subsystem:console /machine:I386 
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib |>AdditionalLibs<| /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib |>AdditionalLibs<| /nologo /subsystem:console\
 /pdb:"$(OUTDIR)/|>ModelName<|.pdb" /machine:I386 /out:"$(OUTDIR)/|>ModelName<|.exe" 
LINK32_OBJS= \
|>LinkObjList<|

"$(OUTDIR)\|>ModelName<|.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) 
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "|>ModelName<| - Win32 Debug"

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
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\|>ModelName<|.exe" "$(OUTDIR)\|>ModelName<|.bsc"

CLEAN : 
|>EraseObjList<|
|>EraseSbrList<|
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\|>ModelName<|.bsc"
	-@erase "$(OUTDIR)\|>ModelName<|.exe"
	-@erase "$(OUTDIR)\|>ModelName<|.ilk"
	-@erase "$(OUTDIR)\|>ModelName<|.map"
	-@erase "$(OUTDIR)\|>ModelName<|.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /Gm /GX /Zi /Od  |>IncludeDirs<| /D "_DEBUG" /D "WIN32" /D "_CONSOLE"  |>RequiredDefines<| /FR /YX /c
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /Zi /Od\
  |>IncludeDirs<|\
 /D "_DEBUG" /D "WIN32" /D "_CONSOLE"\
  |>RequiredDefines<|\
 /FR"$(INTDIR)/" /Fp"$(INTDIR)/|>ModelName<|.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/|>ModelName<|.bsc" 
BSC32_SBRS= \
|>SbrList<|

"$(OUTDIR)\|>ModelName<|.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32)
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib |>AdditionalLibs<| /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib |>AdditionalLibs<| /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib |>AdditionalLibs<| /nologo /subsystem:console\
 /pdb:"$(OUTDIR)/|>ModelName<|.pdb" /debug\
 /machine:I386 /out:"$(OUTDIR)/|>ModelName<|.exe" 
LINK32_OBJS= \
|>LinkObjList<|

"$(OUTDIR)\|>ModelName<|.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32)
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "|>ModelName<| - Win32 Release"
# Name "|>ModelName<| - Win32 Debug"

!IF  "$(CFG)" == "|>ModelName<| - Win32 Release"

!ELSEIF  "$(CFG)" == "|>ModelName<| - Win32 Debug"

!ENDIF 

|>SourceFileList<|
# End Target
# End Project
################################################################################
