# NOTE: Derived from blib\lib\Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 142 "blib\lib\Storable.pm (autosplit into blib\lib\auto/Storable/_freeze.al)"
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

# end of Storable::_freeze
1;
