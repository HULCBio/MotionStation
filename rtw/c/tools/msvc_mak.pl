# Copyright 1994-2002 The MathWorks, Inc.
#
# File    : msvc_mak.pl   $Revision: 1.6 $
# Abstract:
#	The Real-Time Workshop uses this Perl script is used to create a 
#	Microsoft Visual C/C++ project.mak file for a Simulink model.

#-------------#
# Check usage #
#-------------#

$nargs = $#ARGV + 1;

if ($nargs != 2) {&Usage; exit(1);}

$makTemplate = $ARGV[0];
$projectInfo = $ARGV[1];

#--------------------------#
# Load input file contents #
#--------------------------#

open(FILE,$makTemplate) || die "Couldn't open $makTemplate: $!\n";
@makTemplateContents = <FILE>;
close(FILE);

if (!($makTemplateContents[0] =~ /Microsoft Developer Studio/)) {
    print "Unexpected contents in template makefile: $makTemplate\n";
    exit(1);
}

open(FILE,$projectInfo) || die "Couldn't open $projectInfo: $!\n";
@projectInfoContents = <FILE>;
close(FILE);

#--------------------------------------------------#
# Get replacements from project info file contents #
#--------------------------------------------------#

if ($#projectInfoContents < 5) {&BadProjectInfo; exit(1);}

#
# Get model line (model = name)
#
if ($projectInfoContents[0] =~ /^\s*Model\s*=\s*(\w+)\s*$/) {
    $model = $1;
} else {
    &BadProjectInfo; exit(1);
}

#
# Get required defines (RequiredDefines = defines)
#
if ($projectInfoContents[1] =~ /^\s*RequiredDefines\s*=\s*(.+)\n$/) {
    $requiredDefines = $1;
} else {
    &BadProjectInfo; exit(1);
}

#
# Get required include dirs (IncludeDirs = directories)
#
if ($projectInfoContents[2] =~ /^\s*IncludeDirs\s*=\s*(.+)\n$/) {
    $includeDirs = $1;
} else {
    &BadProjectInfo; exit(1);
}

#
# Get additional libs (AdditionalLibs = libs)
#
if ($projectInfoContents[3] =~ /^\s*AdditionalLibs\s*=\s*(.+)\n$/) {
    $AdditionalLibs = $1;
} else {
    &BadProjectInfo; exit(1);
}

#
# Get the sources (Sources:) 
#
if ($projectInfoContents[4] =~ /^\s*Sources:\s*$/) {
    @sources = ();
    for $i (5 .. $#projectInfoContents) {
	if ($projectInfoContents[$i] =~ /^\s*(\S+)\s*\n$/) {
	    push(@sources,$1);
	} else {
	    {&BadProjectInfo; exit(1);}	    
	}
    }
} else {
    &BadProjectInfo; exit(1);
}

#-----------------------------------------#
# Set up source file replacement template #
#-----------------------------------------#

$sline = "################################################################" .
    "################\n" .
    "# Begin Source File\n" .
    "\n" .
    "SOURCE=FILENAME\n" .
    "!IF  \"\$(CFG)\" == \"MODELNAME - Win32 Release\"\n" .
    "\n" .
    "\n" .
    "\"\$(INTDIR)\\SHORTNAME.obj\" : \$(SOURCE) \"\$(INTDIR)\n" .
    "   \$(CPP) \$(CPP_PROJ) \$(SOURCE)\n" .
    "\n" .
    "\n" .
    "!ELSEIF  \"\$(CFG)\" == \"MODELNAME - Win32 Debug\"\n" .
    "\n" .
    "\n" .
    "BuildCmds= \\\n" .
    "	\$(CPP) \$(CPP_PROJ) \$(SOURCE) \\\n" .
    "	\n" .
    "\n" .
    "\"\$(INTDIR)\\SHORTNAME.obj\" : \$(SOURCE) \"\$(INTDIR)\"\n" .
    "   \$(BuildCmds)\n" .
    "\n" .
    "\"\$(INTDIR)\\SHORTNAME.sbf\" : \$(SOURCE) \"\$(INTDIR)\"\n" .
    "   \$(BuildCmds)\n" .
    "\n" .
    "!ENDIF \n" .
    "\n" .
    "# End Source File\n";



#----------------------#
# Perform replacements #
#----------------------#

@newContents = @makTemplateContents;

@sourceNames = ();
foreach $source (@sources) {
    local($slashIdx) = rindex($source,"\\");
    $name = substr($source,$slashIdx+1);
    $name = substr($name,$[,rindex($name,"."));
    push(@sourceNames,$name);
}

foreach $line (@newContents) {

    if ($line =~ /^\s*\|\>LinkObjList\<\|\s*$/) {   # Update |>LinkObjList<| ?
	$line = "";
	foreach $name (@sourceNames) {
	    $line = "$line\t\"\$(INTDIR)\\$name.obj\" \\\n";
	}
	$line = substr($line,$[,rindex($line," \\"));
        $line = "$line\n";
    } elsif ($line =~ /^\s*\|\>SbrList\<\|\s*$/) {  # Update |>SbrList<| ?
	$line = "";
	foreach $name (@sourceNames) {
	    $line = "$line\t\"\$(INTDIR)\\$name.sbr\" \\\n";
	}
	$line = substr($line,$[,rindex($line," \\"));
        $line = "$line\n";
    } elsif ($line =~ /^\s*\|\>EraseObjList\<\|\s*$/) { # |>EraseObjList<| ?
	$line = "";
	foreach $name (@sourceNames) {
	    $line = "$line\t-\@erase \"\$(INTDIR)\\$name.obj\"\n";
	}
    } elsif ($line =~ /^\s*\|\>EraseSbrList\<\|\s*$/) { # |>EraseSbrList<| ?
	$line = "";
	foreach $name (@sourceNames) {
	    $line = "$line\t-\@erase \"\$(INTDIR)\\$name.sbr\"\n";
	}
    } elsif ($line =~ /^\s*\|\>SourceFileList\<\|\s*$/) { # |>SourceFileList<| ?
	$line = "";
	for $i (0 .. $#sources) {
	    $line = $line . $sline;
	    $line =~ s/MODELNAME/$model/g;
	    $line =~ s/FILENAME/$sources[$i]/g;
	    $line =~ s/SHORTNAME/$sourceNames[$i]/g;
	}
    } else {
	#
	# Do any single token replacements:
	#	|>RequiredDefines<|
	#	|>Includedirs<|
	#	|>ModelName<|
        #       |>AdditionalLibs<|
	#
	$line =~ s/\|\>RequiredDefines\<\|/$requiredDefines/g;
	$line =~ s/\|\>IncludeDirs\<\|/$includeDirs/g;
	$line =~ s/\|\>ModelName\<\|/$model/g;
        $line =~ s/\|\>AdditionalLibs\<\|/$AdditionalLibs/g;
    }

}

$makFile = "$model.mak";

open(FILE,">$makFile") || die "Couldn't open $makFile: $!\n";
foreach $line (@newContents) {
    print FILE $line;
}
close(FILE);


#------#
# Done #
#------#
exit(0);

#-------------------#
# Subroutine: Usage #
#-------------------#
sub Usage {
    print "usage: msvc_mak <msvc_tpl.mak> <model.mki>\n";
    print "\n";
    print "msvc_tpl.mak - Microsoft Visual C/C++ template.\n";
    print "model.mki    - Model Make info.\n";
}

sub BadProjectInfo {
    print "Unexpected contents in model make info file: $projectInfo\n";
}
