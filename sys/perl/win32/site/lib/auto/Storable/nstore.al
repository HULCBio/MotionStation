# NOTE: Derived from blib\lib\Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 63 "blib\lib\Storable.pm (autosplit into blib\lib\auto/Storable/nstore.al)"
#
# nstore
#
# Same as store, but in network order.
#
sub nstore {
	return _store(1, @_);
}

# end of Storable::nstore
1;
