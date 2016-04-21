# ==============================================
# GNU Makefile for HIL Block
#
# Copyright 2002-2004 The MathWorks, Inc.
# $Revision: 1.1.6.4 $ $Date: 2004/04/01 15:59:23 $
#
# ----- To use on PC -----
#
# 1) CD to sandbox root (d:\work\A) and type "setmwe pwd"
#
# 2)   at the DOS command line type the following:
#
#    cygnusmake -f makefile.gnu -Id:\work\A\matlab\makerules
#
# This file is assumed (for relative path name purposes) 
# to live in $(MATLABROOT)/toolbox/ccslink/ccsblks
# ==============================================

# Common S-fcn dependencies
include mexrules.gnu

# THIS PRODUCT IS WINDOWS-ONLY!
ifdef ISPC

include ../../dspblks/src/gnumake/dsp_bld_defs.gnu

ML_REL_ROOT         = ../../..
EXT_INC_DIR         = $(ML_REL_ROOT)/extern/include
TMW_SRC_INC_DIR     = $(ML_REL_ROOT)/src/include
TMW_LIB_DIR         = $(ML_REL_ROOT)/lib/$(DIR_ARCH)
SL_INC_DIR          = $(ML_REL_ROOT)/simulink/include
DSPBLKS_DIR         = $(ML_REL_ROOT)/toolbox/dspblks
DSPBLKS_INCLUDE_DIR = $(DSPBLKS_DIR)/include
DSPBLKS_LIB_DIR     = $(DSPBLKS_DIR)/lib/$(DIR_ARCH)
TIHIL_SFCNSRC_DIR   = src
TIHIL_OBJ_DIR       = obj/$(DIR_ARCH)

# "ALL" target
all: tihil_blk

# My target
tihil_blk: stihil.dll

# Mex command
tihil_mex_cmd = $(MEX) $(MEXFLAGS) $<   -I$(DSPBLKS_INCLUDE_DIR) -I$(TMW_SRC_INC_DIR)  $(TMW_LIB_DIR)/libfixedpoint.lib $(DSPBLKS_LIB_DIR)/dsp_sim.lib
tihil_mex_comment = @echo --- Building s-function $@

# S-function dependencies
# $(TI_INCLUDE_DIR)/ti_fixpt_sim.h         \
tihil_sfcn_cmn_deps =   $(DSPBLKS_INCLUDE_DIR)/dsp_trailer.c     \
                       $(DSPBLKS_LIB_DIR)/dsp_sim.lib    \
                       $(TMW_LIB_DIR)/libfixedpoint.lib  \
                       $(SL_INC_DIR)/simstruc_types.h           \
                       $(SL_INC_DIR)/simulink.c                 \
                       $(SL_INC_DIR)/simstruc.h                 \
                       $(DEPENDS)                               \
                       $(EXT_INC_DIR)/tmwtypes.h   \
                       makefile.gnu


# Default rule to build tihil DSPLIB C S-Functions
stihil.dll : src/stihil.c $(tihil_sfcn_cmn_deps)
	$(tihil_mex_comment)
	$(tihil_mex_cmd) 
	$(MAPCSF) $@


# Remove .dll's and .obj's
clean: clean_sfcn

# Remove s-fcn .dll's
clean_sfcn:
	$(RM) stihil.dll

else

# Give empty target for Unix platforms.
all:

clean:

endif
# =============================================
# [EOF] makefile.gnu
