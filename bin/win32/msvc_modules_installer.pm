package msvc_modules_installer;

# $Revision: 1.3 $

use Exporter ();
@ISA = qw(Exporter);

@EXPORT = qw(install_msvc_modules);

use File::Copy;
use getprofiledir;
use strict;

sub merge
{
    my ($src, $dst) = @_;
    my (@srcfile, @dstfile);
    my (%uhash);

    open(SRCFILE, "$src") || return 0;
    chomp(@srcfile = <SRCFILE>);
    close(SRCFILE);

    @dstfile = ();
    open(DSTFILE, "$dst") && chomp(@dstfile = <DSTFILE>) && close(DSTFILE);

    %uhash = map { $_, $_ } (@srcfile, @dstfile);

    open(DSTFILE, ">$dst") || return 0;
    foreach (sort keys %uhash)
    {
        print DSTFILE "$_\n";
    }
    close(DSTFILE);
    return 1;
}

sub install_msvc_modules
{
    my ($specified_compiler_location, $filetable_ref, $matlab_bin) = @_;

    my (@filetable) = @$filetable_ref;

    my ($warnings_issued) = 0;

    print "Installing the MATLAB Visual Studio add-in ...\n\n";
    
    for (my $i = 0; $i < @filetable; $i++)
    {
        my $fname = $specified_compiler_location . $filetable[$i]->[1] . "\\" .
            $filetable[$i]->[0];
        
        chmod 0777, $fname;
    
        if ($filetable[$i]->[0] eq "usertype.dat" && 
            &merge("$matlab_bin\\$filetable[$i]->[0]", "$fname"))
        {
            print "  Merged $matlab_bin\\$filetable[$i]->[0]\n    with $fname\n";
        }
        elsif (copy("$matlab_bin\\$filetable[$i]->[0]", "$fname"))
        {
            print "  Updated $fname\n    from " . 
                "$matlab_bin\\$filetable[$i]->[0]\n";
        }
        else
        {
            print "  Warning: Could not update $fname\n    from " . 
                "$matlab_bin\\$filetable[$i]->[0]\n";
            
            $warnings_issued = 1;
        }
    }

    if ($warnings_issued)
    {
        print(<<'end_notice');

  Note: One or more components necessary to the operation of the MATLAB Visual
        Studio add-in could not be installed. The MATLAB Visual Studio add-in
        will not be available, but the rest of this setup operation will 
        continue normally.
end_notice
    }
    
    print "\n";
    
    if (-f "$matlab_bin\\mcc.exe" && ! -f &get_user_profile_dir() . "\\mccpath"
        && !$warnings_issued)
    {
        print "Note: If you want to use the MATLAB Visual Studio add-in with the MATLAB C/C++\n";
        print "      Compiler, you must start MATLAB and run the following commands:\n\n";
        print "      cd(prefdir);\n";
        print "      mccsavepath;\n\n";
        print "      (You only have to do this configuration step once.)\n\n";
    }
}
