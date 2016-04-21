#GETPHLPATHS Perl script for locating paths to installed MathWorks products.
#   PERL GETPHLPATHS.PL MATLABROOT returns a path separator-separated 
#   string of all the installed MathWorks products' search paths. It finds 
#   these paths by prepeding MATLABROOT to the partial paths listed in each 
#   of the PHL-files found in the root MATLAB/toolbox directory structure.
#   
#   See also RESTOREDEFAULTPATH, SAVEPATH, MATLABRC

#   Copyright 1984-2003 The MathWorks, Inc. 
#   $Revision: 1.1.6.1 $  $Date: 2003/11/06 15:41:57 $

use File::Find;
use Cwd;

# Determine the MATLABROOT
$matlabroot = $ARGV[0] . '/';

# Determine whether we are on UNIX or DOS
# so that we can define the OS pathsep and filesep
($^O =~ /Win/) ? ($isunix = 0) : ($isunix = 1);
if ($isunix) {
    $ps = ':';
    $fs = '/';
} else {
    $ps = ';';
    $fs = '\\';
}   

# Initialize our list of PHL files
@PHLfiles = ();

# If there is a $MATLAB/toolbox/local/path dir, then find the PHL files there (installed version)
# or else we have to search the entire MATLABROOT directory tree
$phlpathdir = $matlabroot . 'toolbox' . $fs . 'local' . $fs . 'path' . $fs;
if (-e $phlpathdir) {
    opendir(HDIR, "$phlpathdir") or die "Cannot open $phlpathdir : $!";
    @PHLfiles = grep { /phl$/ } readdir(HDIR);
    foreach $PHLfile (@PHLfiles) {
        $PHLfile = $phlpathdir . $PHLfile;
    }
    closedir(HDIR) or die "Cannot close $phlpathdir : $!";
} else {
    find(\&getPHLs, $matlabroot . 'toolbox');
}

# Initialize the path list
$defaultpath = '';
@paths = ();

# Look through the PHL files to form a list of paths
foreach $PHLfile (@PHLfiles)
{
    open(HFILE, "$PHLfile") or die "Cannot open $PHLfile : $!";
    while(<HFILE>) {
        chomp;
        push(@paths,$_);
    }
    close(HFILE) or die "Cannot close $PHLfile : $!";
}

# Sort the paths appropriately
# MATLAB, local, Simulink, Stateflow, RTW, and the rest
@sortedpaths = ();
@paths = sort(@paths);
push(@sortedpaths, grep(/^toolbox\/matlab\//, @paths));
@remainingpaths = grep(!/^toolbox\/matlab\//, @paths);
push(@sortedpaths, grep(/^toolbox\/local/, @remainingpaths));
@remainingpaths = grep(!/^toolbox\/local/, @remainingpaths);
push(@sortedpaths, grep(/^toolbox\/simulink\//, @remainingpaths));
@remainingpaths = grep(!/^toolbox\/simulink\//, @remainingpaths);
push(@sortedpaths, grep(/^toolbox\/stateflow\//, @remainingpaths));
@remainingpaths = grep(!/^toolbox\/stateflow\//, @remainingpaths);
push(@sortedpaths, grep(/^toolbox\/rtw\//, @remainingpaths));
@remainingpaths = grep(!/^toolbox\/rtw\//, @remainingpaths);
push(@sortedpaths, @remainingpaths);

# For each non-empty entry, concatenate the MATLABROOT to the path
# Replace PERL "/" with the appropriate OS filesep
foreach $path (@sortedpaths)
{
    chomp($path);
    $path = $matlabroot . $path;
    $path =~ s/\//$fs/g;
}

$path = join($ps, @sortedpaths);
print $path;

# Subroutine used by File::Find to search MATLABROOT tree for PHL files
sub getPHLs 
{
    /^private$/ and $File::Find::prune = 1;
    /^\@/ and $File::Find::prune = 1;
    /^ja$/ and $File::Find::prune = 1;
    /^CVS$/ and $File::Find::prune = 1;
    /\.phl$/ or return;
    push(@PHLfiles, $File::Find::name);
}
    

 