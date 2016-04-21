################################################################################
#
#  File    : gnat_unix.mk                                     $Revision: 1.6.4.2 $
#  Abstract:
#       Makefile to buid Ada S-Functions on Unix platforms using the GNAT
#       Ada 95 complier. This makefile assumes that the GNAT compiler has
#       been installed correctly and is visible on the path. In addition,
#       this makefile requires the  following variables to  be defined on
#       the command line in order to work properly:
#
#       MATLAB_ROOT =
#       ARCH        =
#       MEX_EXT     =
#       ADA_SFCN    =
#       GNAT_VER    =
#
#       Optionally, you may also specify:
#
#       DEBUG       :
#       VERBOSE     :
#       OUTPUT_DIR  :
#       GCC_VERSION :
#       INCLUDES    :
#
#  Author  : Murali Yeddanapudi, 14-Jul-1999
#
#  Copyright 1990-2003 The MathWorks, Inc.
#
################################################################################


################################################################################
# Directories

ADA_SFCN_DIR = $(shell cd $(dir $(ADA_SFCN)); pwd)
ADA_SFCN_SRC = $(basename $(notdir $(ADA_SFCN)))

ifeq ($(OUTPUT_DIR), )
  OUTPUT_DIR = $(shell pwd)
endif
OUT_DIR      = $(OUTPUT_DIR)/$(ADA_SFCN_SRC)_ada_sfcn_$(ARCH)

SL_ADA_DIR   = $(MATLAB_ROOT)/simulink/ada

ifneq ($(INCLUDES),)
  INC1 = $(subst -I,,$(INCLUDES))
  INC2 = $(foreach inc,$(INC1),$(shell cd $(inc); pwd))
  INCDIRS = $(addprefix -I,$(INC2))
endif


################################################################################
# Tools

MEX      = $(MATLAB_ROOT)/bin/mex
GET_DEFS = $(SL_ADA_DIR)/bin/$(ARCH)/get_defines


################################################################################
# List of required source files

ADA_SFCN_ADB = $(ADA_SFCN_DIR)/$(ADA_SFCN_SRC).adb
ADA_SFCN_ADS = $(ADA_SFCN_DIR)/$(ADA_SFCN_SRC).ads

MEX_VER_SRC  = $(MATLAB_ROOT)/extern/src/mexversion.c
SL_ADA_ENTRY = $(SL_ADA_DIR)/interface/sl_ada_entry.c

SL_MEX_API = $(SL_ADA_ENTRY)                                    \
	       $(SL_ADA_DIR)/interface/simstruc.c                 \
	       $(MATLAB_ROOT)/extern/include/mex.h                \
	       $(MATLAB_ROOT)/extern/include/matrix.h             \
	       $(MATLAB_ROOT)/extern/include/tmwtypes.h           \
	       $(MATLAB_ROOT)/simulink/include/simstruc.h         \
               $(MATLAB_ROOT)/simulink/include/simstruc_types.h

################################################################################
# List of required object files

ADA_SFCN_ALI     = $(OUT_DIR)/$(ADA_SFCN_SRC).ali
ADA_SFCN_BND     = $(OUT_DIR)/b_$(ADA_SFCN_SRC).c
ADA_SFCN_BND_OBJ = $(OUT_DIR)/b_$(ADA_SFCN_SRC).o

MEX_VER_OBJ      = $(OUT_DIR)/mexversion.o
SL_ADA_ENTRY_OBJ = $(OUT_DIR)/sl_ada_entry.o
SL_GLUE_OBJS     = $(SL_ADA_ENTRY_OBJ) $(MEX_VER_OBJ)


################################################################################
# Flags

GCC_FLAGS = -Wall -fPIC
ifeq ($(DEBUG), 1)
  GCC_FLAGS += -g
else
  GCC_FLAGS += -O2
endif
ifneq ($(GCC_VERSION), )
  GCC_FLAGS += -V $(GCC_VERSION)
endif

ifeq ($(DEL_OUT_DIR), )
  ifeq ($(DEBUG), 1)
    DEL_OUT_DIR = 0
  else
    DEL_OUT_DIR = 1
  endif
endif

BINDER_FLAGS = -n -C

LINK_FLAGS = -shared -nostartfiles
ifeq ($(VERBOSE), 1)
  LINK_FLAGS += -v
endif
ifeq ($(ARCH), sol2)
  MAPFILE     = $(MATLAB_ROOT)/extern/lib/$(ARCH)/mexFunction.map
  LINK_FLAGS += -Wl,-M,$(MAPFILE)
endif
ifeq ($(ARCH), glnx86)
  MAPFILE     = $(MATLAB_ROOT)/extern/lib/$(ARCH)/mexFunction.map
#  LINK_FLAGS += -Wl,--version-script,$(MAPFILE),-Bsymbolic
  LINK_FLAGS += -Wl,--version-script,$(MAPFILE)
endif

LINK_LIBS = -L$(SL_ADA_DIR)/lib/$(ARCH) -lgnat_pic

