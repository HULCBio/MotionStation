# Copyright 1994-2003 The MathWorks, Inc.
#
# File    : unixtools.mk   $Revision: 1.21.4.8 $
# Abstract:
#	Setup Unix tools for GNU make

ARCH := $(shell echo "$(COMPUTER)" | tr '[A-Z]' '[a-z]')


#
# Modify the following macros to reflect the tools you wish to use for
# compiling and linking your code.
#


DEFAULT_OPT_OPTS = -O
ANSI_OPTS        =
CPP              = c++
LD               = $(CC)
SYSLIBS          =
# Override based on platform if needed

ifeq ($(COMPUTER),GLNX86)
  CC  = gcc
  CPP = g++
  DEFAULT_OPT_OPTS = -O -ffloat-store -fPIC
  # These definitions are used by targets that have the WARN_ON_GLNX option
  GCC_WARN_OPTS     := -Wall -Wwrite-strings \
		       -Wstrict-prototypes -Wnested-externs -Wpointer-arith

  GCC_WARN_OPTS_MAX := -Wall -Wshadow \
                       -Wcast-qual -Wwrite-strings -Wstrict-prototypes \
                       -Wnested-externs -Wpointer-arith
endif

ifeq ($(COMPUTER),HPUX)
  CPP = aCC
  # the PA-RISC 2.0 compiler has optimization bugs, remove -O
  DEFAULT_OPT_OPTS = +z
  ANSI_OPTS = -Ae
endif

ifeq ($(COMPUTER),HP700)
  CPP = aCC
  # the PA-RISC 2.0 compiler has optimization bugs, remove -O
  DEFAULT_OPT_OPTS =
  # +DAportable for both PA-RISC 1.0 and PA-RISC 2.0 code
  ANSI_OPTS = -Ae +DAportable
endif

ifeq ($(COMPUTER),ALPHA)
  CPP = cxx
  ANSI_OPTS = -std1 -ieee
endif

# IBM_RS has optimization problems. Set default to no-optimization.
ifeq ($(COMPUTER),IBM_RS)
  CPP = /usr/vacpp/bin/xlC
  DEFAULT_OPT_OPTS =
  ANSI_OPTS = -qlanglvl=ansi
endif

ifeq ($(COMPUTER),SGI)
  CPP = CC
  ANSI_OPTS = -n32
  LD        = $(CC)
endif

ifeq ($(COMPUTER),SGI64)
  CPP = CC
  ANSI_OPTS = -64
  LD        = $(CC) -64
endif

ifeq ($(COMPUTER),SOL2)
# {accel_unix.tmf, rtwsfcn_unix.tmf} disable this optimization if 
# gcc has been selected as the MEX compiler (IS_MEX_GCC is non-empty)	
  ifeq ($(IS_MEX_GCC),)	
    CPP = CC -compat=5
    IS_SUN_CC_COMPILER = $(shell $(CC) -Version 2>&1 | grep WorkShop)
    ifneq ($(IS_SUN_CC_COMPILER),)
      DEFAULT_OPT_OPTS = -xO3 -dalign
    endif
  endif
endif

ifeq ($(COMPUTER),MAC)
  CC  = gcc-3.3
  CPP = g++-3.3
  ANSI_OPTS = -fno-common -no-cpp-precomp -fexceptions
endif

# To create a Quantify (from Rational) build,
# specify
#     QUANTIFY=1
# or
#     QUANTIFY=/path/to/quantify
#
# Note, may also need QUANTIFY_FLAGS=-cachedir=./q_cache
#
ifdef QUANTIFY
  ifeq ($(QUANTIFY),1)
    QUANTIFY_ROOT = /hub/$(ARCH)/apps/quantify
  else
    QUANTIFY_ROOT = $(QUANTIFY)
  endif

  INSTRUMENT_INCLUDES := -I$(QUANTIFY_ROOT)
  INSTRUMENT_LIBS     := $(QUANTIFY_ROOT)/quantify_stubs.a
  LD                  := quantify $(QUANTIFY_FLAGS) $(LD)
  OPT_OPTS            := -g
endif

# To create a Purify (from Rational) build, specify
#   PURIFY=1
#
ifeq ($(PURIFY),1)
  PURIFY_ROOT = /hub/$(ARCH)/apps/purify

  INSTRUMENT_INCLUDES := -I$(PURIFY_ROOT)

  ifeq ($(ARCH), sgi)
    INSTRUMENT_LIBS     := $(PURIFY_ROOT)/purify_stubs_n32.a
  else
    INSTRUMENT_LIBS     := $(PURIFY_ROOT)/purify_stubs.a
  endif

  CC       := purify $(CC)
  OPT_OPTS := -g
endif

# [eof] unixtools.mk
