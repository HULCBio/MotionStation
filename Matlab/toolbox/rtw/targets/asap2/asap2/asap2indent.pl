# PERL file for correcting indenting of ASAP2 file.
#   $Revision: 1.3 $
#
#   Copyright 1994-2002 The MathWorks, Inc.

$ASAP2FileName  = $ARGV[0];
$outputFileName = "temp_" . $ASAP2FileName;
$indent = "";

# Open ASAP2FILE and OUTPUTFILE
open(ASAP2FILE, $ASAP2FileName) 
  || die "PERL Error: Couldn't open ASAP2 file: ", $ASAP2FileName, "\n";
open(OUTPUTFILE, (">" . $outputFileName)) 
  || die "PERL Error: Couldn't open output file: ", $outputFileName, "\n";

while ($_ = <ASAP2FILE>){
  # Remove leading spaces
  s/[^\S\n]*//;
  
  # Reduce indent if /end found at beginning of line
  if (/^\/end/){
    $indent = substr($indent, 2);
  }

  # Print the current line with appropriate indent:
  print OUTPUTFILE $indent, $_;

  # Increase indent if /begin found at beginning of line
  if (/^\/begin/){
    $indent = ($indent . "  ");
  }
  # Increase indent if /* found at beginning of line
  if (/^\/\*/){
    $indent = ($indent . " ");
  }
  # Reduce indent if */ found
  if (/\*\//){
    $indent = substr($indent,1);
  }
}
close(OUTPUTFILE);
close(ASAP2FILE);

# Rename outputFile to overwrite ASAP2File
rename $outputFileName, $ASAP2FileName;

print "0";