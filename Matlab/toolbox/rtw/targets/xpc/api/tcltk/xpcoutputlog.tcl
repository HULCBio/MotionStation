# XPCOUTPUTLOG.TCL   Read Log data from target and plot
#     XPCOUTPUTLOG  - Generates a TK plot of the most recent 100 data points
#      in the target log from the first entry in the data log.  It uses the Canvas 
#     widget to produce the plot.  The target must be halted to read the log.
#
#     XPCOUTPUTLOG I - Same as above, except it plots entry I in the
#     data log (I is from 0 to N-1)
#
#  To use:
#  1. Adjust the IP Address and Port number to match your target configuration.  
#     These parameters must match the values that were defined in xpcsetup or 
#     xPC Target Explorer.  
#  2. Load your target model and execute it.  (It is possible to use the xPC Demo
#      model xpcosc as a suitable model).  Be sure to terminate target execution.  
#      These steps can be performed with Tcl scripts, see xpcload.tcl, xpcstart.tcl 
#      and xpcstop.tcl.
#  3. At a Tcl or Wish shell execute the following:
#    %source xpcoutputlog.tcl
#    %xpcoutputlog  0 
#    
#  COM Methods used
#
#    NumLogSamples (xPCTarget)
#    GetOutputLog (xPCTarget) 
#    GetNumOutputs (xPCTarget) 
#    NumLogWraps (xPCTarget) 
#    GetxPCError(xPCTarget)
#    GetAppName(xPCTarget)
#

# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:31 $

# This demo creates GUIS using Tk, therefore require Tk package
package require Tk
# This demo requires Tcllib Math package to compute max/min values
package require math::statistics
# Load some useful xPC utility procedures such as xpctcpconnect and shutdown
source xpcbase.tcl 

proc xpcoutputlog { {ioutput 0} } {

	# These always live in the global area to avoid making copies
	global target_obj protocol_obj  

	# Number of points to be plotted.  (should be less than 300 to fit on plot)
	set npts  100

	# Initialize the COM interface and connect to the target (via tcp)
	# Modify the IP address and port as needed
	# Change to xpcrs232connect to use RS-232 host-target communications 
	xpctcpconnect {144.212.20.173} {22222}

	# Check if log index is valid
	if {$ioutput >= [$target_obj GetNumOutputs]} {
		xpcshutdown
		error "The Target Log does contain an ouptut entry at index $ioutput "
	}

	# Check if specified output index is valid 
	set nsamps [$target_obj NumLogSamples]
	if {$nsamps == -1 } {
		set errmsg [$target_obj GetxPCError]
		xpcshutdown
		error "Failed to retreive the number of samples in the output log =>  $errmsg"
	} elseif {  $nsamps < $npts }  {
		xpcshutdown
		error  "Number of samples in the output log  ($nsamps) is less than required points: $npts "
	}
	
	# Check for data wrap 
	if {[$target_obj NumLogWraps] > 0} {
		puts stdout "Warning, Data Log has overflowed and wrapped [$target_obj NumLogWraps] times" 
	}

	# Grab log data and check for correct size
	# This requires an index (ioutput) that indicates which signal to grab
	set startpt [expr $nsamps - $npts]
	set logdat [$target_obj GetOutputLog $startpt $npts 1 $ioutput ]
	if {[llength $logdat] != $npts } {
		set errmsg [$target_obj GetxPCError]
		xpcshutdown
		error "Failed to retreive $npts samps in the output log =>  $errmsg"
	}

	# Get Name of loaded model (and make sure a model is available)
	set appname [$target_obj GetAppName]
	if {$appname == "loader"} {
		xpcshutdown
		error "NO model loaded; Please load a model before using this script"
	}

	# Create window to hold widget  (destroy old one if it exists)
	destroy .t
	toplevel .t
	wm title .t $appname

	label .t.msg -font {Helvetica 12} -wraplength 4i -justify left -text "Plot of values from the output log "
	pack .t.msg -side top

	frame .t.buttons
	pack .t.buttons -side bottom -fill x -pady 2m
	button .t.buttons.dismiss -text Close -command "destroy .t"
	pack .t.buttons.dismiss -side left -expand 1

	canvas .t.c -relief raised -width 450 -height 300
	pack .t.c -side top -fill x

	set plotFont {Helvetica 16}

	.t.c create line 100 250 400 250 -width 2
	.t.c create line 100 250 100 50 -width 2
	.t.c create text 225 20 -text "Output Log #$ioutput - $npts Points" -font $plotFont -fill brown

	for {set i 0} {$i <= 10} {incr i} {
 	  set x [expr {100 + ($i*30)}]
  	  .t.c create line $x 250 $x 245 -width 2
   	  .t.c create text $x 254 -text [expr {10*$i}] -anchor n -font $plotFont
	}

	set ymax [::math::statistics::max $logdat]
	set ymin [::math::statistics::min $logdat]
    	.t.c  create text 96 250 -text [format {%.5g} $ymin] -anchor e -font $plotFont
	.t.c  create line 100 50 105 50 -width 2
    	.t.c  create text 96 50 -text [format {%.5g} $ymax] -anchor e -font $plotFont

	# Plot data using cavas lines
	set i 0
	set ix [expr 300.0 / $npts]
	set yslope [expr {200.0/ ($ymin - $ymax) }]
	set yinter [expr {50.0 - $yslope *$ymax}]
	set x [expr {100 + round( $i * $ix)}]
	set y [expr { round ($yslope * [lindex $logdat  0] + $yinter)}]
          foreach dat $logdat {
	  set nx [expr {100 + round( $i * $ix)}]
  	  set ny [expr { round ($yslope * $dat + $yinter)}]
	  .t.c create line $x $y $nx $ny -fill blue -width 2
	  set x $nx
	  set y $ny
	  incr i
	}

	# Shutdown procedure - Terminate the connection then delete COM objects
	xpcshutdown
}

# [EOF] xpcoutputlog.tcl 
