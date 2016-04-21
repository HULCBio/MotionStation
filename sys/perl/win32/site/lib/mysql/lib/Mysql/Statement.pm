# -*- perl -*-

package Mysql::Statement;

@Mysql::Statement::ISA = qw(DBI::st);

use strict;
use vars qw($OPTIMIZE $VERSION $AUTOLOAD);

$VERSION = '1.2010';

$OPTIMIZE = 0; # controls, which optimization we default to

sub fetchrow ($) {
    my($self) = shift;
    my($ref) = $self->fetchrow_arrayref;
    if ($ref) {
	@$ref;
    } else {
	();
    }
}
sub fetchhash ($) {
    my($self) = shift;
    my($ref) = $self->fetchrow_hashref;
    if ($ref) {
	%$ref;
    } else {
	();
    }
}
sub fetchcol ($$) {
    my($self, $colNum) = @_;
    my(@col);
    $self->dataseek(0);
    my($ref);
    while ($ref = $self->fetchrow_arrayref) {
	push(@col, $ref->[$colNum]);
    }
    @col;
}
sub dataseek ($$) {
    my($self, $pos) = @_;
    $self->func($pos, 'dataseek');
}

sub numrows { my($self) = shift; $self->rows() }
sub numfields { my($self) = shift; $self->{'NUM_OF_FIELDS'} }
sub affectedrows { my($self) = shift; $self->{'affected_rows'} }
sub insertid { my($self) = shift; $self->{'insertid'} }
sub arrAttr ($$) {
    my($self, $attr) = @_;
    my($arr) = $self->{$attr};
    wantarray ? @$arr : $arr
}
sub table ($) { shift->arrAttr('table') }
sub name ($) { shift->arrAttr('NAME') }
sub type ($) { shift->arrAttr('mysql_type') }
sub isnotnull ($) { shift->arrAttr('is_not_null') }
sub isprikey ($) { shift->arrAttr('is_pri_key') }
sub isnum ($) { shift->arrAttr('is_num') }
sub isblob ($) { shift->arrAttr('is_blob') }
sub length ($) { shift->arrAttr('length') }

sub maxlength  {
    my $sth = shift;
    my $result;
    $result = $sth->fetchinternal('maxlength');
    return wantarray ? @$result : $result;
}

sub listindices {
    my($sth) = shift;
    my(@result,$i);
    return ();
}

sub AUTOLOAD {
    my $meth = $AUTOLOAD;
    $meth =~ s/^.*:://;
    $meth =~ s/_//g;
    $meth = lc($meth);

    # Allow them to say fetch_row or FetchRow
    no strict;
    if (defined &$meth) {
	*$AUTOLOAD = \&{$meth};
	return &$AUTOLOAD(@_);
    }
    Carp::croak ("$AUTOLOAD not defined and not autoloadable");
}

sub unctrl {
    my($x) = @_;
    $x =~ s/\\/\\\\/g;
    $x =~ s/([\001-\037\177])/sprintf("\\%03o",unpack("C",$1))/eg;
    $x;
}

sub optimize {
    my($self,$arg) = @_;
    if (defined $arg) {
	return $self->{'OPTIMIZE'} = $arg;
    } else {
	return $self->{'OPTIMIZE'} ||= $OPTIMIZE;
    }
}

sub as_string {
    my($sth) = @_;
    my($plusline,$titline,$sprintf) = ('+','|','|');
    my($result,$s,$l);
    if ($sth->numfields == 0) {
	return '';
    }
    for (0..$sth->numfields-1) {
	$l=CORE::length($sth->name->[$_]);
	if ($l < $sth->maxlength->[$_]) {
	    $l= $sth->maxlength->[$_];
	}
	if (!$sth->isnotnull  &&  $l < 4) {
	    $l = 4;
	}
	$plusline .= sprintf "%$ {l}s+", "-" x $l;
	$l= -$l  if (!$sth->isnum->[$_]);
	$titline .= sprintf "%$ {l}s|", $sth->name->[$_];
	$sprintf .= "%$ {l}s|";
    }
    $sprintf .= "\n";
    $result = "$plusline\n$titline\n$plusline\n";
    $sth->dataseek(0);
    my(@row);
    while (@row = $sth->fetchrow) {
	my ($col, $pcol, @prow, $i, $j);
	for ($i = 0;  $i < $sth->numfields;  $i++) {
	    $col = $row[$i];
	    $j = @prow;
	    $pcol = defined $col ? unctrl($col) : "NULL";
	    push(@prow, $pcol);
	}
	$result .= sprintf $sprintf, @prow;
    }
    $result .= "$plusline\n";
    $s = $sth->numrows == 1 ? "" : "s";
    $result .= $sth->numrows . " row$s processed\n\n";
    return $result;
}

1;
