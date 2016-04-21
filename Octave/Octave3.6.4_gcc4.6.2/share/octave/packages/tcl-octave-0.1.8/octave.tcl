if { [string equal {} [package provide BLT]] } {
    error "octave requires BLT"
}

namespace eval octave {
    variable version 0.1
    variable home [file join [pwd] [file dirname [info script]]]
    variable DEFAULT_PORT 3132
    variable active_socket {}
    variable syncid 0

    variable stamp [clock clicks -millisecond]
}

#proc octave::tic {} { set octave::stamp [clock clicks -millisecond] }
#proc octave::toc {} { puts "dT=[expr {[clock clicks -millisecond]-$::octave::stamp}]" }

proc octave {action args} {
    switch -- $action {
	connect { eval octave::Open $args }
	default {
	    if { [llength $::octave::active_socket] } { 
		eval octave::Dispatch $::octave::active_socket $action $args
	    } else {
		error "octave $action: must open connection to octave first"
	    }
	}
    }
}

proc octave::Dispatch { f action args } {
    if { [llength [info commands ::octave::$action]] == 0 } {
	error "octave \"$action\" unexpected: use close|eval|sync|send|recv|console|capture|mfile"
    } else {
	return [::eval ::octave::$action $f $args]
    }
}


# octave_open ?host:?port ?-as command?
# open a new octave session on host:port, controlled by function octave
proc octave::Open { args } {

    # XXX FIXME XXX surely there is an options parser somewhere that I can use

    # parse -as command if it exists
    set usage "octave connect ?host:?port ?-as command?"
    set nargin [llength $args]
    if { $nargin == 0 } {
	set address {}
	set command {}
    } elseif { $nargin == 1 } {
	if { [string equal -as [lindex $args 0]] } {
	    error $usage
	}
	set address [lindex $args 0]
	set command {}
    } elseif { $nargin == 2 } {
	if { [string equal -as [lindex $args 0]] } {
	    set address {}
	    set command [lindex $args 1]
	} else {
	    error $usage
	}
    } elseif { $nargin == 3 } {
	if { [string equal -as [lindex $args 0]] } {
	    set address [lindex $args 2]
	    set command [lindex $args 1]
	} elseif { [string equal -as [lindex $args 1]] } {
	    set address [lindex $args 0]
	    set command [lindex $args 2]
	} else {
	    error $usage
	}
    } else {
	error $usage
    }


    # parse host:port
    set splitaddr [split $address :]
    if { [llength $splitaddr] == 0 } {
	set host ""
	set port ""
    } elseif { [llength $splitaddr] == 1 } {
	if { [string is integer $splitaddr] } {
	    set host ""
	    set port $splitaddr
	} else {
	    set host $splitaddr
	    set port ""
	}
    } elseif { [llength $splitaddr] == 2 } {
	foreach {host port} $splitaddr {}
    } else {
	error $usage
    }
    variable DEFAULT_PORT
    if { [string equal "" $host] } { set host localhost }
    if { [string equal {{}} $host] } { set host localhost }
    if { [string equal "" $port] } { set port $DEFAULT_PORT }
    # puts "host= $host, port= $port"

    # avoid stomping on active_socket
    variable active_socket
    if { [llength $command] == 0 \
	    && [llength $active_socket] > 0 } {
	error "octave connection exists --- use octave ?host -as command"
    }

    # open the port
    set ret [catch { socket $host $port } f]
    if { $ret } { error "$f $host:$port" }

    # use the socket handle as the array name for the state variables
    variable $f
    upvar 0 $f state

    # associate the command name with the socket
    set state(command) $command
    if { [llength $command] > 0 } {
	proc $command { {action ?} args } \
		"eval octave::Dispatch $f \$action \$args"
    } else {
	set active_socket $f
    }

    # prepare the socket for communication
    fconfigure $f -blocking true -buffering none -translation binary
    fileevent $f readable "octave::Recv $f"

    # set default timeout
    octave::timeout $f

    # setup the communication with octave, including determining the
    # endianish translation requirements.
    set state(swap) {}
    octave::eval $f { page_screen_output = 0; }
    blt::vector create ::octave_swap$f
    ::octave_swap$f set 1.0
    octave::eval $f "send('octave_swap$f',1.0);"

    # while waiting for sync, send the additional function definitions we need
    variable home
    mfile $f $home/tclphoto.m
    mfile $f $home/tclsend.m

    if { ![octave::sync $f] } {	octave::close $f }
    # if 1 != 1 it must be because the byte order got reversed.
    if { [set ::octave_swap${f}(0)] != 1.0 } { set state(swap) -swap }
    blt::vector delete ::octave_swap$f
}

