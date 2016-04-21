# ==============================================================================
# GNU Master Makefile for ETARGETS Blocks
#
# Copyright 2001-2004 The MathWorks, Inc.
# $Revision: 1.1.6.2 $ $Date: 2004/04/20 23:20:32 $
#
#
# ----- To use on PC -----
#
# 1) Make the environment variable MATLAB is defined and
#    contains the path to your sandbox (s:\Adsphw)
#
# 2) If you would like to build only one target,
#    at the DOS command line type the following:
#
#    cygnusmake -f makefile.gnu -Is:\Adsphw\matlab\makerules target_to_build
#
#    If you would like to build all targets,
#    at the DOS command line type the following:
#
#    cygnusmake -f makefile.gnu -Is:\Adsphw\matlab\makerules
#
#
# This file is assumed (for relative path name purposes) 
# to live in $(MATLABROOT)/toolbox/shared/etargets/etargets

# ==============================================================================
# Common S-fcn dependencies
include mexrules.gnu

# THIS PRODUCT IS WINDOWS-ONLY!
ifdef ISPC

ETARGETS_ML_REL_ROOT         = ../../../..
DSPBLKS_HELPER_FCNS          = $(ETARGETS_ML_REL_ROOT)/toolbox/dspblks/src/sim_common

include $(ETARGETS_ML_REL_ROOT)/toolbox/dspblks/src/gnumake/dsp_bld_defs.gnu

TMW_LIB_DIR            = $(ETARGETS_ML_REL_ROOT)/lib/$(DIR_ARCH)
ETARGETS_SFCNSRC_DIR   = src
ETARGETS_OBJ_DIR       = obj/$(DIR_ARCH)
ETARGETS_DLL_DIR       = .

# Determine all source
ETARGETS_mem_c        = $(wildcard $(ETARGETS_SFCNSRC_DIR)/smem*.c)

ETARGETS_mem_dll = $(addprefix $(ETARGETS_DLL_DIR)/, $(patsubst %.c, %.$(EXT), $(notdir $(ETARGETS_mem_c))))

# Build all targets
all: ETARGETS_mem

ETARGETS_mem: $(ETARGETS_mem_dll)

ETARGETS_mex_comment = @echo --- Building ETARGETS S-Function $@

# The source files DSPBLKS_HELPER_FCNS)/*.c in the "cmd" below are needed
# to access utility library functions/macros that belong to DSPBLKS
ETARGETS_mex_cmd = $(MEX) $(MEXFLAGS) $<                           \
    $(DSPBLKS_HELPER_FCNS)/dsp.c	                           \
    $(DSPBLKS_HELPER_FCNS)/dsp_mtrx.c	                           \
    -I$(ETARGETS_ML_REL_ROOT)/toolbox/dspblks/include              \
    -I$(ETARGETS_ML_REL_ROOT)/src/include                          \
    $(TMW_LIB_DIR)/libfixedpoint.$(LIB_EXT)

# Dependencies
ETARGETS_sfcn_cmn_deps = makefile.gnu                              \
    $(ETARGETS_ML_REL_ROOT)/toolbox/dspblks/include/dsp_trailer.c  \
    $(ETARGETS_ML_REL_ROOT)/toolbox/dspblks/lib/$(DIR_ARCH)/dsp_sim.$(LIB_EXT) \
    $(ETARGETS_ML_REL_ROOT)/simulink/include/simstruc_types.h      \
    $(ETARGETS_ML_REL_ROOT)/simulink/include/simulink.c            \
    $(ETARGETS_ML_REL_ROOT)/simulink/include/simstruc.h            \
    $(DEPENDS)                                                     \
    $(ETARGETS_ML_REL_ROOT)/extern/include/tmwtypes.h
	              
# Build Rule
$(ETARGETS_DLL_DIR)/smem%.$(EXT) : src/smem%.c $(ETARGETS_sfcn_cmn_deps) 
	$(ETARGETS_mex_comment)
	$(ETARGETS_mex_cmd) 
	$(MAPCSF) $@


# --------------------------------------------------------
clean: clean_sfcn 

# Remove s-fcn .dll's
clean_sfcn:
	$(RM) $(ETARGETS_dll)

else

# Give empty target for Unix platforms.
all:

endif
# ==============================================================================
# [EOF] 
