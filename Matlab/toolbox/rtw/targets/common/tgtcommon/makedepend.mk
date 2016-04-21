# File: toolbox/rtw/targets/common/tgtcommon
#
# Abstract:
#   Makefile utility file for defining makedepend tool
#
# Notes:
# 	Include this makefile in your own makefile. Ensure that
# 	the environment variable MATLABROOT has been defined first.
# 	The tool also assumes the existence of an INCLUDES variable
# 	which explains to the tool where to find the header files.
#
# 	INCLUDES must be of the form
#
# 	INCLUDES = -Ic:/a/b -Id:/f/x -I../b/c
#
#
#
# 	In your rules for source compilation do the following tailored
# 	to your build process of course
#
# 	include $(MATLABROOT)/toolbox/rtw/targets/common/tgtcommon/makedepend.mk
#
# 	%.o : %.c
# 		$(MAKEDEPEND)
# 		$(CC) $< -o $@
#
#   #########################
#
#	See the directory mkdeptest for a full example
# 

# $Revision: 1.1.8.2 $
# $Date: 2004/04/19 01:21:57 $
#
# Copyright 2002-2004 The MathWorks, Inc.

# Include all the prebuilt dependency files
-include dependencies.mk

ifndef MATLABROOT
	$(error Variable MATLABROOT must be defined before including this makefile)
endif

# Locate perl
__PERL__	= $(MATLABROOT)/sys/perl/win32/bin/perl.exe

# Define the MAKEDEPEND command
define MAKEDEPEND 
	$(__PERL__) $(MATLABROOT)/toolbox/rtw/targets/common/tgtcommon/makedepend.pl $(INCLUDES) $< $@
endef

# The following code ensures that whenever makedepend.mk is included in a makefile
# and the clean target is invoked the dependencies.mk file is removed.
clean : makedepend_clean

.PHONY : makedepend_clean
makedepend_clean :
	$(RM) dependencies.mk
