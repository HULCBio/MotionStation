package Win32::AdminMisc;

#
#AdminMisc.pm
#   (c) 1996-1999 By Dave Roth <rothd@roth.net>
#   Courtesy of Roth Consulting
#   http://www.roth.net/consult

require Exporter;
require DynaLoader;

$PACKAGE = $Package = "Win32::AdminMisc";
$VERSION = 19990405;
 
die "The $Package module works only on Windows NT" if (!Win32::IsWinNT() );

@ISA= qw( Exporter DynaLoader );
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
    LOGON32_LOGON_INTERACTIVE
    LOGON32_LOGON_BATCH
    LOGON32_LOGON_SERVICE
    LOGON32_LOGON_NETWORK

    FILTER_TEMP_DUPLICATE_ACCOUNT
    FILTER_NORMAL_ACCOUNT
    FILTER_INTERDOMAIN_TRUST_ACCOUNT
    FILTER_WORKSTATION_TRUST_ACCOUNT
    FILTER_SERVER_TRUST_ACCOUNT

    UF_TEMP_DUPLICATE_ACCOUNT
    UF_NORMAL_ACCOUNT
    UF_INTERDOMAIN_TRUST_ACCOUNT
    UF_WORKSTATION_TRUST_ACCOUNT
    UF_SERVER_TRUST_ACCOUNT
    UF_MACHINE_ACCOUNT_MASK
    UF_ACCOUNT_TYPE_MASK
    UF_DONT_EXPIRE_PASSWD
    UF_SETTABLE_BITS
    UF_SCRIPT
    UF_ACCOUNTDISABLE
    UF_HOMEDIR_REQUIRED
    UF_LOCKOUT
    UF_PASSWD_NOTREQD
    UF_PASSWD_CANT_CHANGE

    USE_FORCE
    USE_LOTS_OF_FORCE
    USE_NOFORCE

    USER_PRIV_MASK
    USER_PRIV_GUEST
    USER_PRIV_USER
    USER_PRIV_ADMIN

    DRIVE_REMOVABLE
    DRIVE_FIXED
    DRIVE_REMOTE
    DRIVE_CDROM
    DRIVE_RAMDISK


    EWX_LOGOFF
    EWX_FORCE
    EWX_POWEROFF
    EWX_REBOOT
    EWX_SHUTDOWN

    STARTF_USESHOWWINDOW
    STARTF_USEPOSITION
    STARTF_USESIZE
    STARTF_USECOUNTCHARS
    STARTF_USEFILLATTRIBUTE
    STARTF_FORCEONFEEDBACK
    STARTF_FORCEOFFFEEDBACK
    STARTF_USESTDHANDLES

    CREATE_DEFAULT_ERROR_MODE
    CREATE_NEW_CONSOLE
    CREATE_NEW_PROCESS_GROUP
    CREATE_SEPARATE_WOW_VDM
    CREATE_SUSPENDED
    CREATE_UNICODE_ENVIRONMENT
    DEBUG_PROCESS
    DEBUG_ONLY_THIS_PROCESS
    DETACHED_PROCESS;

    HIGH_PRIORITY_CLASS
    IDLE_PRIORITY_CLASS
    NORMAL_PRIORITY_CLASS
    REALTIME_PRIORITY_CLASS

    SW_HIDE
    SW_MAXIMIZE
    SW_MINIMIZE
    SW_RESTORE
    SW_SHOW
    SW_SHOWDEFAULT
    SW_SHOWMAXIMIZED
    SW_SHOWMINIMIZED
    SW_SHOWMINNOACTIVE
    SW_SHOWNA
    SW_SHOWNOACTIVATE
    SW_SHOWNORMAL

    STD_INPUT_HANDLE
    STD_OUTPUT_HANDLE
    STD_ERROR_HANDLE

    FOREGROUND_RED
    FOREGROUND_BLUE
    FOREGROUND_GREEN
    FOREGROUND_INTENSITY
    BACKGROUND_RED
    BACKGROUND_BLUE
    BACKGROUND_GREEN
    BACKGROUND_INTENSITY

    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
    JOB_ADD_CURRENT_DATE
    JOB_RUN_PERIODICALLY
    JOB_EXEC_ERROR
    JOB_RUNS_TODAY
    JOB_NONINTERACTIVE

    ENV_SYSTEM
    ENV_USER

    GROUP_TYPE_ALL
    GROUP_TYPE_LOCAL
    GROUP_TYPE_GLOBAL

    FS_CASE_IS_PRESERVED 
    FS_CASE_SENSITIVE 
    FS_UNICODE_STORED_ON_DISK 
    FS_PERSISTENT_ACLS 
    FS_FILE_COMPRESSION 
    FS_VOL_IS_COMPRESSED

    AF_OP_PRINT
    AF_OP_COMM
    AF_OP_SERVER
    AF_OP_ACCOUNTS

);


sub AUTOLOAD 
{
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.  If a constant is not found then control is passed
    # to the AUTOLOAD in AutoLoader.

    my( $Constant ) = $AUTOLOAD;
    my( $Result, $Value );
    $Constant =~ s/.*:://;

    $Result = GetConstantValue( $Constant, $Value );

    if( 0 == $Result )
    {
        # The extension could not resolve the constant...
        $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
        return;
    }
    elsif( 1 == $Result )
    {
        # $Result == 1 if the constant is valid but not defined
        # that is, the extension knows that the constant exists but for
        # some wild reason it was not compiled with it.
        $pack = 0; 
        ($pack,$file,$line) = caller;
        print "Your vendor has not defined $Package macro $constname, used in $file at line $line.";
    }
    elsif( 2 == $Result )
    {
        # If $Result == 2 then we have a string value
        $Value = "'$Value'";
    }
        # If $Result == 3 then we have a numeric value

    eval "sub $AUTOLOAD { return( $Value ); }";
    goto &$AUTOLOAD;
}


bootstrap $Package;

# Preloaded methods go here.

# Autoload methods go after __END__, and are processed by the autosplit program.

1;
__END__