# $ close
# close an octave connection and remove the associated command
proc octave::close { f } {
    # use the socket handle as the array name for the state variables
    variable $f
    upvar 0 $f state

    # close the connection
    ::close $f

    # if the connection is associated with a procedure, delete the 
    # procedure so nobody tries to use it
    if { [llength $state(command)] > 0 } {
	rename $state(command) ""
    }

    # stop any sync timers
    if { [info exists state(timer)] } { after cancel $state(timer) }

    # delete associated state info
    # Note that all sync threads are waiting on indices into $f, so
    # unsetting $f will trigger all the sync threads.
    unset $f

    # if f was the active socket, then clear the active socket
    variable active_socket
    if { $f == $active_socket } { set active_socket {} }
}

# $ timeout ?t ?query
# Set the timeout duration for sync operations.  If the duration is less 
# than or equal to 0 then there is no timeout.  If query is true, then
# the user will be informed when octave times out and given the option of
# waiting or cancelling.  Timeout defaults to 5s with user query after
# the timeout.
#
# XXX FIXME XXX it would be more idiomatic to use conf/cget
# XXX FIXME XXX users may want to control details of the query dialog
proc octave::timeout { f {timeout 5000} {query yes} } {
    # use the socket handle as the array name for the state variables
    variable $f
    upvar 0 $f state

    set state(timeout) $timeout
    set state(query) $query
}

# Syncronization is tricky.  In essence, we tell octave to touch
# a variable and wait on that variable.  However, we also want
# a timeout so that the user knows that octave is being slow to
# respond, and we want to be able to close the connection or
# cancel the current commands without subjecting the user to a 
# bunch of timeout messages.
#
# (1) We are going to ask octave signal tcl and have sync wait for 
# that signal.  The easiest way to do this is for tcl to wait on a
# variable and have octave touch that variable when it is done what 
# it is doing.  Now we want to add a timeout to the wait.  Again, 
# easy enough.  After timeout, just touch the variable that we are 
# waiting on a different way so that sync knows whether the variable 
# was set by timeout or by octave. Put the timeout in a loop and 
# ask the user each time whether they want to continue waiting.
#
# (2) After octave_sync is done how do we remove the sync variable
# we were waiting on?  vwait is just has happy to trigger when the
# variable is cleared as when the variable is set.  So start the
# variable with a value and clear it from octave.  Even if octave
# times out, the variable will still be cleared only when octave
# clears it.  By keeping the sync variable in the per-connection
# data array, the vwait will also be triggered when the connection
# is closed.
#
# (3) What if the sync variable is set from octave while we are 
# busy querying the user if they want to continue? Again our 
# clever trick of clearing the variable comes to our rescue: if
# it no longer exists after the query box it must be because octave 
# unset it, or the user cancelled the commands or closed the connection.
#
# (4) What if another callback wants to sync while we are waiting
# to timeout?  We only want one message box popping up, so we
# only want one timer.  Each time we sync on a new variable, we
# first check if there is a pending timeout and do nothing if there is.
# After the timer expires we start another one if there are any 
# syncs outstanding.
#
# To get full details, you will need to closely read octave:sync,
# octave::close, octave::cancel and octave::Start_timer.


