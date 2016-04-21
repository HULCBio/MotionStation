# Copyright 1994-2002 The MathWorks, Inc.
#
# File    : mkvc_lnk.pl   $Revision: 1.5.4.1 $
#
# Abstract:
#      Script to parse a string such of the form "one.obj two.obj
#      c:\mysrc\three.obj four.obj" and write out the string ("one.obj two.obj
#      three.obj four.obj") containing only the base names to a command file.
#      This command file is passed to the Microsoft link utility (also see
#      grt_vc.tmf). 
#
#    Usage:
#      	perl mkvc_lnk.pl cmdfile one.obj two.obj c:\mysrc\three.obj four.obj 
#

$filename = shift @ARGV;
open(filehndl,">$filename") || die "Error creating file $filename: $!\n";
grep(do { @tmp=split(/\\/,$_); print filehndl "$tmp[$#tmp]\n"; }, @ARGV);
close(filehndl);
exit(0);
