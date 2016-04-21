# XPCTARGETPING  Check connection for presence of xPC target 
#   XPCTARGETPING IP PORT - Pings an xPC target at IP, using socket number
#    PORT.  IP and PORT should match your settings in xpcsetup or 
#    xPC Target Explorer.  
#
#  To use:
#  1. At a tcl or wish shell run (replace IP address and port)
#    % source xpctargetping.tcl
#    % xpctargetping 144.212.20.173 22222
# 
# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:34 $


# Load some useful xPC utility procedures such as xpctcpconnect and xpcshutdown
source xpcbase.tcl 

proc xpctargetping { {ip 144.212.20.173} {port 22222}} {

	# These always live in the global area to avoid making copies
	global target_obj protocol_obj  

	# Initialize the COM interface and connect to the target (via tcp)
	#  Modify the IP address and port as needed
	xpctcpconnect $ip $port

	# Ping the Target and check results
	if { [$protocol_obj TargetPing] != 1}  {
		xpcshutdown
		error "Failed to Ping the Target Target $ip:$port - Check network connection"
	}
	puts stdout "Ping to The Target $ip:$port was a success!"
	# Note - Ping disconnects the target (shutdown required in this case)

	# Shutdown procedure - Terminate the connection then delete COM objects
	xpcshutdown
}

# [EOF] xpctargetping.tcl 