proc octave::Start_timer { f } {
    error "Start_timer is broken --- do not use it"
    puts "entering Start_timer"

    # use the socket handle as the array name for the state variables
    variable $f
    upvar 0 $f state

    # don't do anything if there is no timeout
    if { $state(timeout) <= 0 } { return }

    # don't do anything if there is a timeout in progress.
    if { [info exists state(timer)] } { return }

    # don't do anything if there are no outstanding syncs
    set l [array names state sync*]
    if { [llength $l] == 0 } { return }

    # syncs are serially ordered, so a dictionary sort on the 
    # unresolved syncs grabs the next one
    set v [lindex [lsort -dictionary $l] 0]
    puts "Timing against $v"

    # clear the timer after $timeout so that vwait is triggered
    # Note: we don't delete it because we are using state(timer) to 
    # block other threads from Start_timer while timer/query is running.
    set state(timer) [ after $state(timeout) "set ::octave::${f}(timer) {}" ]
#    set state(timer) [ after $state(timeout) "set ::octave::${f}($v) -1" ]

    # wait for the timer
    puts "timer waiting for $v"
    vwait ::octave::${f}(timer)
#    vwait ::octave::${f}($v)
    puts "timer complete"

    # make sure the connection to octave is still alive
    if { ![info exists ::octave::$f] } { 
	# we are no longer in the timer/query --- let other threads enter
	unset state(timer)
	return 
    }

    # if the sync message we are waiting for hasn't arrived, then query
    # the user what to do
    if { [info exists state($v)] && [string is true $state(query)] } {

	set answer [tk_messageBox -icon question -default yes \
		-message "octave timed out\ncontinue waiting?" \
		-title "Octave timeout" -type yesno ]

	# we are no longer in the timer/query --- let other threads enter
	unset state(timer)

	# if the connection closed while querying, stop the timer
	if { ![info exists ::octave::$f] } { return }

	# if the user wishes to continue waiting then restart the timer
	# Note: it doesn't matter if the current sync completed because
	# we need to go on to the next one if it has and because 
	# Start_timer does nothing if there are no syncs outstanding
	if { [string equal $answer yes] } {
	    after 0 octave::Start_timer $f
	    return
	}
    } else {
	# we are no longer in the timer/query --- let other threads enter
	unset state(timer)
    }

    # if the sync message we are waiting for hasn't arrived, cancel
    # all pending syncs, otherwise restart the timer on the next sync
    if { [info exists state($v)] } {
	# note: cancel unsets the state variables
	octave::cancel $f
    } else {
	after 0 octave::Start_timer $f
    }
}

# $ cancel
# cancel the active commands
proc octave::cancel {f} {
    # XXX FIXME XXX how do we signal over a socket?
    foreach idx [array names ::octave::$f sync*] {
	array set ::octave::$f [list $idx -1]
    }
}


