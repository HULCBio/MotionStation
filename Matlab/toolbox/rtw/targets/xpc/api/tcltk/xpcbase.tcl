# XPCBASE.TCL  Collection of Tcl/TK procedures used by other xPC demos.
#  
# Utility Procedures
#  1. xpctcpconnect ip ?port? - Connect to an xPC Target via TCP using the
#   specified ip address and port number (default = 22222).  If successful, 
#   this procedure creates two COM objects in the global scope: protocol_obj 
#   and target_obj.  These objects have methods and properties that can
#   be used to control an xPC Target.  
#
#  2. xpcrs232connect ?com? ?baud? - Connect to an xPC Target via RS-232
#   using the specified com port and baud rate.  By default, xpcrs232connect
#   will connect to the target on com port 1 at 115.2 kBaud.   If successful, 
#   this procedure creates two COM objects in the global scope: protocol_obj 
#   and target_obj.  These objects have methods and properties that can
#   be used to control an xPC Target.  
#
#  3. xpcshutdown - Clean shutdown of the xPC Target connection.  This 
#   procedure should always be used to destroy the COM objects that
#   encapsulate the target interface (target_obj and protocol_obj).  If this
#   procedure it not used, it is possible to leave the connection in a bad
#   state, which would require restarting the Tcl shell.  
#
#  4. xpclistequal - Utility function which compares two lists.
#
#  COM Methods used
#
#    Init (xPCProtocol)
#    TcpIpConnect (xPCProtocol)
#    RS232Connect (xPCProtocol)
#    Close (xPCProtocol)
#    Term (xPCProtocol) 
#    Init (xPCTarget) 
#
#
# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:28 $

# The "tcom" package is required to access the COM API exposed by xPC
package require tcom 3.8

#--------------------------------------------------------------------------
#  xpctcpconnect - Initialize the connect to an xPC Target using TCP/IP for 
#   host to target communications.   This function deposits two COM objects
#   in the global scope: protocol_obj and target_obj.  After successful 
#   execution of this procedure, the generated object can then be used to 
#   control the xPC Target.  After 
#
#  xpctcpconnect  ip ?port?
#    ip = IP Address of the Target (required) 
#    port = socket port used to comunicate with target (must match value 
#      defined by xpcsetup or xPC Target explorer).  Port has a 
#      default: 22222.
#
proc xpctcpconnect {ip {port 22222} } {
	global protocol_obj target_obj

# Extract an xPC protocol Object from the COM interface
	set protocol_obj [::tcom::ref createobject -inproc {XpcapiCOM.xPCProtocol}]


# Error check on the generated xPCProtocol object to ensure library was loaded properly
	if {[$protocol_obj Init ] < 0} {
		unset protocol_obj
		error "Failed to initialize xPC COM interface.\n Verify that a copy of xpcapi.dll resides is in this directory :\n [pwd]"
	}

# Attempt to connect to target using xPCProtocol::TcpIpConnect and check status
	if {[$protocol_obj TcpIpConnect $ip $port] != -1} {
		xpcshutdown
		error "Failed to connect to target  $ip:$port"
	}

# Extract an xPC Target Object from the COM interface and attach Protocol object
	set target_obj [::tcom::ref createobject -inproc {XpcapiCOM.xPCTarget}]

# Error check on the generated xPCTarget object to ensure library was loaded properly
	if {[$target_obj Init $protocol_obj] != 0} {
		xpcshutdown
		error "Failed to Initialize Target  $ip:$port"
	}

# Just a friendly reminder of which target we are addressing
	puts stdout "Connected to Target  $ip:$port"
}
#---------------------------------------------------------------------------
#  xpcrs232connect - Initialize the connect to an xPC target using RS-232 
#   for host to target communications.   This function deposits two COM 
#   objects in the global scope:  protocol_obj and target_obj.  These object 
#   can then be used to control the xPC target.
#
#  xpcrs232connect  ?port? ?baud?
#    port = Host Com port to use: COM1 (0) or COM2 (1)
#    baud = Baud rate of connecction: 115200, 57600, etc. 
#
proc xpcrs232connect {{port com1}  {baud 115200}} {
	global protocol_obj target_obj

# Check for valid baud option
	set valid_bauds {115200 57600 38400 19200 9600 4800 2400 1200}
	if { [lsearch $valid_bauds $baud]  < 0 } {

		error "The baud rate is limited to $valid_bauds"
	}
# Check for valid port option
	set valid_com {com1 com2}
	set nport [lsearch $valid_com $port]
	if { $nport  < 0 } {
		error "The Com port is limited to com1 or com2"
	}
	

# Extract an xPC protocol Object from the COM interface
	set protocol_obj [::tcom::ref createobject -inproc {XpcapiCOM.xPCProtocol}]

# Error check on the generated xPCProtocol object to ensure library was loaded properly
	if {[$protocol_obj Init ] < 0} {
		unset protocol_obj
		error "Failed TO initialize Protocol - verify the xpcapi.dll file is installed locally"
	}

# Attempt to connect to target using xPCProtocol::TcpIpConnect and check status
	if {[$protocol_obj RS232Connect $nport $baud] != -1} {
		xpcshutdown
		error "Failed to Connect to Target through COM$port : Baud Rate = $baud"
	}

# Extract an xPC protocol Object from the COM interface
	set target_obj [::tcom::ref createobject -inproc {XpcapiCOM.xPCTarget}]

# Error check on the generated xPCTarget object to ensure library was loaded properly
	if {[$target_obj Init $protocol_obj] != 0} {
		xpcshutdown
		error "Failed to Initialize Target through COM$port : Baud Rate = $baud"
	}

# Just a friendly reminder of which target we are addressing
	puts stdout "Connected to Target COM$port : Baud Rate = $baud"

}

#--------------------------------------------------------
# xpcshutdown - Clean shutdown of connection to the target.  Note, this 
#   routine is the complement to xpctcpconnect and xpcrs232connect.  It 
#   closes the communications channels and cleans up the COM objects.  This 
#   procedure should always be used to preform a clean shutdown, otherwise 
#   it would be necessary to close your Tcl session to re-establish a 
#   target connection.  
#
proc xpcshutdown {} {
	global target_obj protocol_obj  

	# Close is necessary for RS-232 cleanup
	$protocol_obj Close
	$protocol_obj Term
	if {[info exists target_obj]}  {
		unset target_obj
	}
	unset protocol_obj
	puts stdout "Connected to Target was shutdown"
}

#---------------------------------------------------------
# xpclistequal - Compares two lists and returns 1 if they are identical and 
#  0 if they are not.  This is a utility function that does a deep 
#  comparision of two lists.  To be true, both lists must have identical 
#  members and identical ordering.  
proc xpclistequal {a b} {
	if {[llength $a] != [llength $b]} {
		return 0
	}
	for {set i 0} {$i < [llength $a]} {incr i} {
		if {[lindex $a $i ] != [lindex $b $i ] } {
			return 0;
		}
	}
	return 1;
}

# [EOF] xpcbase.tcl 
