# NOTE: Derived from ..\..\lib\POSIX.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package POSIX;

#line 930 "..\..\lib\POSIX.pm (autosplit into ..\..\lib\auto/POSIX/utime.al)"
sub utime {
    usage "utime(filename, atime, mtime)" if @_ != 3;
    CORE::utime($_[1], $_[2], $_[0]);
}

1;
# end of POSIX::utime
