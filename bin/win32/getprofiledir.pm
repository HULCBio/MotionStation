package getprofiledir;

# $Revision: 1.3.4.2 $

use Exporter ();
@ISA = qw(Exporter);

@EXPORT = qw(get_user_profile_dir);

use Win32::Registry;
use strict;

# This function is responsible for obtaining the directory name in which
# mexopts.bat and mbuildopts.bat should be stored.
sub get_user_profile_dir
{
# outputs:
    my ($userProfile);

    # UserProfile environment variable is set by NT only.
    $userProfile = $ENV{'UserProfile'};
    if ($userProfile eq "")
    {
        my ($RegKey, $RegValue, $hkey, $value, %values);

        # ProfileReconciliation is set on Win95/98 if User Profiles are 
        # enabled.
        if ($main::HKEY_CURRENT_USER->Open("Software\\Microsoft\\Windows\\" .
                                           "CurrentVersion\\ProfileReconciliation",
                                           $hkey))
        {
            $hkey->GetValues(\%values);
            foreach $value (keys(%values))
            {
                $RegKey = $values{$value}->[0];
                $RegValue = $values{$value}->[2];
                if ($RegKey eq "ProfileDirectory") {
                    $userProfile = $RegValue;
                }
            }
            $hkey->Close();
        }

        if ($userProfile eq "")
        {
            $userProfile = $ENV{'windir'};
        }
    }

    $userProfile .= "\\Application Data\\MathWorks\\MATLAB\\R14";

    $userProfile;
} # get_user_profile_dir
