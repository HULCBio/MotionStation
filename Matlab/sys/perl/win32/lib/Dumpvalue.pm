require 5.005;			# For (defined ref) and $#$v
package Dumpvalue;
use strict;
use vars qw(%address *stab %subs);

# translate control chars to ^X - Randal Schwartz
# Modifications to print types by Peter Gordon v1.0

# Ilya Zakharevich -- patches after 5.001 (and some before ;-)

# Won't dump symbol tables and contents of debugged files by default

# (IZ) changes for objectification:
#   c) quote() renamed to method set_quote();
#   d) unctrlSet() renamed to method set_unctrl();
#   f) Compiles with `use strict', but in two places no strict refs is needed:
#      maybe more problems are waiting...

my %defaults = (
		globPrint	      => 0,
		printUndef	      => 1,
		tick		      => "auto",
		unctrl		      => 'quote',
		subdump		      => 1,
		dumpReused	      => 0,
		bareStringify	      => 1,
		hashDepth	      => '',
		arrayDepth	      => '',
		dumpDBFiles	      => '',
		dumpPackages	      => '',
		quoteHighBit	      => '',
		usageOnly	      => '',
		compactDump	      => '',
		veryCompact	      => '',
		stopDbSignal	      => '',
	       );

sub new {
  my $class = shift;
  my %opt = (%defaults, @_);
  bless \%opt, $class;
}

sub set {
  my $self = shift;
  my %opt = @_;
  @$self{keys %opt} = values %opt;
}

sub get {
  my $self = shift;
  wantarray ? @$self{@_} : $$self{pop @_};
}

sub dumpValue {
  my $self = shift;
  die "usage: \$dumper->dumpValue(value)" unless @_ == 1;
  local %address;
  local $^W=0;
  (print "undef\n"), return unless defined $_[0];
  (print $self->stringify($_[0]), "\n"), return unless ref $_[0];
  $self->unwrap($_[0],0);
}

sub dumpValues {
  my $self = shift;
  local %address;
  local $^W=0;
  (print "undef\n"), return unless defined $_[0];
  $self->unwrap(\@_,0);
}

# This one is good for variable names:

sub unctrl {
  local($_) = @_;

  return \$_ if ref \$_ eq "GLOB";
  s/([\001-\037\177])/'^'.pack('c',ord($1)^64)/eg;
  $_;
}

