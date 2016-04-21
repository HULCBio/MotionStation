# XPCLISTS.TCL  Generate a list of target signals or parameters
#  XPCLISTS IP PORT - Creates a TK Listbox that is populated with the
#   names of all xPC target signals.  Specify the ip address and port to
#   match your target configuration.  
#  XPCLISTS IP  - Same as above, except PORT defaults to 22222.  
#  XPCLISTS IP PORT params  - Creates a TK Listbox that is populated with 
#   the names of all xPC target parameters.  Specify the ip address and 
#   port to match your target configuration.  
#
#  To use:
#
#  1. Load a model into xPC Target (see xpcload.tcl)
#  2. At a tcl or wish shell run:
#    %source xpclists.tcl
#    %xpclists 144.212.20.171 22222
# 
#  Options - This version produces a list block of all parameters
#    %xpclists  144.212.20.171 22222 params
#
#  COM Methods used
#
#    GetAppName (xPCTarget)
#    GetNumSignals (xPCTarget)
#    GetNumParams (xPCTarget)
#    GetSignalName (xPCTarget)
#    GetParamName (xPCTarget)
#

# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:29 $

# This demo creates GUIS using Tk, therefore require Tk package
package require Tk
# Load some useful xPC utility procedures such as xpctcpconnect and shutdown
source xpcbase.tcl 

proc xpclists { {ip 144.212.20.173} {port 22222} {type signals} } {

	# These always live in the global area to avoid making copies
	global target_obj protocol_obj  

	# Initialize the COM interface and connect to the target (via tcp)
	xpctcpconnect $ip $port

	# Get name of loaded model
	set appname [$target_obj GetAppName]
	if {$appname == "loader"} {
		xpcshutdown
		error "No model loaded; Please load a model before using this script"
	}

	# Create TK Listbox Widget
	destroy .mybase
	toplevel .mybase 
	wm title .mybase $appname
	if {$type == "signals"} {
		Scrolled_Listbox .mybase.slistbox Signals -width 30 -height 8
		pack .mybase.slistbox
		set numSignals [$target_obj GetNumSignals]
		for {set i 0} {$i < $numSignals} {incr i} {
			.mybase.slistbox.list insert end [$target_obj GetSignalName $i]
		}
	} elseif {$type == "params"} {
		Scrolled_Listbox .mybase.slistbox Parameters -width 30 -height 8
		pack .mybase.slistbox
		set numParams [$target_obj GetNumParams]
		for {set i 0} {$i < $numParams} {incr i} {
			.mybase.slistbox.list insert end [$target_obj GetParamName $i]
		}
	} else {
		destroy .mybase
		xpcshutdown
		error {xpclists options limited to "signals" or "params"}
	}
	# Shutdown procedure - Terminate the connection then delete COM objects
	xpcshutdown
}

# Useful listbox widget with automatic scrollbars
# Derived from a sample in "Practical Programming in Tcl and Tk" by Brent B. Welch
proc Scrolled_Listbox { f title args } {
	frame $f
	label $f.label -text $title
	grid $f.label -row 0 -column 0 -columnspan 2 -sticky n

	listbox $f.list \
		-xscrollcommand [list Scroll_Set $f.xscroll \
			[list grid $f.xscroll -row 2 -column 0 -sticky we]] \
		-yscrollcommand [list Scroll_Set $f.yscroll \
			[list grid $f.yscroll -row 1 -column 1 -sticky ns]]
	eval {$f.list configure} $args
	scrollbar $f.xscroll -orient horizontal \
		-command [list $f.list xview]
	scrollbar $f.yscroll -orient vertical \
		-command [list $f.list yview]
	grid $f.list -sticky news
	grid rowconfigure $f 1 -weight 1
	grid columnconfigure $f 0 -weight 1
	return $f.list
}

# Callback to implement scollbar changes
proc Scroll_Set {scrollbar geoCmd offset size} {
	if {$offset != 0.0 || $size != 1.0} {
		eval $geoCmd
	}
	$scrollbar set $offset $size
}

# [EOF] xpclists.tcl 

