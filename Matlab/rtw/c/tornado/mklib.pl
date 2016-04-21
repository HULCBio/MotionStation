# Copyright 1994-2002 The MathWorks, Inc.
#
# File    : mklib.pl   $Revision: 1.8 $
# Abstract:
#	Builds a library from all files in the rtw\c\libsrc directory
#	for PC hosted Tornado targets.
#
#	Usage: 
#	    perl mklib.pl <directory> <libraryName> <ar_cmd> <cc_cmd> <cflags>


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

if ($nargs < 5) {&Usage; exit(1);}

$dir    = $ARGV[0];
$lib    = $ARGV[1];
$ar     = $ARGV[2];
$cc     = $ARGV[3];
$cflags = $ARGV[4];


#-------------------------------#
# Load *.c files from directory #
#-------------------------------#

opendir(DIR,$dir) || die "Couldn't open $dir: $!\n";
@dirContents = readdir($dir,DIR);
closedir(DIR);

@cfiles = ();
foreach $file (@dirContents) {
   if ($file =~ /^.*\.[cC]$/) {
      $file =~ tr/A-Z/a-z/;
      push(@cfiles,"$dir" . "\\" . "$file");
   }
}


if ("@cfiles" eq "") {
    print "ERROR: no .c files found in $dir\n";
    exit(1);
}


#--------------------#
# Create the library #
#--------------------#

if (-e $lib) {
    system("del $lib");
}

foreach $file (@cfiles) {
    #
    # Compile
    #
    $cmd = "$cc $cflags $file";
    print "$cmd\n";
    system("$cmd");

    #
    # Add object to library
    #
    $ofile = $file;
    $ofile =~ s/.*\\//g;
    $ofile =~ s/\.[cC]/.o/g;
    $cmd = "$ar -r $lib $ofile";
    print "$cmd\n";
    system("$cmd");

    #
    # Delete object
    #
    system("del $ofile");
}

#------#
# Done #
#------#
exit(0);

#-------------------#
# Subroutine: Usage #
#-------------------#
sub Usage {
    print "mklib.pl <directory> <libraryName> <ar_cmd> <cc_cmd> <cflags>";
}

# EOF
