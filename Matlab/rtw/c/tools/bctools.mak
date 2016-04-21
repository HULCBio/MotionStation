# Copyright 1994-2000 The MathWorks, Inc.
#
# File    : bctools.mak   $Revision: 1.15.4.1 $
# Abstract:
#	Setup Borland tools for make.


BORLANDTOOLS = $(BORLAND)
!if "$(BC_VER)" == "5.3"
BORLANDTOOLS = $(BORLAND)\cbuilder3
!endif
!if "$(BC_VER)" == "5.4"
BORLANDTOOLS = $(BORLAND)\cbuilder4
!endif
!if "$(BC_VER)" == "5.5"
BORLANDTOOLS = $(BORLAND)\cbuilder5
!endif
!if "$(BC_VER)" == "5.5free"
BORLANDTOOLS = $(BORLAND)\bcc55
!endif
!if "$(BC_VER)" == "5.6"
BORLANDTOOLS = $(BORLAND)\cbuilder6
!endif
!if "$(BC_VER)" == "5.6free"
BORLANDTOOLS = $(BORLAND)\bcc56
!endif


CC     	= "$(BORLANDTOOLS)\bin\bcc32"
LD     	= "$(BORLANDTOOLS)\bin\ilink32"
!if "$(BC_VER)" == "5.0"
LD     	= "$(BORLANDTOOLS)\bin\tlink32"
!endif
!if "$(BC_VER)" == "5.2"
LD     	= "$(BORLANDTOOLS)\bin\tlink32"
!endif
!if "$(BC_VER)" == "5.3"
LD     	= "$(BORLANDTOOLS)\bin\tlink32"
!endif

LIB    	= "$(BORLANDTOOLS)\lib"


LIBCMD 	= "$(BORLANDTOOLS)\bin\tlib"
LIBFLAG = /P64
PRELINK = "$(BORLANDTOOLS)\bin\implib"
PERL   	= $(MATLAB_ROOT)\sys\perl\win32\bin\perl

# Use Perl for echo because Borland's make does not work when MKS Tools
# are installed (MKS Tools contains an echo.exe which conflicts with Borland
# make).

ECHO = $(PERL) $(MATLAB_ROOT)\rtw\c\tools\echo.pl

#
# Default optimization options
#
DEFAULT_OPT_OPTS = -O2

#
# Includes
#

MATLAB_INCLUDES1 = $(MATLAB_ROOT)\simulink\include;$(MATLAB_ROOT)\extern\include
MATLAB_INCLUDES2 = $(MATLAB_ROOT)\rtw\c\src;$(MATLAB_ROOT)\rtw\c\libsrc
MATLAB_INCLUDES3 = $(MATLAB_ROOT)\rtw\c\src\ext_mode\common;$(MATLAB_ROOT)\rtw\c\src\ext_mode\tcpip;$(MATLAB_ROOT)\rtw\c\src\ext_mode\serial;$(MATLAB_ROOT)\rtw\c\src\ext_mode\custom;
MATLAB_INCLUDES  = $(MATLAB_INCLUDES1);$(MATLAB_INCLUDES2);$(MATLAB_INCLUDES3)

# DSP Blockset non-TLC S-fcn source include path
DSP_MEX = $(MATLAB_ROOT)\toolbox\dspblks\dspmex
DSP_SIM = $(MATLAB_ROOT)\toolbox\dspblks\src\sim
DSP_RT  = $(MATLAB_ROOT)\toolbox\dspblks\src\rt
DSP_INCLUDES = $(DSP_RT);$(DSP_SIM)

BLOCKSET_INCLUDES = $(DSP_INCLUDES);$(MATLAB_ROOT)\toolbox\commblks\commmex

COMPILER_INCLUDE_WIN32=
!if "$(BC_VER)" == "5.0"
COMPILER_INCLUDE_WIN32=;$(BORLANDTOOLS)\include\win32
!endif
!if "$(BC_VER)" == "5.2"
COMPILER_INCLUDE_WIN32=;$(BORLANDTOOLS)\include\win32
!endif

COMPILER_INCLUDES = $(BORLANDTOOLS)\include$(COMPILER_INCLUDE_WIN32)

INCLUDES = ..;$(MATLAB_INCLUDES);$(BLOCKSET_INCLUDES);$(COMPILER_INCLUDES)



# [EOF] bctools.mak
