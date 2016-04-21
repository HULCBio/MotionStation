# NOTE: Derived from blib\lib\Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 159 "blib\lib\Storable.pm (autosplit into blib\lib\auto/Storable/retrieve.al)"
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

# end of Storable::retrieve
1;
