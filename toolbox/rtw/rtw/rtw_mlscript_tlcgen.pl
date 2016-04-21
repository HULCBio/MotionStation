#!/usr/local/bin/perl
#
#  File    : rtw_mlscript_tlcgen.pl
#  Abstract:
#    Converts M-code to TLC-code for RTW code generation

# Copyright 1994-2002 The MathWorks, Inc.
# $Revision: 1.3 $

use strict;


my $tmpFile       = $ARGV[0];
my $scriptFcnName = $ARGV[1];

#-----------------------------#
# Load original file contents #
#-----------------------------#
open(FILE, $tmpFile) || die "error reading $tmpFile: $!\n";
my @fileContents = <FILE>;
close(FILE);


#-----------------------
#  Setup tokens mapping
#    u => %<u> or %<u>[i] when "%rtw: u=>%<u>[i]" line exists in script
#    y => %<y> or %<y>[i] when "%rtw: y=>%<y>[i]" line exists in script
#
#    %rtw: C-code. C-code is explicitly placed in the file.
#-----------------------
my $uMap = "%<u>";    # Assume scalar
my $yMap = "%<y>";    # Assume scalar

my @newContents = ();
foreach my $line (@fileContents) {
    if ($line =~ /^%rtw: (\w+)=>(.*)/) {
	if ($1 eq "u") {
	    $uMap = $2;
	} elsif ($1 eq "y") {
	    $yMap = $2;
	}
    } else {
	push(@newContents,$line);
    }    
}

@fileContents = @newContents;

my %tokens = ();

$tokens{"u"} 	  = "$uMap";
$tokens{"y"} 	  = "$yMap";

$tokens{"%rtw: "} = "";


#-------------------------------------------------#
# Update the file contents my mapping the tokens. #
#-------------------------------------------------#

my $fileContents = join("",@fileContents);

foreach my $token (keys(%tokens)) {
    my $replacement = $tokens{$token};
    if ($token =~ /^[0-9a-zA-Z_]+$/) {
	$fileContents =~ s/\b$token\b/$replacement/g;
    } else {
	$fileContents =~ s/$token/$replacement/g;
    }
}

@fileContents = split(/\n/,$fileContents);


#-----------------------#
# Generate the new file #
#-----------------------#

open(FILE,">$tmpFile") || die "error creating $tmpFile: $!\n";

print FILE "\n\n%function $scriptFcnName(block, system) Output\n";

print FILE "  %%\n  {\n";

if ($uMap eq "%<u>") {
    print FILE "  %assign u = LibBlockInputSignal(0, \"\", \"\", 0)\n";
} else {
    print FILE 
	"  const real_T *u = %<LibBlockInputSignalAddr(0, \"\", \"\", 0)>;\n";
    print FILE "  %assign u = \"u\"\n";
}
if ($yMap eq "%<y>") {
    print FILE "  %assign y = LibBlockOutputSignal(0, \"\", \"\", 0)\n";
} else {
    print FILE "  real_T *y = %<LibBlockOutputSignalAddr(0, \"\", \"\", 0)>;\n";
    print FILE "  %assign y = \"y\"\n";
}


foreach my $line (@fileContents) {
    print FILE "    $line\n";
}
print FILE "  }\n";

print FILE "%endfunction\n";

close(FILE);


exit(0);

# [eof] rtw_mlscript_tlcgen.pl
