# XPCSTART.TCL  Start target, then check execution status
#  XPCSTART STOPTIME SAMPTIME - Start the xPC target execution.  STOPTIME
#   will be used as the model stop time.  SAMPTIME will configure the model 
#   sample time.  After waiting for 1/2 second, this script will check 
#   the target status and print information on the command line about the 
#   target.  For example, the model name, execution time (so far), Minimum
#   and Maximum TET times.
#  
#  XPCSTART - Same as above, except stop and sample time are not altered.
#
#  To use:
#  1. Adjust the IP address and port number to match your target configuration.  
#     These value must match the values that were defined in xpcsetup or 
#     xPC Target Explorer.  
#  2. Load a target model (See xpcload)
#  2. At a Tcl or Wish shell execute the following:
#    %source xpcstart.tcl
#    %xpcstart 
#  Optionally, you can supply stop time and sample time parameters
#   %xpcstart 10 0.01
# 
#  COM Methods used
#    IsAppRunning(xPCTarget)
#    MinimumTET (xPCTarget)
#    MaximumTET (xPCTarget)
#    StartApp (xPCTarget)
#    SetStopTime (xPCTarget) 
#    SetSampleTime (xPCTarget) 
#    GetxPCError (xPCTarget)
#    GetAppName (xPCTarget)
#

# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:32 $

# Load some useful xPC utility procedures such as xpctcpconnect and shutdown
source xpcbase.tcl 

proc xpcstart { {stoptime default} {samptime default} } {

	# These always live in the global area to avoid making copies
	global target_obj protocol_obj  

	# Initialize the COM interface and connect to the target (via tcp)
	# Modify the ip address and port as needed
	# Replace with xpcrs232connect for RS-232 host-target communications 
	xpctcpconnect {144.212.20.173} {22222}

	# Check for a valid Appliction 
	if { [$target_obj GetAppName] == "loader"} {
		xpcshutdown
		error "Need a loaded model to start it, please load your target model"
	}

	# Configure Target Sample time, if a new value has been passed in
	if { $samptime != "default" } {
		if {[$target_obj SetSampleTime $samptime ] != -1 } {
			set errmsg [$target_obj GetxPCError]
			xpcshutdown
			error "Failed to set Sample Time to $samptime\nxPC error : $errmsg"
		}
	}

	# Configure Target Stop time, if a new value has been passed in
	if { $stoptime != "default" } {
		if {[$target_obj SetStopTime $stoptime ] != -1 } {
			set errmsg [$target_obj GetxPCError]
			xpcshutdown
			error "Failed to set Stop Time to $stoptime\nxPC error : $errmsg"
		}
	}
	
	# Start Application ...
	if {[$target_obj StartApp] != -1 } {
		set errmsg [$target_obj GetxPCError]
		xpcshutdown
		error "Failed to start Application\nxPC error : $errmsg"
	}
	
	# Wait for 1/2 second and then check status
	after 500 

	# Retreive Execution time information and display at the console
	if {[$target_obj IsAppRunning] != 0} {
		puts stdout "Model '[$target_obj GetAppName]' is still running"
	} else {
		puts stdout "Model '[$target_obj GetAppName]' has stopped"
	}
	puts stdout "Execution time so far (sec) = [$target_obj GetExecTime]"

	# Retreive TET information form the Target and display at the console
	set tetarr [$target_obj MinimumTET]
	puts stdout "Minimum TET (sec) = [lindex $tetarr 0] occured at [lindex $tetarr 1]"
	set tetarr [$target_obj MaximumTET]
	puts stdout "Maximum TET (sec) = [lindex $tetarr 0] occured at [lindex $tetarr 1]"

	# Shutdown procedure - Terminate the connection then delete COM objects
	xpcshutdown
}

# [EOF] xpcstart.tcl 
