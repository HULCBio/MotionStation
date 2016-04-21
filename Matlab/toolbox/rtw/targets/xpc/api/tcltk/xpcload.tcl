# XPCLOAD.TCL  Loads the xPC target with a model file
#  XPCLOAD MODEL   -  Load the specified MODEL file into the
#    xPC Target.  The user will need to modify the communications
#    parameters in this script to match their system (see below). The
#    model file extension (.dlm) is assumed and should not be included.
#
#  XPCLOAD - Same as above, except it loads the model 'xpcosc', which
#    is an xPC demo model.  Note, before downloading, the model must
#    be built for xPC.  
#
#  To Use:
#  1. Adjust the IP Address and Port number to match your target configuration.  
#     These must match the values that were defined in xpcsetup or xPC 
#      Target Explorer.  
#  2. In a Tcl or Wish shell execute the following:
#    %source xpcload.tcl
#    %xpcload "xpcosc"
# 
#  COM Methods used
#
#    LoadApp (xPCTarget)
#    GetxPCError (xPCTarget
#

# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:30 $

# Load some useful xPC utility procedures such as xpctcpconnect and shutdown
source xpcbase.tcl 

proc xpcload { {dlmfile xpcosc} } {

	# These always live in the global area to avoid making copies
	global target_obj protocol_obj  

	# Initialize the COM interface and connect to the target (via tcp)
	# Modify the ip address and port as needed
	# Replace with xpcrs232connect for RS-232 host-target communications 
	xpctcpconnect {144.212.20.173} {22222}

	# Initial load of model from from local directory
	if {[$target_obj LoadApp "." $dlmfile] != -1 } {
		set errmsg [$target_obj GetxPCError]
		xpcshutdown
		error "Failed to load model file : $dlmfile.dlm in [pwd]\nxPC error : $errmsg"
	}

	# Shutdown procedure - Terminate the connection then delete COM objects
	xpcshutdown
}

# [EOF] xpcload.tcl 






