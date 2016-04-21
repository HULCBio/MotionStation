;# $Id: Storable.pm,v 0.6.1.3 1998/07/03 11:32:52 ram Exp $
;#
;#  Copyright (c) 1995-1998, Raphael Manfredi
;#  
;#  You may redistribute only under the terms of the Artistic License,
;#  as specified in the README file that comes with the distribution.
;#
;# $Log: Storable.pm,v $
;# Revision 0.6.1.3  1998/07/03  11:32:52  ram
;# patch3: recent optimizations increased store() throughput
;# patch3: increased revision number
;#
;# Revision 0.6.1.2  1998/06/22  08:58:53  ram
;# patch2: added Jeff Gresham to the list of contributors
;# patch2: increased revision number
;#
;# Revision 0.6.1.1  1998/06/12  09:45:09  ram
;# patch1: increased version number
;#
;# Revision 0.6  1998/06/04  16:08:20  ram
;# Baseline for first beta release.
;#

require DynaLoader;
require Exporter;
package Storable; @ISA = qw(Exporter DynaLoader);

@EXPORT = qw(store retrieve);
@EXPORT_OK = qw(
	nstore store_fd nstore_fd retrieve_fd
	freeze nfreeze thaw
	dclone
);

use AutoLoader;
use Carp;
use vars qw($forgive_me $VERSION);

$VERSION = '0.603';
*AUTOLOAD = \&AutoLoader::AUTOLOAD;		# Grrr...

bootstrap Storable;
1;
__END__

#
# store
#
# Store target object hierarchy, identified by a reference to its root.
# The stored object tree may later be retrieved to memory via retrieve.
# Returns undef if an I/O error occurred, in which case the file is
# removed.
#
sub store {
	return _store(0, @_);
}

#
# nstore
#
# Same as store, but in network order.
#
sub nstore {
	return _store(1, @_);
}

# Internal store to file routine
sub _store {
	my $netorder = shift;
	my $self = shift;
	my ($file) = @_;
	croak "Not a reference" unless ref($self);
	croak "Too many arguments" unless @_ == 1;	# Watch out for @foo in arglist
	local *FILE;
	open(FILE, ">$file") || croak "Can't create $file: $!";
	binmode FILE;				# Archaic systems...
	my $ret;
	# Call C routine nstore or pstore, depending on network order
	eval { $ret = $netorder ? net_pstore(*FILE, $self) : pstore(*FILE, $self) };
	close(FILE) or $ret = undef;
	unlink($file) or warn "Can't unlink $file: $!\n" if $@ || !defined $ret;
	croak $@ if $@ =~ s/\.?\n$/,/;
	return $ret ? $ret : undef;
}

#
# store_fd
#
# Same as store, but perform on an already opened file descriptor instead.
# Returns undef if an I/O error occurred.
#
sub store_fd {
	return _store_fd(0, @_);
}

#
# nstore_fd
#
# Same as store_fd, but in network order.
#
sub nstore_fd {
	my ($self, $file) = @_;
	return _store_fd(1, @_);
}

# Internal store routine on opened file descriptor
sub _store_fd {
	my $netorder = shift;
	my $self = shift;
	my ($file) = @_;
	croak "Not a reference" unless ref($self);
	croak "Too many arguments" unless @_ == 1;	# Watch out for @foo in arglist
	my $fd = fileno($file);
	croak "Not a valid file descriptor" unless defined $fd;
	my $ret;
	# Call C routine nstore or pstore, depending on network order
	eval { $ret = $netorder ? net_pstore($file, $self) : pstore($file, $self) };
	croak $@ if $@ =~ s/\.?\n$/,/;
	return $ret ? $ret : undef;
}

#
# freeze
#
# Store oject and its hierarchy in memory and return a scalar
# containing the result.
#
sub freeze {
	_freeze(0, @_);
}

#
# nfreeze
#
# Same as freeze but in network order.
#
sub nfreeze {
	_freeze(1, @_);
}

# Internal freeze routine
sub _freeze {
	my $netorder = shift;
	my $self = shift;
	croak "Not a reference" unless ref($self);
	croak "Too many arguments" unless @_ == 0;	# Watch out for @foo in arglist
	my $ret;
	# Call C routine mstore or net_mstore, depending on network order
	eval { $ret = $netorder ? net_mstore($self) : mstore($self) };
	croak $@ if $@ =~ s/\.?\n$/,/;
	return $ret ? $ret : undef;
}
#
# retrieve
#
# Retrieve object hierarchy from disk, returning a reference to the root
# object of that tree.
#
sub retrieve {
	my ($file) = @_;
	local *FILE;
	open(FILE, "$file") || croak "Can't open $file: $!";
	binmode FILE;							# Archaic systems...
	my $self;
	eval { $self = pretrieve(*FILE) };		# Call C routine
	close(FILE);
	croak $@ if $@ =~ s/\.?\n$/,/;
	return $self;
}

