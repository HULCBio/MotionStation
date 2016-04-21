# Microsoft Developer Studio Generated NMAKE File, Based on ToWaveDevice.dsp
!IF "$(CFG)" == ""
CFG=ToWaveDevice - Win32 Debug
!MESSAGE No configuration specified. Defaulting to ToWaveDevice - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "ToWaveDevice - Win32 Release" && "$(CFG)" != "ToWaveDevice - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "ToWaveDevice.mak" CFG="ToWaveDevice - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "ToWaveDevice - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "ToWaveDevice - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
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

!IF  "$(CFG)" == "ToWaveDevice - Win32 Release"

OUTDIR=.\..\..\..\..\..\bin\win32
INTDIR=.\..\obj
# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

ALL : "$(OUTDIR)\towavedevice.dll"


CLEAN :
	-@erase "$(INTDIR)\ToWaveDevice.obj"
	-@erase "$(INTDIR)\ToWaveDeviceBlock.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(OUTDIR)\towavedevice.dll"
	-@erase "$(OUTDIR)\ToWaveDevice.exp"
	-@erase "$(OUTDIR)\ToWaveDevice.lib"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP_PROJ=/nologo /MT /W3 /GX /O2 /I "$(DDKROOT)\inc" /I "$(VISUAL_STUDIO)\VC98\Include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "TOWAVEDEVICE_EXPORTS" /Fp"$(INTDIR)\ToWaveDevice.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
MTL_PROJ=/nologo /D "NDEBUG" /mktyplib203 /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\ToWaveDevice.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib winmm.lib /nologo /dll /incremental:no /pdb:"$(OUTDIR)\towavedevice.pdb" /machine:I386 /def:".\ToWaveDevice.def" /out:"$(OUTDIR)\towavedevice.dll" /implib:"$(OUTDIR)\towavedevice.lib" /libpath:"$(VISUAL_STUDIO)\VC98\Lib" 
DEF_FILE= \
	".\ToWaveDevice.def"
LINK32_OBJS= \
	"$(INTDIR)\ToWaveDevice.obj" \
	"$(INTDIR)\ToWaveDeviceBlock.obj"

"$(OUTDIR)\ToWaveDevice.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

SOURCE="$(InputPath)"
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep

ALL : $(DS_POSTBUILD_DEP)

# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

$(DS_POSTBUILD_DEP) : "$(OUTDIR)\ToWaveDevice.dll"
   copy ..\..\..\..\..\bin\win32\ToWaveDevice.lib ..\..\..\..\dspblks\lib\win32\towavedevice.lib
	echo Helper for Post-build step > "$(DS_POSTBUILD_DEP)"

!ELSEIF  "$(CFG)" == "ToWaveDevice - Win32 Debug"

OUTDIR=.\..\..\..\..\..\bin\win32
INTDIR=.\..\obj
# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

ALL : "$(OUTDIR)\ToWaveDevice.dll"


CLEAN :
	-@erase "$(INTDIR)\ToWaveDevice.obj"
	-@erase "$(INTDIR)\ToWaveDeviceBlock.obj"
	-@erase "$(INTDIR)\vc60.idb"
	-@erase "$(INTDIR)\vc60.pdb"
	-@erase "$(OUTDIR)\ToWaveDevice.dll"
	-@erase "$(OUTDIR)\ToWaveDevice.exp"
	-@erase "$(OUTDIR)\ToWaveDevice.ilk"
	-@erase "$(OUTDIR)\ToWaveDevice.lib"
	-@erase "$(OUTDIR)\ToWaveDevice.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

"$(INTDIR)" :
    if not exist "$(INTDIR)/$(NULL)" mkdir "$(INTDIR)"

CPP_PROJ=/nologo /MTd /W3 /Gm /GX /ZI /Od /I "$(DDKROOT)\inc" /I "$(VISUAL_STUDIO)\VC98\Include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "TOWAVEDEVICE_EXPORTS" /Fp"$(INTDIR)\ToWaveDevice.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /GZ /c 
MTL_PROJ=/nologo /D "_DEBUG" /mktyplib203 /win32 
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\ToWaveDevice.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib libmex.lib winmm.lib /nologo /dll /incremental:yes /pdb:"$(OUTDIR)\towavedevice.pdb" /debug /machine:I386 /def:".\ToWaveDevice.def" /out:"$(OUTDIR)\towavedevice.dll" /implib:"$(OUTDIR)\towavedevice.lib" /pdbtype:sept /libpath:"$(MATLAB)\lib\win32" /libpath:"$(VISUAL_STUDIO)\VC98\Lib" 
DEF_FILE= \
	".\ToWaveDevice.def"
LINK32_OBJS= \
	"$(INTDIR)\ToWaveDevice.obj" \
	"$(INTDIR)\ToWaveDeviceBlock.obj"

"$(OUTDIR)\ToWaveDevice.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

SOURCE="$(InputPath)"
DS_POSTBUILD_DEP=$(INTDIR)\postbld.dep

ALL : $(DS_POSTBUILD_DEP)

# Begin Custom Macros
OutDir=.\..\..\..\..\..\bin\win32
# End Custom Macros

$(DS_POSTBUILD_DEP) : "$(OUTDIR)\ToWaveDevice.dll"
   copy ..\..\..\..\..\bin\win32\ToWaveDevice.lib ..\..\..\..\dspblks\lib\win32\towavedevice.lib
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
!IF EXISTS("ToWaveDevice.dep")
!INCLUDE "ToWaveDevice.dep"
!ELSE 
!MESSAGE Warning: cannot find "ToWaveDevice.dep"
!ENDIF 
!ENDIF 


!IF "$(CFG)" == "ToWaveDevice - Win32 Release" || "$(CFG)" == "ToWaveDevice - Win32 Debug"
SOURCE=.\ToWaveDevice.cpp

"$(INTDIR)\ToWaveDevice.obj" : $(SOURCE) "$(INTDIR)"


SOURCE=.\ToWaveDeviceBlock.cpp

"$(INTDIR)\ToWaveDeviceBlock.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

