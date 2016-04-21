## Copyright 2003-2004 The MathWorks, Inc.
## $Revision: 1.1.6.4 $ $Date: 2004/04/12 23:40:31 $
##
## Makefile for dsp_rt module
##
## To run this makefile under Unix:
##	gmake all
##
## To run this makefile under Windows:
##	cygnusmake -I t:\adsp\matlab\makerules -f Makefile all
##

SHELL = bash
export SHELL

ifndef TOP_DIR
  TOP_DIR:=../../../../src
endif

ifndef TOP_DSPBLKS_DIR
  TOP_DSPBLKS_DIR:=../../../dspblks
endif

ifndef MWE_INSTALL
  MWE_INSTALL :=$(TOP_DIR)/..
endif

MAKEFILEINCLUDEPATH:=$(TOP_DIR)
MAKEFILEINCLUDEPATH+=$(MWE_INSTALL)/makerules
include extrules.gnu

SHARED  := 1
MODNAME := dsp_rt
MODDIRS := dspacf dspallpole dspbiquad dspburg dspchol dspcicfilter \
           dspconvcorr dspendian dspeph dspfbsub dspfft dspfilterbank \
           dspfir dspfirdn dspflip dspg711 dspgivensrot dsphist dspic \
           dspiir dspinterp dspintsignext dspisfinite dspldl dsplevdurb \
           dsplpc2cc dsplsp2poly dsplu dspmmult dsppad dsppinv dsppoly2lsf \
           dsppolyval dspqrdc dspqsrt dsprandsrc dsprc2ac dsprc2lpc dsprebuff \
           dspsvd dspunwrap dspupfir dspupfirdn dspvfdly dspwindow

#APPNAME := $(MODNAME)
EXPORTH := ./dsp_rt_exports.h
BINDIR   = $(MWE_INSTALL)/bin/$(ARCH)
OBJDIR   = $(TOP_DSPBLKS_DIR)/obj/rt/$(ARCH)

MYMAKEFILE = Makefile

EXPORTALL=1

ifeq ($(MAKECMDGOALS),all)
  QUICK := 1
endif

ifndef ISPC
include Makefile.module
endif

DEFSRCINC += -I. -I$(TOP_DSPBLKS_DIR)/include -I$(TOP_DSPBLKS_DIR)/fixpt/include -I$(MWE_INSTALL)/simulink/include 
CPPFLAGS += -DDSP_RT_EXPORTS -DMWDSP_DYNAMIC_RTLIBS \
            -D DSPIC_EXPORTS \
            -D DSPACF_EXPORTS \
            -D DSPALLPOLE_EXPORTS \
            -D DSPBIQUAD_EXPORTS \
            -D DSPBLMS_EXPORTS \
            -D DSPBURG_EXPORTS \
            -D DSPCHOL_EXPORTS \
            -D DSPCICFILTER_EXPORTS \
            -D DSPCONVCORR_EXPORTS \
            -D DSPENDIAN_EXPORTS \
            -D DSPEPH_EXPORTS \
            -D DSPFBSUB_EXPORTS \
            -D DSPFFT_EXPORTS \
            -D DSPFILTERBANK_EXPORTS \
            -D DSPFIR_EXPORTS \
            -D DSPFIRDN_EXPORTS \
            -D DSPFLIP_EXPORTS \
            -D DSPG711_EXPORTS \
            -D DSPGIVENSROT_EXPORTS \
            -D DSPHIST_EXPORTS \
            -D DSPIIR_EXPORTS \
            -D DSPINTERP_EXPORTS \
            -D DSPISFINITE_EXPORTS \
            -D DSPLDL_EXPORTS \
            -D DSPLEVDURB_EXPORTS \
            -D DSPLMS_EXPORTS \
            -D DSPLPC2CC_EXPORTS \
            -D DSPLSP2POLY_EXPORTS \
            -D DSPLU_EXPORTS \
            -D DSPMMULT_EXPORTS \
            -D DSPPAD_EXPORTS \
            -D DSPPINV_EXPORTS \
            -D DSPPOLY2LSF_EXPORTS \
            -D DSPPOLYVAL_EXPORTS \
            -D DSPQRDC_EXPORTS \
            -D DSPRANDSRC_EXPORTS \
            -D DSPRANDSRC64BIT_EXPORTS \
            -D DSPRANDSRC32BIT_EXPORTS \
            -D DSPRC2AC_EXPORTS \
            -D DSPRC2LPC_EXPORTS \
            -D DSPREBUFF_EXPORTS \
            -D DSPQSRT_EXPORTS \
            -D DSPSVD_EXPORTS \
            -D DSPUNWRAP_EXPORTS \
            -D DSPUPFIR_EXPORTS \
            -D DSPUPFIRDN_EXPORTS \
            -D DSPVFDLY_EXPORTS \
            -D DSPWINDOW_EXPORTS


# MOD_LDFLAGS = -L$(BINDIR) -lmw<othermodule>

ifeq ($(ARCH), sol2)
MOD_LDFLAGS += -lm
endif

# hack to keep dsp_rt_exports.h from screwing things up...
ifeq ($(ARCH), glnx86)
CXXFLAGS += -Ddsp_rt_exports_h
endif

ifdef USING_VSNET
VARS_SETUP = vsvars32
else
VARS_SETUP = vcvars32
endif

.PHONY: all init once

ifdef ISPC
all: init
	cmd /c "$(VARS_SETUP) & nmake $(NMAKE_FLAGS) /f dsp_rt.mak"
#	vcvars32 & nmake $(NMAKE_FLAGS) /f "dsp_rt.mak"

clean : 
	cmd /c "$(VARS_SETUP) & nmake $(NMAKE_FLAGS) /f dsp_rt.mak clean"
else
all: init $(MODNAME)
endif

once: headers

init:
ifdef ISPC
#	@echo arch is $(DIR_ARCH)
#	@echo dirnameis $(TOP_DIR)
	perl $(dir $(TOP_DIR))tools/nt/gen_modules.pl -mod ".=dsp_rt" -mak
endif