#
# retrieve_fd
#
# Same as retrieve, but perform from an already opened file descriptor instead.
#
sub retrieve_fd {
	my ($file) = @_;
	my $fd = fileno($file);
	croak "Not a valid file descriptor" unless defined $fd;
	my $self;
	eval { $self = pretrieve($file) };		# Call C routine
	croak $@ if $@ =~ s/\.?\n$/,/;
	return $self;
}

#
# thaw
#
# Recreate objects in memory from an existing frozen image created
# by freeze.  If the frozen image passed is undef, return undef.
#
sub thaw {
	my ($frozen) = @_;
	return undef unless defined $frozen;
	my $self;
	eval { $self = mretrieve($frozen) };	# Call C routine
	croak $@ if $@ =~ s/\.?\n$/,/;
	return $self;
}

=head1 NAME

Storable - persistency for perl data structures

=head1 SYNOPSIS

 use Storable;
 store \%table, 'file';
 $hashref = retrieve('file');

 use Storable qw(nstore store_fd nstore_fd freeze thaw dclone);

 # Network order
 nstore \%table, 'file';
 $hashref = retrieve('file');	# There is NO nretrieve()

 # Storing to and retrieving from an already opened file
 store_fd \@array, \*STDOUT;
 nstore_fd \%table, \*STDOUT;
 $aryref = retrieve_fd(\*SOCKET);
 $hashref = retrieve_fd(\*SOCKET);

 # Serializing to memory
 $serialized = freeze \%table;
 %table_clone = %{ thaw($serialized) };

 # Deep (recursive) cloning
 $cloneref = dclone($ref);

=head1 DESCRIPTION

The Storable package brings persistency to your perl data structures
containing SCALAR, ARRAY, HASH or REF objects, i.e. anything that can be
convenientely stored to disk and retrieved at a later time.

It can be used in the regular procedural way by calling C<store> with
a reference to the object to be stored, along with the file name where
the image should be written.
The routine returns C<undef> for I/O problems or other internal error,
a true value otherwise. Serious errors are propagated as a C<die> exception.

To retrieve data stored to disk, use C<retrieve> with a file name,
and the objects stored into that file are recreated into memory for you,
a I<reference> to the root object being returned. In case an I/O error
occurs while reading, C<undef> is returned instead. Other serious
errors are propagated via C<die>.

Since storage is performed recursively, you might want to stuff references
to objects that share a lot of common data into a single array or hash
table, and then store that object. That way, when you retrieve back the
whole thing, the objects will continue to share what they originally shared.

At the cost of a slight header overhead, you may store to an already
opened file descriptor using the C<store_fd> routine, and retrieve
from a file via C<retrieve_fd>. Those names aren't imported by default,
so you will have to do that explicitely if you need those routines.
The file descriptor you supply must be already opened, for read
if you're going to retrieve and for write if you wish to store.

	store_fd(\%table, *STDOUT) || die "can't store to stdout\n";
	$hashref = retrieve_fd(*STDIN);

You can also store data in network order to allow easy sharing across
multiple platforms, or when storing on a socket known to be remotely
connected. The routines to call have an initial C<n> prefix for I<network>,
as in C<nstore> and C<nstore_fd>. At retrieval time, your data will be
correctly restored so you don't have to know whether you're restoring
from native or network ordered data.

When using C<retrieve_fd>, objects are retrieved in sequence, one
object (i.e. one recursive tree) per associated C<store_fd>.

If you're more from the object-oriented camp, you can inherit from
Storable and directly store your objects by invoking C<store> as
a method. The fact that the root of the to-be-stored tree is a
blessed reference (i.e. an object) is special-cased so that the
retrieve does not provide a reference to that object but rather the
blessed object reference itself. (Otherwise, you'd get a reference
to that blessed object).

=head1 MEMORY STORE

The Storable engine can also store data into a Perl scalar instead, to
later retrieve them. This is mainly used to freeze a complex structure in
some safe compact memory place (where it can possibly be sent to another
process via some IPC, since freezing the structure also serializes it in
effect). Later on, and maybe somewhere else, you can thaw the Perl scalar
out and recreate the original complex structure in memory.

Surprisingly, the routines to be called are named C<freeze> and C<thaw>.
If you wish to send out the frozen scalar to another machine, use
C<nfreeze> instead to get a portable image.

Note that freezing an object structure and immediately thawing it
actually achieves a deep cloning of that structure. Storable provides
you with a C<dclone> interface which does not create that intermediary
scalar but instead freezes the structure in some internal memory space
and then immediatly thaws it out.

