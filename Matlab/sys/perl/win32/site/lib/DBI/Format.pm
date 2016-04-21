# -*- perl -*-
#
#   DBI::Format - a package for displaying result tables
#
#   Copyright (c) 1998  Jochen Wiedmann
#   Copyright (c) 1998  Tim Bunce
#
#   The DBI::Shell:Result module is free software; you can redistribute
#   it and/or modify it under the same terms as Perl itself.
#
#   Author: Jochen Wiedmann
#           Am Eisteich 9
#           72555 Metzingen
#           Germany
# 
#           Email: joe@ispsoft.de
#           Phone: +49 7123 14881
# 

use strict;

package DBI::Format;

use Text::Abbrev;

$DBI::Format::VERSION = substr(q$Revision: 1.1 $, 10)+0;


sub available_formatters {
    my ($use_abbrev) = @_;
    my @fmt;
    my @dir = grep { -d "$_/DBI" } @INC;
    foreach my $dir (@dir) {
	opendir DIR, "$dir/DBI" or warn "Unable to read $dir/DBI: $!\n";
	push @fmt, map { m/^Fmt(\w+)\.pm$/i ? ($1) : () } readdir DIR;
	closedir DIR;
    }
    my %fmt = map { (lc($_) => "DBI::Fmt$_") } @fmt;
    $fmt{box}  = "DBI::Format::Box";
    $fmt{neat} = "DBI::Format::Neat";
    my $formatters = \%fmt;
    if ($use_abbrev) {
	$formatters = abbrev(keys %fmt);
	foreach my $abbrev (keys %$formatters) {
	    $formatters->{$abbrev} = $fmt{ $formatters->{$abbrev} } || die;
	}
    }
    return $formatters;
}


sub formatter {
    my ($class, $mode, $use_abbrev) = @_;
    $mode = lc($mode);
    my $formatters = available_formatters($use_abbrev);
    my $fmt = $formatters->{$mode};
    if (!$fmt) {
	$formatters = available_formatters(0);
	die "Format '$mode' unavailable. Available formats: ".
		join(", ", sort keys %$formatters)."\n";
    }
    no strict 'refs';
    unless (%{$class."::"}) {
	eval "require $fmt";
	die "$@\n" if $@;
    }
    return $fmt;
}


package DBI::Format::Base;

sub new {
    my $class = shift;
    my $self = (@_ == 1) ? { %{shift()} } : { @_ };
    bless ($self, (ref($class) || $class));
    $self;
}

sub setup_fh {
    my ($self, $fh);
    $fh ||= \*STDOUT;
    if ($fh !~ /=/) {	# not blessed
	require FileHandle;
	bless $fh => "FileHandle";
    }
    return $fh;
}


sub trailer {
    my($self) = @_;
    my $fh   = delete $self->{'fh'};
    my $sth  = delete $self->{'sth'};
    my $rows = delete $self->{'rows'};
    $fh->print("[$rows rows of $sth->{NUM_OF_FIELDS} fields returned]\n");
}


package DBI::Format::Neat;

@DBI::Format::Neat::ISA = qw(DBI::Format::Base);

sub header {
    my($self, $sth, $fh) = @_;
    $self->{'fh'} = $self->setup_fh($fh);
    $self->{'sth'} = $sth;
    $self->{'rows'} = 0;
    $fh->print(join(',', @{$sth->{'NAME'}}), "\n");
}

sub row {
    my($self, $rowref) = @_;
    my @row = @$rowref;
    # XXX note that neat/neat_list output is *not* ``safe''
    # in the sense the it does not escape any chars and
    # may truncate the string and may translate non-printable chars.
    # We only deal with simple escaping here.
    foreach(@row) {
	next unless defined;
	s/'/\\'/g;
	s/\n/ /g;
    }
    $self->{'fh'}->print(DBI::neat_list(\@row, 9999, ","),"\n");
    ++$self->{'rows'};
}



package DBI::Format::Box;

@DBI::Format::Box::ISA = qw(DBI::Format::Base);

sub header {
    my($self, $sth, $fh) = @_;
    $self->{'fh'} = $self->setup_fh($fh);
    $self->{'sth'} = $sth;
    $self->{'data'} = [];
    my $types = $sth->{'TYPE'};
    my @right_justify;
    my @widths;
    my $names = $sth->{'NAME'};
    my $type;
    for (my $i = 0;  $i < $sth->{'NUM_OF_FIELDS'};  $i++) {
	push(@widths, defined($names->[$i]) ? length($names->[$i]) : 0);
	$type = $types->[$i];
	push(@right_justify,
	     ($type == DBI::SQL_NUMERIC()   ||
	      $type == DBI::SQL_DECIMAL()   ||
	      $type == DBI::SQL_INTEGER()   ||
	      $type == DBI::SQL_SMALLINT()  ||
	      $type == DBI::SQL_FLOAT()     ||
	      $type == DBI::SQL_REAL()      ||
	      $type == DBI::SQL_BIGINT()    ||
	      $type == DBI::SQL_TINYINT()));
    }
    $self->{'widths'} = \@widths;
    $self->{'right_justify'} = \@right_justify;
}


