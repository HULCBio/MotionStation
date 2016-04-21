# PERL file for extracting package information from file: 
# @PackageName/schema.m
#
#   $Revision: 1.3 $
#
#   Copyright 1990-2002 The MathWorks, Inc.

$SCHEMAFileName = $ARGV[0];

# Read SCHEMA.M file as a single string.
if (open(SCHEMAFILE, $SCHEMAFileName)){
  undef $/; $_ = <SCHEMAFILE>; $/ = "\n";
  close(SCHEMAFILE);
} else {
  print "Error: Couldn't open file: ", $SCHEMAFileName, "\n";
  exit;
}

print "{";

# OUTPUT PACKAGENAME IF REQUIRED FOR ERROR CHECKING
## Extract PackageName
#($PackageName) = /schema.package\((\S+)\)/;
#
#print $PackageName;

# Extract EnumType definitions
if (/schema.EnumType/){
  # Split up EnumType definitions
  @enumTypes = split(/schema.EnumType\(/, $_);

  foreach $i (1 .. $#enumTypes){
    # Extract EnumTypeName and corresponding strings
    ($enumName, $enumStrings) = $enumTypes[$i] =~ /(\S+),([^\)]*)/;

    # Remove all new-line characters from enumStrings
    $enumStrings =~ s/\n+//g;

    print "{", $enumName, ", ", $enumStrings, "}; ";
  }
}

print "}";
