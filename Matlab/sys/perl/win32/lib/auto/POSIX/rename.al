# NOTE: Derived from ..\..\lib\POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 523 "..\..\lib\POSIX.pm (autosplit into ..\..\lib\auto/POSIX/rename.al)"
sub rename {
    usage "rename(oldfilename, newfilename)" if @_ != 2;
    CORE::rename($_[0], $_[1]);
}

# end of POSIX::rename
1;