# Because the response time from octave is indeterminate, you do not want
# to generate a new octave eval each time you enter a callback.  Instead
# you only want to eval if there are no other evals outstanding.  Consider
# moving the mouse across a graph.   By the type the eval completes the
# mouse may be long gone.  You want to trigger the next eval from the 
# current position, skipping all the intermediate positions.  When the mouse
# finally stops moving, you want to make sure that the final position is
# also eval'ed.
#
# The procedure slow implements this.  Instead of invoking a callback
# directly, invoke it via slow and it will make sure that only one
# octave eval on that proc is active at a time.
proc octave::Slow { f proc args } {
    # use the socket handle as the array name for the state variables
    variable $f
    upvar 0 $f state

    if [info exists state(slow#$proc)] {
	set state(slow#$proc) $args
	# puts "caching $proc $args"
    } else {
	set state(slow#$proc) $args
	# puts "evaling $proc $args"
	::eval $proc $args
	while [octave::sync $f] { 
	    if [string equal $args $state(slow#$proc)] break
	    # puts "finished $proc $args, evaling $proc $args"
	    set args $state(slow#$proc)
	    ::eval $proc $args
	}
	array unset state slow#$proc
    }
}


# $ sync
# synchronize with octave, which is to say, make sure that all commands
# submitted up to this point have been processed.  Returns 0 if the
# connection closes unexpectedly or if octave times out before the
# variable is returned, otherwise it returns 1.  Use timeout
# to set the timeout duration and allow the user to query the timeout
# *** timeout not implemented ***
#
# $ sync proc args
# when doing callback using octave, you may need to make sure that only
# one instance of the callback is in use.  Normally the tcl event loop
# does this for you by combining all mouse move events but this only works
# when the callback completes before returning to the event loop.  Since 
# octave is executed asynchronously, we have to simulate this behaviour.
# If you call sync with a callback and some args, it will cache the most 
# recent version of args until octave is ready then invoke the callback.
proc octave::sync { f args } {
    if { [llength $args] > 0 } {
	::eval octave::Slow $f $args
    }

    variable syncid
    set v sync[incr syncid]
    array set ::octave::$f [list $v 1]
    octave::eval $f "send('array unset ::octave::$f $v');"
    vwait ::octave::${f}($v)
    if { ![info exists ::octave::$f] } { 
	# close connection
	return 0 
    } elseif { [info exists ::octave::${f}($v) ] } {
	# cancel pending
	array unset ::octave::$f $v
	return 0
    } else { 
	# successful sync
	return 1 
    }
}

# $ eval command_string
# evaluate the command_string in octave, but do not return anything
proc octave::eval {f cmd} {
    # puts "sending $cmd" ; tic
    puts -nonewline $f !!!x
    puts -nonewline $f [binary format I [string length $cmd]]
    puts -nonewline $f $cmd
}

# $ recv x v
proc octave::recv { f tclname {octaverhs {}} } {
    if { [string equal {} $octaverhs] } { set octaverhs $tclname }
    if { [llength [blt::vector names ::$tclname]] == 1 } {
	octave::eval $f "send('$tclname',$octaverhs);"
    } elseif { [lsearch [::image names] $tclname] >= 0 } {
	# XXX FIXME XXX can we avoid searching the entire image
	# list every time?
	octave::eval $f "tclphoto('$tclname',$octaverhs);"
    } else {
	octave::eval $f "tclsend('$tclname',$octaverhs);"
    }
}

# $ send x v
# Set the octave variable x with the value v.  If $v is the name of
# a BLT vector, the contents of that vector will be sent, otherwise
# value is assumed to be a list of numbers.
proc octave::send { f tclname {octavelhs {}} } {
    if { [string equal {} $octavelhs] } { set octavelhs $tclname }
    if { [llength [blt::vector names $tclname]] == 1 } {
	octave::eval $f "$octavelhs=sscanf('[set ${tclname}(:)]','%f ',Inf);"
    } else {
	error "can only send a blt vector"
    }
}

proc octave::image { f name expr } {
    octave::eval $f "tclphoto('$name',$expr);"
}

proc octave::mfile { f name } {
    set fid [::open $name r]
    octave::eval $f [::read $fid]
    ::close $fid
}

# $ console
# open up a new octave console window
proc octave::console {f} {
}

proc octave::capture {f expr} {
    # XXX FIXME XXX capture is not yet implemented
    octave::eval $f $expr
    return "<output capture not yet implemented>"
}

# this will be used by console to do tab completion
proc octave::Completion {f pos list} {
    if {[llength $list] == 1} {
	[lindex pos 0] replace [lindex pos 2] with $list 
    } else {
	[lindex pos 0] insert [eval concat $list]\n at [lindex pos 1]
    }
}
proc octave::Request_Completion {f hint pos} {
    octave::eval $f "t=completion_matches('$hint'); 
                     t=\[t,repmat(' ',rows(t),1)]'; 
                     send(\['octave::Completion $f $pos {',t(:),'}']);"
    sync $f
}

# receive a packet from octave
proc octave::Recv { file } {
    # toc

    variable $file
    upvar 0 $file state

    # puts "Entering Octave_recv"
    set head [read $file 8]
    set n [string length $head]
    while { $n < 8 } {
	if { [eof $file] } {
	    # XXX FIXME XXX tell user to use octave_restart or some such
	    # maybe restart automatically?  If so, need callback to
	    # reset octave state to what is expected.
	    puts "octave closed the connection."
	    octave::close $file
	    return
	}
	# puts "$state(command) grabbing next [expr 8-$n] bytes"
	set head "$head[read $file [expr 8-$n]]"
	set n [string length $head]
    }
    binary scan $head a4I cmd len
    switch -- $cmd {
	!!!e {
	    # puts "Error"
	    if { [info exists state(err)] } {
		# capture an octave error to a variable
		set ::$state(err) [read $file $len]
	    } else {
		# report an octave error
		puts "octave error $state(command):\n[read $file $len]"
	    }
	}
	!!!m {
	    # puts "Matrix"
	    # set blt vector from matrix
	    binary scan [read $file 12] III rows cols namelen
	    set name [read $file $namelen]
	    # puts "creating ${name}($rows,$cols)"
	    if { [string equal "" [blt::vector names ::$name]] } {
		blt::vector create ::$name
	    } else {
		::$name length 0
	    }
	    if { [expr $rows*$cols] > 0 } {
		::$name binread $file [expr $rows*$cols] $state(swap)
	    }
	}
	!!!s {
	    # puts "string"
	    # set tcl value from string
	    binary scan [read $file 8] II strlen namelen
	    set name [read $file $namelen]
	    set str [read $file $strlen]
	    set ::$name $str
	}
	!!!x {
	    # evaluate tcl command in global context
	    set body [read $file $len]
	    # puts "<send tcl>$body</send>"
	    if [catch { uplevel #0 $body } msg ] {
		# translate non-printables to ? before displaying
		# regsub -all "\[^\[:print:]]" $body ? body
		puts "octave tcl failed for <$body>\n$msg"
	    }
	    # puts "done <tcl>"
	}
	!!!I {
	    puts "shouldn't be in !!!I"
	    set val [read $file $len]
	    binary scan $val d
        }
	default {
	    if { [string equal [string range $cmd 0 2] !!!] } {
		puts "octave message unknown: \"$cmd\" length $len"
		read $file $len
	    } else {
		puts "octave communication failure: \"$cmd\"\nclosing octave $state(command)"
		octave::close $file
	    }
	}
    }
}

proc imagefromrgb { name w h rgb } {
    imagefromppm "P6 $w $h 255\n[binary format c[expr $w*$h*3] $rgb]"
}

# receive a ppm photo spec
# XXX FIXME XXX tcl core should let you set a ppm image directly from data!
proc imagefromppm { name data } {

    # try the easy way: load the data directly into the photo
    if { [catch { $name conf -format ppm -data $data }] } {

	# easy way failed (tcl too old?) so do it the hard way
	# by writing to a file
	
	# choose a temp directory
	switch $::tcl_platform(platform) {
	    unix {
		set tmpdir /tmp      ;# or even $::env(TMPDIR), at times.
	    } macintosh {
		set tmpdir $env(TRASH_FOLDER)  ;# a better place?
	    } default {
		set tmpdir [pwd]
		catch {set tmpdir $::env(TMP)}
		catch {set tmpdir $::env(TEMP)}
	    }
	}
	
	# generate a safe filename
	set file [file join $tmpdir tclphoto[pid].ppm]

	# create the file safely
	set access [list WRONLY CREAT EXCL TRUNC]
	set perm 0600
	if {[catch {open $file $access $perm} fid ]} {
	    # something went wrong
	    error "Could not open tempfile: $fid."
	} else {
	    fconfigure $fid -encoding binary  -eofchar {} -translation binary
	    # ok everything went well
	    puts -nonewline $fid $data
	    close $fid
	    $name read $file -format ppm -shrink
	    file delete $file
	}
    }
}

# From Richard Suchenwirth's "A Simple Package Example"
# on the tcl wiki
proc octave::? {} {lsort [info procs ::octave::*]}
# If execution comes this far, we have succeeded ;-)
package provide octave $octave::version

#--------------------------- Self-test code
if {[info exists argv0] && [file tail [info script]]==[file tail $argv0]} {
    puts "package octave contains [octave::?]"
    puts "Need some tests here!!!"
    
    # Simple index generator, if the directory contains only this package
    pkg_mkIndex -verbose [file dirname [info script]] [file tail [info script]]
}
