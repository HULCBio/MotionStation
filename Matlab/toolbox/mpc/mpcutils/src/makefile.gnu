# Makefile for Model Predictive Control Toolbox
#
# To build:
#    setmwe (mlroot)
#    cd (mlroot)/toolbox/mpc/mpcutils/src
# UNIX:
#    gmake -f makefile.gnu
# PC:
#    cygnusmake -f makefile.gnu
#
# Author(s): Rajiv Singh
# Copyright 1986-2003 The MathWorks, Inc.
# $Revision: 1.1.6.2 $ $Date: 2003/12/04 01:37:46 $

# Defining TOPDIR would facilitate mexing in your sandbox
# MWE_INSTALL would ensure appropriate root dir is used in BaT
TOPDIR = ../../../../src

# If not already defined, MWE_INSTALL would be the TOPDIR
ifeq ($(MWE_INSTALL),)
  MWE_INSTALL := $(TOPDIR)/..
endif

include $(MWE_INSTALL)/makerules/mexrules.gnu

MAKEFILE  := makefile.gnu
DEPENDS   += $(MAKEFILE)
DEFSRCINC := -I$(MATLABROOT)/src/include \
             -I$(MATLABROOT)/freeware/icu/$(DIR_ARCH)/release/include
MEXFLAGS  += $(DEFSRCINC)

TARGETS = ../mpc_sfun.$(EXT) ../mpcloop_engine.$(EXT) ../qpsolver.$(EXT)

all  : $(TARGETS)

#
# This is the default dependency line, add anything that all the targets
# are dependent on and always include $(DEPENDS).
# 
$(TARGETS) : $(MAKEFILE) $(DEPENDS) dantzgmp.h mat_macros.h mpc_sfun.h mpcloop_engine.h dantzgmp_solver.c

../mpc_sfun.$(EXT) : mpc_sfun.c dantzgmp_solver.c

../mpcloop_engine.$(EXT) : mpcloop_engine.c dantzgmp_solver.c

../qpsolver.$(EXT) : qpsolver.c dantzgmp_solver.c

clean :
	rm -f $(TARGETS)
