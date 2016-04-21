# Perl script to query xPC Generated COM Classes for blockdiagram
#
# $Revision: 1.1 $ $Date: 2002/02/22 20:53:49 $


use Win32::Registry;
foreach my $Register (@ARGV) {
    my $hkey;
    $HKEY_CLASSES_ROOT->Open($Register,$hkey)|| die $!;
    $hkey->QueryKey($subkeys,$values);
    print "$subkeys keys, $values values\n";
    $hkey->Close();
}
