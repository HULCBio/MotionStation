package Win32::Service;

#
# Service.pm
# Written by Douglas_Lankshear@ActiveWare.com
#
# subsequently hacked by Gurusamy Sarathy <gsar@umich.edu>
#

$VERSION = '0.04';

require Exporter;
require DynaLoader;

die "The Win32::Service module works only on Windows NT" if(!Win32::IsWinNT());

@ISA= qw( Exporter DynaLoader );
@EXPORT_OK =
    qw(
	StartService
	StopService
	GetStatus
	PauseService
	ResumeService
	GetServices
    );

=head1 NAME

Win32::Service - manage system services in perl

=head1 SYNOPSIS

	use Win32::Service;

=head1 DESCRIPTION

This module offers control over the administration of system services.

=head1 FUNCTIONS

=head2 NOTE:

All of the functions return FALSE (0) if they fail, unless otherwise noted.
If hostName is an empty string, the local machine is assumed.

=over 10

=item StartService(hostName, serviceName)

Start the service serviceName on machine hostName.

=item StopService(hostName, serviceName)

Stop the service serviceName on the machine hostName.

=item GetStatus(hostName, serviceName, status) 

Get the status of a service.

=item PauseService(hostName, serviceName)

=item ResumeService(hostName, serviceName)

=item GetServices(hostName, hashref) 

Enumerates both active and inactive Win32 services at the specified host.
The hashref is populated with the descriptive service names as keys
and the short names as the values.

=back

=cut

sub AUTOLOAD
{
    my($constname);
    ($constname = $AUTOLOAD) =~ s/.*:://;
    #reset $! to zero to reset any current errors.
    $!=0;
    my $val = constant($constname);
    if ($! != 0) {
	if($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    ($pack,$file,$line) = caller;
	    die "Your vendor has not defined Win32::Service macro $constname, used in $file at line $line.";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

bootstrap Win32::Service;

1;
__END__
