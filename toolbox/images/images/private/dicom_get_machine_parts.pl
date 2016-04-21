# DICOM_GET_MACHINE_PARTS   
# 
# Return machine values that can be used to generate the machine portion of
# a UID.  This function generates a string containing (1) the MAC address of
# the first ethernet card listed or the 32-bit Host ID and (2) the process
# number of this script.
#
# Unuccessful execution produces a nonzero return value.

# Copyright 1993-2003 The MathWorks, Inc.
# $Revision: 1.5.4.1 $ $Date: 2003/01/26 05:58:34 $


##
## Main Routine.
##

# Find the ethernet address or the host ID.
#
# Get this machine's architecture from the command line.
$ARCH = shift(@ARGV);

for ($ARCH) {

    /alpha/   and do {$machine = get_alpha(); last; };
    /hp700/   and do {$machine = get_hp();    last; };
    /hpux/    and do {$machine = get_hp();    last; };
    /glnx86/  and do {$machine = get_linux(); last; };
    /ibm_rs/  and do {$machine = get_ibmrs(); last; };
    /mac/     and do {$machine = get_mac();   last; };
    /sgi/     and do {$machine = get_sgi();   last; };
    /sgi64/   and do {$machine = get_sgi();   last; };
    /sol2/    and do {$machine = get_sol2();  last; };
    die "Unknown architecture value: $ARCH\n";

}

# Return the address/ID along with the process number ($$).
print($machine . " " . $$);
exit(0);


##
## Machine-specific subfunctions
##

sub get_alpha {

    # Look for the ethernet address.
    $shell_result = `netstat -i`;
    $shell_result =~ s/(\w{1,2}:.{1,2}:.{1,2}:.{1,2}:.{1,2}:\w{1,2})//;

    # Remove the colons and reconstitute the hex string.
    @fields = split(/:/, $1);
    
    $out = "";
    
    foreach(@fields) {
        $out = $out . sprintf("%02s", $_);
    }

    return $out;
}



sub get_linux {

    # Look for the ethernet address.
    $shell_result = `/sbin/ifconfig eth0`;
    $shell_result =~ s/(\w{1,2}:.{1,2}:.{1,2}:.{1,2}:.{1,2}:\w{1,2})//;

    # Remove the colons and reconstitute the hex string.
    @fields = split(/:/, $1);
    
    $out = "";
    
    foreach(@fields) {
        $out = $out . sprintf("%02s", $_);
    }

    return $out;
}



sub get_mac {

    # Look for the ethernet address.
    $shell_result = `/sbin/ifconfig en0`;
    $shell_result =~ s/(\w{1,2}:.{1,2}:.{1,2}:.{1,2}:.{1,2}:\w{1,2})//;

    # Remove the colons and reconstitute the hex string.
    @fields = split(/:/, $1);
    
    $out = "";
    
    foreach(@fields) {
        $out = $out . sprintf("%02s", $_);
    }

    return $out;
}



sub get_hp {

    # Look for the ethernet address (aka "Station Name").
    $shell_result = `/etc/lanscan -a`;

    # Get the value of the first card listed and remove "0x".
    $shell_result =~ s/0x(\w{12})//;

    return $1;
}



sub get_ibmrs {

    # Get the 32-bit host ID.  The 3rd - 10th values are the host ID.
    $shell_result = `uname -m`;
    $shell_result =~ s/\w{2}(\w{8})\w{2}//;

    return "01" . $1;
}



sub get_sgi {

    # Get the 32-bit host ID and convert it to hex.
    return "02" . sprintf("%X", `/etc/sysinfo -s`);
}



sub get_sol2 {

    # Get the 32-bit host ID.
    $shell_result = `hostid`;
    chomp($shell_result);

    return "03" . $shell_result;
}
