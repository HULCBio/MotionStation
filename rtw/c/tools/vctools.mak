# Copyright 1994-2000 The MathWorks, Inc.
#
# File    : vctools.mak   $Revision: 1.9.4.3 $
# Abstract:
#	Setup Visual tools for nmake.

# The following line setting "lflags" is needed to avoid a link warning in
# MSVC 7.0 only but doesn't hurt the other versions so we always do it.

lflags = /NODEFAULTLIB:LIBC $(lflags)

# The following setting of APPVER to 4.0 is needed so that under MSVC 7.0 we
# produce executables compatible with NT 4.0.  Otherwise, MSVC 7.0's ntwin32.mak
# will use a default APPVER of 5.0.  APPVER is the minimum version of Windows
# required, e.g. 5.0 ==> require Win2000 or later.  Doesn't hurt for other
# versions of MSVC so we always do it.

APPVER = 4.0

!include <ntwin32.mak>

CC     = cl
LD     = link
LIBCMD = lib

# VISUAL_VER_TENS is "VISUAL_VER" without the decimal point (the major version
# is in the tens as opposed to ones place)

VISUAL_VER_TENS = $(VISUAL_VER:.=)

# msvc60opts.bat,
# msvc70opts.bat, etc.
!ifndef MEX_OPT_FILE
MEX_OPT_FILE = -f $(MATLAB_BIN)\mexopts\msvc$(VISUAL_VER_TENS)opts.bat
!endif
#
# Default optimization options.
#
DEFAULT_OPT_OPTS = -Ot

#[eof] vctools.mak
