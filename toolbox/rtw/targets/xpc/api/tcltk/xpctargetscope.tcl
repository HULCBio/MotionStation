# XPCTTARGETSCOPE.TCL  Demo GUI to add/control a target scope.  
#
#  XPCTTARGETSCOPE opens a small window with several TK widget.  These
#   widgets control the configuration of an xPC target scope.   During 
#   initialization, this procedure creates a target scope in slot 1 and adds
#   the signal name which is passed into this procedure.  If a scope already
#   exists in this position it is destroyed. 
#
#  To use this script with Demo xPC project:
#
#  1. Adjust this script to match the host-target communications parameters
#      of your system.  (See below). 
#  2. Load the xPC Demo project 'xpcosc' into the target:   See xpcload.tcl 
#  3. Start execution of target: See xpcstart.tcl
#  4. At a tcl or wish shell execute this procedure:
#    %source xpctargetscope.tcl
#    %xpctargetscope
# 
#  To use this script with any xpc project:
#  1. Adjust this script to match the host-target communications parameters
#      of your system.  (See below). 
#  2. Load the desired xPC project:   See xpcload.tcl 
#  3. Start execution of target: See xpcstart.tcl
#  4. At a tcl or wish shell pass the signal to be displayed
#    %source xpctargetscope.tcl
#    %xpctargetscope mysignal
#
#  COM Methods used
#
#    GetAppName (xPCTarget)
#    GetSignalName (xPCTarget)
#    GetNumSignals (xPCTarget)
#    RemScope (xPCScope)
#    TargetScopeGetYLimits (xPCScope)
#    ScopeAddSignal (xPCScope)
#    AddTargetScope (xPCScope)
#    RemScope (xPCScope)
#    ScopeStart (xPCScope)
#    ScopeStop (xPCScope)
#    TargetScopeSetYLimits  (xPCScope)
#    TargetScopeSetGrid (xPCScope)
#    TargetScopeGetGrid (xPCScope)
#    ScopeSetTriggerMode (xPCScope)
#

# Copyright 1996-2004 The MathWorks, Inc.
# $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:24:35 $

# This demo creates a Tk GUI, therefore we require the Tk package
package require Tk
# Load required xPC utility procedures such as xpctcpconnect and xpdshutdown
source xpcbase.tcl 

