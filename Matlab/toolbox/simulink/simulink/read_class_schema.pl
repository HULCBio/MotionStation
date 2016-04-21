# PERL file for extracting class information from file:
# @PackageName/@ClassName/schema.m
#
#   $Revision: 1.6 $
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

# OUTPUT CLASSNAME IF REQUIRED FOR ERROR CHECKING
## Extract ClassName
#($ClassName) = /schema.class\((\S+)\)/;
#
#print $ClassName;

# Extract info about parent package & class
($DeriveFromPackage) = /findpackage\((\S+)\)/;
($DeriveFromClass)   = /findclass\([^,]*,\s*(\S+)\)/;

if ($DeriveFromClass eq "") {
  print "{''; ''}; ";
}
else {
  print "{", $DeriveFromPackage, "; ", $DeriveFromClass, "}; ";
}

# Remove all text after "%%%% Create CustomStorageClass listeners"
if (($DeriveFromPackage eq "Simulink") && ($DeriveFromClass eq "RTWInfo")){
  s/%%%% Create CustomStorageClass listeners(.*)//s;
}

# Extract local property definitions
print "{";
if (/schema.prop/){
  # Split up property definitions
  @localProps = split(/schema.prop/, $_);

  foreach $i (1 .. $#localProps) {
    $_ = $localProps[$i];
    # Extract PropertyName & PropertyType
    ($propName, $propType) = /\([^,]*,\s*([^,]*),\s*([^\)]*)/;
    # ------------------------ (.....,  propName,  propType)

    # Extract FactoryValue (if defined)
    if (/.FactoryValue\s*=/){
      ($propFV) = /.FactoryValue\s*=\s*(.*)\s*/;
      # ---------- .FactoryValue   =   propFV;
      $propFV =~ s/'/''''/g;
    }
    else {
      $propFV = "";
    }
    print $propName, ", ", $propType, ", '''", $propFV, "'''; ";
  }
}
print "}";

print "}";






