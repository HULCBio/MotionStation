# Copyright 1994-2002 The MathWorks, Inc.
#
# File    : win_sub.pm   $Revision: 1.4 $
# Abstract:
#	
#    Perl module subroutines specific to windows used by the RTW build
#    process.
#
# $Revision: 1.4 $

package win_subs;

use strict;
use vars qw(@ISA @EXPORT);

require Exporter;

@ISA    = qw(Exporter);
@EXPORT = qw(SetupWinSysPath);


sub SetupWinSysPath {
    my $sysdir = &Win32::IsWinNT ? $ENV{SystemRoot} : $ENV{windir};
    my $sysdir2 = 
	&Win32::IsWinNT ? "$ENV{SystemRoot}\\SYSTEM32" : "$ENV{windir}\\SYSTEM";
    $ENV{PATH} = "$sysdir;$sysdir2;$ENV{PATH}";
}