SL_DEFS      = $(shell $(GET_DEFS) $(ADA_SFCN_ADS))
SFCN_NAME    = $(shell $(GET_DEFS) $(ADA_SFCN_ADS) 0)
TARGET       = $(OUTPUT_DIR)/$(SFCN_NAME).$(MEX_EXT)

SL_REQ_INCL  = -I$(MATLAB_ROOT)/extern/include \
               -I$(MATLAB_ROOT)/simulink/include \
	       -I$(SL_ADA_DIR)/interface
SL_GCC_FLAGS = $(GCC_FLAGS) $(SL_DEFS) -DMATLAB_MEX_FILE $(SL_REQ_INCL)

GNATGCC = $(dir $(shell which gnatmake))gcc

################################################################################
# Rules

all : $(TARGET)

#
# Invoke gcc to link
#
$(TARGET) : $(ADA_SFCN_ALI) $(ADA_SFCN_BND_OBJ)  $(SL_GLUE_OBJS)
	@echo "### Linking $@"
	@obj=`ls -1 $(OUT_DIR)/*.o | paste -s -d" " -`;                    \
	if [ "$(VERBOSE)" = "1" ]; then                                    \
		echo " ";                                                  \
		echo "     $(GNATGCC) -o $@ $(LINK_FLAGS) $$obj $(LINK_LIBS)"; \
		echo " ";                                                  \
	fi;                                                                \
	$(GNATGCC) -o $@ $(LINK_FLAGS) $$obj $(LINK_LIBS);                 \
	if [ $$? -eq 0 ]; then                                             \
		if [ "$(DEL_OUT_DIR)" = "1" ]; then                        \
			echo "### Deleting directory $(OUT_DIR)";          \
			\rm -rf $(OUT_DIR);                                \
		fi;                                                        \
	fi
	@echo "### Built mex-file '$@' for Ada S-function $(ADA_SFCN)"
#
# Complie the Ada code
#
$(ADA_SFCN_ALI) :
	@if [ ! -d $(OUT_DIR) ]; then \
		echo "### Creating directory $(OUT_DIR)"; \
		mkdir -p $(OUT_DIR); \
	fi
	@echo "### Compiling $(ADA_SFCN_ADB)"
	@if [ "$(VERBOSE)" = "1" ]; then \
		echo " "; \
		echo "    cd $(OUT_DIR); " \
			"gnatmake -a -c -f -q --GCC=$(GNATGCC) " \
			"-aI$(SL_ADA_DIR)/interface $(INCDIRS) " \
			"$(ADA_SFCN_ADB) -cargs $(GCC_FLAGS)"; \
		echo " "; \
	fi
	@cd $(OUT_DIR); \
	gnatmake -a -c -f -q --GCC=$(GNATGCC) -aI$(SL_ADA_DIR)/interface \
		$(INCDIRS) $(ADA_SFCN_ADB) -cargs $(GCC_FLAGS)
#
# Compile the binder output file
#
$(ADA_SFCN_BND_OBJ) : $(ADA_SFCN_BND)
	@echo "### Compiling $<"
	@cflags=`echo $(GCC_FLAGS) | sed -e 's/-Wall//g'`; \
	if [ "$(VERBOSE)" = "1" ]; then \
		echo " "; \
		echo "    $(GNATGCC) -o $@ -c $$cflags $<"; \
		echo " "; \
	fi; \
	$(GNATGCC) -o $@ -c $$cflags $<
#
# Generate Ada initialization and finalization code
#
$(ADA_SFCN_BND) : $(ADA_SFCN_ALI)
	@echo "### Generating binder file $@"
	@if [ "$(VERBOSE)" = "1" ]; then \
		echo " "; \
		echo "    cd $(OUT_DIR); gnatbind -o $@ $(BINDER_FLAGS) $< "; \
		echo " "; \
	fi
	@cd $(OUT_DIR); \
	gnatbind -o $@ $(BINDER_FLAGS) $<
#
# Compile the Ada S-Function's entry point
#
$(SL_ADA_ENTRY_OBJ) : $(ADA_SFCN_ADS) $(SL_MEX_API)
	@echo "### Compiling $(SL_ADA_ENTRY)"
	@if [ "$(VERBOSE)" = "1" ]; then \
		echo " "; \
		echo "    $(GNATGCC) -o $@ -c $(SL_GCC_FLAGS) $(SL_ADA_ENTRY)"; \
		echo " "; \
	fi
	@$(GNATGCC) -o $@ -c $(SL_GCC_FLAGS) $(SL_ADA_ENTRY)
#
# Compile mexversion.c
#
$(MEX_VER_OBJ) : $(MEX_VER_SRC)
	@echo "### Compiling $<"
	@if [ "$(VERBOSE)" = "1" ]; then \
		echo " "; \
		echo "    $(GNATGCC) -o $@ -c $(SL_GCC_FLAGS) $<"; \
		echo " "; \
	fi
	@$(GNATGCC) -o $@ -c $(SL_GCC_FLAGS) $<

#eof: gnat_unix.mk
