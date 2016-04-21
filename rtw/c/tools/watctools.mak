# Copyright 1994-2000 The MathWorks, Inc.
#
# File    : watctools.mak   $Revision: 1.4.2.2 $
# Abstract:
#	Setup Watcom tools for wmake.



CC     = $(WATCOM)\binnt\wcc386
CPP    = $(WATCOM)\binnt\wpp386
LD     = $(WATCOM)\binnt\wlink
LIB    = $(WATCOM)\lib386;$(WATCOM)\lib386\nt
LIBCMD = $(%WATCOM11)\binnt\wlib # Hack! see farhan
AS     = $(WATCOM)\binnt\wasm

PERL   = $(MATLAB_ROOT)\sys\perl\win32\bin\perl

DEFAULT_OPT_OPTS = -oaxt

#[EOF] watctools.mak
