#!perl
#
# Due to a bug in the Borland C++ Builder 3.0 resource compiler (brc32),
# we cannot use the resource compiler to add a version resource to 
# a MEX-file. Instead, we have to provide the .RES file at link time
# to the linker, ilink32. ilink32 has some very specific requirements
# regarding the order in which filenames and options are presented to
# it at the command line. To allow mex.bat to call ilink32, we have
# it call this script instead, which rearranges the files and options
# into the required order and then passes them to ilink32.
#
# $Revision: 1.4 $ $Date: 2001/05/29 17:45:43 $
#

require "shellwords.pl";

BEGIN {
    # Correct how the $cmd_name variable looks so that it is presentable
    # to DOS users (i.e., trade / with \).
    ($cmd_name) = $0;
    ($cmd_name) =~ s/\//\\/g;
    ($cmd_name) =~ tr/a-z/A-Z/;

    ($script_directory) = ($cmd_name =~ /(.*)\\.*/);
    $script_directory = `cd` if (!($script_directory));

    # Make sure the registry Perl files are on the path
    unshift @INC, "$script_directory\\perl\\lib";
}

sub process_response_file
{
# inputs:
    local($filename) = @_;

# locals:
    local($rspfile);

    open(RSPFILE, "$filename") || die "Can't open response file $filename";
    while (<RSPFILE>)
    {
        $rspfile .= $_;
    }
    close(RSPFILE);

    # shellwords strips out backslashes thinking they are escape sequences.
    # In DOS we'd rather treat them as DOS path seperators.
    $rspfile =~ s/\\/\\\\/g;
    # return output of shellwords
    &shellwords($rspfile);
}

for (;$_=shift(@ARGV);) 
{
  ARG:
    {
        /^@(.*)$/ && do {
            @NEW_ARGS = &process_response_file($1);
            unshift(@ARGV, @NEW_ARGS);
            last ARG;
        };

        /^[-\/].*$/ && do
        {
            $OPTION .= " " . $_;
            last ARG;
        };

        /^.*\.obj$/i && do
        {
            $OBJ .= " \"" . $_ . "\"";
            last ARG;
        };

        /^.*\.lib$/i && do
        {
            $LIB .= " \"" . $_ . "\"";
            last ARG;
        };

        /^.*\.def$/i && do
        {
            $DEF .= " \"" . $_ . "\"";
            last ARG;
        };

        /^.*\.res$/i && do
        {
            $RES .= " \"" . $_ . "\"";
            last ARG;
        };

        /^.*\.dll$/i && do
        {
            $DLL .= " \"" . $_ . "\"";
            last ARG;
        };
        
        /^.*\.exe$/i && do
        {
            $DLL .= " \"" . $_ . "\"";
            last ARG;
        };
        # Treat anything else as an option
        $OPTION .= " " . $_;
    }
}

srand;
$$ = int(rand(10000));
open(RSPFILE, ">$$.rsp") || die "Can't open $$.rsp";
print RSPFILE "$OBJ";
close(RSPFILE);

$cmd = "ilink32 $OPTION \@$$.rsp , $DLL , , $LIB , $DEF , $RES";
if (0)
{
    $| = 1;
    print "\$OPTION = $OPTION\n";
    print "\$OBJ    = $OBJ\n";
    print "\$DLL    = $DLL\n";
    print "\$LIB    = $LIB\n";
    print "\$DEF    = $DEF\n";
    print "\$RES    = $RES\n";
    print "-----------------------------\n";
    printf("$cmd\n");
}

system($cmd);
unlink("$$.rsp");
