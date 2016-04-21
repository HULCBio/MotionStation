# Copyright 1994-2000 by The MathWorks, Inc.
#
# File    : lcctools.mak   $Revision: 1.5.2.1 $
# Abstract:
#	Setup LCC tools for gmake.

CC     = $(LCC)\bin\lcc
LD     = $(LCC)\bin\lcclnk
LIB    = $(LCC)\lib
LIBCMD = $(LCC)\bin\lcclib
BUILDLIB = $(LCC)\bin\buildlib

PERL   = $(MATLAB_ROOT)\sys\perl\win32\bin\perl

DEFAULT_OPT_OPTS = 

#------------------------------------#
# Setup INCLUDES, DSP_MEX source dir #
#------------------------------------#

MATLAB_INCLUDES = \
	-I$(MATLAB_ROOT)\simulink\include \
	-I$(MATLAB_ROOT)\extern\include \
	-I$(MATLAB_ROOT)\rtw\c\src \
	-I$(MATLAB_ROOT)\rtw\c\libsrc \
	-I$(MATLAB_ROOT)\rtw\c\src\ext_mode\common \
	-I$(MATLAB_ROOT)\rtw\c\src\ext_mode\tcpip \
	-I$(MATLAB_ROOT)\rtw\c\src\ext_mode\serial \
	-I$(MATLAB_ROOT)\rtw\c\src\ext_mode\custom

# DSP Blockset non-TLC S-fcn source path
# and additional file include paths
DSP_MEX      = $(MATLAB_ROOT)\toolbox\dspblks\dspmex
DSP_SIM      = $(MATLAB_ROOT)\toolbox\dspblks\src\sim
DSP_RT       = $(MATLAB_ROOT)\toolbox\dspblks\src\rt
DSP_INCLUDES = \
	-I$(DSP_SIM) \
	-I$(DSP_RT)

BLOCKSET_INCLUDES = $(DSP_INCLUDES) \
                   -I$(MATLAB_ROOT)\toolbox\commblks\commmex

COMPILER_INCLUDES = -I$(LCC)\include

INCLUDES = -I. -I.. $(MATLAB_INCLUDES) $(BLOCKSET_INCLUDES) \
           $(COMPILER_INCLUDES) $(USER_INCLUDES)


#[EOF] lcctools.mak


