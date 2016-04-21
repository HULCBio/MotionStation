#
#  Name:
#     mex/mbuild Perl script for PC only.
# 
#     mex	 compilation program for MATLAB C/C++ and Fortran
#                language MEX-files
#
#     mbuild	 compilation program for executable programs for
#                the MATLAB compiler.
#
#  Usage:
#     MEX [option1 ... optionN] sourcefile1 [... sourcefileN]
#     [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
#
#     MBUILD [option1 ... optionN] sourcefile1 [... sourcefileN]
#     [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
#     [exportfile1 ... exportfileN]
#
#  Description:
#     This Perl program provides dual functionality for MEX and MBUILD.
#     The input argument '-mb' targets the routine to do MBUILD. 
#     Otherwise, it does MEX.
#     
#  Options:
#
#     See the 'describe' subroutine below for the MEX options.
#
#     See the 'describe_mb' subroutine below for the MBUILD options.
#
#  Options (undocumented):
#
#     -setup:$compiler[:$optionfile_type]
#
#           $compiler must be taken from the option file name:
#
#	      <compiler>[<optionfile_type>]opts.bat  (mex)
#	      <compiler>compp.bat                    (mbuild)
#
#           Currently, <optionfile_type> = 'engmat' for mex only.
#
#     -f $destination
#
#           Where to put the options file. $destination must
#	    be $dir/$file where at least $dir exists and is
#	    writable. It can be used only with -setup. If
#	    not used the file is put in the default location:
#
#	    PC: 
#           --
#
#        <UserProfile>\Application Data\MathWorks\MATLAB\R<version>
#
#           where
#
#	      <UserProfile>    Is the value determined by Perl
#			       subroutine:
#
#			       get_user_profile_dir
#
#			 file: $MATLAB\bin\win32\getprofiledir.pm
#			   
#	      <version>        MATLAB Release number like 14.
#
#	    UNIX/Linux/Mac: 
#           --------------
#
#	 $HOME/.matlab/R<version>
#
#           where
#
#	      <version>        MATLAB Release number like 14.
#
#  Option files:
#
#     mex:    $MATLAB\bin\win32\mexopts\*.stp
#	      $MATLAB\bin\win32\mexopts\*.bat
#
#             *opts.bat        files are 'installed' by -setup.
#	      *engmatopts.bat  files are arguments using -f only.
#
#     mbuild: $MATLAB\win\win32\mbuildopts\*.stp
#             $MATLAB\win\win32\mbuildopts\*.bat
#
#
#  Call structure:
#
#     mex.pl
#        -> mexsetup.pm
#           -> getprofiledir.pm
#           MEX:
#              -> mexopts/<compiler>opts.stp
#	          (compiler == msvc50 || msvc60)
#		     -> msvc_modules_installer.pm 
#	       -> mexopts/<compiler>opts.bat
#                 (compiler == bcc53 || bcc54 || bcc55 || bcc55free
#			       bcc56)
#	             -> link_borland_mex.pl
#              -> mexopts/<compiler>engmatopts.bat
#
#           MBUILD:
#	       -> mbuildopts/<compiler>compp.stp
#	          (compiler == msvc50 || msvc60)
#		     -> msvc_modules_installer.pm 
#              -> mbuildopts/<compiler>compp.bat
#                 (compiler == bcc54 || bcc55 || bcc55free || bcc56)
#	             -> link_borland_mex.pl
#
#  Globals:
#
#     $main::mbuild           => {"yes", "no"}
#                                mbuild or mex?
#     $main::script_directory => string with $MATLAB\bin in it.
#     $main::cmd_name         => {"MBUILD.BAT", "MEX.BAT"}
#     $main::no_execute       => {0, 1}
#                                RunCmd execute command?
#                                (used by -n switch)
#  Internals:
#
#     @setup_args = ($compiler,$optionsfile_type,$destination)
#
#                    $compiler,$optionsfile_type values come from the
#                        '-setup' argument.       
#                    $destination value comes from the '-f' argument.
#
# Copyright 1984-2004 The MathWorks, Inc.
# $Revision: 1.161.4.11 $
#__________________________________________________________________________
#
#=======================================================================
BEGIN
{
    #===================================================================
    # Set @INC for 5.00503 perl.
    # If perl gets upgraded, this may have to be changed.
    #===================================================================
    if ( $] < 5.00503 ) {
	die "ERROR: This script requires perl 5.00503 or higher.
You have perl $] installed on your machine and you did not set MATLAB variable,
so the correct version of perl could not be found";
    }
    if ( ! $ENV{"MATLAB"} ) {
	my($f) = $0;
	$f =~ s%[\\/][\w\.]+[\\/]\.\.[\\/]%\\%g;
	$f =~ s%^[^\.][^\\/]+[\\/]\.\.[\\/]%%g;
	# print "$0 -> $f ";
	$0 = $f;
	if ($f =~ s%^bin[\\/]win32[\\/].*%% ) {
	    $f = '.';
	} elsif ($f =~ s%[\\/]bin[\\/]win32[\\/].*%% ) {
	    # fine
	} else {
	    $f .= "\\..\\..\\..";
	    $f =~ s%\\[^\.][^\\]+\\\.\.\\%\\%g;
	    $f =~ s%^[^\.][^\\]+\\\.\.\\%%g;
	}
	# print "-> $f\n";
	$ENV{'MATLAB'} = $f;
    }
    if ( $ENV{'MATLAB'} ) {
	unshift (@INC, map { "$ENV{MATLAB}/sys/perl/win32/$_" }
		 ("lib", "site/lib"));
        push(@INC, "$ENV{MATLAB}/bin/win32");
    } else {
	warn "WARNING: MATLAB variable is not set.";
    }
}
#=======================================================================

use Cwd;
use mexsetup;
use getprofiledir;
use File::DosGlob 'glob';
use File::Basename;
require "shellwords.pl";  # Found in $MATLAB/sys/perl/win32/lib
                          # This is necessary to break up the text in
			  # the file into shell arguments. This is used
			  # to support the @<rspfile> argument.

