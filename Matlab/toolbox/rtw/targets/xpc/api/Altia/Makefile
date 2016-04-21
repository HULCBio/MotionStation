#
# Author:   Altia Incorporated
#
# Revision: Altia Design 1.40 - October, 1994
#
#           Copyright (c) 1993-1994, Altia Incorporated
#
# Description:
#
# Makefile for cruise control demo.  Set up for use with standard Microsoft
# Windows development kit.
#

ALTIAHOME	= ..\..

CX		= cl

LD		= link

MAKE		= nmake

CXFLAGS		= -GA -Gx- -AL -c -I$(ALTIAHOME)\lib  -DWIN16

LDFLAGS		= /BATCH /ONERROR:NOEXE /NOE /NOD 

DDELIBS		= $(ALTIAHOME)\lib\libdde.lib

LANLIBS		= $(ALTIAHOME)\lib\liblan.lib

LIBS		= $(DDELIBS)

STDDDELIBS	= llibcew libw toolhelp ddeml

STDLANLIBS	= 

STDLIBS		= $(STDDDELIBS)

SRC1BASE	= cruise

OBJS		= $(SRC1BASE).obj

PROGRAM		= $(SRC1BASE).exe

all: $(PROGRAM)

dde:
	@$(MAKE) clean all LIBS="$(DDELIBS)" STDLIBS="$(STDDDELIBS)"

lan:
	@$(MAKE) clean all LIBS="$(LANLIBS)" STDLIBS="$(STDLANLIBS)"

$(PROGRAM): $(OBJS) $(LIBS)
	$(LD) $(LDFLAGS) $(OBJS) , $@, , $(LIBS) $(STDLIBS), $(SRC1BASE).def
	@echo Done.

$(OBJS): $$(@B).c
	$(CX) $(CXFLAGS) $(@B).c

clean::
	@del $(OBJS)
	@del $(PROGRAM)