=head1 SPEED

The heart of Storable is written in C for decent speed. Extra low-level
optimization have been made when manipulating perl internals, to
sacrifice encapsulation for the benefit of a greater speed.

Storage is now slightly slower than retrieval since the former has to
also store data in a hash table to keep track of which objects
have been stored already, whilst the latter uses an array instead of
a hash table.

On my HP 9000/712 machine running HPUX 9.03 and with perl 5.004, I can
store 0.85 Mbyte/s and I can retrieve at 0.90 Mbytes/s, approximatively
(CPU + system time).
This was measured with Benchmark and the I<Magic: The Gathering>
database from Tom Christiansen (1.6 Mbytes on disk).

=head1 CANONICAL REPRESENTATION

Normally Storable stores elements of hashes in the order they are
stored internally by Perl, i.e. pseudo-randomly.  If you set
C<$Storable::canonical> to some C<TRUE> value, Storable will store
hashes with the elements sorted by their key.  This allows you to
compare data structures by comparing their frozen representations (or
even the compressed frozen representations), which can be useful for
creating lookup tables for complicated queries.

Canonical order does not imply network order, those are two orthogonal
settings.

=head1 EXAMPLES

Here are some code samples showing a possible usage of Storable:

	use Storable qw(store retrieve freeze thaw dclone);

	%color = ('Blue' => 0.1, 'Red' => 0.8, 'Black' => 0, 'White' => 1);

	store(\%color, '/tmp/colors') or die "Can't store %a in /tmp/colors!\n";

	$colref = retrieve('/tmp/colors');
	die "Unable to retrieve from /tmp/colors!\n" unless defined $colref;
	printf "Blue is still %lf\n", $colref->{'Blue'};

	$colref2 = dclone(\%color);

	$str = freeze(\%color);
	printf "Serialization of %%color is %d bytes long.\n", length($str);
	$colref3 = thaw($str);

which prints (on my machine):

	Blue is still 0.100000
	Serialization of %color is 102 bytes long.

=head1 WARNING

If you're using references as keys within your hash tables, you're bound
to disapointment when retrieving your data. Indeed, Perl stringifies
references used as hash table keys. If you later wish to access the
items via another reference stringification (i.e. using the same
reference that was used for the key originally to record the value into
the hash table), it will work because both references stringify to the
same string.

It won't work across a C<store> and C<retrieve> operations however, because
the addresses in the retrieved objects, which are part of the stringified
references, will probably differ from the original addresses. The
topology of your structure is preserved, but not hidden semantics
like those.

On platforms where it matters, be sure to call C<binmode()> on the
descriptors that you pass to Storable functions.

Storing data canonically that contains large hashes can be
significantly slower than storing the same data normally, as
temprorary arrays to hold the keys for each hash have to be allocated,
populated, sorted and freed.  Some tests have shown a halving of the
speed of storing -- the exact penalty will depend on the complexity of
your data.  There is no slowdown on retrieval.

=head1 BUGS

You can't store GLOB, CODE, FORMLINE, etc... If you can define
semantics for those operations, feel free to enhance Storable so that
it can deal with them.

The store functions will C<croak> if they run into such references
unless you set C<$Storable::forgive_me> to some C<TRUE> value. In that
case, the fatal message is turned in a warning and some
meaningless string is stored instead.

Setting C<$Storable::canonical> may not yield frozen strings that
compare equal due to possible stringification of numbers. When the
string version of a scalar exists, it is the form stored, therefore
if you happen to use your numbers as strings between two freezing
operations on the same data structures, you will get different
results.

Due to the aforementionned optimizations, Storable is at the mercy
of perl's internal redesign or structure changes. If that bothers
you, you can try convincing Larry that what is used in Storable
should be documented and consistently kept in future revisions.

=head1 CREDITS

Thank you to (in chronological order):

	Jarkko Hietaniemi <jhi@iki.fi>
	Ulrich Pfeifer <pfeifer@charly.informatik.uni-dortmund.de>
	Benjamin A. Holzman <benjamin.a.holzman@bender.com>
	Andrew Ford <A.Ford@ford-mason.co.uk>
	Gisle Aas <gisle@aas.no>
	Jeff Gresham <gresham_jeffrey@jpmorgan.com>

for their bug reports, suggestions and contributions.

Benjamin Holzman contributed the tied variable support, Andrew Ford
contributed the canonical order for hashes, and Gisle Aas fixed
a few misunderstandings of mine regarding the Perl internals,
and optimized the emission of "tags" in the output streams by
simply counting the objects instead of tagging them (leading to
a binary incompatibility for the Storable image starting at version
0.6--older images are of course still properly understood).

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@grenoble.hp.comE<gt>>

=cut
