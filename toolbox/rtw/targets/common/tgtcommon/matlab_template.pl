# File : matlab_template.pl
#
# Abstract :
#   Simple matlab templating engine
#
# Usage:
#   # template
#   # header = 'mystring';
#   # for i = 1:10
#   #   s = sin(i);
#   #   k = i + s;
#   ${header} ------------------
#   ${i} + ${s%0.2f} = ${k%0.2f} 
#   ----------------------------
#   # end
#
# or
#
#   # template(i,j,k)
#   # header = 'mystring';
#   # for n = 1:i
#   ${i} , ${j}, ${n}
#   # end
# 
# Notes:
#   At this time the expanded values
#   in the template should be scalars
#   or strings. Arrays and cell arrays
#   are not supported and may make the
#   engine crash.
#
# $Revision: 1.1.6.2 $
# $Date: 2004/04/19 01:22:00 $ 
#
# Copyright 2002-2004 The MathWorks, Inc.

if ($ARGV == 1){
    $infile = $ARGV[1];
    open (STDIN,"<$infile");
}
# Lexical states are
#  header       -   looking for the header
#  start        -   start of the processing
#  command      -   last line processed was a command line
#  text         -   last line processed was a text line
$state = 'header';
$line = 0;
while ( <> ) {
    chomp; # Remove line feeds
    $line ++;

    if ( $state =~ /header/ ){

        if ( ($args) = $_ =~ /\s*#\s*template\s*\((.*)\)/ ) {
            @args = split(',',$args);
            $i=1;
            foreach $arg ( @args ){
               if ($arg !~ /^\s*$/){
                  print "$arg = TEMPLATE_ARGS{$i};\n";
                  $i+=1;
               }
            }
            $state = 'start';
            print "OUTPUT_TEXT = '';\n";
        }elsif ( $_ !~ /^\s*$/){
            die <<END
ERROR parsing line $line 
Expecting to find #template at head of template file. Found

$_

END
        }
    }elsif ( $_ =~ /^\s*#/ ) {
        #
        # Command Line
        #

        $_ =~ s/^(\s*)#(.*)/\1\2/ ;
        if ( $state =~ /text/ ){
            print "\t);\n";
        }
        print "$_\n";
        $state = 'command';
    }else{
        #
        # Text Line
        #
        $args = $_;

        # Escape some matlab characters for the sprintf commands
        $_ =~ s/%/%%/g;
        $_ =~ s/'/''/g;

        #
        # Process inlined references. Inlined references
        # are noted by forms such as ${i} or ${i%g}. These
        # forms can be literally placed into the output
        # stream by escaping with backslash \. ie
        # \${i} -> ${i} in the output stream
        #

        # Process formatted text insertion such as ${i%0.5g}
        $_ =~ s/([^\\]|^)\${[^}]*(%[^}]*)}/\1\2/g ;
        # Process unformatted text insertion such as ${i}
        $_ =~ s/([^\\]|^)\${[^}]*}/\1%s/g ;
        # Insert escaped characters by removing the backslash
        $_ =~ s/\\(.)/\1/g;


        # Generate the sprintf argument list
        $args = getargs($args);
        if ( $state =~ /command|start/  ){
            print "OUTPUT_TEXT = strvcat(OUTPUT_TEXT, ...\n\tsprintf(\'$_\'$args) ";
        }else{
            print ", ...\n\tsprintf(\'$_\'$args) ";
        }
        $state = 'text';
    }
}
if ( $state =~ /text/ ){
    print "\t);\n";
}

sub getargs {
    # Get the sprintf argument list
    my $args = shift;
    $out = "";
    while ( $args ){
        if ( ($tmp,$arg, $args) = ($args =~ /([^\\]|^)\${([^}]*)}(.*)/) ){
            if ($arg =~ /%/){
                # Formatted arguments are passed directly to sprintf
                $arg =~ s/%.*//;
            }else{
                # Unformatted arguments are processed with num2str
                # first. Unformatted arguments are given the %s specifier
                # in the sprintf format string.
                $arg = "strtrim(evalc('disp(($arg))'))";
            }
            $out = "$out,$arg";
        }
    }
    return "${out}";
}

