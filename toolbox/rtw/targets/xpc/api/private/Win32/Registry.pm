package Win32::Registry;
#######################################################################
#Perl Module for Registry Extensions
# This module creates an object oriented interface to the Win32
# Registry.
#
# NOTE: This package exports the following "key" objects to
# the main:: name space.
#
# $main::HKEY_CLASSES_ROOT
# $main::HKEY_CURRENT_USER
# $main::HKEY_LOCAL_MACHINE
# $main::HKEY_USERS
# $main::HKEY_PERFORMANCE_DATA
# $main::HKEY_CURRENT_CONFIG
# $main::HKEY_DYN_DATA
#######################################################################
#$Revision: 1.1 $ $Date: 2002/02/22 20:53:52 $

require Exporter;
require DynaLoader;
use Win32::WinError;

$VERSION = '0.06';

@ISA= qw( Exporter DynaLoader );
@EXPORT = qw(
	HKEY_CLASSES_ROOT
	HKEY_CURRENT_USER
	HKEY_LOCAL_MACHINE
	HKEY_PERFORMANCE_DATA
	HKEY_CURRENT_CONFIG
	HKEY_DYN_DATA
	HKEY_USERS
	KEY_ALL_ACCESS
	KEY_CREATE_LINK
	KEY_CREATE_SUB_KEY
	KEY_ENUMERATE_SUB_KEYS
	KEY_EXECUTE
	KEY_NOTIFY
	KEY_QUERY_VALUE
	KEY_READ
	KEY_SET_VALUE
	KEY_WRITE
	REG_BINARY
	REG_CREATED_NEW_KEY
	REG_DWORD
	REG_DWORD_BIG_ENDIAN
	REG_DWORD_LITTLE_ENDIAN
	REG_EXPAND_SZ
	REG_FULL_RESOURCE_DESCRIPTOR
	REG_LEGAL_CHANGE_FILTER
	REG_LEGAL_OPTION
	REG_LINK
	REG_MULTI_SZ
	REG_NONE
	REG_NOTIFY_CHANGE_ATTRIBUTES
	REG_NOTIFY_CHANGE_LAST_SET
	REG_NOTIFY_CHANGE_NAME
	REG_NOTIFY_CHANGE_SECURITY
	REG_OPENED_EXISTING_KEY
	REG_OPTION_BACKUP_RESTORE
	REG_OPTION_CREATE_LINK
	REG_OPTION_NON_VOLATILE
	REG_OPTION_RESERVED
	REG_OPTION_VOLATILE
	REG_REFRESH_HIVE
	REG_RESOURCE_LIST
	REG_RESOURCE_REQUIREMENTS_LIST
	REG_SZ
	REG_WHOLE_HIVE_VOLATILE
);

@EXPORT_OK = qw(
    RegCloseKey
    RegConnectRegistry
    RegCreateKey
    RegCreateKeyEx
    RegDeleteKey
    RegDeleteValue
    RegEnumKey
    RegEnumValue
    RegFlushKey
    RegGetKeySecurity
    RegLoadKey
    RegNotifyChangeKeyValue
    RegOpenKey
    RegOpenKeyEx
    RegQueryInfoKey
    RegQueryValue
    RegQueryValueEx
    RegReplaceKey
    RegRestoreKey
    RegSaveKey
    RegSetKeySecurity
    RegSetValue
    RegSetValueEx
    RegUnLoadKey
);
$EXPORT_TAGS{ALL}= \@EXPORT_OK;

bootstrap Win32::Registry;

sub import
{
    my( $pkg )= shift;
    if (  $_[0] && "Win32" eq $_[0]  ) {
	Exporter::export( $pkg, "Win32", @EXPORT_OK );
	shift;
    }
    Win32::Registry->export_to_level( 1+$Exporter::ExportLevel, $pkg, @_ );
}

#######################################################################
# This AUTOLOAD is used to 'autoload' constants from the constant()
# XS function.  If a constant is not found then control is passed
# to the AUTOLOAD in AutoLoader.

sub AUTOLOAD {
    my($constname);
    ($constname = $AUTOLOAD) =~ s/.*:://;
    #reset $! to zero to reset any current errors.
    $!=0;
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
	    ($pack,$file,$line) = caller;
	    die "Your vendor has not defined Win32::Registry macro $constname, used at $file line $line.";
	}
    }
    eval "sub $AUTOLOAD { $val }";
    goto &$AUTOLOAD;
}

#######################################################################
# _new is a private constructor, not intended for public use.
#

sub _new
{
    my $self;
    if ($_[0]) {
	$self->{'handle'} = $_[0];
	bless $self;
    }
    $self;
}

#define the basic registry objects to be exported.
#these had to be hardwired unfortunately.
# XXX Yuck!

$main::HKEY_CLASSES_ROOT	= _new(&HKEY_CLASSES_ROOT);
$main::HKEY_CURRENT_USER	= _new(&HKEY_CURRENT_USER);
$main::HKEY_LOCAL_MACHINE	= _new(&HKEY_LOCAL_MACHINE);
$main::HKEY_USERS		= _new(&HKEY_USERS);
$main::HKEY_PERFORMANCE_DATA	= _new(&HKEY_PERFORMANCE_DATA);
$main::HKEY_CURRENT_CONFIG	= _new(&HKEY_CURRENT_CONFIG);
$main::HKEY_DYN_DATA		= _new(&HKEY_DYN_DATA);


#######################################################################
#Open
# creates a new Registry object from an existing one.
# usage: $RegObj->Open( "SubKey",$SubKeyObj );
#               $SubKeyObj->Open( "SubberKey", *SubberKeyObj );

sub Open
{
    my $self = shift;
    die 'usage: Open( $SubKey, $ObjRef )' if @_ != 2;
    
    my ($subkey) = @_;
    my ($result,$subhandle);

    $result = RegOpenKey($self->{'handle'},$subkey,$subhandle);
    $_[1] = _new( $subhandle );
    
    return 0 unless $_[1];
    $! = Win32::GetLastError() unless $result;
    return $result;
}

#######################################################################
#Close
# close an open registry key.
#
sub Close
{
    my $self = shift;
    die "usage: Close()" if @_ != 0;

    my $result = RegCloseKey($self->{'handle'});
    $! = Win32::GetLastError() unless $result;
    return $result;
}

#QueryKey
# QueryKey "    "       "       "  key  "       "       "       

sub QueryKey
{
    my $garbage;
    my $self = shift;
    die 'usage: QueryKey( $classref, $numberofSubkeys, $numberofVals )'
        if @_ != 2;


    my $result = RegQueryInfoKey($self->{'handle'}, $garbage,
                                 $garbage, $garbage, $_[0],
                                 $garbage, $garbage, $_[1],
                                 $garbage, $garbage, $garbage, $garbage);


    $! = Win32::GetLastError() unless $result;
    return $result;
}
1;
__END__
