package Carp;

=head1 NAME

carp    - warn of errors (from perspective of caller)

cluck   - warn of errors with stack backtrace
          (not exported by default)

croak   - die of errors (from perspective of caller)

confess - die of errors with stack backtrace

=head1 SYNOPSIS

    use Carp;
    croak "We're outta here!";

    use Carp qw(cluck);
    cluck "This is how we got here!";

=head1 DESCRIPTION

The Carp routines are useful in your own modules because
they act like die() or warn(), but report where the error
was in the code they were called from.  Thus if you have a 
routine Foo() that has a carp() in it, then the carp() 
will report the error as occurring where Foo() was called, 
not where carp() was called.

=head2 Forcing a Stack Trace

As a debugging aid, you can force Carp to treat a croak as a confess
and a carp as a cluck across I<all> modules. In other words, force a
detailed stack trace to be given.  This can be very helpful when trying
to understand why, or from where, a warning or error is being generated.

This feature is enabled by 'importing' the non-existent symbol
'verbose'. You would typically enable it by saying

    perl -MCarp=verbose script.pl

or by including the string C<MCarp=verbose> in the L<PERL5OPT>
environment variable.

=head1 BUGS

The Carp routines don't handle exception objects currently.
If called with a first argument that is a reference, they simply
call die() or warn(), as appropriate.

=cut

# This package is heavily used. Be small. Be fast. Be good.

# Comments added by Andy Wardley <abw@kfs.org> 09-Apr-98, based on an
# _almost_ complete understanding of the package.  Corrections and
# comments are welcome.

# The $CarpLevel variable can be set to "strip off" extra caller levels for
# those times when Carp calls are buried inside other functions.  The
# $Max(EvalLen|(Arg(Len|Nums)) variables are used to specify how the eval
# text and function arguments should be formatted when printed.

$CarpLevel = 0;		# How many extra package levels to skip on carp.
$MaxEvalLen = 0;	# How much eval '...text...' to show. 0 = all.
$MaxArgLen = 64;        # How much of each argument to print. 0 = all.
$MaxArgNums = 8;        # How many arguments to print. 0 = all.
$Verbose = 0;		# If true then make shortmess call longmess instead

require Exporter;
@ISA = ('Exporter');
@EXPORT = qw(confess croak carp);
@EXPORT_OK = qw(cluck verbose);
@EXPORT_FAIL = qw(verbose);	# hook to enable verbose mode


# if the caller specifies verbose usage ("perl -MCarp=verbose script.pl")
# then the following method will be called by the Exporter which knows
# to do this thanks to @EXPORT_FAIL, above.  $_[1] will contain the word
# 'verbose'.

sub export_fail {
    shift;
    $Verbose = shift if $_[0] eq 'verbose';
    return @_;
}


# longmess() crawls all the way up the stack reporting on all the function
# calls made.  The error string, $error, is originally constructed from the
# arguments passed into longmess() via confess(), cluck() or shortmess().
# This gets appended with the stack trace messages which are generated for
# each function call on the stack.

