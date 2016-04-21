package Cwd;
require 5.000;

=head1 NAME

getcwd - get pathname of current working directory

=head1 SYNOPSIS

    use Cwd;
    $dir = cwd;

    use Cwd;
    $dir = getcwd;

    use Cwd;
    $dir = fastgetcwd;

    use Cwd 'chdir';
    chdir "/tmp";
    print $ENV{'PWD'};

    use Cwd 'abs_path';
    print abs_path($ENV{'PWD'});

    use Cwd 'fast_abs_path';
    print fast_abs_path($ENV{'PWD'});

=head1 DESCRIPTION

The getcwd() function re-implements the getcwd(3) (or getwd(3)) functions
in Perl.

The abs_path() function takes a single argument and returns the
absolute pathname for that argument. It uses the same algorithm as
getcwd(). (actually getcwd() is abs_path("."))

The fastcwd() function looks the same as getcwd(), but runs faster.
It's also more dangerous because it might conceivably chdir() you out
of a directory that it can't chdir() you back into.  If fastcwd
encounters a problem it will return undef but will probably leave you
in a different directory.  For a measure of extra security, if
everything appears to have worked, the fastcwd() function will check
that it leaves you in the same directory that it started in. If it has
changed it will C<die> with the message "Unstable directory path,
current directory changed unexpectedly". That should never happen.

The fast_abs_path() function looks the same as abs_path(), but runs faster.
And like fastcwd() is more dangerous.

The cwd() function looks the same as getcwd and fastgetcwd but is
implemented using the most natural and safe form for the current
architecture. For most systems it is identical to `pwd` (but without
the trailing line terminator).

It is recommended that cwd (or another *cwd() function) is used in
I<all> code to ensure portability.

If you ask to override your chdir() built-in function, then your PWD
environment variable will be kept up to date.  (See
L<perlsub/Overriding Builtin Functions>.) Note that it will only be
kept up to date if all packages which use chdir import it from Cwd.

=cut

## use strict;

use Carp;

$VERSION = '2.01';

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(cwd getcwd fastcwd fastgetcwd);
@EXPORT_OK = qw(chdir abs_path fast_abs_path);


# The 'natural and safe form' for UNIX (pwd may be setuid root)

sub _backtick_pwd {
    my $cwd;
    chop($cwd = `pwd`);
    $cwd;
}

# Since some ports may predefine cwd internally (e.g., NT)
# we take care not to override an existing definition for cwd().

*cwd = \&_backtick_pwd unless defined &cwd;


# By Brandon S. Allbery
#
# Usage: $cwd = getcwd();

sub getcwd
{
    abs_path('.');
}

# By John Bazik
#
# Usage: $cwd = &fastcwd;
#
# This is a faster version of getcwd.  It's also more dangerous because
# you might chdir out of a directory that you can't chdir back into.
    
# List of metachars taken from do_exec() in doio.c
my $quoted_shell_meta = quotemeta('$&*(){}[]";\\|?<>~`'."'\n");

sub fastcwd {
    my($odev, $oino, $cdev, $cino, $tdev, $tino);
    my(@path, $path);
    local(*DIR);

    my($orig_cdev, $orig_cino) = stat('.');
    ($cdev, $cino) = ($orig_cdev, $orig_cino);
    for (;;) {
	my $direntry;
	($odev, $oino) = ($cdev, $cino);
	CORE::chdir('..') || return undef;
	($cdev, $cino) = stat('.');
	last if $odev == $cdev && $oino == $cino;
	opendir(DIR, '.') || return undef;
	for (;;) {
	    $direntry = readdir(DIR);
	    last unless defined $direntry;
	    next if $direntry eq '.';
	    next if $direntry eq '..';

	    ($tdev, $tino) = lstat($direntry);
	    last unless $tdev != $odev || $tino != $oino;
	}
	closedir(DIR);
	return undef unless defined $direntry; # should never happen
	unshift(@path, $direntry);
    }
    $path = '/' . join('/', @path);
    # At this point $path may be tainted (if tainting) and chdir would fail.
    # To be more useful we untaint it then check that we landed where we started.
    $path = $1 if $path =~ /^(.*)$/;	# untaint
    CORE::chdir($path) || return undef;
    ($cdev, $cino) = stat('.');
    die "Unstable directory path, current directory changed unexpectedly"
	if $cdev != $orig_cdev || $cino != $orig_cino;
    $path;
}


