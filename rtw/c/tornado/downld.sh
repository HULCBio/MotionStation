#! /bin/sh
# Copyright 1994-2002 The MathWorks, Inc.
#
# File    : downld.sh   $Revision: 1.9 $
# Abstract:
#	For UNIX systems, start Target Server, load Stethoscope
#       libraries if required and download/start model on Tornado
#       target.
#
#	Usage: 
#	    downld.sh $WIND_BASE $WIND_HOST_TYPE $TARGET 
#                $TGTSVR_HOST $LIBPATH $PROGRAM $MODEL $STETHOSCOPE
#                $PROGRAM_OPTS $VX_CORE_LOC

if [ $# -ne 10 ]; then
    echo Usage:
    echo downld.sh WIND_BASE WIND_HOST_TYPE TARGET
    echo TGTSVR_HOST LIBPATH PROGRAM MODEL STETHOSCOPE
    echo PROGRAM_OPTS VX_CORE_LOC
    exit 1
fi

WIND_BASE=$1
WIND_HOST_TYPE=$2
TARGET=$3
TGTSVR_HOST=$4
LIBPATH=$5
PROGRAM=$6
MODEL=$7
STETHOSCOPE=$8
PROGRAM_OPTS=$9
shift
VX_CORE_LOC=$9

#echo Starting target server on host: $TGTSVR_HOST
#echo $WIND_BASE/host/$WIND_HOST_TYPE/bin/tgtsvr $TARGET -V -c $VX_CORE_LOC
#Start tgtsvr once by hand since invoking it here causes Matlab to block
#$WIND_BASE/host/$WIND_HOST_TYPE/bin/tgtsvr $TARGET -V -c $VX_CORE_LOC &
echo 'semGive(startStopSem)' | \
  $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
  -q $TARGET@$TGTSVR_HOST > /dev/null
if [ $STETHOSCOPE -eq 1 ]; then
  echo i | $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
       -q $TARGET@$TGTSVR_HOST | grep tScope > /dev/null
  if [ $? -ne 0 ]; then
    echo    Loading StethoScope run-time libraries
#
# Use the appropriate path to the StethoScope libraries based on your
# installation path for StethScope
#
#    echo ld'('1,0,\"$LIBPATH/libxdr.so\"')' | \
#         $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
#         -q $TARGET@$TGTSVR_HOST 
#    echo ld'('1,0,\"$LIBPATH/libutilsip.so\"')' | \
#	 $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
#         -q $TARGET@$TGTSVR_HOST 
#    echo ld'('1,0,\"$LIBPATH/libscope.so\"')' | \
#	 $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
#         -q $TARGET@$TGTSVR_HOST 
    echo ld'('1,0,\"/home/jcarrick/rti/rtilib.3.9h/lib/m68kVx5.4/libxdr.so\"')' | \
	 $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
         -q $TARGET@$TGTSVR_HOST 
    echo ld'('1,0,\"/home/jcarrick/rti/rtilib.3.9h/lib/m68kVx5.4/libutilsip.so\"')' | \
	 $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
         -q $TARGET@$TGTSVR_HOST 
    echo ld'('1,0,\"$LIBPATH/libscope.so\"')' | \
	 $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
	 -q $TARGET@$TGTSVR_HOST
  fi
fi
  
echo Loading and Starting Model: $PROGRAM $PROGRAM_OPTS
echo ld'('1,0,\"$PROGRAM\"');' sp'('rt_main,$MODEL,\"$PROGRAM_OPTS\",\"*\",0,-1,17725')' | \
     $WIND_BASE/host/$WIND_HOST_TYPE/bin/windsh \
     $TARGET@$TGTSVR_HOST
