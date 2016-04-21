# NOTE: Derived from blib\lib\Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 107 "blib\lib\Storable.pm (autosplit into blib\lib\auto/Storable/_store_fd.al)"
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

# end of Storable::_store_fd
1;
