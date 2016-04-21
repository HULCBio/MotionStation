# XPCSTOP.TCL  Halt execution of the xPC Target
#  XPCSTOP - Will stop model execution of an xPC Target.  
#
#  To use:
#  1. Adjust the IP address and port number to match your target configuration.  
#     These value must match the values that were defined in xpcsetup or 
#     xPC Target Explorer.   
#  2. Load a target model,  see xpcload.tcl
#  2. At a Tcl or Wish shell execute the following:
#    %source xpcstart.tcl
#    %xpcstart 
# 
#  COM Methods used
#
#    StopApp (xPCTarget)
#    GetxPCError (xPCTarget)
#
# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:33 $

# Load some useful xPC utility procedures such as xpctcpconnect and shutdown
source xpcbase.tcl 

proc xpcstop {} {

	# These always live in the global area to avoid making copies
	global target_obj protocol_obj  

	# Initialize the COM interface and connect to the target (via tcp)
	# Modify the ip address and port as needed
	# Replace with xpcrs232connect for RS-232 host-target communications 
	xpctcpconnect {144.212.20.173} {22222}

	# Start Application ...
	if {[$target_obj StopApp] != -1 } {
		set errmsg [$target_obj GetxPCError]
		xpcshutdown
		error "Failed to stop application\nxPC error : $errmsg"
	}
	
	# Shutdown procedure - Terminate the connection then delete COM objects
	xpcshutdown
}

# [EOF] xpcstop.tcl 
