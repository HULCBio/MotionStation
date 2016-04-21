#
# File    : examples.mk                                       $Revision: 1.15 $
#
# Abstract:
#   Makefile to build the Ada S-Function examples into MEX Files.
#
# Usage:
#   make -f examples.mk MATLABROOT=<mlroot> -I<mlroot>/makerules [all] | clean
#
# Author(s): Murali Yeddanapudi, 04-Aug-1999
# Copyright 1990-2002 The MathWorks, Inc.

include mexrules.gnu

ifdef ISPC
  ARCH = win32
endif

MAKEFILE   = examples.mk

SL_ADA_DIR   = $(MATLABROOT)/simulink/ada
TARGET_DIR   = $(MATLABROOT)/toolbox/simulink/blocks
EXAMPLES_DIR = $(SL_ADA_DIR)/examples
GNAT_SETUP   = $(SL_ADA_DIR)/internal/setgnatenv.sh

ifeq ($(GNAT_VER), )
  GNAT_VER=3.12a2
endif

ifeq ($(ARCH), win32)
TARGETS = $(TARGET_DIR)/ada_times_two.$(EXT) \
	  $(TARGET_DIR)/ada_multi_port.$(EXT) \
	  $(TARGET_DIR)/ada_matrix_gain.$(EXT) \
	  $(TARGET_DIR)/ada_simple_lookup.$(EXT)
endif
ifeq ($(ARCH), glnx86)
TARGETS = $(TARGET_DIR)/ada_times_two.$(EXT) \
	  $(TARGET_DIR)/ada_multi_port.$(EXT) \
	  $(TARGET_DIR)/ada_matrix_gain.$(EXT) \
	  $(TARGET_DIR)/ada_simple_lookup.$(EXT)
endif
ifeq ($(ARCH), sol2)
TARGETS = $(TARGET_DIR)/ada_times_two.$(EXT) \
	  $(TARGET_DIR)/ada_multi_port.$(EXT) \
	  $(TARGET_DIR)/ada_matrix_gain.$(EXT) \
	  $(TARGET_DIR)/ada_simple_lookup.$(EXT)
endif

CSF_FILES = $(addsuffix .csf, $(TARGETS))

TMP_DIRS := times_two_ada_sfcn_$(ARCH) \
            multi_port_ada_sfcn_$(ARCH) \
            matrix_gain_ada_sfcn_$(ARCH) \
            simple_lookup_ada_sfcn_$(ARCH)

ifdef ISPC
  TMP_DIRS := $(addprefix $(SL_ADA_DIR)/examples/, $(TMP_DIRS))
else
  TMP_DIRS := $(addprefix $(TARGET_DIR)/, $(TMP_DIRS))
endif

DEPENDS := $(MATLABROOT)/extern/include/mex.h                      \
	   $(MATLABROOT)/extern/include/matrix.h                   \
	   $(MATLABROOT)/extern/include/tmwtypes.h                 \
	   $(MATLABROOT)/extern/src/mexversion.c                   \
	   $(SL_ADA_DIR)/interface/simstruc.c                      \
	   $(MATLABROOT)/simulink/include/simstruc.h               \
           $(MATLABROOT)/simulink/include/simstruc_types.h         \
	   $(filter-out %~, $(wildcard $(SL_ADA_DIR)/interface/*)) \
	   $(wildcard $(SL_ADA_DIR)/lib/$(ARCH)/*)                 \
	   $(wildcard $(SL_ADA_DIR)/bin/$(ARCH)/*)

ifdef ISPC
  DEPENDS += $(MATLABROOT)/bin/mex.bat      \
	     $(MATLABROOT)/bin/$(ARCH)/mex.pl
else
  DEPENDS += $(MATLABROOT)/bin/mex
endif

all : $(TARGETS)

once :

$(TARGET_DIR)/ada_%.$(EXT) :
ifdef ISPC
	@echo "---> Rebuilding $@ because $? is newer"
	@echo ""
	$(MEX) $(MEXFLAGS) -v -ada $(EXAMPLES_DIR)/$*/$*.ads
	mv ada_$*.$(EXT) $@
	rm -rf $*_ada_sfcn_$(ARCH)
	@echo ""
else
	@cd $(TARGET_DIR);                                                     \
	if [ "$(ARCH)" = "sol2" -o "$(ARCH)" = "glnx86" ]; then                \
		echo "---> Rebuilding $@ because $? is newer";                 \
		GNAT_VER=$(GNAT_VER); . $(GNAT_SETUP);                         \
		echo "---> $(MEX) $(MEXFLAGS) -ada $(EXAMPLES_DIR)/$*/$*.ads"; \
		$(MEX) $(MEXFLAGS) -ada $(EXAMPLES_DIR)/$*/$*.ads;             \
		echo "---> $(MAPCSF) $@";                                      \
		$(MAPCSF) $@;                                                  \
		echo "";                                                       \
	else                                                                   \
		echo "Ada S-Function $@ is currently not build on $(ARCH)";    \
	fi
endif

#
# Dependencies
#

$(TARGETS) : $(MAKEFILE) $(DEPENDS)

$(TARGET_DIR)/ada_times_two.$(EXT)     : \
			$(wildcard $(SL_ADA_DIR)/examples/times_two/*.ads) \
			$(wildcard $(SL_ADA_DIR)/examples/times_two/*.adb)

$(TARGET_DIR)/ada_matrix_gain.$(EXT)   : \
			$(wildcard $(SL_ADA_DIR)/examples/matrix_gain/*.ads) \
			$(wildcard $(SL_ADA_DIR)/examples/matrix_gain/*.adb)

$(TARGET_DIR)/ada_multi_port.$(EXT)    : \
			$(wildcard $(SL_ADA_DIR)/examples/multi_port/*.ads) \
			$(wildcard $(SL_ADA_DIR)/examples/multi_port/*.adb)

$(TARGET_DIR)/ada_simple_lookup.$(EXT) : \
			$(wildcard $(SL_ADA_DIR)/examples/simple_lookup/*.ads) \
			$(wildcard $(SL_ADA_DIR)/examples/simple_lookup/*.adb)

clean:
ifdef ISPC
	rm -rf $(TARGETS) $(TMP_DIRS)
else
	/bin/rm -rf $(TARGETS) $(CSF_FILES) $(TMP_DIRS)
endif

# eof: examples.mk