sub row {
    my($self, $orig_row) = @_;
    my $i = 0;
    my $col;
    my $widths = $self->{'widths'};
    my @row = @$orig_row; # don't mess with the original row
    map {
	if (!defined($_)) {
	    $_ = ' (NULL) ';
	} else {
	    $_ =~ s/\n/\\n/g;
	    $_ =~ s/\t/\\t/g;
	    $_ =~ s/[\000-\037\177-\237]/./g;
	}
	if (length($_) > $widths->[$i]) {
	    $widths->[$i] = length($_);
	}
	++$i;
    } @row;
    push @{$self->{data}}, \@row;
}


sub trailer {
    my $self = shift;
    my $widths = delete $self->{'widths'};
    my $right_justify = delete $self->{'right_justify'};
    my $sth  = $self->{'sth'};
    my $data = $self->{'data'};
    $self->{'rows'} = @$data;

    my $format_sep = '+';
    my $format_names = '|';
    my $format_rows = '|';
    for (my $i = 0;  $i < $sth->{'NUM_OF_FIELDS'};  $i++) {
	$format_sep   .= ('-' x $widths->[$i]) . '+';
	$format_names .= sprintf("%%-%ds|", $widths->[$i]);
	$format_rows  .= sprintf("%%"
			. ($right_justify->[$i] ? "" : "-") . "%ds|",
			$widths->[$i]);
    }
    $format_sep   .= "\n";
    $format_names .= "\n";
    $format_rows  .= "\n";

    my $fh = $self->{'fh'};
    $fh->print($format_sep);
    $fh->print(sprintf($format_names, @{$sth->{'NAME'}}));
    foreach my $row (@$data) {
	$fh->print($format_sep);
	$fh->print(sprintf($format_rows, @$row));
    }
    $fh->print($format_sep);

    $self->SUPER::trailer(@_);
}


1;

=head1 NAME

DBI::Format - A package for displaying result tables

=head1 SYNOPSIS

  # create a new result object
  $r = DBI::Format->new('var1' => 'val1', ...);

  # Prepare it for output by creating a header
  $r->header($sth, $fh);

  # In a loop, display rows
  while ($ref = $sth->fetchrow_arrayref()) {
    $r->row($ref);
  }

  # Finally create a trailer
  $r->trailer();


=head1 DESCRIPTION

THIS PACKAGE IS STILL VERY EXPERIMENTAL. THINGS WILL CHANGE.

This package is used for making the output of DBI::Shell configurable.
The idea is to derive a subclass for any kind of output table you might
create. Examples are

=over 8

=item *

a very simple output format as offered by DBI::neat_list().
L<"AVAILABLE SUBCLASSES">.

=item *

a box format, as offered by the Data::ShowTable module.

=item *

HTML format, as used in CGI binaries

=item *

postscript, to be piped into lpr or something similar

=back

In the future the package should also support interactive methods, for
example tab completion.

These are the available methods:

=over 8

=item new(@attr)

=item new(\%attr)

(Class method) This is the constructor. You'd rather call a subclass
constructor. The construcor is accepting either a list of key/value
pairs or a hash ref.

=item header($sth, $fh)

(Instance method) This is called when a new result table should be
created to display the results of the statement handle B<$sth>. The
(optional) argument B<$fh> is an IO handle (or any object supporting
a I<print> method), usually you use an IO::Wrap object for STDIN.

The method will query the B<$sth> for its I<NAME>, I<NUM_OF_FIELDS>,
I<TYPE>, I<SCALE> and I<PRECISION> attributes and typically print a
header. In general you should not assume that B<$sth> is indeed a DBI
statement handle and better treat it as a hash ref with the above
attributes.

=item row($ref)

(Instance method) Prints the contents of the array ref B<$ref>. Usually
you obtain this array ref by calling B<$sth-E<gt>fetchrow_arrayref()>.

=item trailer

(Instance method) Once you have passed all result rows to the result
package, you should call the I<trailer> method. This method can, for
example print the number of result rows.

=back


=head1 AVAILABLE SUBCLASSES

First of all, you can use the DBI::Format package itself: It's
not an abstract base class, but a very simple default using
DBI::neat_list().


=head2 Ascii boxes

This subclass is using the I<Box> mode of the I<Data::ShowTable> module
internally. L<Data::ShowTable(3)>.


=head1 AUTHOR AND COPYRIGHT

This module is Copyright (c) 1997, 1998

    Jochen Wiedmann
    Am Eisteich 9
    72555 Metzingen
    Germany

    Email: joe@ispsoft.de
    Phone: +49 7123 14887

The DBD::Proxy module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.


=head1 SEE ALSO

L<DBI::Shell(3)>, L<DBI(3)>, L<dbish(1)>