sub longmess {
    return @_ if ref $_[0];
    my $error = join '', @_;
    my $mess = "";
    my $i = 1 + $CarpLevel;
    my ($pack,$file,$line,$sub,$hargs,$eval,$require);
    my (@a);
    #
    # crawl up the stack....
    #
    while (do { { package DB; @a = caller($i++) } } ) {
	# get copies of the variables returned from caller()
	($pack,$file,$line,$sub,$hargs,undef,$eval,$require) = @a;
	#
	# if the $error error string is newline terminated then it
	# is copied into $mess.  Otherwise, $mess gets set (at the end of
	# the 'else {' section below) to one of two things.  The first time
	# through, it is set to the "$error at $file line $line" message.
	# $error is then set to 'called' which triggers subsequent loop
	# iterations to append $sub to $mess before appending the "$error
	# at $file line $line" which now actually reads "called at $file line
	# $line".  Thus, the stack trace message is constructed:
	#
	#        first time: $mess  = $error at $file line $line
	#  subsequent times: $mess .= $sub $error at $file line $line
	#                                  ^^^^^^
	#                                 "called"
	if ($error =~ m/\n$/) {
	    $mess .= $error;
	} else {
	    # Build a string, $sub, which names the sub-routine called.
	    # This may also be "require ...", "eval '...' or "eval {...}"
	    if (defined $eval) {
		if ($require) {
		    $sub = "require $eval";
		} else {
		    $eval =~ s/([\\\'])/\\$1/g;
		    if ($MaxEvalLen && length($eval) > $MaxEvalLen) {
			substr($eval,$MaxEvalLen) = '...';
		    }
		    $sub = "eval '$eval'";
		}
	    } elsif ($sub eq '(eval)') {
		$sub = 'eval {...}';
	    }
	    # if there are any arguments in the sub-routine call, format
	    # them according to the format variables defined earlier in
	    # this file and join them onto the $sub sub-routine string
	    if ($hargs) {
		# we may trash some of the args so we take a copy
		@a = @DB::args;	# must get local copy of args
		# don't print any more than $MaxArgNums
		if ($MaxArgNums and @a > $MaxArgNums) {
		    # cap the length of $#a and set the last element to '...'
		    $#a = $MaxArgNums;
		    $a[$#a] = "...";
		}
		for (@a) {
		    # set args to the string "undef" if undefined
		    $_ = "undef", next unless defined $_;
		    if (ref $_) {
			# dunno what this is for...
			$_ .= '';
			s/'/\\'/g;
		    }
		    else {
			s/'/\\'/g;
			# terminate the string early with '...' if too long
			substr($_,$MaxArgLen) = '...'
			    if $MaxArgLen and $MaxArgLen < length;
		    }
		    # 'quote' arg unless it looks like a number
		    $_ = "'$_'" unless /^-?[\d.]+$/;
		    # print high-end chars as 'M-<char>' or '^<char>'
		    s/([\200-\377])/sprintf("M-%c",ord($1)&0177)/eg;
		    s/([\0-\37\177])/sprintf("^%c",ord($1)^64)/eg;
		}
		# append ('all', 'the', 'arguments') to the $sub string
		$sub .= '(' . join(', ', @a) . ')';
	    }
	    # here's where the error message, $mess, gets constructed
	    $mess .= "\t$sub " if $error eq "called";
	    $mess .= "$error at $file line $line\n";
	}
	# we don't need to print the actual error message again so we can
	# change this to "called" so that the string "$error at $file line
	# $line" makes sense as "called at $file line $line".
	$error = "called";
    }
    # this kludge circumvents die's incorrect handling of NUL
    my $msg = \($mess || $error);
    $$msg =~ tr/\0//d;
    $$msg;
}


# shortmess() is called by carp() and croak() to skip all the way up to
# the top-level caller's package and report the error from there.  confess()
# and cluck() generate a full stack trace so they call longmess() to
# generate that.  In verbose mode shortmess() calls longmess() so
# you always get a stack trace

sub shortmess {	# Short-circuit &longmess if called via multiple packages
    goto &longmess if $Verbose;
    return @_ if ref $_[0];
    my $error = join '', @_;
    my ($prevpack) = caller(1);
    my $extra = $CarpLevel;
    my $i = 2;
    my ($pack,$file,$line);
    # when reporting an error, we want to report it from the context of the
    # calling package.  So what is the calling package?  Within a module,
    # there may be many calls between methods and perhaps between sub-classes
    # and super-classes, but the user isn't interested in what happens
    # inside the package.  We start by building a hash array which keeps
    # track of all the packages to which the calling package belongs.  We
    # do this by examining its @ISA variable.  Any call from a base class
    # method (one of our caller's @ISA packages) can be ignored
    my %isa = ($prevpack,1);

    # merge all the caller's @ISA packages into %isa.
    @isa{@{"${prevpack}::ISA"}} = ()
	if(defined @{"${prevpack}::ISA"});

    # now we crawl up the calling stack and look at all the packages in
    # there.  For each package, we look to see if it has an @ISA and then
    # we see if our caller features in that list.  That would imply that
    # our caller is a derived class of that package and its calls can also
    # be ignored
    while (($pack,$file,$line) = caller($i++)) {
	if(defined @{$pack . "::ISA"}) {
	    my @i = @{$pack . "::ISA"};
	    my %i;
	    @i{@i} = ();
	    # merge any relevant packages into %isa
	    @isa{@i,$pack} = ()
		if(exists $i{$prevpack} || exists $isa{$pack});
	}

	# and here's where we do the ignoring... if the package in
	# question is one of our caller's base or derived packages then
	# we can ignore it (skip it) and go onto the next (but note that
	# the continue { } block below gets called every time)
	next
	    if(exists $isa{$pack});

	# Hey!  We've found a package that isn't one of our caller's
	# clan....but wait, $extra refers to the number of 'extra' levels
	# we should skip up.  If $extra > 0 then this is a false alarm.
	# We must merge the package into the %isa hash (so we can ignore it
	# if it pops up again), decrement $extra, and continue.
	if ($extra-- > 0) {
	    %isa = ($pack,1);
	    @isa{@{$pack . "::ISA"}} = ()
		if(defined @{$pack . "::ISA"});
	}
	else {
	    # OK!  We've got a candidate package.  Time to construct the
	    # relevant error message and return it.   die() doesn't like
	    # to be given NUL characters (which $msg may contain) so we
	    # remove them first.
	    (my $msg = "$error at $file line $line\n") =~ tr/\0//d;
	    return $msg;
	}
    }
    continue {
	$prevpack = $pack;
    }

    # uh-oh!  It looks like we crawled all the way up the stack and
    # never found a candidate package.  Oh well, let's call longmess
    # to generate a full stack trace.  We use the magical form of 'goto'
    # so that this shortmess() function doesn't appear on the stack
    # to further confuse longmess() about it's calling package.
    goto &longmess;
}


# the following four functions call longmess() or shortmess() depending on
# whether they should generate a full stack trace (confess() and cluck())
# or simply report the caller's package (croak() and carp()), respectively.
# confess() and croak() die, carp() and cluck() warn.

sub croak   { die  shortmess @_ }
sub confess { die  longmess  @_ }
sub carp    { warn shortmess @_ }
sub cluck   { warn longmess  @_ }

1;
