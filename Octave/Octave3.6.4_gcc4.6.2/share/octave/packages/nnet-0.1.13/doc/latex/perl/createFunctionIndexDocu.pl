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
my $Dir = "D:/daten/octave/neuroPackage/0.1.9/nnet/inst";
my $fileExt = "m";
my $funcIndDir = "D:/daten/octave/neuroPackage/0.1.9/nnet/doc/latex/developers/funcindex";
my $relFuncDir = "funcindex/";
my $funcFileExt = "tex";
my $mainLatexFuncIndexFile = "funcindexCalled.tex";
my $chapter = "Function Index";
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

# in @DirArray should be only names, ending with *.m
# but if there is a directory, we will remove it at
# the next line of code
my @FuncReferences = grep /.+\.$fileExt/ , @DirArray; #/
my @FuncNames = @FuncReferences;
# now I have to remove the path and file extension
foreach (@FuncNames)
{
 	s/\.m//g;   # removes file ending
 	s/$Dir\///g; # removes any parts of the file & directory path
}
my @input = ();
my @calledFunction = ();
my $deleteFile = 1;
my $anzahl_elemente = 0;
# now analyze functions to see which other functions are called
foreach my $FuncRef (@FuncReferences)
{

  open(FILE,$FuncRef); # opens e.g. 'subset.m'
  @input = <FILE>; # read the complete content of the file to @input
  # now remove all comment and test lines ..
  @input = grep s/^\s+//, @input; # removes white-space characters at the
  								  # beginning of a line
  @input = grep /^[^#|%]/ , @input; # removes lines starting with # or %

#   foreach (@input)
#   {
#     print "$_";
#     sleep(1);
#   }
      my $actFuncName = "";
  foreach my $FuncName (@FuncNames)
  {

    if ($FuncRef !~/$FuncName/)   # returns true if pattern is not found
    {
      # now search for each $FuncName
      # inside of the @input array
      # if one is found, put them to a list
      # \todo ERRORs are still available
      # if the $FuncName occures in another context!!
      # such lines should be deleted!
	  if (grep /$FuncName/,@input)
	  {
          push (@calledFunction, "$FuncName");
      }
    }else{
      $actFuncName = $FuncName;
    }
  }
  # now remove double entries of @calledFunction
  undef my %saw;
  @saw{@calledFunction} = ();
  @calledFunction = sort keys %saw;  # remove sort if undesired
  if (-e "$funcIndDir" . "/" . "$mainLatexFuncIndexFile")
  {
    # if the file exist, delete it
    if ($deleteFile){
      unlink("$funcIndDir" . "/" . "$mainLatexFuncIndexFile");
      $deleteFile = 0;
      open(DAT,">$funcIndDir" . "/" . "$mainLatexFuncIndexFile");
      print DAT "\\begin{longtable}{ll}\n";
      print DAT "\\textbf{main function}	&	\\textbf{called function} \\\\ \n";
      print DAT "\\hline\n";
	  $_ = $actFuncName;
	  s/_/\\_/g;     # put a backslash for each underscore
      print DAT "$_	";
      $anzahl_elemente = @calledFunction;
      if ($anzahl_elemente > 0)
      {
      	foreach (@calledFunction){          
          	  s/_/\\_/g;  # put a backslash for each underscore
	    	print DAT " &	$_\\\\ \n";
  	  	}
	  }else{
        print DAT " & \\\\ \n";
      }

  	  close(DAT);

    }else{
      # file doesn't have to be deleted
      open(DAT,">>$funcIndDir" . "/" . "$mainLatexFuncIndexFile");
      print DAT "\\hline\n";
      	  $_ = $actFuncName;
	  s/_/\\_/g;     # put a backslash for each underscore
      print DAT "$_	";
      $anzahl_elemente = @calledFunction;
      if ($anzahl_elemente > 0)
      {
      	foreach (@calledFunction){
          s/_/\\_/g;  # put a backslash for each underscore
	    	print DAT " &	$_\\\\ \n";
  	  	}
	  }else{
        print DAT " & \\\\ \n";
      }
  	    close(DAT);
    }

  }else{
    # File doesn't exist yet
    open(DAT,">$funcIndDir" . "/" . "$mainLatexFuncIndexFile");
    print DAT "\\begin{longtable}{l l}\n";
    print DAT "\\textbf{main function}	&	\\textbf{called function} \\\\ \n";
    print DAT "\\hline\n";
          	  $_ = $actFuncName;
	  s/_/\\_/g;    # put a backslash for each underscore
      print DAT "$_	";
      $anzahl_elemente = @calledFunction;
      if ($anzahl_elemente > 0)
      {
      	foreach (@calledFunction){
            s/_/\\_/g;  # put a backslash for each underscore
	    	print DAT " &	$_\\\\ \n";
  	  	}
	  }else{
        print DAT " & \\\\ \n";
      }
  	  close(DAT);
  }
#  print DAT "Function-File: $actFuncName\n";
#  print DAT "=============================\n";
#   foreach (@calledFunction){
# 	print DAT "$_\n";
#   }

  @calledFunction = ();

}
  open(DAT,">>$funcIndDir" . "/" . "$mainLatexFuncIndexFile");
  print DAT "\\end{longtable}\n";
  close(DAT);