sub stringify {
  my $self = shift;
  local $_ = shift;
  my $noticks = shift;
  my $tick = $self->{tick};

  return 'undef' unless defined $_ or not $self->{printUndef};
  return $_ . "" if ref \$_ eq 'GLOB';
  { no strict 'refs';
    $_ = &{'overload::StrVal'}($_)
      if $self->{bareStringify} and ref $_
	and defined %overload:: and defined &{'overload::StrVal'};
  }

  if ($tick eq 'auto') {
    if (/[\000-\011\013-\037\177]/) {
      $tick = '"';
    } else {
      $tick = "'";
    }
  }
  if ($tick eq "'") {
    s/([\'\\])/\\$1/g;
  } elsif ($self->{unctrl} eq 'unctrl') {
    s/([\"\\])/\\$1/g ;
    s/([\000-\037\177])/'^'.pack('c',ord($1)^64)/eg;
    s/([\200-\377])/'\\0x'.sprintf('%2X',ord($1))/eg
      if $self->{quoteHighBit};
  } elsif ($self->{unctrl} eq 'quote') {
    s/([\"\\\$\@])/\\$1/g if $tick eq '"';
    s/\033/\\e/g;
    s/([\000-\037\177])/'\\c'.chr(ord($1)^64)/eg;
  }
  s/([\200-\377])/'\\'.sprintf('%3o',ord($1))/eg if $self->{quoteHighBit};
  ($noticks || /^\d+(\.\d*)?\Z/)
    ? $_
      : $tick . $_ . $tick;
}

sub DumpElem {
  my ($self, $v) = (shift, shift);
  my $short = $self->stringify($v, ref $v);
  my $shortmore = '';
  if ($self->{veryCompact} && ref $v
      && (ref $v eq 'ARRAY' and !grep(ref $_, @$v) )) {
    my $depth = $#$v;
    ($shortmore, $depth) = (' ...', $self->{arrayDepth} - 1)
      if $self->{arrayDepth} and $depth >= $self->{arrayDepth};
    my @a = map $self->stringify($_), @$v[0..$depth];
    print "0..$#{$v}  @a$shortmore\n";
  } elsif ($self->{veryCompact} && ref $v
	   && (ref $v eq 'HASH') and !grep(ref $_, values %$v)) {
    my @a = sort keys %$v;
    my $depth = $#a;
    ($shortmore, $depth) = (' ...', $self->{hashDepth} - 1)
      if $self->{hashDepth} and $depth >= $self->{hashDepth};
    my @b = map {$self->stringify($_) . " => " . $self->stringify($$v{$_})}
      @a[0..$depth];
    local $" = ', ';
    print "@b$shortmore\n";
  } else {
    print "$short\n";
    $self->unwrap($v,shift);
  }
}

sub unwrap {
  my $self = shift;
  return if $DB::signal and $self->{stopDbSignal};
  my ($v) = shift ;
  my ($s) = shift ;		# extra no of spaces
  my $sp;
  my (%v,@v,$address,$short,$fileno);

  $sp = " " x $s ;
  $s += 3 ;

  # Check for reused addresses
  if (ref $v) {
    my $val = $v;
    { no strict 'refs';
      $val = &{'overload::StrVal'}($v)
	if defined %overload:: and defined &{'overload::StrVal'};
    }
    ($address) = $val =~ /(0x[0-9a-f]+)\)$/ ;
    if (!$self->{dumpReused} && defined $address) {
      $address{$address}++ ;
      if ( $address{$address} > 1 ) {
	print "${sp}-> REUSED_ADDRESS\n" ;
	return ;
      }
    }
  } elsif (ref \$v eq 'GLOB') {
    $address = "$v" . "";	# To avoid a bug with globs
    $address{$address}++ ;
    if ( $address{$address} > 1 ) {
      print "${sp}*DUMPED_GLOB*\n" ;
      return ;
    }
  }

  if ( UNIVERSAL::isa($v, 'HASH') ) {
    my @sortKeys = sort keys(%$v) ;
    my $more;
    my $tHashDepth = $#sortKeys ;
    $tHashDepth = $#sortKeys < $self->{hashDepth}-1 ? $#sortKeys : $self->{hashDepth}-1
      unless $self->{hashDepth} eq '' ;
    $more = "....\n" if $tHashDepth < $#sortKeys ;
    my $shortmore = "";
    $shortmore = ", ..." if $tHashDepth < $#sortKeys ;
    $#sortKeys = $tHashDepth ;
    if ($self->{compactDump} && !grep(ref $_, values %{$v})) {
      $short = $sp;
      my @keys;
      for (@sortKeys) {
	push @keys, $self->stringify($_) . " => " . $self->stringify($v->{$_});
      }
      $short .= join ', ', @keys;
      $short .= $shortmore;
      (print "$short\n"), return if length $short <= $self->{compactDump};
    }
    for my $key (@sortKeys) {
      return if $DB::signal and $self->{stopDbSignal};
      my $value = $ {$v}{$key} ;
      print $sp, $self->stringify($key), " => ";
      $self->DumpElem($value, $s);
    }
    print "$sp  empty hash\n" unless @sortKeys;
    print "$sp$more" if defined $more ;
  } elsif ( UNIVERSAL::isa($v, 'ARRAY') ) {
    my $tArrayDepth = $#{$v} ;
    my $more ;
    $tArrayDepth = $#$v < $self->{arrayDepth}-1 ? $#$v : $self->{arrayDepth}-1
      unless  $self->{arrayDepth} eq '' ;
    $more = "....\n" if $tArrayDepth < $#{$v} ;
    my $shortmore = "";
    $shortmore = " ..." if $tArrayDepth < $#{$v} ;
    if ($self->{compactDump} && !grep(ref $_, @{$v})) {
      if ($#$v >= 0) {
	$short = $sp . "0..$#{$v}  " .
	  join(" ",
	       map {$self->stringify($_)} @{$v}[0..$tArrayDepth])
	    . "$shortmore";
      } else {
	$short = $sp . "empty array";
      }
      (print "$short\n"), return if length $short <= $self->{compactDump};
    }
    for my $num ($[ .. $tArrayDepth) {
      return if $DB::signal and $self->{stopDbSignal};
      print "$sp$num  ";
      $self->DumpElem($v->[$num], $s);
    }
    print "$sp  empty array\n" unless @$v;
    print "$sp$more" if defined $more ;
  } elsif (  UNIVERSAL::isa($v, 'SCALAR') or ref $v eq 'REF' ) {
    print "$sp-> ";
    $self->DumpElem($$v, $s);
  } elsif ( UNIVERSAL::isa($v, 'CODE') ) {
    print "$sp-> ";
    $self->dumpsub(0, $v);
  } elsif ( UNIVERSAL::isa($v, 'GLOB') ) {
    print "$sp-> ",$self->stringify($$v,1),"\n";
    if ($self->{globPrint}) {
      $s += 3;
      $self->dumpglob('', $s, "{$$v}", $$v, 1);
    } elsif (defined ($fileno = fileno($v))) {
      print( (' ' x ($s+3)) .  "FileHandle({$$v}) => fileno($fileno)\n" );
    }
  } elsif (ref \$v eq 'GLOB') {
    if ($self->{globPrint}) {
      $self->dumpglob('', $s, "{$v}", $v, 1);
    } elsif (defined ($fileno = fileno(\$v))) {
      print( (' ' x $s) .  "FileHandle({$v}) => fileno($fileno)\n" );
    }
  }
}

sub matchvar {
  $_[0] eq $_[1] or
    ($_[1] =~ /^([!~])(.)([\x00-\xff]*)/) and
      ($1 eq '!') ^ (eval {($_[2] . "::" . $_[0]) =~ /$2$3/});
}

sub compactDump {
  my $self = shift;
  $self->{compactDump} = shift if @_;
  $self->{compactDump} = 6*80-1 
    if $self->{compactDump} and $self->{compactDump} < 2;
  $self->{compactDump};
}

sub veryCompact {
  my $self = shift;
  $self->{veryCompact} = shift if @_;
  $self->compactDump(1) if !$self->{compactDump} and $self->{veryCompact};
  $self->{veryCompact};
}

sub set_unctrl {
  my $self = shift;
  if (@_) {
    my $in = shift;
    if ($in eq 'unctrl' or $in eq 'quote') {
      $self->{unctrl} = $in;
    } else {
      print "Unknown value for `unctrl'.\n";
    }
  }
  $self->{unctrl};
}

sub set_quote {
  my $self = shift;
  if (@_ and $_[0] eq '"') {
    $self->{tick} = '"';
    $self->{unctrl} = 'quote';
  } elsif (@_ and $_[0] eq 'auto') {
    $self->{tick} = 'auto';
    $self->{unctrl} = 'quote';
  } elsif (@_) {		# Need to set
    $self->{tick} = "'";
    $self->{unctrl} = 'unctrl';
  }
  $self->{tick};
}

sub dumpglob {
  my $self = shift;
  return if $DB::signal and $self->{stopDbSignal};
  my ($package, $off, $key, $val, $all) = @_;
  local(*stab) = $val;
  my $fileno;
  if (($key !~ /^_</ or $self->{dumpDBFiles}) and defined $stab) {
    print( (' ' x $off) . "\$", &unctrl($key), " = " );
    $self->DumpElem($stab, 3+$off);
  }
  if (($key !~ /^_</ or $self->{dumpDBFiles}) and defined @stab) {
    print( (' ' x $off) . "\@$key = (\n" );
    $self->unwrap(\@stab,3+$off) ;
    print( (' ' x $off) .  ")\n" );
  }
  if ($key ne "main::" && $key ne "DB::" && defined %stab
      && ($self->{dumpPackages} or $key !~ /::$/)
      && ($key !~ /^_</ or $self->{dumpDBFiles})
      && !($package eq "Dumpvalue" and $key eq "stab")) {
    print( (' ' x $off) . "\%$key = (\n" );
    $self->unwrap(\%stab,3+$off) ;
    print( (' ' x $off) .  ")\n" );
  }
  if (defined ($fileno = fileno(*stab))) {
    print( (' ' x $off) .  "FileHandle($key) => fileno($fileno)\n" );
  }
  if ($all) {
    if (defined &stab) {
      $self->dumpsub($off, $key);
    }
  }
}

sub dumpsub {
  my $self = shift;
  my ($off,$sub) = @_;
  $sub = $1 if $sub =~ /^\{\*(.*)\}$/;
  my $subref = \&$sub;
  my $place = $DB::sub{$sub} || (($sub = $subs{"$subref"}) && $DB::sub{$sub})
    || ($self->{subdump} && ($sub = $self->findsubs("$subref"))
	&& $DB::sub{$sub});
  $place = '???' unless defined $place;
  print( (' ' x $off) .  "&$sub in $place\n" );
}

sub findsubs {
  my $self = shift;
  return undef unless defined %DB::sub;
  my ($addr, $name, $loc);
  while (($name, $loc) = each %DB::sub) {
    $addr = \&$name;
    $subs{"$addr"} = $name;
  }
  $self->{subdump} = 0;
  $subs{ shift() };
}

sub dumpvars {
  my $self = shift;
  my ($package,@vars) = @_;
  local(%address,$^W);
  my ($key,$val);
  $package .= "::" unless $package =~ /::$/;
  *stab = *main::;

  while ($package =~ /(\w+?::)/g) {
    *stab = $ {stab}{$1};
  }
  $self->{TotalStrings} = 0;
  $self->{Strings} = 0;
  $self->{CompleteTotal} = 0;
  while (($key,$val) = each(%stab)) {
    return if $DB::signal and $self->{stopDbSignal};
    next if @vars && !grep( matchvar($key, $_), @vars );
    if ($self->{usageOnly}) {
      $self->globUsage(\$val, $key)
	unless $package eq 'Dumpvalue' and $key eq 'stab';
    } else {
      $self->dumpglob($package, 0,$key, $val);
    }
  }
  if ($self->{usageOnly}) {
    print <<EOP;
String space: $self->{TotalStrings} bytes in $self->{Strings} strings.
EOP
    $self->{CompleteTotal} += $self->{TotalStrings};
    print <<EOP;
Grand total = $self->{CompleteTotal} bytes (1 level deep) + overhead.
EOP
  }
}

sub scalarUsage {
  my $self = shift;
  my $size = length($_[0]);
  $self->{TotalStrings} += $size;
  $self->{Strings}++;
  $size;
}

sub arrayUsage {		# array ref, name
  my $self = shift;
  my $size = 0;
  map {$size += $self->scalarUsage($_)} @{$_[0]};
  my $len = @{$_[0]};
  print "\@$_[1] = $len item", ($len > 1 ? "s" : ""), " (data: $size bytes)\n"
      if defined $_[1];
  $self->{CompleteTotal} +=  $size;
  $size;
}

sub hashUsage {			# hash ref, name
  my $self = shift;
  my @keys = keys %{$_[0]};
  my @values = values %{$_[0]};
  my $keys = $self->arrayUsage(\@keys);
  my $values = $self->arrayUsage(\@values);
  my $len = @keys;
  my $total = $keys + $values;
  print "\%$_[1] = $len item", ($len > 1 ? "s" : ""),
    " (keys: $keys; values: $values; total: $total bytes)\n"
      if defined $_[1];
  $total;
}

sub globUsage {			# glob ref, name
  my $self = shift;
  local *stab = *{$_[0]};
  my $total = 0;
  $total += $self->scalarUsage($stab) if defined $stab;
  $total += $self->arrayUsage(\@stab, $_[1]) if defined @stab;
  $total += $self->hashUsage(\%stab, $_[1]) 
    if defined %stab and $_[1] ne "main::" and $_[1] ne "DB::";	
  #and !($package eq "Dumpvalue" and $key eq "stab"));
  $total;
}

1;

=head1 NAME

Dumpvalue - provides screen dump of Perl data.

=head1 SYNOPSYS

  use Dumpvalue;
  my $dumper = new Dumpvalue;
  $dumper->set(globPrint => 1);
  $dumper->dumpValue(\*::);
  $dumper->dumpvars('main');

=head1 DESCRIPTION

=head2 Creation

A new dumper is created by a call

  $d = new Dumpvalue(option1 => value1, option2 => value2)

Recognized options:

=over

=item C<arrayDepth>, C<hashDepth>

Print only first N elements of arrays and hashes.  If false, prints all the
elements.

=item C<compactDump>, C<veryCompact>

Change style of array and hash dump.  If true, short array
may be printed on one line.

=item C<globPrint>

Whether to print contents of globs.

=item C<DumpDBFiles>

Dump arrays holding contents of debugged files.

=item C<DumpPackages>

Dump symbol tables of packages.

=item C<DumpReused>

Dump contents of "reused" addresses.

=item C<tick>, C<HighBit>, C<printUndef>

Change style of string dump.  Default value of C<tick> is C<auto>, one
can enable either double-quotish dump, or single-quotish by setting it
to C<"> or C<'>.  By default, characters with high bit set are printed
I<as is>.

=item C<UsageOnly>

I<very> rudimentally per-package memory usage dump.  If set,
C<dumpvars> calculates total size of strings in variables in the package.

=item unctrl

Changes the style of printout of strings.  Possible values are
C<unctrl> and C<quote>.

=item subdump

Whether to try to find the subroutine name given the reference.

=item bareStringify

Whether to write the non-overloaded form of the stringify-overloaded objects.

=item quoteHighBit

Whether to print chars with high bit set in binary or "as is".

=item stopDbSignal

Whether to abort printing if debugger signal flag is raised.

=back

Later in the life of the object the methods may be queries with get()
method and set() method (which accept multiple arguments).

=head2 Methods

=over

=item dumpValue

  $dumper->dumpValue($value);
  $dumper->dumpValue([$value1, $value2]);

=item dumpValues

  $dumper->dumpValues($value1, $value2);

=item dumpvars

  $dumper->dumpvars('my_package');
  $dumper->dumpvars('my_package', 'foo', '~bar$', '!......');

The optional arguments are considered as literal strings unless they
start with C<~> or C<!>, in which case they are interpreted as regular
expressions (possibly negated).

The second example prints entries with names C<foo>, and also entries
with names which ends on C<bar>, or are shorter than 5 chars.

=item set_quote

  $d->set_quote('"');

Sets C<tick> and C<unctrl> options to suitable values for printout with the
given quote char.  Possible values are C<auto>, C<'> and C<">.

=item set_unctrl

  $d->set_unctrl('"');

Sets C<unctrl> option with checking for an invalid argument.
Possible values are C<unctrl> and C<quote>.

=item compactDump

  $d->compactDump(1);

Sets C<compactDump> option.  If the value is 1, sets to a reasonable
big number.

=item veryCompact

  $d->veryCompact(1);

Sets C<compactDump> and C<veryCompact> options simultaneously.

=item set

  $d->set(option1 => value1, option2 => value2);

=item get

  @values = $d->get('option1', 'option2');

=back

=cut

