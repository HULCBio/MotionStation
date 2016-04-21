#
# Author:   Altia Incorporated
#
# Revision: Altia Design 2.0 - November, 1995
#
#           Copyright (c) 1995, Altia Incorporated
#
# Description:
#
# Example Microsoft 32-bit NT make file for Altia cruise demo.
# This make file is executed from a MS-DOS shell prompt window, but it
# builds a Windows executable program.
#
# TO USE THIS MAKE FILE:
#
# A copy of this make file already exists in the altia\demos\cruise
# directory as make32.ms.  Change directory to \altia\demos\cruise
# in a MS-DOS shell prompt window and then run the Microsoft nmake command
# from the shell prompt window using a command line that looks like: 
#
#   \mstools\bin\nmake -f make32.ms
#
# Where \mstools\bin\nmake is the path to the Microsoft 32-bit nmake program.
#

!include <ntwin32.mak>

FILENAME        = make32.ms

ALTIAHOME	= <Path to ALTIA Root Directory>

CX		= $(cc)

LD		= $(link)

MAKE		= nmake

CXFLAGS		= $(cflags) $(cvars) -I$(ALTIAHOME)\lib\ms32

LDFLAGS		= $(conlflags)

DDELIBS		= $(ALTIAHOME)\lib\ms32\libdde.lib

LANLIBS		= $(ALTIAHOME)\lib\ms32\liblan.lib

LIBS		= $(DDELIBS)

STDDDELIBS	= $(conlibs) user32.lib

STDLANLIBS	= $(conlibs) user32.lib wsock32.lib

STDLIBS		= $(STDDDELIBS)

SRC1BASE	= sf_car_xpc

OBJS		= $(SRC1BASE).obj

PROGRAM		= $(SRC1BASE).exe

all: $(PROGRAM)

dde:
	@$(MAKE) -f $(FILENAME) clean all LIBS="$(DDELIBS)" STDLIBS="$(STDDDELIBS)"

lan:
	@$(MAKE) -f $(FILENAME) clean all LIBS="$(LANLIBS)" STDLIBS="$(STDLANLIBS)"

$(PROGRAM): $(OBJS) $(LIBS) xpcinitfree.obj
	$(LD) $(LDFLAGS) -out:$@ $(OBJS) xpcinitfree.obj $(LIBS) $(STDLIBS)
	@echo Done.

xpcinitfree.obj: xpcinitfree.c
	$(CX) $(CXFLAGS) xpcinitfree.c

$(OBJS): $$(@B).c
	$(CX) $(CXFLAGS) $(@B).c

clean::
	@del $(OBJS) $(PROGRAM)



