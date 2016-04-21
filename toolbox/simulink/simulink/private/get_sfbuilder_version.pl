#  Name:
#     get_sfbuilder_version.pl-- reads version of the generated S-function.  
#  Usage:
#    to be called by $MATLAB/toolbox/simulink/simulink/sfunctionwizard.m
#
# Copyright 1990-2002 The MathWorks, Inc.
# $Revision: 1.2 $

($SfunName)= @ARGV;

$defineData ="#define SFUNWIZ_REVISION";

$beginStr = "SFUNWIZ_defines_Changes_BEGIN";
$endStr = "SFUNWIZ_defines_Changes_END";

open(HFile, "<$SfunName") || die "Unable to open  $SfunName";

while (<HFile>) {  
 my($line) = $_;
 if(/$beginStr/.../$endStr/){
   if(/$defineData\s*\.*/) {
     ($var0, $var1, $var2) = /(\w+)\s+(\w+)\s+(.*)/;
      $mlVar =  "ad.Version = '$var2';"
   }
 }
}
close(HFile);
print "$assignMATLABVar\n";

print "$mlVar\n";



