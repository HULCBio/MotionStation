# Copyright 1994-2002 The MathWorks, Inc.
#
# File    : downld.pl   $Revision: 1.12 $
# Abstract:
#	For Windows platforms, start Target Server, load Stethoscope
#       libraries if required and download/start model on Tornado 
#       target.
#
#	Usage: 
#	    perl downld.pl $WIND_BASE $WIND_HOST_TYPE $TARGET 
#                $TGTSVR_HOST $LIBPATH $PROGRAM $MODEL $STETHOSCOPE
#                $PROGRAM_OPTS $VX_CORE_LOC

#------------------------------------------------#
# Setup path for Win32 to get at system commands #
#------------------------------------------------#

BEGIN {
    my ($scriptDir) = ($0 =~ /(.+)[\\\/]/);
    push(@INC, "$scriptDir/../tools");
} 

use win_subs;

SetupWinSysPath();

#-------------#
# Check usage #
#-------------#

$nargs = $#ARGV + 1;

#ARGV + 1;

#printf("\nnargs=$nargs\n");
#printf("\n\n-------args-----------\n");
#foreach $i (0 .. $#ARGV) {
#    printf("$ARGV[$i]\n");
#}
#printf("\n");

if ($nargs != 10) {&Usage; exit(1);}

$WIND_BASE      = $ARGV[0];
$WIND_HOST_TYPE = $ARGV[1];
$TARGET         = $ARGV[2];
$TGTSVR_HOST    = $ARGV[3];
$LIBPATH        = $ARGV[4];
$PROGRAM        = $ARGV[5];
$MODEL          = $ARGV[6];
$STETHOSCOPE    = $ARGV[7];
$PROGRAM_OPTS   = $ARGV[8];
$VX_CORE_LOC    = $ARGV[9];

#---------#
# Do work #
#---------#
#$string = "    Starting target server on host: $TGTSVR_HOST\n";
#print $string;

#if ($ENV{OS} eq "Windows_NT") {
#    $cmd = "\"start /min /D$WIND_BASE\" $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\tgtsvr $TARGET -V -c $VX_CORE_LOC";
#    system $cmd;
#} else {
#    $cmd = "start /min $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\tgtsvr $TARGET";
#    system $cmd;
#}

$cmd = `echo semGive(startStopSem) |$WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
#@_ = split /Wind River Systems, Inc./, $cmd; 
#print @_;

if ($STETHOSCOPE == 1) {
    $cmd = `echo i | $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
#    @_ = split /Wind River Systems, Inc./, $cmd; 
#    print @_[1];
    if (!($cmd =~ /tScope/)) {
	print "    Loading StethoScope run-time libraries\n";
#
# Use the appropriate path to the StethoScope libraries based on your
# installation path for StethScope
#
#	$cmd = `echo ld(1,0,"$LIBPATH/libxdr.so") | $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
#	@_ = split /Wind River Systems, Inc./, $cmd; 
#	print @_[1];
#	$cmd = `echo ld(1,0,"$LIBPATH/libutilsip.so") | $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
#	@_ = split /Wind River Systems, Inc./, $cmd; 
#	print @_[1];
#	$cmd = `echo ld(1,0,"$LIBPATH/libscope.so") | $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
#	@_ = split /Wind River Systems, Inc./, $cmd; 
#	print @_[1];
	$cmd = `echo ld(1,0,"d:/rti/rtilib.3.9h/lib/m68kVx5.4/libxdr.so") | $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
	@_ = split /Wind River Systems, Inc./, $cmd; 
	print @_[1];
	$cmd = `echo ld(1,0,"d:/rti/rtilib.3.9h/lib/m68kVx5.4/libutilsip.so") | $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
	@_ = split /Wind River Systems, Inc./, $cmd; 
	print @_[1];
	$cmd = `echo ld(1,0,"$LIBPATH/libscope.so") | $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
	@_ = split /Wind River Systems, Inc./, $cmd; 
	print @_[1];
    }
}

print "    Loading and Starting Model: $PROGRAM $PROGRAM_OPTS\n";
$cmd =`echo ld(1,0,"$PROGRAM");sp(rt_main,$MODEL,"$PROGRAM_OPTS","*",0,-1,17725)| $WIND_BASE\\host\\$WIND_HOST_TYPE\\bin\\windsh $TARGET\@$TGTSVR_HOST`;
@_ = split /Wind River Systems, Inc./, $cmd; 
print @_[1];

#------#
# Done #
#------#
exit(0);

#-------------------#
# Subroutine: Usage #
#-------------------#
sub Usage {
    printf "Usage:\n";
    print "perl downld.pl WIND_BASE WIND_HOST_TYPE TARGET TGTSVR_HOST LIBPATH PROGRAM MODEL STETHOSCOPE PROGRAM_OPTS VX_CORE_LOC\n";
}

# EOF
