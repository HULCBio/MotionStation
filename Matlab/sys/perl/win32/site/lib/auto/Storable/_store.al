# NOTE: Derived from blib\lib\Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 68 "blib\lib\Storable.pm (autosplit into blib\lib\auto/Storable/_store.al)"
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

# end of Storable::_store
1;
