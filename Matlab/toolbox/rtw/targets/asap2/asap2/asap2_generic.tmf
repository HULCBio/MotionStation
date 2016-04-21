# Copyright 1994-2002 The MathWorks, Inc.
#
# File    : asap2_generic.tmf
#
# Abstract:
#	Real-Time Workshop template makefile used to create <model>.mk
#	file for ASAP2 target (not compiler-specific).
#
#	Note that this template is automatically customized by the Real-Time
#	Workshop build procedure to create "<model>.mk" which then is
#	passed to nmake to produce <model>.mak
#
#	The following defines can be used to modify the behavior of the build:
#    OPTS           - Additional user defines.
#    USER_SRCS      - Additional user sources, such as files needed by
#                     S-functions.
#    USER_INCLUDES  - Additional include paths
#                     (i.e. USER_INCLUDES="/I where-ever1 /I where-ever2")

#------------------------ Macros read by make_rtw -----------------------------
#
# The following macros are read by the Real-Time Workshop build procedure:
#
#  MAKECMD         - This is the command used to invoke the make utility
#  HOST            - What platform this template makefile is targeted for
#                    (i.e. PC or UNIX)
#  BUILD           - Invoke make from the Real-Time Workshop build procedure
#                    (yes/no)?
#  SYS_TARGET_FILE - Name of system target file.

MAKECMD         = nmake
HOST            = PC
BUILD           = no
SYS_TARGET_FILE = asap2.tlc

