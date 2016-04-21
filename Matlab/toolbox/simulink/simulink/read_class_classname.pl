# PERL file for extracting class information from file:
# @PackageName/@ClassName/ClassName.m
#
#   $Revision: 1.4 $
#
#   Copyright 1990-2002 The MathWorks, Inc.

$CLASSNAMEFile = $ARGV[0];

# Read SCHEMA.M file as a single string.
if (open(SCHEMAFILE, $CLASSNAMEFile)){
  undef $/; $_ = <SCHEMAFILE>; $/ = "\n";
  close(SCHEMAFILE);
} else {
  print "Error: Couldn't open file: ", $CLASSNAMEFile, "\n";
  exit;
}

#print "{";
#
# OUTPUT CLASSNAME IF REQUIRED FOR ERROR CHECKING
## Extract ClassName
#($ClassName) = /schema.class\((\S+)\)/;
#
#print $ClassName;

## Extract Initialization information if defined
if (/%%%% Initialize property values\n/) {
  ($classInit) = /%%%% Initialize property values\s*(.*)$/s;
}else {
  $classInit = "";
}

print $classInit;

#print "}";






