#!/usr/bin/perl -w

use strict;
use diagnostics;# Force verbose warning diagnostics.
use warnings;
use English;

#
# Modules from the Standard Perl Library.


#
# Own modules
use analyzeOctaveSource;


#--- DEFINE VARIABLES -------------------------------
my $Dir = "D:\\daten\\octave\\neuroPackage\\0.1.9\\nnet\\inst";
my $fileExt = "m";
my $testDir = "D:\\daten\\octave\\neuroPackage\\0.1.9\\nnet/doc/latex/developers/tests";
my $relTestDir = "tests/";
my $testFileExt = "tex";
my $mainLatexTestFile = "test.tex";
my $chapter = "Test";
#--- END DEFINE VARIABLES ---------------------------


my @filesArray = ();
my @filesName = ();
my $fileName = "";
my $savePath = "";
my $nTestLines = 0;
my $m = 0;

# analyze directory structure
my $obj = analyzeOctaveSource->new();
my @DirArray = $obj->readDirTree($Dir,$fileExt);

# analyze file structure
my $nFiles = @DirArray;
if ($nFiles>=1){ # if $nFiles==0 readDirTree will die
  # if we are in this branch, we should check the files
  # to found those which content tests (lines beginning with
  # !% )
  foreach (@DirArray){
	  # open file and search for lines beginning with
	  # !%
	  if (-d $_){
        # if directory, do nothing
      }else{
      	print "$_\n";
      	sleep(0.1);
      	
	    open(FILE,$_) or die "File $_ not found!\n";
	    my @fileContent = <FILE>;
	    chomp(@fileContent);
	    $nTestLines = @fileContent;
        my @temp = grep /^%!/, @fileContent;
        my $nTemp = @temp;
        if ($nTemp>0){ # this means, 
                       # test lines are available
          # now create latex files without header
          # take the same name like the *.m file
          # and save in specified directory $testDir
          # with file extens in $testFileExt
          # use verbatim environment
          @filesName = split(/\//, $_);
          $fileName = $filesName[$#filesName];
          # now remove file extension .m
          @filesName = split(/\./,$fileName);
          $savePath = ("$testDir" . "\\\\" . "$filesName[0]." . "$testFileExt");
          open(OUTFILE, ">$savePath");
          my $i = 0;
          print OUTFILE "\\begin{verbatim}\n";
          while ($i < $nTestLines){
            if ($fileContent[$i]=~/^%!/){
              print OUTFILE "$fileContent[$i]\n";            
            }
            $i++;
		  } # END while ($i <= $#fileContent)
		  print OUTFILE "\\end{verbatim}\n";
		  close OUTFILE;
		  
		  ## now set entries in the main test latex file ..
          my $mainTestFile = ("$testDir" . "\\\\" . "$mainLatexTestFile");
          if ($m==0){
            open(TESTFILE,">$mainTestFile") or die "Could not found file $mainTestFile!\n";
            print TESTFILE "\\chapter{$chapter}\n\n";
            
			# test if back slash needed
            # a back slash is needed if the sign "underscore"
            # is used in the file name. This happens at each
            # "sub function". There are two underscores!
            my $tempString = "";
            my $oldString = $filesName[0];
			$_ = $filesName[0];
			s/_/\\_/g; # s/ : search & replace pattern (everything between / /)
					   # here: search underscore
					   # if found, replace with \_ (two back slashes are needed
					   # to get \_ as sign)
					   # /g means: each occurence of pattern, otherwise, only one _
					   # will be replaced

			print "test file name: $_\n";
            print TESTFILE "\\section{$_}\n";
            $tempString = $relTestDir . $oldString;
            print TESTFILE "\\input{$tempString}\n";
          }else{
            open(TESTFILE,">>$mainTestFile") or die "Could not found file $mainTestFile!\n";
            # test if back slash needed
            my $tempString = "";
            my $oldString = $filesName[0];
            # test if back slash needed
            # a back slash is needed if the sign "underscore"
            # is used in the file name. This happens at each
            # "sub function". There are two underscores!
            my $tempString = "";
            my $oldString = $filesName[0];
			$_ = $filesName[0];
			s/_/\\_/g; # s/ : search & replace pattern (everything between / /)
					   # here: search underscore
					   # if found, replace with \_ (two back slashes are needed
					   # to get \_ as sign)
					   # /g means: each occurence of pattern, otherwise, only one _
					   # will be replaced

            print TESTFILE "\\section{$_}\n";
            $tempString = $relTestDir . $oldString;
            print TESTFILE "\\input{$tempString}\n";
          }
          $m++;
          close TESTFILE;
  
		  
        }# END if($nTemp>0)
        close FILE;
               
	  }# END if(-d $_)
	  
	}# END foreach (@DirArray)

}else{ # if $nFiles==0
  print "No file found with valid file extension: .$fileExt.\n";
  die;
}