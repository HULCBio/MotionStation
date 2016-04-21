# NOTE: Derived from ../LIB\DynaLoader.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package DynaLoader;

#line 308 "../LIB\DynaLoader.pm (autosplit into ..\lib\auto/DynaLoader/dl_find_symbol_anywhere.al)"
sub dl_find_symbol_anywhere
{
    my $sym = shift;
    my $libref;
    foreach $libref (@dl_librefs) {
	my $symref = dl_find_symbol($libref,$sym);
	return $symref if $symref;
    }
    return undef;
}

1;
# end of DynaLoader::dl_find_symbol_anywhere
