# Copyright 1994-2004 The MathWorks, Inc.
#
# File    : scan_mexopts_for_env.pl   $Revision: 1.14.4.2 $
#
# Abstract:
#    Scan the default mexopts file for name of a compiler env variable
#    that specifies a template make file.
#
# Usage:
#       perl scan_mexopts_for_env.pl mexoptsfile
#

use strict;

my $mexoptsfile = $ARGV[0];

my $MsVcDirPat     = LocSetPattern("msvcdir",   ".*?");
my $MsDevDirPat    = LocSetPattern("msdevdir",  ".*?");
my $MsDevEnvDirPat = LocSetPattern("devenvdir", ".*?");
my $WatDirPat      = LocSetPattern("watcom",    ".*?");
my $BorDirPat      = LocSetPattern("borland",   ".*?");
my $LccDirPat      = LocSetPattern("compiler",  "lcc");
my $iclDirPat      = LocSetPattern("intel",     ".*?");

open(FILE, $mexoptsfile) || die "Error opening $mexoptsfile: $!\n";

my $tmfSuffix = "";
my $envVal    = "";
my $msvcdir  = "";

foreach my $line (<FILE>) {

    if ($line =~ /$iclDirPat/io) {
        $envVal = $1;
        $tmfSuffix = "_intel.tmf";
        last;

    } elsif ($line =~ /$MsVcDirPat/io) {
        $msvcdir=$1;
        $tmfSuffix = "_vc.tmf";

    } elsif ($line =~ /$MsDevDirPat/io) {

        $envVal = LocSubstMsVcDir($1, $msvcdir);

    } elsif ($line =~ /$MsDevEnvDirPat/io) {

        ($envVal = LocSubstMsVcDir($1, $msvcdir)) =~ s/tools$/IDE/i;
	last;

	# For some reason, mexopts.bat files define DevEnvDir as
	# %MSVCDir%\..\Common7\Tools, whereas a real installation has it as
	# %MSVCDir%\..\Common7\IDE, which is what we (RTW) expect, so we change
	# it with the s/// above.

    } elsif ($line =~ /$WatDirPat/io) {
        $envVal = $1;
        $tmfSuffix = "_watc.tmf";
        last;
    } elsif ($line =~ /$BorDirPat/io) {
        $envVal = $1;
        # Remove cbuilder3-6 for 5.3, 5.4, 5.5, and 5.6.
        $envVal =~ s/\\cbuilder3//i;
        $envVal =~ s/\\cbuilder4//i;
        $envVal =~ s/\\cbuilder5//i;
        $envVal =~ s/\\cbuilder6//i;
        $envVal =~ s/\\bcc55//i;
        $tmfSuffix = "_bc.tmf";
        last;
    } elsif ($line =~ /$LccDirPat/io) {
        $envVal = $1;
        $tmfSuffix = "_lcc.tmf";
        last;
    }
}
close(FILE);


print $tmfSuffix.'@'.$envVal.'@'.$msvcdir;
exit(0);

sub LocSetPattern {

    my ($iVarName, $iValPat) = @_;

    return '^\s*set\s+'.$iVarName.'\s*=\s*('.$iValPat.')\s*$';
}

sub LocSubstMsVcDir {

    my ($iMsDevDir, $iMsVcDir) = @_;

    my $oMsDevDir = $iMsDevDir;

    if ($iMsVcDir ne "") {

        $oMsDevDir =~ s/\%MSVCDir\%/$iMsVcDir/;
    }
    return $oMsDevDir;
}


#[eof] scan_mexopts_for_env.pl
