# XPCTUNE  TK Widget to tune a scalar xPC parameter
#  XPCTUNE {BLK PARAM} - opens a small window with a TK Scale widget.  
#   This widget is connected to a tunable xPC Parameter to provide direct 
#   control over the target.  The desired parameter name is specified as 
#   a Tcl List of the block name followed by the parameter name.  
#  XPCTUNE - Default procedure will a open scale widget attached to the 
#   xPC parameter {Gain1 Gain}.  This parameter exists in the xPC demo 
#   model: xpcosc.
#
#  To use this script with Demo xPC project: xpcosc
#  1. Adjust the IP address and port number to match your target configuration.  
#    These value must match the values that were defined in xpcsetup or 
#    xPC Target Explorer. 
#  2. Load the xPC Demo project 'xpcosc' into the target.  See xpcload.tcl 
#  3. Add and Start a target scope on signal 'Integrator1' See xpctargetscope.tcl
#  4. Start execution of target: See xpcstart.tcl
#  5. At a tcl or wish shell execute this procedure:
#    %source xpctune.tcl
#    %xpctune
#
#  To use this script with any xpc project:
#  1. Adjust the IP address and port number to match your target configuration.  
#    These value must match the values that were defined in xpcsetup or 
#    xPC Target Explorer. 
#  2. Load the desired xPC project.  See xpcload.tcl 
#  3. Start execution of target. See xpcstart.tcl
#  4. At a tcl or wish shell execute this procedure and pass the name of 
#    the block and parameter to be tuned as a list:
#    %source xpctune.tcl
#    %xpctune  {block param}
#
#  COM Methods used
#
#    GetAppName (xPCTarget)
#    GetNumParams (xPCTarget)
#    GetParamName (xPCTarget)
#    GetParam (xPCTarget)
#    SetParam (xPCTarget)
#     

# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:36 $

# This demo creates a Tk GUI, therefore we require the Tk package
package require Tk
# Load required xPC utility procedures such as xpctcpconnect and xpcshutdown
source xpcbase.tcl 

proc xpctune { {blkparam  {Gain1 Gain} } } {

	# These always live in the global area to avoid making copies
	global target_obj protocol_obj  
	global valueparam


	# ADJUSTMENT REQUIRED !!
	# Please modify the IP address and port to reflect your configuration
	# OR replace with xpcrs232connect to use RS-232 host-target communications 
	xpctcpconnect {144.212.20.173} {22222}

	# Get name of loaded model (and make sure a model is available)
	set appname [$target_obj GetAppName]
	if {$appname == "loader"} {
		xpcshutdown
		error "No model loaded; Please load a model before using this script"
	}

	# Check if specified block/param exists in the loaded target
	set index -1
	set nparam [$target_obj GetNumParams]
	for {set iparam 0}  {$iparam < $nparam} {incr iparam} {
		set check [$target_obj GetParamName $iparam ]
		if { [xpclistequal $check $blkparam ] } {
			set index $iparam
			break;
		}
	}
	if {$index == -1} {
		xpcshutdown
		error "The specified parameter does not exist in the loaded xPC Model\n\
                            Block => [lindex $blkparam 0]   Parameter =>  [lindex $blkparam 1] "
	}
	set nameparam [lindex [$target_obj GetParamName $index] 0]
	set nameblock [lindex [$target_obj GetParamName $index] 1]	
	set valueparam [$target_obj GetParam $index 1]

	# Create window to hold widget  (destroy old one if it exists)
	destroy .t
	toplevel .t
	wm title .t $appname
	
	# Create a scale widget and have it control the tunable parameter
	# referenced by 'index'.  The range of the slider is (arbitrarily) defined by
	# scaling the present value of the parameter
	label  .t.label -text "$nameblock : $nameparam"
	scale  .t.scale		-showvalue 1 	-orient horizontal  -length 180\
		-variable valueparam \
		-to [expr $valueparam * 2] \
                   -from [expr $valueparam / 2]  \
		-command  "tunecommand $index"

	# Use pack geometry procedures to place the widgets within the window	
	pack .t.label -fill x
	pack .t.scale -fill x

	# Shutdown procedure - Terminate the connection then delete COM objects
	# Shutdown is perfrmed in when the .t.scale widget is destroyed.
	bind .t.scale <Destroy>  {xpcshutdown}
}

# This callback is used to convert movement of the scale widget into
#  xPC Target parameter changes. 
proc tunecommand {index newval} {
	global target_obj
	$target_obj SetParam $index newval
}

# [EOF] xpctune.tcl 
