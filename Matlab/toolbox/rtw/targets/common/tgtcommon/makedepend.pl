# makedepend.pl
#
# Arguments
#
#  -Iincludepath1 -Iincludepath2 -Iincludepath3  sourcefile.c targetfile.o
#
# Outputs
#
#   targetfile.o.dep


# $Revision: 1.1.6.2 $
# $Date: 2004/04/19 01:21:58 $
#
# Copyright 2003-2004 The MathWorks, Inc.

# Allow the use of the cwd command
use Cwd;


# Hash of targets and prerequisites from exisiting depenendency file
# 
# Target name maps to an array of prerequisites
%targets = ();

# Hash of all the dependencies in the scanned source file
#
# Prerequisite name maps to the full path to the prerequisite
%dependencies = ();

# Array of dummy targets
@dummies = ();

# Array of the include directories with a default current directory.
my @includedirs; 
push @includedirs, ".";

# Show debug output ?
$debug = 0;

# The name of the current source file
my $sourcefile = '';

# The name of the current target file
my $targetfile = '';


if ( @ARGV ) {				# parse command line args
    foreach $opt ( @ARGV ) {
		# Extract the -I include options
        if ( $opt =~ /^-I.*$/ ){
            $opt =~ s/^-I(.*$)/\1/;
            push @includedirs, fix_path_seps($opt);
        }

        my %includesfilter;
        @includesfilter{@includedirs} = ();
        @includedirs = keys %includesfilter;

		# The sourcefile and the targetfile will be
		# the 2nd last and the last options
		# respectively
        $sourcefile = $targetfile;
        $targetfile = $opt;
    }
}else{
    usage("");
}

$sourcefile = fix_path_seps($sourcefile);
$targetfile = fix_path_seps($targetfile);
$depFileName = "dependencies.mk";

processFile($sourcefile);
parseDependFile($depFileName);
createDependencyFile($sourcefile,$targetfile,$depFileName);

# mergeDependencies
#
# Merge the dependencies for the current source file
# with the dependencies scanned from an existing 
# dependency file
sub mergeDependencies {
    @dependencies = values %dependencies;
    # Remove unfound files
    @dependencies = grep { !/^\s*$/ } @dependencies;
    $targets{$targetfile} = \@dependencies;

    # A filter to remove duplicates prerequisites
    # for building the list of dummies
    my %targetfilter;

    foreach $target ( keys(%targets) ){
        @prerequisites = @{$targets{$target}};
        @targetfilter{@prerequisites} = ();
    }
    @dummies = keys %targetfilter;
}

# createDependencyFile
#
# Create the dependency file
#
# Arguments
#   $file    -   The name of the original file
sub createDependencyFile {
    my $sourcefile = shift;
    my $targetfile = shift;
    my $depfile = shift;

    # Merge in the dependencies of the old file
    mergeDependencies();

    print "Create dependency file $depfile\n"; 

    if ( open ( DEPFILE, ">$depfile") ){ 

print DEPFILE<<END;

# -----------------------------------------------
# 
# Automatically generated gmake dependency file
#
# Do not manually edit this file.
#
# Manual changes may cause future dependency
# generation to fail.
#
# -----------------------------------------------

END

        foreach $target ( keys(%targets) ) {
            print DEPFILE "# START TARGET $target\n";
            print DEPFILE "$target : "; 
			   @prerequisites = @{$targets{$target}};
				foreach $prerequisite ( @prerequisites ){
					$prerequisite = escapeSpaces($prerequisite);
					print DEPFILE "\\\n\t$prerequisite";
				}
            print DEPFILE "\n";
            print DEPFILE "# END TARGET $target\n\n";
        }

        print DEPFILE "# START DUMMY TARGETS\n";
        foreach $dummy ( @dummies ){
			$dummies = escapeSpaces($dummy);
            print DEPFILE "\n$dummy :\n";
        }
        print DEPFILE "# END DUMMY TARGETS\n";
        close DEPFILE;
    }else{
        die "Unable to open $depfile\n";
    }
}

# Escape spaces in strings
#
# escapeSpaces('abc xyz\ 123') -> 'abc\ xyz\ 123'
#
sub escapeSpaces {
	my $in = shift;
	$in =~ s/(?<!\\)(\s)/\\$1/g;
	return $in;
}



# Generate the dependencies for the specific
# file by recursively scanning this file and
# then all its dependent files.
#
# The dependencies are added to the global
# hash %dependencies
#
# Arguments
#   $file   -   The file to process
sub processFile {
    my $file = shift;
    my @includes;

    @includes = &getIncludesFromFile($file);

    foreach $include ( @includes ) {
        if (!defined($dependencies{$include})){
            if ( $fullpath = findpath($include) ) {
                $dependencies{$include} = generate_relative_path(cwd,$fullpath);
                processFile($fullpath);
            }else{
                $dependencies{$include} = "";
            }
        }
    }
}

