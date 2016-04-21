# Microsoft Developer Studio Generated NMAKE File, Based on FromWaveDevice.dsp
!IF "$(CFG)" == ""
CFG=FromWaveDevice - Win32 Debug
!MESSAGE No configuration specified. Defaulting to FromWaveDevice - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "FromWaveDevice - Win32 Release" && "$(CFG)" != "FromWaveDevice - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "FromWaveDevice.mak" CFG="FromWaveDevice - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "FromWaveDevice - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "FromWaveDevice - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "FromWaveDevice - Win32 Release"

OUTDIR=.\..\..\..\..\..\bin\win32
INTDIR=.\..\obj
# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

ALL : "$(OUTDIR)\fromwavedevice.dll"


CLEAN :
	-@erase "$(INTDIR)\FromWaveDevice.obj"
	-@erase "$(INTDIR)\FromWaveDeviceBlock.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\fromwavedevice.dll"
	-@erase "$(OUTDIR)\FromWaveDevice.exp"
	-@erase "$(OUTDIR)\FromWaveDevice.lib"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP_PROJ=/nologo /MT /W3 /GX /O2 /I "$(DDKROOT)\inc" /I "$(VISUAL_STUDIO)\VC98\Include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "FROMWAVEDEVICE_EXPORTS" /Fp"$(INTDIR)\FromWaveDevice.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\FromWaveDevice.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /dll /incremental:no /pdb:"$(OUTDIR)\fromwavedevice.pdb" /machine:I386 /def:".\FromWaveDevice.def" /out:"$(OUTDIR)\fromwavedevice.dll" /implib:"$(OUTDIR)\fromwavedevice.lib" /libpath:"$(VISUAL_STUDIO)\VC98\Lib" 
DEF_FILE= \
	".\FromWaveDevice.def"
LINK32_OBJS= \
	"$(INTDIR)\FromWaveDevice.obj" \
	"$(INTDIR)\FromWaveDeviceBlock.obj"

"$(OUTDIR)\FromWaveDevice.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

SOURCE="$(InputPath)"
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep

ALL : $(DS_POSTBUILD_DEP)

# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

$(DS_POSTBUILD_DEP) : "$(OUTDIR)\FromWaveDevice.dll"
   copy ..\..\..\..\..\bin\win32\FromWaveDevice.lib ..\..\..\..\dspblks\lib\win32\fromwavedevice.lib
	echo Helper for Post-build step > "$(DS_POSTBUILD_DEP)"

!ELSEIF  "$(CFG)" == "FromWaveDevice - Win32 Debug"

OUTDIR=.\..\..\..\..\..\bin\win32
INTDIR=.\..\obj
# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

ALL : "$(OUTDIR)\FromWaveDevice.dll"


CLEAN :
	-@erase "$(INTDIR)\FromWaveDevice.obj"
	-@erase "$(INTDIR)\FromWaveDeviceBlock.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\FromWaveDevice.dll"
	-@erase "$(OUTDIR)\FromWaveDevice.exp"
	-@erase "$(OUTDIR)\FromWaveDevice.ilk"
	-@erase "$(OUTDIR)\FromWaveDevice.lib"
	-@erase "$(OUTDIR)\FromWaveDevice.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(DDKROOT)\inc" /I "$(VISUAL_STUDIO)\VC98\Include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "FROMWAVEDEVICE_EXPORTS" /Fp"$(INTDIR)\FromWaveDevice.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\FromWaveDevice.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /dll /incremental:yes /pdb:"$(OUTDIR)\fromwavedevice.pdb" /debug /machine:I386 /def:".\FromWaveDevice.def" /out:"$(OUTDIR)\fromwavedevice.dll" /implib:"$(OUTDIR)\fromwavedevice.lib" /pdbtype:sept /libpath:"$(VISUAL_STUDIO)\VC98\Lib" 
DEF_FILE= \
	".\FromWaveDevice.def"
LINK32_OBJS= \
	"$(INTDIR)\FromWaveDevice.obj" \
	"$(INTDIR)\FromWaveDeviceBlock.obj"

"$(OUTDIR)\FromWaveDevice.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

SOURCE="$(InputPath)"
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep

ALL : $(DS_POSTBUILD_DEP)

# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

$(DS_POSTBUILD_DEP) : "$(OUTDIR)\FromWaveDevice.dll"
   copy ..\..\..\..\..\bin\win32\FromWaveDevice.lib ..\..\..\..\dspblks\lib\win32\fromwavedevice.lib
	echo Helper for Post-build step > "$(DS_POSTBUILD_DEP)"

!ENDIF 

.c{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(INTDIR)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(NO_EXTERNAL_DEPS)" != "1"
!IF EXISTS("FromWaveDevice.dep")
!INCLUDE "FromWaveDevice.dep"
!ELSE 
!MESSAGE Warning: cannot find "FromWaveDevice.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "FromWaveDevice - Win32 Release" || "$(CFG)" == "FromWaveDevice - Win32 Debug"
SOURCE=.\FromWaveDevice.cpp

"$(INTDIR)\FromWaveDevice.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\FromWaveDeviceBlock.cpp

"$(INTDIR)\FromWaveDeviceBlock.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