# Keeps track of current working directory in PWD environment var
# Usage:
#	use Cwd 'chdir';
#	chdir $newdir;

my $chdir_init = 0;

sub chdir_init {
    if ($ENV{'PWD'} and $^O ne 'os2' and $^O ne 'dos') {
	my($dd,$di) = stat('.');
	my($pd,$pi) = stat($ENV{'PWD'});
	if (!defined $dd or !defined $pd or $di != $pi or $dd != $pd) {
	    $ENV{'PWD'} = cwd();
	}
    }
    else {
	$ENV{'PWD'} = cwd();
    }
    # Strip an automounter prefix (where /tmp_mnt/foo/bar == /foo/bar)
    if ($ENV{'PWD'} =~ m|(/[^/]+(/[^/]+/[^/]+))(.*)|) {
	my($pd,$pi) = stat($2);
	my($dd,$di) = stat($1);
	if (defined $pd and defined $dd and $di == $pi and $dd == $pd) {
	    $ENV{'PWD'}="$2$3";
	}
    }
    $chdir_init = 1;
}

sub chdir {
    my $newdir = shift || '';	# allow for no arg (chdir to HOME dir)
    $newdir =~ s|///*|/|g;
    chdir_init() unless $chdir_init;
    return 0 unless CORE::chdir $newdir;
    if ($^O eq 'VMS') { return $ENV{'PWD'} = $ENV{'DEFAULT'} }

    if ($newdir =~ m#^/#) {
	$ENV{'PWD'} = $newdir;
    } else {
	my @curdir = split(m#/#,$ENV{'PWD'});
	@curdir = ('') unless @curdir;
	my $component;
	foreach $component (split(m#/#, $newdir)) {
	    next if $component eq '.';
	    pop(@curdir),next if $component eq '..';
	    push(@curdir,$component);
	}
	$ENV{'PWD'} = join('/',@curdir) || '/';
    }
    1;
}

# Taken from Cwd.pm It is really getcwd with an optional
# parameter instead of '.'
#

sub abs_path
{
    my $start = @_ ? shift : '.';
    my($dotdots, $cwd, @pst, @cst, $dir, @tst);

    unless (@cst = stat( $start ))
    {
	carp "stat($start): $!";
	return '';
    }
    $cwd = '';
    $dotdots = $start;
    do
    {
	$dotdots .= '/..';
	@pst = @cst;
	unless (opendir(PARENT, $dotdots))
	{
	    carp "opendir($dotdots): $!";
	    return '';
	}
	unless (@cst = stat($dotdots))
	{
	    carp "stat($dotdots): $!";
	    closedir(PARENT);
	    return '';
	}
	if ($pst[0] == $cst[0] && $pst[1] == $cst[1])
	{
	    $dir = undef;
	}
	else
	{
	    do
	    {
		unless (defined ($dir = readdir(PARENT)))
	        {
		    carp "readdir($dotdots): $!";
		    closedir(PARENT);
		    return '';
		}
		$tst[0] = $pst[0]+1 unless (@tst = lstat("$dotdots/$dir"))
	    }
	    while ($dir eq '.' || $dir eq '..' || $tst[0] != $pst[0] ||
		   $tst[1] != $pst[1]);
	}
	$cwd = (defined $dir ? "$dir" : "" ) . "/$cwd" ;
	closedir(PARENT);
    } while (defined $dir);
    chop($cwd) unless $cwd eq '/'; # drop the trailing /
    $cwd;
}

sub fast_abs_path {
    my $cwd = getcwd();
    my $path = shift || '.';
    CORE::chdir($path) || croak "Cannot chdir to $path:$!";
    my $realpath = getcwd();
    CORE::chdir($cwd)  || croak "Cannot chdir back to $cwd:$!";
    $realpath;
}


# --- PORTING SECTION ---

# VMS: $ENV{'DEFAULT'} points to default directory at all times
# 06-Mar-1996  Charles Bailey  bailey@newman.upenn.edu
# Note: Use of Cwd::chdir() causes the logical name PWD to be defined
#   in the process logical name table as the default device and directory
#   seen by Perl. This may not be the same as the default device
#   and directory seen by DCL after Perl exits, since the effects
#   the CRTL chdir() function persist only until Perl exits.

sub _vms_cwd {
    return $ENV{'DEFAULT'};
}

sub _vms_abs_path {
    return $ENV{'DEFAULT'} unless @_;
    my $path = VMS::Filespec::pathify($_[0]);
    croak("Invalid path name $_[0]") unless defined $path;
    return VMS::Filespec::rmsexpand($path);
}

sub _os2_cwd {
    $ENV{'PWD'} = `cmd /c cd`;
    chop $ENV{'PWD'};
    $ENV{'PWD'} =~ s:\\:/:g ;
    return $ENV{'PWD'};
}

sub _win32_cwd {
    $ENV{'PWD'} = Win32::GetCwd();
    $ENV{'PWD'} =~ s:\\:/:g ;
    return $ENV{'PWD'};
}

*_NT_cwd = \&_win32_cwd if (!defined &_NT_cwd && 
                            defined &Win32::GetCwd);

*_NT_cwd = \&_os2_cwd unless defined &_NT_cwd;

sub _dos_cwd {
    if (!defined &Dos::GetCwd) {
        $ENV{'PWD'} = `command /c cd`;
        chop $ENV{'PWD'};
        $ENV{'PWD'} =~ s:\\:/:g ;
    } else {
        $ENV{'PWD'} = Dos::GetCwd();
    }
    return $ENV{'PWD'};
}

sub _qnx_cwd {
    $ENV{'PWD'} = `/usr/bin/fullpath -t`;
    chop $ENV{'PWD'};
    return $ENV{'PWD'};
}

sub _qnx_abs_path {
    my $path = shift || '.';
    my $realpath=`/usr/bin/fullpath -t $path`;
    chop $realpath;
    return $realpath;
}

{
    local $^W = 0;	# assignments trigger 'subroutine redefined' warning

    if ($^O eq 'VMS') {
        *cwd		= \&_vms_cwd;
        *getcwd		= \&_vms_cwd;
        *fastcwd	= \&_vms_cwd;
        *fastgetcwd	= \&_vms_cwd;
        *abs_path	= \&_vms_abs_path;
        *fast_abs_path	= \&_vms_abs_path;
    }
    elsif ($^O eq 'NT' or $^O eq 'MSWin32') {
        # We assume that &_NT_cwd is defined as an XSUB or in the core.
        *cwd		= \&_NT_cwd;
        *getcwd		= \&_NT_cwd;
        *fastcwd	= \&_NT_cwd;
        *fastgetcwd	= \&_NT_cwd;
        *abs_path	= \&fast_abs_path;
    }
    elsif ($^O eq 'os2') {
        # sys_cwd may keep the builtin command
        *cwd		= defined &sys_cwd ? \&sys_cwd : \&_os2_cwd;
        *getcwd		= \&cwd;
        *fastgetcwd	= \&cwd;
        *fastcwd	= \&cwd;
        *abs_path	= \&fast_abs_path;
    }
    elsif ($^O eq 'dos') {
        *cwd		= \&_dos_cwd;
        *getcwd		= \&_dos_cwd;
        *fastgetcwd	= \&_dos_cwd;
        *fastcwd	= \&_dos_cwd;
        *abs_path	= \&fast_abs_path;
    }
    elsif ($^O eq 'qnx') {
        *cwd		= \&_qnx_cwd;
        *getcwd		= \&_qnx_cwd;
        *fastgetcwd	= \&_qnx_cwd;
        *fastcwd	= \&_qnx_cwd;
        *abs_path	= \&_qnx_abs_path;
        *fast_abs_path	= \&_qnx_abs_path;
    }
}

# package main; eval join('',<DATA>) || die $@;	# quick test

1;

__END__
BEGIN { import Cwd qw(:DEFAULT chdir); }
print join("\n", cwd, getcwd, fastcwd, "");
chdir('..');
print join("\n", cwd, getcwd, fastcwd, "");
print "$ENV{PWD}\n";