# Find the path of the file on the include paths
#
# Arguments
#   $file   -   The name of the file to find
sub findpath{
    my $file = shift;
    foreach $includedir ( @includedirs ) {
        $fullpath = "$includedir/$file";
        if (open FH, $fullpath){
            close FH;
            print "findpath : found $fullpath\n" if $debug; 
            return $fullpath;
        }
    }
    $tmp = join("\n",@includedirs);
    warn "Unable to find $file in \n$tmp\n" if $debug;
    return undef;
}

sub parseDependFile {
    # Name of the file to parse
    my $file = shift;

    # Valid states are
    #   reset
    #   target
    #   prerequisites
    #   dummy
    my $state = 'reset';

    # Current target
    my $target = '';

    # Array of prerequisites for the currently scanned targets
    my @prerequisites = ();

    $open = open FH,fix_path_seps($file); 
    if ( $open ){
        @lines = <FH>;

        foreach $line ( @lines) {
            for ($state){
                # Reset State
                /reset/ && do {
                    for ($line) {

                        # START TARGET token
                        /START TARGET/ && do {
                            chomp;
                            $target = $_;
                            $target =~ s/.*START TARGET\s*//;
                            @prerequisites = ();
                            $state = 'target';
                            last;
                        };

                        # START DUMMY targets token
                        /START DUMMY TARGETS/ && do {
                            $state = 'dummy';
                            last;
                        };
                    }
                    last;
                };

                # Target State
                /target/ && do {
                    # We allready know the name of the target so we
                    # don't need to parse this line. 
                    $state = 'prerequisites';
                    last;
                };

                # Prerequisites State
                /prerequisites/ && do {
                    for ($line){
                        
                        # END TARGET token
                        /END TARGET/ && do {
                            # Add all the prerequisites to the target hash
                            $state = 'reset';
                            $targets{$target} = [@prerequisites];
                            last;
                        };

                        do {
                            # Add the current prerequisite to the list
                            s/\\\s*$//;
                            push @prerequisites, trim($_);
                            last;
                        }
                    }
                    last;
                };

                # Dummy State
                /dummy/ && do {
                    for ($line) {
                        /END DUMMY/ && do {
                            $state = 'reset';
                            last;
                        };
                    }
                    last;
                };

                # Catch a programming error.
                die "Unmatched state $state.";
            }
        }   
    }else{
        print "Warning : dependencies.mk does not yet exist.\n";
    }

    return %targets;
}

#Trim whitespace
sub trim($)
{
    $_ = shift;
    s/^\s*//;
    s/\s*$//;
    return $_;
}


# Extract all the include lines from the file
#
# Arguments
#   $file   -   The name of the file to parse

sub getIncludesFromFile {
    my $file = shift;

    $open = open FH,fix_path_seps($file); 
    if ( $open ){
        @lines = <FH>;
        # Find all #include, %include, .include  lines
		  #
		  # This should deal with C, Assembler and SWIG files
        @allincs = grep(/^\s*[\%\#\.]\s*include/,@lines); 
        foreach ( @allincs ) {
            # Extract file names
            if ( !(/\s*[\%\#\.]\s*include\s+[<\"]([^>\"]*)[>\"]/) ) {
                next;
            }
            push(@includes, $1);
        }
        return @includes;
    }else{
        usage("Can't find file $file whilst processing sourcefile $sourcefile");
    }
}

# Dump error message then die
sub usage {
    my $message = shift;

    print "$message\n\n";
    print "Usage :\n";
    print "makedepend.pl -I incpath1 -I incpath2 -I inpath3 <sourcefile> <targetfile>\n";
    die;
}

# Make sure we use forward slashes
sub fix_path_seps {
    my($p) = @_;
    $p =~ s-\\-/-g;
    return $p;
}


# generate_relative_path
#
# Arguments
#   $start      -   The path from which you start
#   $end        -   The path you wish to navigate to
#
# Returns
#   A relative path navigation from start to end
#
# Example
#   d:/a/b/c/d/e d:/a/b/c/d/e/hell.txt
#   hell.txt
#
#   d:/a/b/c/d/e/f d:/a/b/c/d/e/hell.txt
#   ../hell.txt
#
#   perl pp.pl d:/a/b/c/d/e d:/a/b/c/d/e/g/i/hell.txt
#   g/i/hell.txt
sub generate_relative_path {
	my $start = shift;
	my $end = shift;

	#Check to see if $end a relative path allready
	if ( open FH, "$start/$end" ){
		close FH;
		return $end;
	}


	#Split the start and end paths along the forward
	#slash seperator. Then remove the common prefix
	my @start = split m!/!, $start;
	my @end = split m!/!, $end;


	$common_volume = 0;
	if ($^O eq "MSWin32"){
		# MSWin32 is case insensitive
		while ( lc($start[0]) eq lc($end[0]) ) {
			$common_volume = 1;
			shift @start;
			shift @end;
		}
	}else{
		while ( $start[0] eq $end[0] ) {
			$common_volume = 1;
			shift @start;
			shift @end;
		}
	}

	return $end if !$common_volume;


	my $start_to_end = join '/', ( '..' ) x @start, @end;

	return $start_to_end;
}
 