proc xpctargetscope { {signal  {Integrator1} } } {

	# These variables live in the global scope to avoid passing copies
	global target_obj protocol_obj  
	global scope_obj iscope

	# ADJUSTMENT REQUIRED !!
	# Please modify the IP address and port to reflect your configuration
	# OR replace with xpcrs232connect to use RS-232 host-target communications 
	# Initializes the COM interface and connects to the target (via tcp)
	xpctcpconnect {144.212.20.173} {22222}

	# Get name of loaded model (and make sure a model is available)
	set appname [$target_obj GetAppName]
	if {$appname == "loader"} {
		xpcshutdown
		error "No model loaded; Please load a model before using this script"
	}

	# Create and initialize the Scope object
	set scope_obj [::tcom::ref createobject -inproc {XpcapiCOM.xPCScopes}]
	if {[$scope_obj Init $protocol_obj] != 0} {
		xpcshutdown
		error "Failed to Initialize Scope Object"
	}
	
	# Add a new scope to slot 1 (iscope)
	# If a scope already exists at this position, delete it 
	# Scope slots are numbered from 1. (iscope = 1,2, ...)
	set iscope 1 
	set stat [$scope_obj AddTargetScope $iscope]
	if {$stat != -1 } {
		$scope_obj RemScope $iscope
		$scope_obj AddTargetScope $iscope
	}
	
	# Determine index of signal 
	set index -1
	set nsig [$target_obj GetNumSignals]
	for {set isig 0}  {$isig < $nsig} {incr isig} {
		set check [$target_obj GetSignalName $isig]
		if {$check == $signal }  {
			set index $isig
			break;
		}
	}
	if {$index == -1} {
		xpcshutdown
		error "The specified signal does not exist in the loaded xPC Model\n\
                              Signal Name =>  $signal "
	}

	# Add this signal to the Target Scope
	$scope_obj ScopeAddSignal $iscope $index
	global ltrigmode
	set ltrigmode {
            "Free Run" Software Signal Scope
	}


	# Create window to contain widget  (destroy any old versions, if it exists in the global scope)
	destroy .t
	toplevel .t
	wm title .t $appname

	# Create a scale widget and have it control the tunable parameter
	# referenced by 'index'.  The range of the slider is (arbitrarily) defined by
	# scaling the present value. 
	set ylimit [$scope_obj TargetScopeGetYLimits $iscope]
	set ymin  [lindex $ylimit 0]
	set ymax [lindex $ylimit 1]

	# Create a simple text description at the top of the GUI
	label  .t.label  -text  "Target Scope $iscope Control"
	pack .t.label -in .t -fill x -anchor w

	# Create a spinbox to control trigger mode of the target scope
	frame .t.ftrig -bd 4
	label  .t.ftrig.label -text "Trigger Mode "  -anchor w
	spinbox .t.ftrig.spinbox  -values $ltrigmode -width 10 \
              -command "scopemode %s"
	grid .t.ftrig.label -in .t.ftrig -column 0 
	grid .t.ftrig.spinbox -in .t.ftrig  -column 1 -row 0 -sticky ew
	grid columnconfigure .t.ftrig 1 -weight 1
	pack .t.ftrig -in .t -fill x -anchor w

	# Create button to display/hide target scope grid
	set gridon 1
	checkbutton .t.vgrid -text "Grid On" -variable gridon -relief flat \
		-command "scopegrid"
	pack .t.vgrid -in .t -anchor w
	 .t.vgrid select

	# Create entries for Y maximum and minimum and add buttons
	# to apply the changes or force autoscale mode.  
	frame .t.scale -bd 2 -relief groove

	label .t.lymax -text "Maximum Y" 
	entry .t.vymax -background white
	.t.vymax insert 0 [lindex $ylimit 1]
	label .t.lymin  -text "Minimum Y " 
	entry .t.vymin -background white
	.t.vymin insert 0 [lindex $ylimit 0]

	pack .t.lymax  .t.vymax  .t.lymin  .t.vymin -in .t.scale -anchor w -padx 2 -fill x
	#pack .t.vymax .t.vymin -in .t.scale -fill x 
	frame .t.scale.buttons -bd 4
         button  .t.scale.buttons.apply -text "Apply" -command "plotlimits" 
         button  .t.scale.buttons.auto -text "AutoScale" -command "autoscale"
	grid  .t.scale.buttons.apply -column 0  -padx 5 
	grid  .t.scale.buttons.auto  -column 1 -row 0 -padx 5

	pack  .t.scale.buttons  -in .t.scale -padx 5 -pady 2 -anchor w
	pack .t.scale -anchor w -fill x


	# Create a pair of start/stop buttons for the scope
	frame .t.exe -bd 6
         button  .t.exe.start -text "Start Scope" -command "startstopscope 1" 
         button  .t.exe.stop -text "Stop Scope" -command "startstopscope 0"
         button  .t.exe.quit -text "Quit" -command "destroy .t"
	grid  .t.exe.start -in .t.exe -column 0  -padx 5 -pady 2
	grid  .t.exe.stop -in  .t.exe -column 1 -row 0 -padx 5 -pady 2
	grid  .t.exe.quit -in  .t.exe -column 2 -row 0 -padx 5 -pady 2
	pack .t.exe -anchor w

	bind .t.vymax <KeyPress> "%W configure -background LightYellow"
	bind .t.vymin <KeyPress> "%W configure -background LightYellow"

	# Limit resizing to width
	wm resizable .t 1 0

	# Shutdown procedure - Terminate the connection then delete COM objects
	# Called in the scale destroy event
	bind .t.vgrid <Destroy>  {xpcshutdown}
}

# This callback is used to autocale the plot.  Autoscaling is implied by
# zeroing the Y maximum and y minimum parameters.
proc autoscale {} {
	global scope_obj iscope
	uplevel .t.vymax delete 0 end
	uplevel .t.vymax insert 0 0
	uplevel .t.vymin delete 0 end
	uplevel .t.vymin insert 0 0
	set ylimit {0 0}
	$scope_obj TargetScopeSetYLimits $iscope {ylimit}
	uplevel .t.vymax configure -background white
	uplevel .t.vymin configure -background white
}

# Callback to apply new limits to the target scope
proc plotlimits { } {
	global scope_obj iscope
	set ymax [uplevel .t.vymax get]
	set ymin  [uplevel .t.vymin get]
	set ylimit "$ymax $ymin"
	$scope_obj TargetScopeSetYLimits $iscope {ylimit}
	uplevel .t.vymax configure -background white
	uplevel .t.vymin configure -background white
}

# Callback to Start or Stop the target scope 
proc startstopscope {state} {
	global scope_obj iscope
	if {$state == 1} {
		 $scope_obj ScopeStart $iscope
	} else {
		$scope_obj ScopeStop $iscope
	}
}

# This callback is used change the scope mode
proc scopemode {state} {
	global scope_obj iscope	ltrigmode
	$scope_obj ScopeSetTriggerMode $iscope [lsearch $ltrigmode $state]
}


# This callback is used to turn on/off the scope grid
proc scopegrid {} {
	global scope_obj iscope gridon
	$scope_obj TargetScopeSetGrid $iscope $gridon
}

# [EOF] xpctargetscope.tcl 
