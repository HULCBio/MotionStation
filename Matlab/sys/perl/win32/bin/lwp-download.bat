@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
goto endofperl
@rem ';
#!perl -w
#line 14

# $Id: lwp-download.PL,v 1.10 1999/03/19 14:06:30 gisle Exp $

=head1 NAME

lwp-download - fetch large files from the net

=head1 SYNOPSIS

 lwp-download [-a] <url> [<local file>]

=head1 DESCRIPTION

The I<lwp-download> program will down load the document specified by the URL
given as the first command line argument to a local file.  The local
filename used to save the document is guessed from the URL unless
specified as the second command line argument.

The I<lwp-download> program is implemented using the I<libwww-perl>
library.  It is better suited to down load big files than the
I<lwp-request> program because it does not store the file in memory.
Another benefit is that it will keep you updated about its progress
and that you don't have much options to worry about.

Use the C<-a> option to save the file in text (ascii) mode.  Might make a
difference on dosish systems.

=head1 EXAMPLE

Fetch the newest and greatest perl version:

 $ lwp-download http://www.perl.com/CPAN/src/latest.tar.gz
 Saving to 'latest.tar.gz'...
 1.47 MB received in 22 seconds (68.7 KB/sec)

=head1 AUTHOR

Gisle Aas <gisle@aas.no>

=cut

use strict;

use LWP::UserAgent ();
use LWP::MediaTypes qw(guess_media_type media_suffix);
use URI ();
use HTTP::Date ();

my $progname = $0;
$progname =~ s,.*/,,;    # only basename left in progname
$progname =~ s/\.\w*$//; # strip extension if any

#parse option
use Getopt::Std;
my %opt;
unless (getopts('a', \%opt)) {
    usage();
}

my $url = URI->new(shift || usage());
my $argfile = shift;
my $version = q$Revision: 1.10 $;

my $ua = new LWP::UserAgent;

$ua->agent("lwp-download/$version " . $ua->agent);
$ua->env_proxy;

my $req = new HTTP::Request GET => $url;

my $file;      # name of file we download into
my $length;    # total number of bytes to download
my $flength;   # formatted length
my $size = 0;  # number of bytes received
my $start_t;   # start time of download
my $last_dur;  # time of last callback

my $shown = 0; # have we called the show() function yet

$SIG{INT} = sub { die "Interrupted\n"; };

$| = 1;  # autoflush

my $res = $ua->request($req,
  sub {
      unless($file) {
	  my $res = $_[1];
	  unless ($argfile) {
	      # must find a suitable name to use.  First thing
	      # to do is to look for the "Content-Disposition"
	      # header defined by RFC1806.  This is also supported
	      # by Netscape
	      my $cd = $res->header("Content-Disposition");
	      if ($cd && $cd =~ /\bfilename\s*=\s*(\S+)/) {
		  $file = $1;
		  $file =~ s/;$//;
		  $file =~ s/^([\"\'])(.*)\1$/$2/;
	      }
		
	      # if this fails we try to make something from the URL
	      unless ($file) {
		  my $req = $res->request;  # now always there
		  my $rurl = $req ? $req->url : $url;
		  
		  $file = ($rurl->path_segments)[-1];
		  unless (length $file) {
		      $file = "index";
		      my $suffix = media_suffix($res->content_type);
		      $file .= ".$suffix" if $suffix;
		  } elsif ($rurl->scheme eq 'ftp' ||
			   $file =~ /\.tgz$/      ||
			   $file =~ /\.tar(\.(Z|gz))?$/
			  ) {
		      # leave the filename as it was
		  } else {
		      my $ct = guess_media_type($file);
		      unless ($ct eq $res->content_type) {
			  # need a better suffix for this type
			  my $suffix = media_suffix($res->content_type);
			  $file .= ".$suffix" if $suffix;
		      }
		  }
	      }

	      # Check if the file is already present
	      if (-f $file && -t) {
		  print "Overwrite $file? [y] ";
		  my $ans = <STDIN>;
		  exit if !defined($ans) || !($ans =~ /^y?\n/);
	      } else {
		  print "Saving to '$file'...\n";
	      }
	  } else {
	      $file = $argfile;
	  }
	  open(FILE, ">$file") || die "Can't open $file: $!";
          binmode FILE unless $opt{a};
	  $length = $res->content_length;
	  $flength = fbytes($length) if defined $length;
	  $start_t = time;
	  $last_dur = 0;
      }
      $size += length($_[0]);
      print FILE $_[0];
      if (defined $length) {
	  my $dur  = time - $start_t;
	  if ($dur != $last_dur) {  # don't update too often
	      $last_dur = $dur;
	      my $perc = $size / $length;
	      my $speed;
	      $speed = fbytes($size/$dur) . "/sec" if $dur > 3;
	      my $secs_left = fduration($dur/$perc - $dur);
	      $perc = int($perc*100);
	      my $show = "$perc% of $flength";
	      $show .= " (at $speed, $secs_left remaining)" if $speed;
	      show($show, 1);
	  }
      } else {
	  show( fbytes($size) . " received");
      }
  }
);

if ($res->is_success || $res->message =~ /^Interrupted/) {
    show("");  # clear text
    print "\r";
    print fbytes($size);
    print " of ", fbytes($length) if defined($length) && $length != $size;
    print " received";
    my $dur = time - $start_t;
    if ($dur) {
	my $speed = fbytes($size/$dur) . "/sec";
	print " in ", fduration($dur), " ($speed)";
    }
    print "\n";
    my $died = $res->header("X-Died");
    if ($died || !$res->is_success) {
	if (-t) {
	    print "Transfer aborted.  Delete $file? [n] ";
	    my $ans = <STDIN>;
	    unlink($file) if defined($ans) && $ans =~ /^y\n/;
	} else {
	    print "Transfer aborted, $file kept\n";
	}
    }
} else {
    print "\n" if $shown;
    print "$progname: ", $res->status_line, "\n";
    exit 1;
}


sub fbytes
{
    my $n = int(shift);
    if ($n >= 1024 * 1024) {
	return sprintf "%.3g MB", $n / (1024.0 * 1024);
    } elsif ($n >= 1024) {
	return sprintf "%.3g KB", $n / 1024.0;
    } else {
	return "$n bytes";
    }
}

sub fduration
{
    use integer;
    my $secs = int(shift);
    my $hours = $secs / (60*60);
    $secs -= $hours * 60*60;
    my $mins = $secs / 60;
    $secs %= 60;
    if ($hours) {
	return "$hours hours $mins minutes";
    } elsif ($mins >= 2) {
	return "$mins minutes";
    } else {
	$secs += $mins * 60;
	return "$secs seconds";
    }
}


BEGIN {
    my @ani = qw(- \ | /);
    my $ani = 0;

    sub show
    {
        my($mess, $show_ani) = @_;
        print "\r$mess" . (" " x (75 - length $mess));
	print $show_ani ? "$ani[$ani++]\b" : " ";
        $ani %= @ani;
        $shown++;
    }
}

sub usage
{
    die "Usage: $progname [-a] <url> [<lpath>]\n";
}
__END__
:endofperl
