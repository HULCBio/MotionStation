# PERL file for extracting custom storage class attributes relationships from file:
# @PackageName/@ClassName/CustomStorageClassListener.m
#
#   $Revision: 1.3 $
#
#   Copyright 1990-2002 The MathWorks, Inc.

$ListenerFileName = $ARGV[0];

# Read CustomStorageClassListener.m file as a single string.
if (open(LISTENERFILE, $ListenerFileName)){
  undef $/; $_ = <LISTENERFILE>; $/ = "\n";
  close(LISTENERFILE);
} else {
  print "Error: Couldn't open file: ", $ListenerFileName, "\n";
  exit;
}

# Extract correct Attributes class names for each CustomStorageClass
print "{";
if (/case/){
  # Split up CustomStorageClass==>Attributes mappings
  @CSCs = split(/case/, $_);

  foreach $i (1 .. $#CSCs) {
    $_ = $CSCs[$i];
    # Extract CustomStorageClassName & correctAttributesClass
    ($CSCName, $AttribClass) = /\s*('\S+')\s*correctAttribClass\s*=\s*('\S*')/;
    # --------------------------  'CSCName'  correctAttribClass   =  'AttribClass'

    print $CSCName, ", ", $AttribClass, "; ";
  }
}
print "}";