# $Revision: 1.1 $
# PERL file for replacing MemoryAddress placeholders.
# @MemoryAddress@varName@ ==> MemoryAddress(varName)
# ---------------------------------------------------
$addrPrefix = "@" . "MemoryAddress" . "@";
$addrSuffix = "@";
$ASAP2FileName = $ARGV[0];
$MAPFileName   = $ARGV[1];
$outputFileName = "temp_" . $ASAP2FileName;
$indent = "";
%MAPFileHash = ();

# Read MAPFILE and convert to Hash Table.
# - Read MAPFILE
open(MAPFILE, $MAPFileName) 
  || die "PERL Error: Couldn't open MAP file: ", $MAPFileName, ".\n";
undef $/; $MAPFileString = <MAPFILE>; $/ = "\n";
close(MAPFILE);
# - Replace consecutive white-space characters with a single space
$MAPFileString =~ s/\s+/ /g;
# - Convert MAPFileString to MAPFile Hash Table
%MAPFileHash = split(/[\s]/, $MAPFileString);

# Read ASAP2FILE and replace MemoryAddress placeholders.
# - Read ASAP2FILE
open(ASAP2FILE, $ASAP2FileName) 
  || die "PERL Error: Couldn't open ASAP2 file: ", $ASAP2FileName, "\n";
undef $/; $ASAP2FileString = <ASAP2FILE>; $/ = "\n";
close(ASAP2FILE);

# - Replace MemoryAddress placeholder with actual address from MAP file
$ASAP2FileString =~ s/$addrPrefix(\S*)$addrSuffix/($MAPFileHash{$1} || ($addrPrefix . $1 . $addrSuffix))/egs;

# Open ASAP2FILE for writing
open(OUTPUTFILE, (">" . $outputFileName)) 
  || die "PERL Error: Couldn't open output file: ", $outputFileName, "\n";
print OUTPUTFILE $ASAP2FileString;
close(OUTPUTFILE);

# Rename OUTPUTFILE (overwrites ASAP2FILE)
rename $outputFileName, $ASAP2FileName;