########################################################################
#=======================================================================
# Common subroutines:
#=======================================================================
#
# compile_files:	     Compile files and form list of files to
#                            link.
# compile_resource:	     Compile the resource.
# do_setup:		     Do only the setup.
# emit_compile_step:	     Output compile step to makefile.
# emit_delete_resource_file: Output delete resource file to makefile.
# emit_link_dependency:	     Output link dependency to makefile.
# emit_linker_step:          Output linker step to makefile.
# emit_makedef:		     Output makedef step to makefile.
# emit_makefile_terminator:  Output terminator for makefile.
# emit_postlink_step:	     Output postlink step to makefile.
# emit_prelink:		     Output prelink step to makefile.
# emit_resource_compiler:    Output resource compile step to makefile.
# emit_resource_linker_step: Output resource linker step to makefile.
# expand_wildcards:          Expand possible wildcards in the arguments
#                            for perl >= 5.00503
# expire:                    Die but with cleanup.
# find_options_file: 	     Find the options file.
# fix_common_variables:      Fix common variables.
# fix_flag_variables:	     Fix the flag variables.
# files_to_remove:	     Add files to remove list.
# init_common:		     Common initialization.
# linker_arguments:          Create response file of linker arguments or
#                            just string.		
# link_files:		     Link files.
# options_file:              Get options file if not passed as an
#                            argument. Source the options file.
# parse_common_dash_args:    Parse the common dash arguments.
# parse_common_nodash_args:  Parse the common non-dash arguments.
# postlink:		     Do postlink steps.
# prelink:		     Do prelink steps.
# process_overrides:         Process command line overrides.
# process_response_file:     Run shellwords on filename argument.
# rectify_path:              Check path for system directories and add
#                            them if not present.
# resource_linker:	     Run resource linker.
# RunCmd: 		     Run a single command.
# search_path:		     Search DOS PATH environment for $binary_name
#                            argument
# set_common_variables:      Set more common variables.
# smart_quote:		     Add quotes around strings with space.
# start_makefile:	     Open and write the main dependency to the
#                            makefile.
# tool_name:		     Returns the tool name, i.e. mex or mbuild.
#
#-----------------------------------------------------------------------
#
# Common variables:
#
#   perl:
#
#     FILES_TO_REMOVE
#     FILES_TO_LINK
#     FLAGS
#     LINKFLAGS
#     MAKEFILE
#
#   DOS environment:
#
#     PATH                      system path
#     MATLAB			MATLAB root
#
#     [$ENV: get in script]
#       MEX_DEBUG		This is for debugging this script.
#
#     [$ENV: set in script]
#       LIB_NAME
#       MATLAB			MATLAB root
#       MATLAB_BIN
#       MATLAB_EXTLIB
#       OUTDIRN
#       OUTDIR
#       RES_NAME
#       RES_PATH
#  
#=======================================================================
sub compile_files
{
    #===================================================================
    # compile_files: Compile files and form list of files to link.
    #===================================================================

    # Loop over @FILES to compile each file.  Keep files we actually
    # compile separate from the ones we don't compile but need to link.
    # This way, we can later clean up all .obj files we created.
    #
    for (;$_=shift(@FILES);) {
        ($FILENAME, $EXTENSION) = (/([ \w]+)\.(\w*)$/);
        if ($EXTENSION =~ /($COMPILE_EXTENSION)$/i ) {
	    my ($target_name, $name_arg);
            if ($NAME_OBJECT) {
                $target_name = "$ENV{'OUTDIR'}$FILENAME.obj";
                $name_arg = $NAME_OBJECT . &smart_quote($target_name);
            }
            else {
                $target_name = "$FILENAME.obj";
                $name_arg = "";
            }

	    my ($args) =
	        "$ARG_FLAGS $COMPFLAGS $name_arg $FLAGS " . &smart_quote($_);

            if (!$makefilename)
            {
                my $messages = RunCmd("$COMPILER $args");
 
                # Check for error; $? might not work, so also check for resulting file
                #
                if ($? != 0 || !(-e "$target_name" || $main::no_execute)) {
                    print "$messages" unless $verbose; # verbose => printed in RunCmd
                    &expire("Error: Compile of '$_' failed.");
                }
                if (!$compile_only)
                {
                    push(@FILES_TO_REMOVE, "$target_name");
                }
            }
            else
            {
		&emit_compile_step();
            }

            push(@FILES_TO_LINK, "$LINK_FILE " . &smart_quote($target_name));
            push(@FILES_TO_LINK_BASE, &smart_quote($target_name));
        }
        elsif ($EXTENSION =~ /lib$/i)
        {
            push(@FILES_TO_LINK, "$LINK_LIB " . &smart_quote($_));
            push(@FILES_TO_LINK_BASE, &smart_quote($_));
        }
        else
        {
            push(@FILES_TO_LINK, "$LINK_FILE " . &smart_quote($_));
            push(@FILES_TO_LINK_BASE, &smart_quote($_));
        }
    }
}
#=======================================================================
sub compile_resource
{
    #===================================================================
    # compile_resource: Compile the resource.
    #===================================================================

    my ($rc_line) = '';
    $rc_line .= " -DARRAY_ACCESS_INLINING" if ($inline);
    $rc_line .= " -DV5_COMPAT" if ($v5);
    $rc_line .= " " . &smart_quote("$ENV{'RES_PATH'}$ENV{'RES_NAME'}.rc");

    if (!$makefilename)
    {
        my $messages = RunCmd("$RC_COMPILER $rc_line");

        # Check for error; $? might not work, so also check for string "error"
        #
        if ($? != 0 || $messages =~ /\b(error|fatal)\b/i) {
            print "$messages" unless $verbose; # verbose => printed out in RunCmd
            &expire("Error: Resource compile of '$ENV{'RES_NAME'}.rc' failed.");
        }
        push(@FILES_TO_REMOVE, "$ENV{'OUTDIR'}$ENV{'RES_NAME'}.res");
    }
    else
    {
        &emit_resource_compiler();
    }
    
    push(@FILES_TO_LINK, &smart_quote("$ENV{'OUTDIR'}$ENV{'RES_NAME'}.res"));
}
#=======================================================================
sub do_setup
{
    #===================================================================
    # do_setup: Do only the setup.
    #===================================================================

    if ($setup) { 
        @setup_args = (); 
        (!&setup(&tool_name, $main::script_directory, 
            ['ANY'], 0, \@setup_args)) || exit(1); # 0 == no automode
    } else {
        (!&setup(&tool_name, $main::script_directory, 
            ['ANY'], 2, \@setup_args)) || exit(1); # 2 == full automode
    }
}
#=======================================================================
sub emit_compile_step
{
    #===================================================================
    # emit_compile_step: Output compile step to makefile.
    #===================================================================

    # Emit compile dependency rule
    #
    print MAKEFILE &smart_quote($target_name) . " : " . &smart_quote($_);
    print MAKEFILE "\n\t$COMPILER $args\n\n";
}
#=======================================================================
sub emit_delete_resource_file
{
    #===================================================================
    # emit_delete_resource_file: Output delete resource file to makefile.
    #===================================================================

    print MAKEFILE "\tif exist \"$ENV{'OUTDIR'}$ENV{'RES_NAME'}.res\" del \"$ENV{'OUTDIR'}$ENV{'RES_NAME'}.res\"\n";
}
#=======================================================================
sub emit_link_dependency
{
    #===================================================================
    # emit_link_dependency: Output link dependency to makefile.
    #===================================================================

    # Emit link dependency rule
    #
    print MAKEFILE "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension";
    print MAKEFILE " : @FILES_TO_LINK_BASE\n";
}
#=======================================================================
sub emit_linker_step
{
    #===================================================================
    # emit_linker_step: Output linker step to makefile.
    #===================================================================

    print MAKEFILE "\t$LINKER $ARGS\n";
}
#=======================================================================
sub emit_makedef
{
    #===================================================================
    # emit_makedef: Output makedef step to makefile.
    #===================================================================

    print MAKEFILE "\t$makedef\n";
}
#=======================================================================
sub emit_makefile_terminator
{
    #===================================================================
    # emit_makefile_terminator: Output terminator for makefile.
    #===================================================================

    print MAKEFILE "\n";
}
#=======================================================================
sub emit_postlink_step
{
    #===================================================================
    # emit_postlink_step: Output postlink step to makefile.
    #===================================================================

    print MAKEFILE "\t$postlink\n";
}
#=======================================================================
sub emit_prelink
{
    #===================================================================
    # emit_prelink: Output prelink step to makefile.
    #===================================================================

    print MAKEFILE "\t$prelink\n";
}
#=======================================================================
sub emit_resource_compiler
{
    #===================================================================
    # emit_resource_compiler: Output resource compile step to makefile.
    #===================================================================

    print MAKEFILE "\t$RC_COMPILER $rc_line\n";
}
#=======================================================================
sub emit_resource_linker_step
{
    #===================================================================
    # emit_resource linker_step: Output resource linker step to makefile
    #===================================================================

    print MAKEFILE "\t$RC_LINKER $rc_line\n";
}
#=======================================================================
sub expand_wildcards
{
    #===================================================================
    # expand_wildcards: Expand possible wildcards in the arguments
    #                   for perl >= 5.00503
    #===================================================================

    if ($] >= 5.00503) {
        my (@a) = map { /\*/ ? glob($_) : $_ } @ARGV;
        if ( "@a" ne "@ARGV" ) {
	    #my ($n) = 0;
	    #print join("\n\t", "Old arguments:",
	    #	   map { $n++; "$n. $_" } @ARGV), "\n";
	    #$n = 0;
	    #print join("\n\t", "New arguments:",
	    #	   map { $n++; "$n. $_" } @a), "\n";
	    @ARGV = @a;
        }
    }
}
#=======================================================================
sub expire
{
    #===================================================================
    # expire: Issue message and exit. This is like "die" except that
    #         it cleans up intermediate files before exiting.
    #         &expire("normally") exits normally (doesn't die).
    #===================================================================

    # Clean up compiled files, unless we're only compiling
    #
    unlink @FILES_TO_REMOVE;

    # clean up _lib? files in any case.
    #
    my $outdir = $ENV{'OUTDIR'};
    if ($outdir eq "")
    {
        $outdir = ".";
    }
    else
    {
        # strip trailing backslash:
	#
        $outdir = substr($outdir, 0, length($outdir) - 1);
    }

    opendir(DIR,$outdir) || die " Can't open dir '$outdir': $!\n";
    while ($file = readdir(DIR)) {
        if ($file =~ /^_lib*.*/) {
            unlink("$outdir\\$file");
        }
    }
    closedir(DIR);

    if ($makefilename)
    {
        close(MAKEFILE);
        if ($_[0] ne "normally")
        {
            unlink $makefilename;
        }
    }

    die "\n  $main::cmd_name: $_[0]\n\n" unless ($_[0] eq "normally");
    exit(0);
}
#=======================================================================
sub find_options_file
{
    #===================================================================
    # find_options_file: Find the options file.
    #===================================================================

    # inputs:
    #
    my ($OPTFILE_NAME, $language, $no_setup) = @_;

    # outputs: ($OPTFILE_NAME,$source_dir,$sourced_msg)
    #
    my ($source_dir, $sourced_msg);

    # locals:
    #
    my ($REGISTERED_COMPILER, @JUNK);

    if (-e ".\\$OPTFILE_NAME")
    {
	chop($source_dir = `cd`);
    }
    elsif (-e &get_user_profile_dir . "\\$OPTFILE_NAME")
    {
        $source_dir = &get_user_profile_dir;
    }
    elsif (-e "$main::script_directory\\$OPTFILE_NAME")
    {
	$source_dir = "$main::script_directory";
    }
    else
    {
        if (!$no_setup)
        {
            # Not a preset so create an empty setup argument list
            # 
            @setup_args = ();

            # No options file found, so try to detect the compiler
            #
            if($silent_setup)
            {
                &setup(&tool_name, $main::script_directory, [uc($lang)], 
		       2,\@setup_args); # 2 == silent automode
            }
            else
            {
                &setup(&tool_name, $main::script_directory, [uc($lang)],
		       1,\@setup_args); # 1 == automode
            }
        }

        if (-e &get_user_profile_dir . "\\$OPTFILE_NAME")
        {
            $source_dir = &get_user_profile_dir;
        }
        else
        {
            &expire("Error: No compiler options file could be found to compile source code. Please run \"" . &tool_name . " -setup\" to rectify.");
        }
    }
    $OPTFILE_NAME = "$source_dir\\$OPTFILE_NAME";
    $sourced_msg = "-> Default options filename found in $source_dir";

    ($OPTFILE_NAME, $source_dir, $sourced_msg);
}
#=======================================================================
sub fix_common_variables
{
    #===================================================================
    # fix_common_variables: Fix common variables.
    #===================================================================

    $bin_extension = $NAME_OUTPUT;
    $bin_extension =~ s/\"//g;
    $bin_extension =~ s/.*\.([^.]*)$/\1/;

    # WATCOM Compiler can't handle MATLAB installations with spaces in
    # path names.
    #
    if ($COMPILER =~ /(wpp)|(wcc)|(wcl)/ && $MATLAB =~ " ")
    {
        &expire("You have installed MATLAB into a directory whose name contains spaces. " .
            "The WATCOM compiler cannot handle that. Either rename your MATLAB " .
            "directory (currently $MATLAB) or run mex -setup and select a " .
            "different compiler.");
    }

    # Decide how to optimize or debug
    #
    if (! $debug) {                                  # Normal case
        $LINKFLAGS = "$LINKFLAGS $LINKOPTIMFLAGS";
    } elsif (! $optimize) {                          # Debug; don't optimize
        $LINKFLAGS = "$LINKDEBUGFLAGS $LINKFLAGS ";
    } else {                                         # Debug and optimize
        $LINKFLAGS = "$LINKDEBUGFLAGS $LINKFLAGS $LINKOPTIMFLAGS ";
    }

    # Add inlining if switch was set
    #
    $FLAGS = "$FLAGS -DARRAY_ACCESS_INLINING" if ( $inline );
}
#=======================================================================
sub fix_flag_variables
{
    #===================================================================
    # fix_flag_variables: Fix the flag variables.
    #===================================================================

    # Based on the language we're using, possibly adjust the flags
    # 
    if ($lang eq "cpp" && $CPPCOMPFLAGS ne "")
    {
        $COMPFLAGS = $CPPCOMPFLAGS;
        $LINKFLAGS = "$LINKFLAGS $CPPLINKFLAGS";
        $DEBUGFLAGS = $CPPDEBUGFLAGS;
        $OPTIMFLAGS = $CPPOPTIMFLAGS;
    }
}
#=======================================================================
sub files_to_remove
{
    #===================================================================
    # files_to_remove: Add files to remove list.
    #===================================================================

    push(@FILES_TO_REMOVE,
         ("$ENV{'MEX_NAME'}lib.exp"),
         ("$ENV{'MEX_NAME'}lib.lib"),
         ("$ENV{'MEX_NAME'}.bak"));
}
#=======================================================================
sub init_common
{
    #===================================================================
    # init_common: Common initialization.
    #===================================================================

    # Replace '.' or '.\' by the current working directory
    # Be sure to fix the 'unix' like path that comes back from getcwd.
    #
    if ( $ENV{'MATLAB'} =~ /^\.\\?$/ )
    {
        ($ENV{'MATLAB'} = getcwd()) =~ s%/%\\%g;
    }

    &expand_wildcards();

    # Correct how the $cmd_name variable looks so that it is 
    # presentable to DOS users (i.e. trade / with \).
    #
    ($main::cmd_name = $0) =~ s/\//\\/g;
     $main::cmd_name =~ tr/a-z/A-Z/;
    ($main::script_directory) = ($main::cmd_name =~ /(.*)\\.*/);

    $sourced_msg = 'none';

    $mex_include_dir = "extern\\include";

    $| = 1;                              # Force immediate output flushing
    open(STDERR,">&STDOUT");		 # redirect stderr to stdout for matlab
    select((select(STDERR), $|=1 )[0]);  # force immediate flushing for STDERR

    # Fix the path if necessary.
    #
    rectify_path();

    # Fix for Windows NT/2000 systemroot bug
    #
    $ENV{'PATH'} =~ s/\%systemroot\%/$ENV{'systemroot'}/ig;

    # Trap case where an invalid options file is used, by checking the
    # value of the compiler.
    #
    $COMPILER = "none";

    # $$ should be the pid, but this is not defined for Windows perl
    # We'll use a random integer instead.  This is only an issue
    # if you build more than one mex file in the same directory at
    # the same time, and this way there's a pretty low chance of
    # failure.
    #
    srand;
    $$ = int(rand(10000));
}
#=======================================================================
sub linker_arguments
{
    #===================================================================
    # linker_arguments: Create response file of linker arguments or just
    #                   string.
    #===================================================================

    # NAME_OUTPUT always goes in the list, but it may be blank (in which
    # case it's harmless to put it in).  Leaving the variable blank is
    # equivalent to assuming that the output will be named after the
    # first object file in the list.
    #
    $ARGS = '';
    if ( $ENV{'RSP_FILE_INDICATOR'} )
    {
        my $response_file;
        if ($makefilename)
        {
            $response_file = "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}_master.rsp";
        }
        else
        {
            $response_file = "$ENV{'OUTDIR'}$$\_tmp.rsp";
        }
        open(RSPFILE, ">$response_file") || &expire("Error: Can't open file '$response_file': $!");
        push(@FILES_TO_REMOVE, "$response_file") if (!$makefilename);
        print RSPFILE " @FILES_TO_LINK";
        close(RSPFILE);

        $ARGS = "$NAME_OUTPUT $LINKFLAGS " .
                &smart_quote("$ENV{'RSP_FILE_INDICATOR'}$response_file") .
	        " $LINKFLAGSPOST";

        if ($verbose && !$makefilename)
        {
            print "    Contents of $response_file:\n";
            print " @FILES_TO_LINK\n\n";
        }
    }
    else
    {
        $ARGS = "$NAME_OUTPUT $LINKFLAGS @FILES_TO_LINK $LINKFLAGSPOST";
    }
}
#=======================================================================
sub link_files
{
    #===================================================================
    # link_files: Link files.
    #===================================================================

    if (!$makefilename)
    {
        my $messages = RunCmd("$LINKER $ARGS");

	# LCC doesn't pay attention to -"output dir\file" as an option
	# it puts the file into the current directory.  If that's the case
	# move the file to dir
	if (($ENV{'COMPILER'} == "lcc") &&
	    !(-e "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension") &&
	    (-e "$ENV{'MEX_NAME'}.$bin_extension")) {
	  
	  print "    Renaming ", "$ENV{'MEX_NAME'}.$bin_extension", " to ",
 	        "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension\n" if $verbose;
	  rename("$ENV{'MEX_NAME'}.$bin_extension",
		 "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension") == 1 ||
		   &expire("Error: Rename of '$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension' failed.");
	}
	
        # Check for error; $? might not work, so also check for resulting file
        #
        if ($? != 0 || !(-e "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension" || $main::no_execute ))
        {
            print "$messages" unless $verbose; # verbose => printed in RunCmd
            &expire("Error: Link of '$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension' failed.");
        }

        # If we got a file, make sure there were no errors
        #
        if ($messages =~ /\b(error|fatal)\b/i) {
            print "$messages" unless $verbose; # verbose => printed in RunCmd
            &expire("Error: Link of '$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension' failed.");
        }

        if ($COMPILER =~ /bcc/ && $debug ne "yes")
        {
            push(@FILES_TO_REMOVE, "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.tds");
        }
    }
    else
    {
	&emit_linker_step();
    }
}
#=======================================================================
sub options_file
{
    #===================================================================
    # options_file: Get options file if not passed as an argument.
    #               Source the options file.
    #===================================================================

    # MATHWORKS ONLY: VCnn and VSNETnn are MathWorks specific
    #                 environment variables used only for internal
    #                 regression testing. If MSVCDir is not set
    #                 then we need to set if a Microsoft Visual
    #                 Studio compiler option file is specified on
    #                 the command line or the VSNET7 variable 
    #                 is set.
    #
    if ($ENV{'MSVCDir'} eq "") {

        if (grep /msvc\d+/, $OPTFILE_NAME) {

	    # Microsoft Visual Studio Compiler option file was specified
   	    # 
    	    if ($ENV{'VSNET7'} ne "" && (grep /msvc71/, $OPTFILE_NAME)) {
	        print("Setting MSVCDir for use with MSVC 7.1 (MathWorks-only diagnostic - do not geck)\n");
	        $ENV{'MSVCDir'} = $ENV{'VSNET7'} . "\\Vc7";
	    } elsif ($ENV{'VC70'} ne "" && (grep /msvc70/, $OPTFILE_NAME)) {
	        print("Setting MSVCDir for use with MSVC 7.0 (MathWorks-only diagnostic - do not geck)\n");
	        $ENV{'MSVCDir'} = $ENV{'VC70'} . "\\Vc7";
	    } elsif ($ENV{'VC60'} ne "" && (grep /msvc60/, $OPTFILE_NAME)) {
	        print("Setting MSVCDir for use with MSVC 6.0 (MathWorks-only diagnostic - do not geck)\n");
	        $ENV{'MSVCDir'} = $ENV{'VC60'} . "\\VC98";
	    } elsif ($ENV{'VC50'} ne "" && (grep /msvc50/, $OPTFILE_NAME)) {
	        print("Setting MSVCDir for use with MSVC 5.0(MathWorks-only diagnostic - do not geck)\n");
	        $ENV{'MSVCDir'} = $ENV{'VC50'} . "\\VC";
	    }
        } elsif ($ENV{'VSNET7'} ne "") {
	    print("Setting MSVCDir for use with MSVC 7.1 [MathWorks Default] (MathWorks-only diagnostic - do not geck)\n");
	    $ENV{'MSVCDir'} = $ENV{'VSNET7'} . "\\Vc7";	
        }
    }

    # Search and locate options file if not specified on the command
    # line.
    #
    if ($sourced_msg eq 'none')
    {
        ($OPTFILE_NAME, $source_dir, $sourced_msg) = &find_options_file($OPTFILE_NAME, $lang, $no_setup);
    }

    # Parse the batch file. DOS batch language is too limited.
    #
    open (OPTIONSFILE, $OPTFILE_NAME) || &expire("Error: Can't open file '$OPTFILE_NAME': $!");
    while ($_ = <OPTIONSFILE>) {
        chomp;
        next if (!(/^\s*set /i));     # Ignore everything but set commands
        s/^\s*set //i;                # Remove "set " command itself
        s/\s+$//;                     # Remove trailing whitespace
        s/\\$//g;                     # Remove trailing \'s
        s/\\/\\\\/g;                  # Escape all other \'s with another \
        s/%(\w+)%/'.\$ENV{'$1'}.'/g;  # Replace %VAR% with $ENV{'VAR'}
        s/%%/%/g;                     # Replace %%s with %s
        my $perlvar = '$' . $_ . "\';";
        $perlvar =~ s/=/='/;
        my $dosvar = '$ENV{'."'".$_."';";
        $dosvar =~ s/=/'}='/;
        eval($perlvar);
        eval($dosvar);

        # We need a special case for the WATCOM compiler because it
        # can't handle directories with spaces or quotes in their
        # names. So only put the quotes around the MATLAB directory
        # name if it has spaces in it.
        #
        $ML_DIR = &smart_quote($MATLAB);

        # Set the special MATLAB_BIN environment variable
        #
        if ( (! $ENV{'MATLAB'} eq "") && $ENV{'MATLAB_BIN'} eq "" )
        {
	    $ENV{'MATLAB_BIN'} = "$ML_DIR\\bin\\win32";
        }

        # Set the special MATLAB_EXTLIB environment variable
        #
        if ( (! $ENV{'MATLAB'} eq "") && $ENV{'MATLAB_EXT'} eq "" )
        {
	    $ENV{'MATLAB_EXTLIB'} = "$ML_DIR\\extern\\lib\\win32";
        }
    }
    close(OPTIONSFILE);
}
#=======================================================================
sub parse_common_dash_args
{
    #===================================================================
    # parse_common_dash_args: Parse the common dash arguments.
    #===================================================================

    local ($_) = @_;

    ARGTYPE: { 
      /^-c$/ && do {
          $compile_only = "yes";
          last ARGTYPE;
      };

      /^-D\S*$/ && do {
          if ($_ eq "-DV5_COMPAT") {
              &expire("Please use -V5 rather than directly passing in -DV5_COMPAT.");
          } elsif ($_ eq "-DARRAY_ACCESS_INLINING") {
              &expire("Please use -inline rather than directly passing in -DARRAY_ACCESS_INLINING.");
          } else {
              $_ =~ s/[=\#]/=/;
              $ARG_FLAGS = "$ARG_FLAGS $_";
              last ARGTYPE;
          }
      };

      /^-U\S*$/ && do {
          $ARG_FLAGS = "$ARG_FLAGS $_";
          last ARGTYPE;
      };

      /^-I.*$/ && do {
          $ARG_FLAGS .= " " . &smart_quote($_);
          last ARGTYPE;
      };

      /^-f$/ && do {
          $filename = shift(@ARGV);
          if ("$setup_special" eq "yes") {
              $setup_args[2] = $filename;
              last ARGTYPE;
          }
          if (-e $filename) {
              $OPTFILE_NAME =  "$filename";
          } elsif (-e "$main::script_directory\\$filename") {
              $OPTFILE_NAME = "$main::script_directory\\$filename";
          }
          else {
              &expire("Error: Could not find specified options file\n    '$filename'.");
          }
          $sourced_msg = '-> Options file specified on command line';
          last ARGTYPE;
      };

      # This is an undocumented feature which is subject to change
      #
      /^-silentsetup$/ && do {
          $silent_setup = "yes";
          last ARGTYPE;
      };

      /^-g$/ && do {
          $debug = "yes";
          last ARGTYPE;
      };

      /^-inline$/ && do {
          $inline = "yes";
          last ARGTYPE;
      };

      # This is an undocumented feature which is subject to change.
      #
      /^-k$/ && do {
          $makefilename = shift(@ARGV);
          last ARGTYPE;
      };

      /^-setup$/ && do {
          $setup = "yes";
          last ARGTYPE;
      };

      /^-setup:.*$/ && do {
          $setup_special = "yes";
          s/-setup://;
          @setup_args = ($f1,$f2,$f3) = split(/:/);
          if (!$f1) {
              print "\nError: No compiler specified . . .\n\n";
              exit(1);
          }
          last ARGTYPE;
      };

      # This is passed by mex.m and mbuild.m
      #
      /^-called_from_matlab$/ && do {
          $called_from_matlab = "yes";
          last ARGTYPE;
      };

      /^-output$/ && do {
          $output_flag = "yes";
          $ENV{'MEX_NAME'}=shift(@ARGV);
          last ARGTYPE;
      };

      /^-O$/ && do {
          $optimize = "yes";
          last ARGTYPE;
      };

      /^-outdir$/ && do {
          $outdir_flag = "yes";
          my $outdir = shift(@ARGV);
          $outdir =~ s/\//\\/g;
          $ENV{'OUTDIRN'} = $outdir;          
          $outdir = $outdir . "\\";
          $ENV{'OUTDIR'} = $outdir;
          last ARGTYPE;
      };

      /^-matlab$/ && do {
          $matlab = shift(@ARGV);
          $matlab =~ tr/"//d;
          $ENV{'MATLAB'} = $matlab;
          last ARGTYPE;
      };

      /^-n$/ && do {
          $main::no_execute = 1; # global used by RunCmd
          last ARGTYPE;
      };

      # This is an undocumented feature which is subject to change
      #
      /^-no_setup$/ && do {
          $no_setup = 1;
          last ARGTYPE;
      };

      return 0;
    }
    return 1;
}
#=======================================================================
sub parse_common_nodash_args
{
    #===================================================================
    # parse_common_nodash_args: Parse the common non-dash arguments.
    #===================================================================

    local ($_) = @_;

    ARGTYPE: {
      /^[A-Za-z0-9_]+\#.*$/ && do {
          push(@CMD_LINE_OVERRIDES, $_);
          last ARGTYPE;
      };

      /^@(.*)$/ && do {
          @NEW_ARGS = &process_response_file($1);

          # Expand possible wildcards in the arguments for
          # perl >= 5.00503
          #
          if ($] >= 5.00503) {
              my (@a) = map { /\*/ ? glob($_) : $_ } @NEW_ARGS;
              @NEW_ARGS = @a;
          }

          unshift(@ARGV, @NEW_ARGS);
          last ARGTYPE;
      };

      return 0;
    }
    return 1;
}
#=======================================================================
sub postlink
{
    #===================================================================
    # postlink: Do postlink steps.
    #===================================================================

    # Call any postlink commands that may exist
    #
    my @postlink = split(/;/, $ENV{"POSTLINK_CMDS"});
    while ($postlink = shift(@postlink)) {
        next if (!($postlink =~ /\S/));
        $postlink =~ s/\//\\/g;
        if (!$makefilename)
        {
            RunCmd($postlink);
        }
        else
        {
	    &emit_postlink_step();
        }
    }

    $i = 1;
    $postlink = $ENV{"POSTLINK_CMDS" . $i};
    while ($postlink =~ /\S/)
    {
        if (!$makefilename)
        {
            RunCmd($postlink);
        }
        else
        {
	    &emit_postlink_step();
        }
        $i++;
        $postlink = $ENV{"POSTLINK_CMDS" . $i};
    }
}
#=======================================================================
sub prelink
{
    #===================================================================
    # prelink: Do prelink steps.
    #===================================================================

    # Note that error checking is not possible; we don't get a return
    # status, and there's no way of knowing a priori what each task is
    # supposed to do.
    #
    (@PRELINK_CMDS) = split(/;/,$PRELINK_CMDS);
    while ($prelink= shift(@PRELINK_CMDS))
    {
        # Skip if $prelink is only whitespace
        #
        next if (!($prelink =~ /\S/));

        if (!$makefilename)
        {
            RunCmd($prelink);
        }
        else
        {
            &emit_prelink();
        }
    }

    # There can be multiple prelink command lines called, PRELINK_CMDS1,
    # 2 etc. So loop through dealing with each.
    #
    my $i = 1;
    while ( my $prelink = $ENV{"PRELINK_CMDS$i"} )
    {
        if (!$makefilename)
        {
            RunCmd($prelink);
        }
        else
        {
            &emit_prelink();
        }
        $i++;
        $prelink =$ENV{"PRELINK_CMDS".$i};
    }
}
#=======================================================================
sub process_overrides
{
    #===================================================================
    # process_overrides: Process command line overrides.
    #===================================================================

    foreach $override (@CMD_LINE_OVERRIDES)
    {
        $override =~ /^([A-Za-z0-9_]+)[\#](.*)$/;
        $lhs = $1;
        $rhs = $2;

        $rhs =~ s/\\/\\\\/g;              # Escape all other \'s with another \
        $rhs =~ s/"/\\"/g;
        $rhs =~ s/\$([A-Za-z0-9_]+)/\$ENV{'$1'}/g;  # Replace $VAR with $ENV{'VAR'}

        my $perlvar = '$' . $lhs . " = \"" . $rhs . "\";";
        my $dosvar = "\$ENV{\'" . $lhs . "\'} = \"" . $rhs . "\";";

        eval($perlvar);
        eval($dosvar);
    }
}
#=======================================================================
sub process_response_file
{
    #===================================================================
    # process_response_file: Run shellwords on filename argument.
    #===================================================================

    # inputs:
    #
    my ($filename) = @_;

    # locals:
    #
    my ($rspfile);

    open(RSPFILE, "$filename") || &expire("Error: Can't open response file '$filename': $!");
    while (<RSPFILE>)
    {
        $rspfile .= $_;
    }
    close(RSPFILE);

    # shellwords strips out backslashes thinking they are escape sequences.
    # In DOS we'd rather treat them as DOS path separators.
    #
    $rspfile =~ s/\\/\\\\/g;

    # return output of shellwords
    #
    &shellwords($rspfile);
}
#=======================================================================
sub rectify_path
{
    #===================================================================
    # rectify_path: Check path for system directories and add them if
    #               not present.
    #===================================================================
  
    my ($missing, $resysdir, $systemdir, $sysroot, $syssys32, $command, $osid);

    # Make sure system path is on path so perl can spawn commands
    # We will prefer the environment variable SystemRoot and failing
    # that we will look for windir.  If neither are available perl
    # may still fail in a very uninformative way.
    #
    $osid = Win32::GetOSVersion();

    $systemdir = $ENV{SystemRoot};
    if($systemdir eq "")
    {
	$systemdir = $ENV{windir};
    }

    # if we got something make sure it's on the path
    #
    if($systemdir ne "")
    {
	$missing = "false";
	$resysdir = $systemdir;
	$resysdir =~ s/\\/\\\\/;

        # Root system dir (i.e. WINNT or WINDOWS)
        # 
        unless($ENV{PATH} =~ /$resysdir;/i)
        {
            $missing = "true";
            $sysroot = $systemdir . ";";
        }

        if($osid == 2) #WinNT
        {
            # system32
	    #
            unless($ENV{PATH} =~ /$resysdir\\system32;/i)
            {
                $missing = "true";
                $syssys32 = $systemdir . "\\system32;";
            }
        }
        elsif($osid == 1) #Win9x
        {
            # command
	    #
            unless($ENV{PATH} =~ /$resysdir\\command;/i)
            {
                $missing = "true";
                $command = $systemdir . "\\command;";
            }
        }
        
        if($missing eq "true")
        {
#            print "One or more system directories are missing from your path environment variable.\n";
            $ENV{PATH} = $sysroot . $syssys32 . $command . $ENV{PATH};
#            print $ENV{PATH} . "\n";
        }
    }
}
#=======================================================================
sub resource_linker
{
    #===================================================================
    # resource_linker: Run resource linker. 
    #===================================================================

    my $rc_line = "$ENV{'RES_PATH'}\\$ENV{'RES_NAME'}.rc " .
    &smart_quote("$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension");

    $rc_line = "$rc_line -DARRAY_ACCESS_INLINING" if ($inline);
    $rc_line = "$rc_line -DV5_COMPAT" if ($v5);

    if (!$makefilename)
    {
        my $messages = RunCmd("$RC_LINKER $rc_line");

        # Check for error; $? might not work, so also check for string "error"
        #
        if ($? != 0 || $messages =~ /\b(error|fatal)\b/i) {
            print "$messages" unless $verbose; # verbose => printed in RunCmd
            &expire("Error: Resource link of '$ENV{'RES_NAME'}.rc' failed.");
        }

        push(@FILES_TO_REMOVE,"$ENV{'OUTDIR'}$ENV{'RES_NAME'}.res");
    }
    else
    {
	&emit_resource_linker_step();
    }
}
#=======================================================================
sub RunCmd
{
    #===================================================================
    # RunCmd: Run a single command.
    #===================================================================

    my ($cmd) = @_;
    my ($rc, $messages);

    $cmd = "\"$cmd\"" if ( $] >= 5.00503 && $ENV{OS} eq 'Windows_NT' );
    print "\n--> $cmd\n\n" if ($verbose || $main::no_execute);
    if (! $main::no_execute)
    {
        $messages = `$cmd`;
        $rc = $?;
        print $messages if $verbose;
        $rc = $rc >> 8 if $rc;
    }
    else
    {
        $messages = "";
        $rc = 0;
    }
    wantarray ? ($messages, $rc) : $messages;
}
#=======================================================================
sub search_path
{
    #===================================================================
    # search_path: Search DOS PATH environment variable for
    #              $binary_name.  Return the directory containing the
    #              binary if found on the path, or an empty path
    #              otherwise.
    #===================================================================

    my ($binary_name) = @_;
    my (@path, $path_entry, $found);

    foreach ( split(/;/,$ENV{'PATH'}) ) {
        print "checking existence of:  $_\\$binary_name\n" if $ENV{MEX_DEBUG};
	if ( -e "$_\\$binary_name" ) {
	    print "search_path found: $_\\$binary_name\n" if $ENV{MEX_DEBUG};
	    return $_;
	}
    }
    '';
}
#=======================================================================
sub set_common_variables
{
    #===================================================================
    # set_common_variables: Set more common variables.
    #===================================================================

    # Create a unique name for the created import library
    #
    $ENV{'LIB_NAME'} = &smart_quote("$ENV{'OUTDIR'}\_lib$$");

    $RC_LINKER = " ";
    $RC_COMPILER = " ";

}
#=======================================================================
sub smart_quote
{
    #===================================================================
    # smart_quote: Adds quotes (") at the beginning and end of its input
    #              if the input contains a space. The quoted string is
    #              returned as the output. If the input contains no
    #              spaces, the input is returned as the output.
    #===================================================================

    my ($str) = @_;	# input

    $str = "\"$str\"" if ($str =~ / /);
    $str;		# output
}
#=======================================================================
sub start_makefile
{
    #===================================================================
    # start_makefile: Open and write the main dependency to the makefile.
    #===================================================================

    open(MAKEFILE, ">>$makefilename")
        || &expire("Error: Cannot append to file '$makefilename': $!");

    # Emit main dependency rule
    #
    print MAKEFILE "bin_target : $ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension\n\n";
}
#=======================================================================
sub tool_name
{
    #===================================================================
    # tool_name: Returns the tool name, i.e. mex or mbuild.
    #===================================================================

    if ($main::mbuild eq "yes")
    {
        "mbuild";
    }
    else
    {
        "mex";
    }
}
#=======================================================================
########################################################################
#=======================================================================
# Mex only subroutines:
#=======================================================================
#
# build_ada_s_function:      Builds an Ada S-Function
# describe:		     Issues mex messages.
# fix_mex_variables:	     Fix variables for mex. 
# init_mex:		     Mex specific initialization.
# parse_mex_args:	     Parse all arguments including mex.
# set_mex_variables:	     Set more variables for mex.
#
#-----------------------------------------------------------------------
#
# Mex variables:
#
#   Perl:
#
#     <none>
#
#   DOS environment:
#
#     <none>
#
#     [$ENV: set in script]
#       MEX_NAME		WATCH THE NAME! This is the target name
#				for both MEX and MBUILD!
#       ENTRYPOINT		default is "mexFunction"
#
#     [$ENV: get in script]
#
#     [set in option .bat files]
#
#       [General]
#         MATLAB		[script]
#         -------
#         BORLAND		(Borland compilers only)
#         DF_ROOT		(Dec Fortran and Dec Visual Fortran)
#         VCDir			(Dec Visual Fortran)
#         MSDevDIR		(Dec Visual Fortran)
#         DFDir			(Dec Visual Fortran)
#         MSVCDir		(Microsoft Visual Studio only)
#				  [MathWorks]
#         MSDevDir		(Microsoft Visual Studio only)
#         WATCOM		(WATCOM compilers only)
#         -------
#         PATH			[DOS]
#         INCLUDE
#         LIB
#         -------
#         LCCMEX		(standalone engine or MAT programs
#				 only for lcc)
#         DevEnvDir		(Microsoft Visual Studio only)
#         PERL			(some)
#         EDPATH		(some WATCOM compilers only)
#         -------
#
#       [Compile]
#         COMPILER		compiler name
#         COMPFLAGS		compiler flags
#         DEBUGFLAGS		debug flags
#         OPTIMFLAGS		optimization flags
#         NAME_OBJECT
#
#       [library creation]
#         PRELINK_CMDS1		(some)
#       
#       [linker]
#         LIBLOC
#         LINKER
#         LINKFLAGS
#         LINKOPTIMFLAGS
#         LINKDEBUGFLAGS	(some)
#         LINK_FILE
#         LINK_LIB
#         NAME_OUTPUT
#         RSP_FILE_INDICATOR
#
#       [resource compiler]
#         RC_COMPILER       
#         RC_LINKER
#
#       [postlink]
#         POSTLINK		(some)			
#         POSTLINK1		(some)
#         POSTLINK2		(some)
#         POSTLINK3		(some)
#=======================================================================
sub build_ada_s_function
{
    #===================================================================
    # build_ada_s_function: Builds an Ada S-Function.
    #===================================================================

    my ($ada_sfunction, $ada_include_dirs) = @_;
    $ada_sfunction =~ s/\//\\/g;
    if ($ada_sfunction eq "") {
	&expire("Error: Invalid use of -ada option");
    }

    # get the directorires
    #
    my $mlroot = $main::script_directory;
    $mlroot =~ s/(.*)\\bin.*/$1/i;
    my $sl_ada_dir = $mlroot . "\\simulink\\ada";
    my $def_dir    = $mlroot . "\\extern\\include";
    my $cwd = getcwd(); $cwd =~ s/\//\\/g;

    my $sfcn_base = $ada_sfunction;
    $sfcn_base =~ s/(.+\\)*(\w+).ad[bs]/$2/;

    my $sfcn_dir = $ada_sfunction;
    $sfcn_dir =~ s/(.*)$sfcn_base\.ad[sb]/$1/;
    if ($sfcn_dir eq "") {
        $sfcn_dir = $cwd;
    } else {
        # strip trailing backslash:
        $sfcn_dir = substr($sfcn_dir, 0, length($sfcn_dir) - 1);
    }

    my $sfcn_ads = $sfcn_dir . "\\" . $sfcn_base . ".ads";
    my $sfcn_adb = $sfcn_dir . "\\" . $sfcn_base . ".adb";

    # get s-function name
    #
    my $cmd= "$sl_ada_dir\\bin\\win32\\get_defines $ada_sfunction 0";
    my $sfcn_name = RunCmd($cmd);
    if ($? != 0) {
	print "$sfcn_name" unless $verbose;
	&expire("Error: Unable to determine S-Function name - $!");
    }
    chomp($sfcn_name);

    # get s-function defines
    #
    $cmd= "$sl_ada_dir\\bin\\win32\\get_defines $ada_sfunction";
    my $sfcn_defs = RunCmd($cmd);
    if ($? != 0) {
	print "$sfcn_defs" unless $verbose;
	&expire("Error: Unable to determine S-Function methods - $!");
    }
    chomp($sfcn_defs);

    # Make sure that the GNAT Ada Compiler is available.
    #
    my $gnat_check = `gnatdll -v`;
    if ($? != 0) {
	&expire("Error: Unable to find the GNAT Ada compiler.  To use mex to " .
		"build Ada S-function '$ada_sfunction', you need to have the " .
		"GNAT Ada compiler (version 3.12 or higher), correctly " .
		"installed and available on the path.");
    }

    # create obj dir, and cd to it.
    #
    my $obj_dir = $cwd . "\\" . $sfcn_base . "_ada_sfcn_win32";
    if ( !(-e $obj_dir) ) {
	mkdir($obj_dir, 777);
	if ($? != 0) {
	    &expire("Error: Unable to create $obj_dir -> $!");
	}
    }
    chdir($obj_dir);
    if ($? != 0) {
	&expire("Error: Unable to cd to $obj_dir -> $!");
    }

    # compiler flags for gcc
    #
    my $gcc_flags = "-Wall -malign-double";
    if ($debug eq "yes") {
	$gcc_flags = $gcc_flags . " -g";
    } else {
	$gcc_flags = $gcc_flags . " -O2";
    }

    # fixup include paths, if any, specified in $ARG_FLAGS
    #
    my $args = '';
    foreach my $arg (split(' ',$ARG_FLAGS)) {
	if ($arg =~ /-I(.+)/) {
	    $arg = $1;
	    if ( !($arg =~ /^[a-zA-Z]:\\.*/) ) {
		$arg = '..\\' . $arg;
	    }
	    $arg = ' -aI' . $arg;
	}
	$args .= ' ' . $arg;
    }

    # invoke gnatmake to compile the ada sources (creates .ali file)
    #
    my $sfcn_ali = $sfcn_base . ".ali";
    my $cmd  = "gnatmake -q -c -aI$sl_ada_dir\\interface -aI$sfcn_dir " .
	       "$ada_include_dirs $args $sfcn_adb -cargs $gcc_flags";
    my $messages = RunCmd($cmd);
    if ($? != 0 || !(-e "$sfcn_ali" || $main::no_execute)) {
	print "$messages" unless $verbose;
	&expire("Error: Unable to compile $sfcn_adb -> $!");
    }

    # Compile the Ada S-Function's entry point
    #
    my $sl_ada_entry = "$sl_ada_dir\\interface\\sl_ada_entry.c";
    my $cmd  = "gcc -I$sl_ada_dir\\interface -I$mlroot\\extern\\include " .
	       "-I$mlroot\\simulink\\include $gcc_flags -DMATLAB_MEX_FILE " .
	       "$sfcn_defs -c $sl_ada_entry";
    my $messages = RunCmd($cmd);
    if ($? != 0 || !(-e "sl_ada_entry.o" || $main::no_execute)) {
	print "$messages" unless $verbose;
	&expire("Error: Unable to compile $sl_ada_entry -> $!");
    }

    # invoke dlltool to build the stubs libraries.
    #
    my @stubs = ('libmx', 'libmex');
    foreach my $s (@stubs) {
	my $perlexe = $^X;
	my $cmd = "type $def_dir\\$s.def | $perlexe -p -e \"s/LIBRARY.*//g;s/^\s*\$//g\" > $s_tmp.def &" .
	          "dlltool -k --def $s_tmp.def --output-lib $s.lib --dllname $s.dll";
	my $messages = RunCmd($cmd);
	if ( $? != 0 || !(-e "$s.lib" || $main::no_execute) ) {
	    print "$messages" unless $verbose;
	    &expire("Error: Unable to create $s.lib : $!");
	}
    }

    # Invoke gnatdll to build the dll (mex file)
    #
    my $mex_file = $sfcn_name . ".dll";
    my $cmd = "gnatdll -q -n -e $sl_ada_dir\\interface\\mex.def " .
	      "-d $sfcn_name.dll $sfcn_ali sl_ada_entry.o " .
	      "-largs libmx.lib libmex.lib";
    my $messages = RunCmd($cmd);
    if ( $? != 0 || !(-e "$mex_file" || $main::no_execute) ) {
	print "$messages" unless $verbose;
	&expire("Error: Unable to build mex-file $mex_file - $!");
    }

    # move it to the
    #
    rename($mex_file, $cwd . "\\" . $mex_file);
    if ($? != 0) {
	print "$messages" unless $verbose;
	&expire("Error: Unable to move $mex_file to $cwd\\$mex_file - $!");
    }
    print "---> Created Ada S-Function: $mex_file\n\n" if ($verbose);
}
#=======================================================================
sub describe
{
    #===================================================================
    # describe: Issues mex messages. This way lengthy messages do not
    #           clutter up the main body of code.
    #===================================================================

    local($_) = $_[0];

 DESCRIPTION: {
     /^help$/ && print(<<'end_help') && last DESCRIPTION;
MEX [option1 ... optionN] sourcefile1 [... sourcefileN]
    [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]

Description:
  MEX compiles and links source files into a shared library called a
  MEX-file, executable from within MATLAB. The resulting file has a
  platform-dependent extension, as shown in the table below:

    sol2, SunOS 5.x - .mexsol
    hpux            - .mexhpux
    hp700           - .mexhp7
    ibm_rs          - .mexrs6
    sgi             - .mexsg
    alpha           - .mexaxp
    glnx86          - .mexglx
    Windows         - .dll

  The first file name given (less any file name extension) will be the name
  of the resulting MEX-file. Additional source, object, or library files can
  be given to satisfy external references. On Windows, either C or Fortran,
  but not both, may be specified. On UNIX, both C and Fortran source files
  can be specified when building a MEX-file. If C and Fortran are mixed, the
  first source file given determines the entry point exported from the
  MEX-file (MATLAB loads and runs a different entry point symbol for C or
  Fortran MEX-files).

  Both an options file and command line options affect the behavior of MEX.
  The options file contains a list of variables that are passed as arguments
  to various tools such as the compiler, linker, and other platform-
  dependent tools (such as the resource linker on Windows). Command line
  options to MEX may also affect what arguments are passed to these tools,
  or may control other aspects of MEX's behavior.

Command Line Options:
  Options available on all platforms:

  -ada <sfcn.ads>
      Use this option to compile a Simulink S-function written in Ada, where
      <sfcn.ads> is the Package Specification for the S-function. When this
      option is specified, only the -v (verbose) and -g (debug) options are
      relevant. All other options are ignored. See
      $MATLAB/simulink/ada/examples/README for examples and info on
      supported compilers and other requirements.
  -argcheck
      Add argument checking. This adds code so that arguments passed
      incorrectly to MATLAB API functions will cause assertion failures.
      Adds -DARGCHECK to the C compiler flags, and adds
      $MATLAB/extern/src/mwdebug.c to the list of source files. (C functions
      only).
  -c
      Compile only. Creates an object file but not a MEX-file.
  -D<name>
      Define a symbol name to the C preprocessor. Equivalent to a
      "#define <name>" directive in the source.
  -D<name>#<value>
      Define a symbol name and value to the C preprocessor. Equivalent to a
      "#define <name> <value>" directive in the source.
  -f <optionsfile>
      Specify location and name of options file to use. Overrides MEX's
      default options file search mechanism.
  -g
      Create a debuggable MEX-file. If this option is specified, MEX appends
      the value of options file variables ending in DEBUGFLAGS with their
      corresponding base variable. (For example, the value of LINKDEBUGFLAGS
      would be appended to the LINKFLAGS variable before calling the
      linker.) This option also disables MEX's default behavior of
      optimizing built object code.
  -h[elp]
      Print this message.
  -I<pathname>
      Add <pathname> to the list of directories to search for #include
      files.
  -inline
      Inline matrix accessor functions (mx*). The MEX-function generated
      may not be compatible with future versions of MATLAB.
  -n
      No execute mode. Print out any commands that MEX would otherwise have
      executed, but do not actually execute any of them.
  -O
      Optimize the object code by including the optimization flags listed in
      the options file. If this option is specified, MEX appends the value
      of options file variables ending in OPTIMFLAGS with their
      corresponding base variable. (For example, the value of LINKOPTIMFLAGS
      would be appended to the LINKFLAGS variable before calling the
      linker.) Note that optimizations are enabled by default, are disabled
      by the -g option, but are reenabled by -O.
  -outdir <dirname>
      Place all output files in directory <dirname>.
  -output <resultname>
      Create MEX-file named <resultname> (an appropriate MEX-file extension
      is automatically appended). Overrides MEX's default MEX-file naming
      mechanism.
  -setup
      Interactively specify the compiler options file to use as default for
      future invocations of MEX by placing it in "<UserProfile>\Application
      Data\MathWorks\MATLAB\R13" (for Windows) or $HOME/.matlab/R13 (for
      UNIX). When this option is specified, no other command line input is
      accepted.
  -U<name>
      Remove any initial definition of the C preprocessor symbol <name>.
      (Inverse of the -D option.)
  -v
      Print the values for important internal variables after the options
      file is processed and all command line arguments are considered.
      Prints each compile step and final link step fully evaluated to see
      which options and files were used. Very useful for debugging.
  -V5
      Compile a MATLAB 5-style MEX-file. This option is intended as an aid
      to migration, and is not recommended as a permanent solution.
  <name>#<value>
      Override an options file variable for variable <name>. See the
      platform-dependent discussion of options files below for more details.
      This option is processed after the options file is processed and all
      command line arguments are considered.

Additional options available on Windows platforms:

  @<rspfile>
      Include contents of the text file <rspfile> as command line arguments
      to MEX.

Additional options available on Unix platforms:

  -<arch>
      Assume local host has architecture <arch>. Possible values for <arch>
      include sol2, hpux, hp700, alpha, ibm_rs, sgi, and glnx86.
  -D<name>=<value>
      Define a symbol name and value to the C preprocessor. Equivalent to a
      "#define <name> <value>" directive in the source.
  -fortran
      Specify that the gateway routine is in Fortran. This will override
      what the script normally assumes, which is that the first source file
      in the list is the gateway routine.
  -l<name>
      Link with object library "lib<name>" (for "ld(1)").
  -L<directory>
      Add <directory> to the list of directories containing object-library
      routines (for linking using "ld(1)").
  <name>=<value>
      Override an options file variable for variable <name>. See the
      platform-dependent discussion of options files below for more details.

Options File Details:
  On Windows:
    The options file is written as a DOS batch file. If the -f option is not
    used to specify the options file name and location, then MEX searches
    for an options file named mexopts.bat in the following directories: the
    current directory, then the directory "<UserProfile>\Application
    Data\MathWorks\MATLAB\R13". Any variable specified in the options file
    can be overridden at the command line by use of the <name>#<value>
    command line argument. If <value> has spaces in it, then it should be
    wrapped in double quotes (e.g., COMPFLAGS#"opt1 opt2"). The definition
    can rely on other variables defined in the options file; in this case
    the variable referenced should have a prepended "$" (e.g.,
    COMPFLAGS#"$COMPFLAGS opt2").

    Note: The options files in $MATLAB\bin\mexopts named *engmatopts.bat are
    special case options files that can be used with MEX (via the -f option)
    to generate stand-alone MATLAB Engine and MATLAB MAT-API executables.
    Such executables are given a ".exe" extension.

  On UNIX:
    The options file is written as a UNIX shell script. If the -f option is
    not used to specify the options file name and location, then MEX
    searches for an options file named mexopts.sh in the following
    directories: the current directory (.), then $HOME/.matlab/R13, then
    $MATLAB/bin. Any variable specified in the options file can be
    overridden at the command line by use of the <name>=<def> command line
    argument. If <def> has spaces in it, then it should be wrapped in single
    quotes (e.g., CFLAGS='opt1 opt2'). The definition can rely on other
    variables defined in the options file; in this case the variable
    referenced should have a prepended "$" (e.g., CFLAGS='$CFLAGS opt2').

    Note: The options files in $MATLAB/bin named engopts.sh and matopts.sh
    are special case options files that can be used with MEX (via the -f
    option) to generate stand-alone MATLAB Engine and MATLAB MAT-API
    executables. Such executables are not given any default extension.

Examples:
    The following command will compile "myprog.c" into "myprog.mexsol" (when
    run under Solaris):

      mex myprog.c

    When debugging, it is often useful to use "verbose" mode as well
    as include symbolic debugging information:

      mex -v -g myprog.c

end_help
     /^usage$/ && print(<<'end_usage') && last DESCRIPTION;
    Usage:
        MEX [option1 ... optionN] sourcefile1 [... sourcefileN]
            [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]

      or (to build an Ada S-function):
        MEX [-v] [-g] -ada <sfcn>.ads

    Use the -help option for more information, or consult the MATLAB API Guide.

end_usage
     /^general_info$/ && print(<<"end_general_info") && last DESCRIPTION;
 This is mex, Copyright 1984-2003 The MathWorks, Inc.

end_general_info
     /^invalid_options_file$/ && print(<<"end_invalid_options_file") && last DESCRIPTION;
    Warning: An options file for MEX.BAT was found and sourced, but the
             value for 'COMPILER' was not set.  This could mean that the
             value is not specified within the options file, or it could
             mean that there is a syntax error within the file.

end_invalid_options_file
     /^final_options$/ && print(<<"end_final_options") && last DESCRIPTION;
$sourced_msg
----------------------------------------------------------------
->    Options file           = $OPTFILE_NAME
      MATLAB                 = $MATLAB
->    COMPILER               = $COMPILER
->    Compiler flags:
         COMPFLAGS           = $COMPFLAGS
         OPTIMFLAGS          = $OPTIMFLAGS
         DEBUGFLAGS          = $DEBUGFLAGS
         arguments           = $ARG_FLAGS
         Name switch         = $NAME_OBJECT
->    Pre-linking commands   = $PRELINK_CMDS
->    LINKER                 = $LINKER
->    Link directives:
         LINKFLAGS           = $LINKFLAGS
         LINKFLAGSPOST       = $LINKFLAGSPOST
         Name directive      = $NAME_OUTPUT
         File link directive = $LINK_FILE
         Lib. link directive = $LINK_LIB
         Rsp file indicator  = $RSP_FILE_INDICATOR
->    Resource Compiler      = $RC_COMPILER
->    Resource Linker        = $RC_LINKER
----------------------------------------------------------------

end_final_options
     /^file_not_found$/ && print(<<"end_file_not_found") && last DESCRIPTION;
  $main::cmd_name:  $filename not a normal file or does not exist.

end_file_not_found
     /^meaningless_output_flag$/ && print(<<"end_meaningless_output_flag")  && last DESCRIPTION;
  Warning: -output ignored (no MEX-file is being created).

end_meaningless_output_flag

    /^compiler_not_found$/ && print(<<"end_compiler_not_found") && last DESCRIPTION;
  Could not find the compiler "$COMPILER" on the DOS path.
  Use mex -setup to configure your environment properly.

end_compiler_not_found

    /^outdir_missing_name_object$/ && print(<<"end_outdir_missing_name_object") && last DESCRIPTION;
  Warning: The -outdir switch requires the mex options file to define
           NAME_OBJECT. Make sure you are using the latest version of
           your compiler's mexopts file.

end_outdir_missing_name_object

    /^fortran_cannot_change_entrypt$/ && print(<<"end_fortran_cannot_change_entrypt") && last DESCRIPTION;
  Warning: -entrypt ignored (FORTRAN entry point cannot be overridden).

end_fortran_cannot_change_entrypt

    do {
        print "Internal error: Description for $_[0] not implemented\n";
        last DESCRIPTION;
    };
 }
}
#=======================================================================
sub fix_mex_variables
{
    #===================================================================
    # fix_mex_variables: Fix variables for mex.
    #===================================================================

    if ($verbose) {
	&describe("final_options");
    }

    if ($COMPILER eq "none") {
        &describe("invalid_options_file");
    }

    if ($outdir_flag && $NAME_OBJECT eq "") {
        &describe("outdir_missing_name_object");
    }

    # check that MATLAB is where it is expected to be
    #
    if ( ! -e "$MATLAB\\extern\\include\\matrix.h" ) {
        &expire("Error: The variable MATLAB in \"mex.bat\" was not set properly.\n" .
                "           Please modify this variable at the top of the file " .
                "\"mex.bat\".\n\n           MATLAB is currently set to $MATLAB");
    }

    # If we are checking arguments, add $MATLAB/extern/src/mwdebug.c
    # to source file list.
    #
    push(@FILES, "$MATLAB\\extern\\src\\mwdebug.c") if ($argcheck eq "yes");

    # Decide how to optimize or debug
    #
    if (! $debug) {                                  # Normal case
        $FLAGS = "$OPTIMFLAGS";
    } elsif (! $optimize) {                          # Debug; don't optimize
        $FLAGS = "$DEBUGFLAGS";
    } else {                                         # Debug and optimize
        $FLAGS = "$DEBUGFLAGS $OPTIMFLAGS";
    }

    # Include the simulink include directory if it exists
    #
    my ($simulink_inc_dir) = '';
    $simulink_inc_dir = "-I$ML_DIR\\simulink\\include"
        if (-e "$MATLAB\\simulink\\include");

    # Add extern/include to the path (it always exists)
    #
    $FLAGS = "-I$ML_DIR\\$mex_include_dir $simulink_inc_dir $FLAGS"
        unless ($fortran);

    # Verify that compiler binary exists
    #
    $COMPILER_DIR = &search_path("$COMPILER.exe");
    if ( ! $COMPILER_DIR ) {
	&describe("compiler_not_found");
        &expire("Error: Unable to locate compiler.");
    }

    # If there are no files, then exit.
    #
    if (!@FILES) {
        &describe("usage");
        &expire("Error: No file names given.");
    }
}
#=======================================================================
sub init_mex
{
    #===================================================================
    # init_mex: Mex specific initialization.
    #===================================================================

    if ($main::script_directory) {
        ($main::script_directory) .= "\\mexopts";
    } else {
        ($main::script_directory) = ".\\mexopts";
    }
    $OPTFILE_NAME = "mexopts.bat";

    # Ada S-Functions:
    #
    #    mex [-v] [-g] [-aI<dir1>] ... [-aI<dirN>] -ada sfcn.ads
    #
    #
    $ada_sfunction    = "";
    $ada_include_dirs = "";

    # Should always be one of {"c", "cpp", "fortran", "all", "ada"}
    #
    $lang = "c"; 
    $link = "unspecified";
    $ENV{'ENTRYPOINT'} = "mexFunction";

    $COMPILE_EXTENSION = 'c|f|cc|cxx|cpp|for|f90';
}
#=======================================================================
sub parse_mex_args
{
    #===================================================================
    # parse_mex_args: Parse all mex arguments including common.
    #===================================================================

    for (;$_=shift(@ARGV);) {

        # Perl-style case construct
        # print "DEBUG input argument is $_\n";
        #
        ARGTYPE: {

            /^[-\/](h(elp)?)|\?$/ && do {
	        &describe("help");
                &expire("normally");
                last ARGTYPE;
	    };

            /^-v$/ && do {
	        &describe("general_info");
                $verbose = "yes";
                last ARGTYPE;
            };

            if (&parse_common_dash_args($_)) {
                last ARGTYPE;
            }

            /^-argcheck$/ && do {
                $ARG_FLAGS = "$ARG_FLAGS -DARGCHECK";
                $argcheck = "yes";
                last ARGTYPE;
            };

            /^-V5$/ && do {
                $v5 = "yes";
                $ARG_FLAGS = "$ARG_FLAGS -DV5_COMPAT";
                last ARGTYPE;
            };

            /^-ada$/ && do {
                if ($ada_sfunction ne "" || $#ARGV == -1) {
                    &expire("Error: Invalid use of -ada option");
                }
                $ada_sfunction = shift(@ARGV);
                if ( !(-e $ada_sfunction) ) {
                    &expire("Error: File '$ada_sfunction' not found");
                }
                $lang_override = "ada";
                last ARGTYPE;
            };

            /^-aI.*$/ && do {
                $ada_include_dirs .= " " . $_;
                last ARGTYPE;
            };

            /^-entrypt$/ && do {
                $ENV{'ENTRYPOINT'} = shift(@ARGV);
                if ($ENV{'ENTRYPOINT'} ne "mexFunction" &&
                    $ENV{'ENTRYPOINT'} ne "mexLibrary")
                {
                    &expire("Error: -entrypt argument must be either 'mexFunction'\n  or 'mexLibrary'");
                }
                last ARGTYPE;
            };

            # Finished processing all '-' arguments. Error at this
            # point if a '-' argument.
            #
            /^-.*$/ && do {
	        &describe("usage");
                &expire("Error: Unrecognized switch: $_.");
                last ARGTYPE;
            };

            if (&parse_common_nodash_args($_)) {
                last ARGTYPE;
            }

            do {

                # Remove command double quotes (but there by mex.m)
                #
                tr/"//d;

                if (/(.*)\.dll$/)
                {
                    &expire("Error: " . &tool_name() . " cannot link to '$_' directly.\n" .
                            "  Instead, you must link to the file '$1.lib' which corresponds " .
                            "to '$_'.");
                }

                if (!/\.lib$/ && !-e $_) {
	            &expire("Error: '$_' not found.");
                }

                # Put file in list of files to compile
                #
	        push(@FILES, $_);

	        # Try to determine compiler (C or C++) to use from
                # file extension.
                #
                if (/\.(cpp|cxx|cc)$/i)
                {
                    $lang = "cpp";
                }
                if (/\.c$/i)
                {
                    $lang = "c";
                }
                if (/\.(f|for|f90)$/i)
                {
                    $lang = "fortran";
                }

                last ARGTYPE;
            }
        } # end ARGTYPE block
    } # end for loop 

    if ($lang_override) { $lang = $lang_override; }

    if ($lang eq "fortran" && $ENV{'ENTRYPOINT'} ne "mexFunction")
    {
        &describe("fortran_cannot_change_entrypt");
        $ENV{'ENTRYPOINT'} = "mexFunction";
    }

    # Warn user that output target is ignored when compile only.
    #
    if ($compile_only && $output_flag) {
	&describe("meaningless_output_flag");
    }
}
#=======================================================================
sub set_mex_variables
{
    #===================================================================
    # set_mex_variables: Set more variables for mex.
    #===================================================================

    # Use the 1st file argument for the target name (MEX_NAME)
    # if not set. Also set $fortran variable if correct extension.
    #
    ($derived_name, $EXTENSION) = ($FILES[0] =~ /([ \w]*)\.(\w*)$/);
     $ENV{'MEX_NAME'} = $derived_name if (!($ENV{'MEX_NAME'}));
     $fortran = "yes" if ($EXTENSION =~ /^(f|for|f90)$/i);

    if ($RC_COMPILER =~ /\S/) {
        $ENV{'RES_PATH'} = "$ENV{'MATLAB'}\\extern\\include\\";
        $ENV{'RES_NAME'} = "mexversion";
    }
}
#=======================================================================
########################################################################
#=======================================================================
# Mbuild only subroutines:
#=======================================================================
#
# create_export_file:	     Create a single exports file.
# describe_mb:		     Issues mbuild messages.
# dll_makedef:		     Make the exports list.
# dll_variables:	     Set variables with dll options.
# fix_mbuild_variables:	     Fix variables for mbuild.
# init_mbuild:		     Mbuild specific initialization.
# parse_mbuild_args:	     Parse all mbuild arguments including common.
# process_idl_files:	     Process any idl files.
# process_java_files:	     Process any java files.
# register_dll:		     Register DLL with COM object system.
# set_mbuild_variables:	     Set more variables for mbuild.
#
#-----------------------------------------------------------------------
#
# Mbuild variables:
#
#   Perl:
#
#     <none>
#
#   DOS environment:
#
#     <none>
#
#     [$ENV: set in script]
#       MEX_NAME		WATCH THE NAME! This is the target name
#				for both MEX and MBUILD!
#       BASE_EXPORTS_FILE
#       DEF_FILE
#
#     [$ENV: get in script]
#
#       JAVA_DEBUG_FLAGS
#       JAVA_HOME
#       JAVA_OPTIM_FLAGS
#       JAVA_OUTPUT_DIR
#
#     [set in option .bat files]
#
#       [General]
# 	  MATLAB		[script]
#         -------
# 	  BORLAND		(Borland compilers only)
# 	  LCCMEX		(LCC C compiler)
# 	  MSVCDir		(Microsoft Visual Studio only)
#				  [MathWorks]
# 	  DevEnvDir		(Microsoft Visual Studeio 7.1 only)
#				  [MathWorks]	
# 	  MSDevDir		(Microsoft Visual Studio only)
#         -------
# 	  PATH			[DOS]
# 	  INCLUDE		(some)
# 	  LIB			(some)
#         -------
# 	  PERL
#         -------
#
#       [Compile]
# 	  COMPILER		compiler name
# 	  COMPFLAGS		compiler flags
# 	  CPPCOMPFLAGS		C++ executable compiler flags
# 	  DLLCOMPFLAGS		C++ shared library compiler flags
# 	  OPTIMFLAGS		optimization flags
# 	  DEBUGFLAGS		debug flags
# 	  CPPOPTIMFLAGS		C++ optimization flags
# 	  CPPDEBUGFLAGS		C++ DEBUG flags
# 	  NAME_OBJECT		
#
#       [library creation]
# 	  DLL_MAKEDEF
# 	  DLL_MAKEDEF1		(some)
#       
#       [linker]
#	  LIBLOC
#	  LINKER
#	  LINK_LIBS		(some)
#	  LINKFLAGS
#	  LINKFLAGSPOST		(some)
#	  CPPLINKFLAGS
#	  DLLLINKFLAGS
#	  LINKFLAGSPOST		(some)
#	  HGLINKFLAGS		(OBSOLETE)
#	  HGLINKFLAGSPOST	(OBSOLETE some)
#	  LINKOPTIMFLAGS
#	  LINKDEBUGFLAGS
#	  LINK_FILE
#	  LINK_LIB
#	  NAME_OUTPUT
#	  DLL_NAME_OUTPUT
#	  RSP_FILE_INDICATOR
#
#       [resource compiler]
#	  RC_COMPILER       
#	  RC_LINKER
#
#       [IDL Compiler]
# 	  IDL_COMPILER		(some)
# 	  IDL_OUTPUTDIR		(some)
# 	  IDL_DEBUG_FLAGS	(some)	
# 	  IDL_OPTIM_FLAGS	(some)
#
#       [postlink]
#	  POSTLINK1		
#	  POSTLINK2		(some)
#=======================================================================
sub create_export_file
{
    #===================================================================
    # create_export_file: Create a single exports file.
    #===================================================================

    # copy all exported symbols into one master export file
    #
    open(EXPORT_FILE, ">$base_exports_file_nq") ||
            &expire("Could not open file '$base_exports_file_nq': $!");
    push(@FILES_TO_REMOVE, "$base_exports_file_nq") if (!$makefilename);
    foreach my $an_export_file (@EXPORT_FILES)
    {
        open(AN_EXPORT_FILE, "$an_export_file") ||
             &expire("Could not open file '$an_export_file': $!");
        while (<AN_EXPORT_FILE>)
        {
            # Strip out lines that only contain whitespace and
            # lines that start with '#' or '*' (comments)
	    #
            if (/\S/ && !/^[\#*]/)
            {
                print EXPORT_FILE $_;
            }
        }
        close(AN_EXPORT_FILE);
    }
    close(EXPORT_FILE);
}
#=======================================================================
sub describe_mb
{
    #===================================================================
    # describe_mb: Issues mbuild messages. This way lengthy messages do
    #              not clutter up the main body of code.
    #===================================================================

    local($_) = $_[0];

 DESCRIPTION: {
     /^help$/ && print(<<'end_help_mb') && last DESCRIPTION;
  MBUILD [option1 ... optionN] sourcefile1 [... sourcefileN]
         [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
         [exportfile1 ... exportfileN]

Description:
  MBUILD compiles and links source files that call functions in the
  MATLAB Compiler-generated shared libraries into a stand-alone
  executable or shared library.
  
  The first filename given (less any file name extension) will be the
  name of the resulting executable. You can give additional source,
  object, or library files to satisfy external references. You can
  specifiy either C or C++ source files when building executables. In
  addition, you can specify both C and C++ source files at the same
  time as long as the C files are C++ compatible, and you specify the
  -lang cpp option (see -lang below).
  
  Both an options file and command line options affect the behavior of
  MBUILD. The options file contains a list of variables that are passed
  as arguments to various tools such as the compiler, linker, and other
  platform-dependent tools (such as the resource linker on Windows).
  Command line options to MBUILD may also affect what arguments are
  passed to these tools, or may control other aspects of MBUILD's
  behavior.

Command Line Options:
  Options available on all platforms:

  -c
      Compile only. Creates an object file but not an executable.
  -D<name>
      Define a symbol name to the C/C++ preprocessor. Equivalent to a
      "#define <name>" directive in the source.
  -D<name>#<value>
      Define a symbol name and value to the C/C++ preprocessor.
      Equivalent to a "#define <name> <value>" directive in the source.
  -f <optionsfile>
      Specify location and name of options file to use. Overrides
      MBUILD's default options file search mechanism.
  -g
      Create a debuggable executable. If this option is specified,
      MBUILD appends the value of options file variables ending in
      DEBUGFLAGS with their corresponding base variable. (For example,
      the value of LINKDEBUGFLAGS would be appended to the LINKFLAGS
      variable before calling the linker.) This option also disables
      MBUILD's default behavior of optimizing built object code.
  -h[elp]
      Print this message.
  -I<pathname>
      Add <pathname> to the list of directories to search for #include
      files.
  -inline
      Inline matrix accessor functions (mx*). The executable generated
      may not be compatible with future versions of the MATLAB
      Compiler.
  -lang <language>
      Specify compiler language. <language> can be c or cpp. By
      default, MBUILD determines which compiler (C or C++) to use by
      inspecting the source file's extension. This option overrides
      that default.
  -n
      No execute mode. Print out any commands that MBUILD would
      otherwise have executed, but do not actually execute any of them.
  -O
      Optimize the object code by including the optimization flags
      listed in the options file. If this option is specified, MBUILD
      appends the value of options file variables ending in OPTIMFLAGS
      with their corresponding base variable. (For example, the value
      of LINKOPTIMFLAGS would be appended to the LINKFLAGS variable
      before calling the linker.) Note that optimizations are enabled
      by default, are disabled by the -g option, but are reenabled by
      -O.
  -outdir <dirname>
      Place all output files in directory <dirname>.
  -output <resultname>
      Create an executable named <resultname>. (An appropriate
      executable extension is automatically appended.) Overrides
      MBUILD's default executable naming mechanism.
  -setup
      Interactively specify the compiler options file to use as a
      default for future invocations of MBUILD by placing it in
      "<UserProfile>\Application Data\MathWorks\MATLAB\<rel_version>"
      (for Windows) or $HOME/.matlab/<rel_version> (for UNIX). 
      <rel_version> is the base release version, such as R14. When this
      option is specified, no other command line input is accepted.
  -U<name>
      Remove any initial definition of the C preprocessor symbol
      <name>. (This is the inverse of the -D option.)
  -v
      Print the values for important internal variables after the
      options file is processed and all command-line arguments are
      considered. Prints each compile step and final link step fully
      evaluated to see which options and files were used. This option
      is very useful for debugging.
  <name>#<value>
      Override an options file variable for variable <name>. See the
      platform-dependent discussion of options files below for more
      details. This option is processed after the options file is
      processed and all command-line arguments are considered.

Additional options available on Windows platforms:

  @<rspfile>
      Include contents of the text file <rspfile> as command line
      arguments to MBUILD.

Shared Libraries and Exports Files:
  MBUILD can also create shared libraries from C source code. If a file
  or files with the extension ".exports" is passed to MBUILD, then it
  builds a shared library. The .exports file must be a flat text file,
  with each line containing either an exported symbol name, or starting
  with a # or * in the first column (in which case it is treated as a
  comment line). If multiple .exports files are specified, then all
  symbol names in all specified .exports files are exported.

Options File Details:
  On Windows:
    The options file is written as a DOS batch file. If the -f option
    is not used to specify the options filename and location, then
    MBUILD searches for an options file named compopts.bat in the
    current directory, and then the directory
    "<UserProfile>\Application Data\MathWorks\MATLAB\<rel_version>".
    <rel_version> is the base release version, such as R14. You can
    override any variable specified in the options file at the command
    line by using the <name>#<value> command-line argument. If <value>
    has spaces in it, then it should be in double quotes (e.g.,
    COMPFLAGS#"opt1 opt2"). The definition can rely on other variables
    defined in the options file; in this case the variable referenced
    should have a prepended "$" (e.g., COMPFLAGS#"$COMPFLAGS opt2").

  Examples:

    This command will compile "myprog.c" into "myprog.exe" (when run
    under Windows):

      mbuild myprog.c

    When debugging, it is often useful to use "verbose" mode as well as
    include symbolic debugging information.

      mbuild -v -g myprog.c

    This command will compile "mylib.c" into "mylib.dll" (when run
    under Windows). "mylib.dll" will export the symbols listed in
    "mylib.exports":

      mbuild mylib.c mylib.exports

  See Also:
    MATLAB Compiler User's Guide

end_help_mb
     /^usage$/ && print(<<'end_usage_mb') && last DESCRIPTION;
    Usage:
      MBUILD [option1 ... optionN] sourcefile1 [... sourcefileN]
             [objectfile1 ... objectfileN] [libraryfile1 ... libraryfileN]
             [exportfile1 ... exportfileN]

    Use the -help option for more information, or consult the MATLAB Compiler
    User's Guide.

end_usage_mb
     /^general_info$/ && print(<<"end_general_info_mb") && last DESCRIPTION;
 This is mbuild Copyright 1984-2004 The MathWorks, Inc.

end_general_info_mb
     /^invalid_options_file$/ && print(<<"end_invalid_options_file_mb") && last DESCRIPTION;
    Warning: An options file for MBUILD.BAT was found but the
             value for 'COMPILER' was not set.  This could mean that the
             value is not specified within the options file, or it could
             mean that there is a syntax error within the file.


end_invalid_options_file_mb
     /^final_options$/ && print(<<"end_final_options_mb") && last DESCRIPTION;
$sourced_msg
----------------------------------------------------------------
->    Options file           = $OPTFILE_NAME
->    COMPILER               = $COMPILER
->    Compiler flags:
         COMPFLAGS           = $COMPFLAGS
         OPTIMFLAGS          = $OPTIMFLAGS
         DEBUGFLAGS          = $DEBUGFLAGS
         arguments           = $ARG_FLAGS
         Name switch         = $NAME_OBJECT
->    Pre-linking commands   = $PRELINK_CMDS
->    LINKER                 = $LINKER
->    Link directives:
         LINKFLAGS           = $LINKFLAGS
         LINKFLAGSPOST       = $LINKFLAGSPOST
         Name directive      = $NAME_OUTPUT
         File link directive = $LINK_FILE
         Lib. link directive = $LINK_LIB
         Rsp file indicator  = $RSP_FILE_INDICATOR
->    Resource Compiler      = $RC_COMPILER
->    Resource Linker        = $RC_LINKER
----------------------------------------------------------------

end_final_options_mb
     /^file_not_found$/ && print(<<"end_file_not_found_mb") && last DESCRIPTION;
  $main::cmd_name:  $filename not a normal file or does not exist.

end_file_not_found_mb
     /^meaningless_output_flag$/ && print(<<"end_meaningless_output_flag_mb")  && last DESCRIPTION;
  Warning: -output ignored (no MBUILD application is being created).

end_meaningless_output_flag_mb

    /^compiler_not_found$/ && print(<<"end_compiler_not_found_mb") && last DESCRIPTION;
  Could not find the compiler "$COMPILER" on the DOS path.
  Use mbuild -setup to configure your environment properly.

end_compiler_not_found_mb

    /^outdir_missing_name_object$/ && print(<<"end_outdir_missing_name_object_mb") && last DESCRIPTION;
  Warning: The -outdir switch requires the mbuild options file to define
           NAME_OBJECT. Make sure you are using the latest version of
           your compiler's mbuildopts file.

end_outdir_missing_name_object_mb

    /^bad_lang_option$/ && print(<<"end_bad_lang_option_mb") && last DESCRIPTION;
  Unrecognized language specified. Please use -lang cpp (for C++) or
  -lang c (for C).

end_bad_lang_option_mb

    /^bad_link_option$/ && print(<<"end_bad_link_option_mb") && last DESCRIPTION;
  Unrecognized link target specified. Please use -link exe (for an executable)
  or -link shared (for a shared/dynamically linked library).

end_bad_link_option_mb

     do {
         print "Internal error: Description for $_[0] not implemented\n";
         last DESCRIPTION;
     };
 }
}
#=======================================================================
sub dll_makedef
{
    #===================================================================
    # dll_makedef: Make the exports list.
    #===================================================================

    $i = 0;
    my $makedef = $ENV{"DLL_MAKEDEF"};
    while ($makedef =~ /\S/)
    {
        if ($makefilename)
        {
	    &emit_makedef();
        }
        RunCmd($makedef);
        $i++;
        $makedef = $ENV{"DLL_MAKEDEF" . $i};
    }

}
#=======================================================================
sub dll_variables
{
    #===================================================================
    # dll_variables: set variables with dll options.
    #===================================================================

    if ($DLLCOMPFLAGS eq "")
    {
        &expire("Error: The current options file is not configured to create DLLs. "
                . "You can use\n" . &tool_name() . " -setup to set up an options file "
                . "which is configured to create DLLs.");
    }

    $COMPFLAGS = $DLLCOMPFLAGS;
    $LINKFLAGS = $DLLLINKFLAGS;
    $LINKFLAGSPOST = $DLLLINKFLAGSPOST;
    $NAME_OUTPUT = $DLL_NAME_OUTPUT;
}
#=======================================================================
sub fix_mbuild_variables
{
    #===================================================================
    # fix_mbuild_variables: Fix variables for mbuild.
    #===================================================================

    if ($verbose) {
	&describe_mb("final_options");
    }

    if ($COMPILER eq "none") {
        &describe_mb("invalid_options_file");
    }

    if ($outdir_flag && $NAME_OBJECT eq "") {
        &describe_mb("outdir_missing_name_object");
    }

    # Decide how to optimize or debug
    #
    if (! $debug) {                                  # Normal case
        $FLAGS = "$OPTIMFLAGS";
    } elsif (! $optimize) {                          # Debug; don't optimize
        $FLAGS = "$DEBUGFLAGS";
    } else {                                         # Debug and optimize
        $FLAGS = "$DEBUGFLAGS $OPTIMFLAGS";
    }

    # Include the simulink include directory if it exists
    #
    my ($simulink_inc_dir) = '';
    $simulink_inc_dir = "-I$ML_DIR\\simulink\\include"
        if (-e "$MATLAB\\simulink\\include");

    # Add extern/include to the path (it always exists)
    #
    $FLAGS = "-I$ML_DIR\\$mex_include_dir $simulink_inc_dir $FLAGS";

    # Verify that compiler binary exists
    #
    $COMPILER_DIR = &search_path("$COMPILER.exe");
    if ( ! $COMPILER_DIR ) {
	&describe_mb("compiler_not_found");
        &expire("Error: Unable to locate compiler.");
    }

    # If there are no files, then exit.
    #
    if (!@FILES) {
        &describe_mb("usage");
        &expire("Error: No file names given.");
    }
}
#=======================================================================
sub init_mbuild
{
    #===================================================================
    # init_mbuild: Mbuild specific initialization.
    #===================================================================

    if ($main::script_directory) {
        ($main::script_directory) .= "\\mbuildopts";
    } else {
        ($main::script_directory) = ".\\mbuildopts";
    }
    $OPTFILE_NAME = "compopts.bat";

    # Should always be one of {"c", "cpp", "fortran", "all"}
    #
    $lang = "c"; 
    $link = "unspecified";

    $COMPILE_EXTENSION = 'c|cc|cxx|cpp';
}
#=======================================================================
sub parse_mbuild_args
{
    #===================================================================
    # parse_mbuild_args: Parse all mbuild arguments including common.
    #===================================================================

    for (;$_=shift(@ARGV);) {

        # Perl-style case construct
        # print "DEBUG input argument is $_\n";
        #
        ARGTYPE: {

            /^[-\/](h(elp)?)|\?$/ && do {
	        &describe_mb("help");
                &expire("normally");
                last ARGTYPE;
            };

            /^-v$/ && do {
	        &describe_mb("general_info");
                $verbose = "yes";
                last ARGTYPE;
            };

            if (&parse_common_dash_args($_)) {
                last ARGTYPE;
            }

            /^-lang$/ && do {
                $lang_override = shift(@ARGV);
                if (!($lang_override =~ /(cpp|c)/)) { &describe_mb("bad_lang_option"); }
                last ARGTYPE;
            };

            # This is an undocumented feature which is subject to change
            #
            /^-link$/ && do {
                $link = shift(@ARGV);
                if (!($link =~ /^(shared|exe|dll)$/)) { &describe_mb("bad_link_option"); }
                last ARGTYPE;
            };

            /^-regsvr$/ && do {
                $regsvr = "yes";
                last ARGTYPE;
            };

            # Already found. Skip over it.
            #
            /^-mb$/ && do {
                last ARGTYPE;
            };

            /^-package$/ && do {
                $jpackage_flag = "yes";
                $jpackage = shift(@ARGV);
                last ARGTYPE;
            };

            # Finished processing all '-' arguments. Error at this
            # point if a '-' argument.
            #
            /^-.*$/ && do {
	        &describe_mb("usage");
                &expire("Error: Unrecognized switch: $_.");
                last ARGTYPE;
            };

            if (&parse_common_nodash_args($_)) {
                last ARGTYPE;
            }

            /^.*\.exports$/ && do {
                push(@EXPORT_FILES, $_);
                last ARGTYPE;
            };

            /^.*\.def$/ && do {
                if (@DEF_FILES > 0) {
                    &expire( "Error: " . &tool_name() . " Only one .def file is allowed on the command line." );
                }
                push(@DEF_FILES, $_);
                last ARGTYPE;
            };

            /^(.*)\.rc$/ && do {
                if (@RC_FILES > 0) {
                    &expire( "Error: " . &tool_name() . " Only one .rc file is allowed on the command line." );
                }
                push(@RC_FILES, $1);
                last ARGTYPE;
            };

            /^.*\.idl/  && do {
                push(@IDL_FILES, $_);
                last ARGTYPE;
            };

            /^.*\.java/ && do {
                push(@JAVA_FILES, $_);
                last ARGTYPE;
            };

            do {

                # Remove command double quotes (but there by mex.m)
                #
                tr/"//d;

                if (/(.*)\.dll$/)
                {
                    &expire("Error: " . &tool_name() . " cannot link to '$_' directly.\n" .
                            "  Instead, you must link to the file '$1.lib' which corresponds " .
                            "to '$_'.");
		}

                if (!/\.lib$/ && !-e $_) {
	            &expire("Error: '$_' not found.");
                }

                # Put file in list of files to compile
                #
	        push(@FILES, $_);

	        # Try to determine compiler (C or C++) to use from
                # file extension.
                #
                if (/\.(cpp|cxx|cc)$/i)
                {
                    $lang = "cpp";
                }
                if (/\.c$/i)
                {
                    $lang = "c";
                }
                if (/\.(f|for|f90)$/i)
                {
                    $lang = "fortran";
                }

                last ARGTYPE;
            }
        } # end ARGTYPE block
    } # end for loop

    if ($lang_override) { $lang = $lang_override; }

    if ($link eq "unspecified")
    {
        if (@EXPORT_FILES > 0)
        {
            $link = "shared";
        }
        elsif (@DEF_FILES >0) 
        {
            $link = "dll";
        }
        else
        {
            $link = "exe";
        }
    }

    # Warn user that output target is ignored when compile only.
    #
    if ($compile_only && $output_flag) {
	&describe_mb("meaningless_output_flag");
    }
}
#=======================================================================
sub process_idl_files
{
    #===================================================================
    # process_idl_files: Process any idl files.
    #===================================================================

    if ($debug eq "yes") {
        $options = $ENV{'IDL_DEBUG_FLAGS'};
    }
    else {
        $options = $ENV{'IDL_OPTIM_FLAGS'};
    }
    if ($ENV{'OUTDIR'} ne "") {
        $options = "$options $ENV{'IDL_OUTPUTDIR'}";
    }
    if ($ENV{'IDL_COMPILER'} eq "") {
        expire("Error: The chosen compiler does not support building COM objects.\n\tPlease see the MATLAB Add-in for Excel documentation for the latest list of supported compilers." );
    }
    RunCmd("copy $ENV{'MATLAB'}\\extern\\include\\mwcomutil.tlb .");

    foreach my $an_idl_file (@IDL_FILES) 
    {        
        RunCmd( "$ENV{'IDL_COMPILER'} $options \"$an_idl_file\"" );
        if ($? != 0) {
            &expire("Error: IDL compile of '$an_idl_file' failed.");
        }
    }

    RunCmd("del mwcomutil.tlb");
}
#=======================================================================
sub process_java_files
{
    #===================================================================
    # process_java_files: Process any java files.
    #===================================================================

    # environment variable takes precedence
    #
    $java_home = $ENV{'JAVA_HOME'};
    if($java_home eq "")
    {
	#attempt to lookup java info in registry
	$java_version = &registry_lookup("SOFTWARE\\JavaSoft\\Java Development Kit", "CurrentVersion");
	if($java_version ne "")
	{
	    $java_home = &registry_lookup("SOFTWARE\\JavaSoft\\Java Development Kit\\" . $java_version, "JavaHome");
	}
	else
	{
	    &expire("Error: Failed to locate java home location in either windows registry or environment variable.");
	}
    }

    if($java_home ne "")
    {
        print "JAVA HOME: $java_home\n";
 
        $java_bin = $java_home . "\\bin";
        $javac = $java_bin . "\\javac";
        $javah = $java_bin . "\\javah";
        $jar = $java_bin . "\\jar";

        $jni_include = "$java_home\\include";
        $jni_include = "-I\"$jni_include\" -I\"$jni_include\\win32\"";
        $FLAGS = "$FLAGS $jni_include";

	#Wrap in quotes in case of space in path
	$java_bin = "\"" . $java_bin . "\"";
	$javac = "\"" . $javac . "\"";
	$javah = "\"" . $javah . "\"";
	$jar = "\"" . $jar . "\"";
	$jni_include = "\"" . $jni_include . "\"";

    }

    # classpath handling
    #
    $java_builder_jar = $ENV{'MATLAB'} . "\\java\\jar\\toolbox\\javabuilder.jar";
    print "matlab jar file $java_builder_jar\n";
    $java_classpath = $ENV{'CLASSPATH'};
    print "classpath unadulterated: $java_classpath\n";
    if($java_classpath eq "")
    {
        $java_classpath = ".;" . "\"" . $java_builder_jar . "\";";
	print "classpath was empty - set classpath to: $java_classpath\n";
    }
    elsif ($java_classpath =~ m/\Q$java_builder_jar/i eq "")
    {
	$java_classpath = $java_classpath . ";" . "\"" . $java_builder_jar . "\";";
	print "added mathworks jar file - set classpath to: $java_classpath\n";
    }
    else
    {
	print "classpath ok: $java_classpath\n";
    }

    # if we didn't get a hit in the registry try the environment
    #
    if($java_home eq "")
    {
        print "Did not locate java in registry.  Trying environment.\n";

        $java_home = $ENV{'JAVA_HOME'};
        if($java_home eq "")
        {
            &expire("Error: Failed to locate java home location in either windows registry or environment variable.");
        }
    }

    if ($debug eq "yes") {
        $options = $ENV{'JAVA_DEBUG_FLAGS'};
    }
    else {
        $options = $ENV{'JAVA_OPTIM_FLAGS'};
    }
    if ($ENV{'OUTDIR'} ne "") {
        $options = "$options $ENV{'JAVA_OUTPUTDIR'}";
    }

    $new_jar = 1;
    foreach my $a_java_file (@JAVA_FILES) 
    {
        print "javac\n";
        RunCmd( "$javac $options -classpath $java_classpath \"$a_java_file\"" );
        if ($? != 0) {
            &expire("Error: javac of '$a_java_file' failed.");
        }

        ($base, $dir, $ext) = fileparse($a_java_file);
        
        $jni_file = (fileparse($base,'\..*'))[0];
        if($jpackage_flag eq "yes")
        {
            $jni_file = $jpackage . "." . $jni_file;
        }

        print "javah\n";
        RunCmd( "$javah $options -classpath $java_classpath \"$jni_file\"" );
        if ($? != 0) {
            &expire("Error: javah of '$jni_file' failed.");
        }

        print "jar\n";
	$jpackage_orig = $jpackage;
	$jpackage =~ s/\./\\/g;
	$jpackage_path = $jpackage;
	$jpackage = $jpackage_orig;

	print "jpackage path = $jpackage_path\n";

        $java_class_file = $jpackage_path . "\\" . (fileparse($base,'\..*'))[0] . ".class";

        if($new_jar == 1)
        {
            $jar_opts = "-cvf";
        }
        else
        {
            $jar_opts = "-uvf";
        }

        RunCmd( "$jar $jar_opts $ENV{'MEX_NAME'}.jar \"$java_class_file\"" );
        if ($? != 0) {
            &expire("Error: jar failed.");
        }
        else
        {
            $new_jar = 0;
        }
    }

    print "Done processing files";
}
#=======================================================================
sub register_dll
{
    #===================================================================
    # register_dll: Register DLL with COM object system.
    #===================================================================

    RunCmd( "mwregsvr " . &smart_quote( "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension") );
    if ($? != 0) {
        &expire("Error: regsvr32 for $ENV{'OUTDIR'}$ENV{'MEX_NAME'}.$bin_extension failed.");
    }
}
#=======================================================================
sub set_mbuild_variables
{
    #===================================================================
    # set_mbuild_variables: Set more variables for mbuild.
    #===================================================================

    # Use the 1st file argument for the target name (MEX_NAME)
    # if not set.
    #
    ($derived_name, $EXTENSION) = ($FILES[0] =~ /([ \w]*)\.(\w*)$/);
     $ENV{'MEX_NAME'} = $derived_name if (!($ENV{'MEX_NAME'}));

    # Create the name of the master exports file which mex will generate.
    # This is an "input" to the options file so it needs to be set before we
    # process the options file.
    #
    if ($link eq "dll") {
        $ENV{'DEF_FILE'}          = &smart_quote(@DEF_FILES);
    }
    elsif ($makefilename)
    {
        # _nq => not quoted
	#
        $base_exports_file_nq     = "$ENV{'OUTDIR'}$ENV{'MEX_NAME'}_master.exports";
        $ENV{'BASE_EXPORTS_FILE'} = &smart_quote($base_exports_file_nq);
        $ENV{'DEF_FILE'}          = &smart_quote("$ENV{'OUTDIR'}$ENV{'MEX_NAME'}_master.def");
    }
    else
    {
        $base_exports_file_nq     = "$ENV{'OUTDIR'}$$\_tmp.exports";
        $ENV{'BASE_EXPORTS_FILE'} = &smart_quote($base_exports_file_nq);
        $ENV{'DEF_FILE'}          = "$ENV{'LIB_NAME'}.def";
    }
    $BASE_EXPORTS_FILE = $ENV{'BASE_EXPORTS_FILE'};
    $DEF_FILE          = $ENV{'DEF_FILE'};

    if (@RC_FILES>0) {
        $_ = pop(@RC_FILES);
        /(.*\\|)([ \w]+)$/;
        $ENV{'RES_PATH'} = $1;
        $ENV{'RES_NAME'} = $2;
    }
}
#=======================================================================
########################################################################
#=======================================================================
# Main:
#=======================================================================
&init_common();

$main::mbuild = scalar(grep {/^-mb$/i} @ARGV) ? 'yes' : 'no';

if ($main::mbuild eq 'no')
{
    #===================================================================
    # MEX section
    #===================================================================

    &init_mex();
    &parse_mex_args();

    # Ada S-function
    #
    if ($lang eq "ada")
    {
        build_ada_s_function($ada_sfunction, $ada_include_dirs);
        &expire("normally");
    }

    # Do only setup if specified.
    #
    if ($setup || $setup_special)
    {
        &do_setup();
        exit(0);
    }

    &set_common_variables();
    &set_mex_variables();    

    &options_file();

    &fix_flag_variables();
    &process_overrides();

    &fix_mex_variables();
    &fix_common_variables();

    if ($makefilename)
    {
        # MAKEFILE is closed in &expire()
        #
        &start_makefile();
    }
    &compile_files();
    &expire("normally") if ($compile_only);
    if ($makefilename)
    {
        &emit_link_dependency();
    }
    &prelink();
    &files_to_remove();
    if ($ENV{'RES_NAME'} =~ /\S/)
    {
	&compile_resource();
    }
    &linker_arguments();
    &link_files();
    if ($ENV{'RES_NAME'} =~ /\S/ && $RC_LINKER =~ /\S/)
    {
	&resource_linker();
    }
    &postlink();
    if ($makefilename)
    {
       &emit_delete_resource_file();
       &emit_makefile_terminator();
    }
    &expire("normally");
}
else
{
    #===================================================================
    # MBUILD section
    #===================================================================

    &init_mbuild();
    &parse_mbuild_args();

    # Do only setup if specified.
    #
    if ($setup || $setup_special)
    {
        &do_setup();
        exit(0);
    }

    &set_common_variables();
    &set_mbuild_variables();    

    &options_file();
    if ($link eq "shared" || $link eq "dll") 
    {
        &dll_variables();
        if ($link eq "shared")
        {
	   &create_export_file();
        }
    } 

    &fix_flag_variables();
    &process_overrides();

    &fix_mbuild_variables();
    &fix_common_variables();
    
    if ($makefilename)
    {
        # MAKEFILE is closed in &expire()
        #
        &start_makefile();
    }
    if (scalar(@JAVA_FILES) > 0)
    {
	&process_java_files();
    }
    if (scalar(@IDL_FILES) > 0)
    {
	&process_idl_files();
    }
    &compile_files();
    &expire("normally") if ($compile_only);
    if ($makefilename)
    {
        &emit_link_dependency();
    }
    &prelink();
    if ($link eq "shared")
    {
	&dll_makedef();
    }
    &files_to_remove();
    if ($ENV{'RES_NAME'} =~ /\S/)
    {
	&compile_resource();
    }
    &linker_arguments();
    &link_files();
    if ($ENV{'RES_NAME'} =~ /\S/ && $RC_LINKER =~ /\S/)
    {
	&resource_linker();
    }
    &postlink();
    if ($regsvr)
    {
        &register_dll();
    }
    if ($makefilename)
    {
       &emit_delete_resource_file();
       &emit_makefile_terminator();
    }
    &expire("normally");
}
#=======================================================================
