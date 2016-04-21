#!/usr/bin/perl 
#
# File: map2ir.pl
#
# Abstract: This file serve the purpose of translating MAP files
# which generated from multiple compilers vendors into a IR
# (Internal Representive) file.
#
# Arguments:
#   1. input MAP file name, normaly with extension .map;
#   2. rules file name which define pattern rule and section knowledge of 
#      a specific compiler vendor, normaly with extension .rul;
#   3. output IR file which is a comma seperated file, with extension .csv;
#   4. (optional) the file which contains search file name list, that is
#      used to report the code size only related to the search files
#      (usually, it's module generated files);
#
# $Revision: 1.1.6.2 $
# $Date: 2004/04/19 01:21:36 $
#
# Copyright 2002-2003 The MathWorks, Inc.


# IR file format:
#	1. name convention: *.csv;
#	2. contents:
#	     MATLAB info,
#	     Compiler info,
#	     MAP file name,
#	     Rule file name,
#	     //(Date/time,)
#	     //RAW_LINES begin
#		//raw key lines read from MAP file
#	     //RAW_LINES begin
#	     Code begin,
#	       section name, start address(hex), end address(hex), section size(hex)
#	       ....... continues
#	       total size,
#	     Code end,
#	     Dynamic Data begin,
#	       section name, start address(hex), end address(hex), section size(hex)
#	       ....... continues
#	       total size,
#	     Dynamic Data end,
#	     Static Data begin,
#	       section name, start address(hex), end address(hex), section size(hex)
#	       ....... continues
#	       total size,
#	     Static Data end,
#	     Heap begin,
#	       Heap, start address(hex), end address(hex), section size(hex)
#	     Heap end,
#	     Stack begin,		#we display stack in same manner as other sections
#	       Stack, start address(hex), end address(hex), section size(hex)
#	     Stack end,
#	     Whocare begin,
#	       section name, start address(hex), end address(hex), section size(hex)
#	       ....... continues
#	       total size,
#	     Whocare end,

# strict restriction enforced
#use strict;


local($EchoDebugInfo) = 0;
# local variables definition, to be read from rules file
local($Compiler);
local($CompilerOption);
local($ExistStartLine);
local($StartLine);
local($ExistSummary);
local($SummaryPrefix);
local($SummaryEnd);
local($LineException);
local($Line1stCharPos);
local($LinePattern);
local($SectionNamePos);
local($SectionStartAddrPos);
local($SectionStartAddrFmt);
local($SectionSizePos);
local($SectionSizeFmt);
local($DefinedSectionCategory);
local($SectionCategoryPos);
local(@CODE);		# name lists
local(@CONST);		# name lists
local(@DATA);		# name lists
local(@UNKNOWN);	# name lists
local(@DWARF);		# name lists

local(@HeapName);
local(@StackName);

local($HeapDefinedAsSection);
local($HeapStartLinePattern);
local($HeapEndLinePattern);
local($HeapAddrPos);
local($HeapAddrFmt);

local($StackDefinedAsSection);
local($StackStartLinePattern);
local($StackEndLinePattern);
local($StackAddrPos);
local($StackAddrFmt);
 
local($Regular_EXPR); 	# regular expression generated from $LinePattern

# local variables
local(@KEY_LINES);	#array used to store "key" lines from MAP file
local(@format_KEY_LINES); # convert KEY lines into standard format used by IR
local(@CODE_LINES);	# formatted key lines belong to CODE category
local(@CONST_LINES);	# formatted key lines belong to CONST category
local(@DATA_LINES);	# formatted key lines belong to DATA category
local(@UNKNOWN_LINES);	# formatted key lines belong to UNKNOWN category
local(@DWARF_LINES);	# formatted key lines belong to DWARF category

local(@STACK_LINES); 	# formatted stack line (should be only one line)
local(@HEAP_LINES);	# formatted heap line (should be only one line)


local(@search_files);	# file list conatins to be searched files 


local($SectionLayoutLinePattern);
local($SLFuncNamePos);
local($SLLibNamePos);
local($SLFileNamePos);
local($SLAddrPos);
local($SLAddrFmt);
local($SLSizePos);
local($SLSizeFmt);

local($SectionLayoutLinePattern2);
local($SLFuncNamePos2);
local($SLLibNamePos2);
local($SLFileNamePos2);
local($SLAddrPos2);
local($SLAddrFmt);
local($SLSizePos2);
local($SLSizeFmt);

local(@ModelFileExtension);

# subroutines
sub usage {
	print "Usage: map2IR MAP_filename rule_filename output_filename \n";
	print "   or: map2IR MAP_filename rule_filename output_filename search_file_list_filename\n";
	print "   or: map2IR MAP_filename rule_filename output_filename search_file_list_filename rtwlib_file_list_filename\n";
	exit();
}

sub badRuleFile {
	print "Invalid Rule File, Please check again \n";
	exit ();
}
sub transferFailed {
	print "Transfer Falied \n";
	exit ();
}


# read Rule file, save the values into variables and (hopefully not) complain
# invalid rule files
sub readRuleFile {
	my($FILE_HANDLE) = @_;
	while(<$FILE_HANDLE>) {
		@current_line = split(/\s+/, $_);		#break into words
		@comma_deli_words = split(/,+/, $current_line[2]); #break comma seperated
								 #values into words
		/^Compiler\s+/ and $Compiler = $current_line[2];
		/^CompilerOption\s+/ and $CompilerOption = $current_line[2];
		/^ExistStartLine\s+/ and $ExistStartLine = $current_line[2];
		/^StartLine\s+/ and $StartLine = $current_line[2];
		/^ExistSummary\s+/ and $ExistSummary = $current_line[2];
		/^SummaryPrefix\s+/ and $SummaryPrefix = $current_line[2];
		/^SummaryEnd\s+/ and $SummaryEnd = $current_line[2];
		/^LineException\s+/ and $LineException = $current_line[2];
		/^Line1stCharPos\s+/ and $Line1stCharPos = $current_line[2];
		/^LinePattern\s+/ and $LinePattern = $current_line[2];
		/^SectionNamePos\s+/ and $SectionNamePos = $current_line[2];
		/^SectionStartAddrPos\s+/ and $SectionStartAddrPos = $current_line[2];
		/^SectionStartAddrFmt\s+/ and $SectionStartAddrFmt = $current_line[2];
		/^SectionSizePos\s+/ and $SectionSizePos = $current_line[2];
		/^SectionSizeFmt\s+/ and $SectionSizeFmt = $current_line[2];
		/^DefinedSectionCategory\s+/ and $DefinedSectionCategory = $current_line[2];
		/^SectionCategoryPos\s+/ and $SectionCategoryPos = $current_line[2];
		/^CODE\s+/ and @CODE = @comma_deli_words;
		/^CONST\s+/ and @CONST = @comma_deli_words;
		/^DATA\s+/ and @DATA = @comma_deli_words;
		/^UNKNOWN\s+/ and @UNKNOWN = @comma_deli_words;
		/^DWARF\s+/ and @DWARF = @comma_deli_words;
		
		/^HeapName\s+/ and @HeapName = @comma_deli_words;
		/^StackName\s+/ and @StackName = @comma_deli_words;
		
		/^HeapDefinedAsSection\s+/ and $HeapDefinedAsSection = $current_line[2];
		/^HeapStartLinePattern\s+/ and $HeapStartLinePattern = $current_line[2];
		/^HeapEndLinePattern\s+/ and $HeapEndLinePattern = $current_line[2];
		/^HeapAddrPos\s+/ and $HeapAddrPos = $current_line[2];
		/^HeapAddrFmt\s+/ and $HeapAddrFmt = $current_line[2];
		
		/^StackDefinedAsSection\s+/ and $StackDefinedAsSection = $current_line[2];
		/^StackStartLinePattern\s+/ and $StackStartLinePattern = $current_line[2];
		/^StackEndLinePattern\s+/ and $StackEndLinePattern = $current_line[2];
		/^StackAddrPos\s+/ and $StackAddrPos = $current_line[2];
		/^StackAddrFmt\s+/ and $StackAddrFmt = $current_line[2];
		
		
		/^SectionLayoutLinePattern\s+/ and $SectionLayoutLinePattern = $current_line[2];
		/^SLFuncNamePos\s+/ and $SLFuncNamePos = $current_line[2];
		/^SLLibNamePos\s+/ and $SLLibNamePos = $current_line[2];
		/^SLFileNamePos\s+/ and $SLFileNamePos = $current_line[2];
		/^SLAddrPos\s+/ and $SLAddrPos = $current_line[2];
		/^SLAddrFmt\s+/ and $SLAddrFmt = $current_line[2];
		/^SLSizePos\s+/ and $SLSizePos = $current_line[2];
		/^SLSizeFmt\s+/ and $SLSizeFmt = $current_line[2];
		/^SectionLayoutLinePattern2\s+/ and $SectionLayoutLinePattern2 = $current_line[2];
		/^SLFuncNamePos2\s+/ and $SLFuncNamePos2 = $current_line[2];
		/^SLLibNamePos2\s+/ and $SLLibNamePos2 = $current_line[2];
		/^SLFileNamePos2\s+/ and $SLFileNamePos2 = $current_line[2];
		/^SLAddrPos2\s+/ and $SLAddrPos2 = $current_line[2];
		/^SLAddrFmt\s+/ and $SLAddrFmt = $current_line[2];
		/^SLSizePos2\s+/ and $SLSizePos2 = $current_line[2];
		/^SLSizeFmt\s+/ and $SLSizeFmt = $current_line[2];
		
		/^ModelFileExtension\s+/ and @ModelFileExtension = @comma_deli_words;
		#/^\s+/ and $ = $current_line[2];
		
	}
	#print "$Compiler \n";
	#print "$ExistSummary \n";
	#print "$SummaryPrefix \n";
	#print "@TEXT \n";
	#foreach $each(@DATA) {
	#print "$each \n";}
}


sub createCompilerOption() {
	if (!$CompilerOption) {
		push @temp, "Compiler Option begin\n";
		push @temp, "Not Available\n";
		push @temp, "Compiler Option end\n";
	}
	return @temp;
}

	
# translate 
sub TBL {
	my($section) = @_;
	if ($EchoDebugInfo) {
		print "$section";
	}
}

# compare 2 arrays, same return 1, else return 0
sub cmpList {
	my($array1, $array2) = @_;		# pass reference
	#print "@$array1 $#$array1 ||| ";
	#print "@$array2 $#$array2 \n";
	for ($i = 0; $i <= $#$array1; $i ++) {
		if ($$array1[$i] ne $$array2[$i]) {
			return 0;
		}
	}
	return 1;
}


# it take 2 scalar as parameters, and the 1st must be SummaryPrefix or SummaryEnd
sub lineMatch {
	my($line1, $line2) = @_;		
	@line1array = split (/,+/, $line1);	#comma seperated 1st string
	@line2array = split (/\s+/, $line2); 	#space/tab seperated 2nd string
	if ($line2array[0] eq "" ) {		# split would keep a empty element if the string
		shift @line2array;		# is leading by the delimiter
	}
	
	if ($line1array[0] eq "EMPTYLINE") {
		@line1array = ();		#means empty lines
	}
	
	#print $#line1array, " ", @line1array, " |||||", $#line2array, " ", @line2array, "\n";
	# compare elements number of 2 arrays
	if (@line1array eq @line2array) {
		$lineSame = 1;
	} else {
		$lineSame = 0;
	}
	
	# compare each elements
	for ($i = 0; $i <= $#line1array; $i ++) {
		#print $line1array[$i], " | ", $line2array[$i], "\n";
		if ($line1array[$i] ne $line2array[$i]) {
			$lineSame = 0;
		}
	}
	if ($lineSame) {		
		return 1
	} else {
		return 0
	}
}

	
# read MAP file which has summary sections, we will use SummaryPrefix and SummaryEnd
# to capture key lines;
sub readMapFilewithSummary {
	my(@FILE_HANDLE) = @_;
	$in_section_flag = 0;
	$process_ends = 0;
	@KEY_LINES = ();
	# while(<$FILE_HANDLE>) 
	foreach $_ (@FILE_HANDLE)
	{
		chomp;	#delete EOL
		if ($in_section_flag) {
			if (lineMatch($SummaryPrefix, $_)) { #allow duplicate SummaryPrefix
							 #exists to improve robustness
				$in_section_flag = 1;
				@KEY_LINES = ();
			} elsif (lineMatch($SummaryEnd, $_)) {
				$in_section_flag = 0;
				$process_ends = 1;
			} else 	{
				push @KEY_LINES, $_;
				#print "Will push:", $_, "\n";
			}
		} else  {
			if ( lineMatch($SummaryPrefix, $_) and !$process_ends ) {
				$in_section_flag = 1;
				#print $_, " ", $SummaryPrefix, "\n";
			}
		}
	}
	if ($EchoDebugInfo) {
		foreach $eachline (@KEY_LINES) {
			print $eachline, "\n";
		}
	}

	if (!$process_ends) {			# must ends processing
		transferFailed();
	}
}

$DEC_pattern = '([0-9])';	#single quote to avoid interpolation
$HEX_pattern = '([0-9]|[a-f]|[A-F])';
$HEX2_pattern = '([0-9]|[a-f]|[A-F]|[hH])';
$HEX3_pattern = '([0x]|[0-9]|[a-f]|[A-F])';

# translate LinePattern variable into a regular expression string
sub createLinePattern {
	my($LinePattern, $local_line1stChPos) = @_;
	local($Regular_EXPR);
	@linePatternArray = split (/,+/, $LinePattern);
	$Regular_EXPR = "";
	
	#define start address of 1st non space character
	if ($local_line1stChPos eq "n") {
		$Regular_EXPR .= '^\s*';	#start with 0 or more spaces
	} 
	elsif ($local_line1stChPos =~ /\d+/) {	#start at position $Line1stCharPos
		$Regular_EXPR .= '^';		#start sign
		for ($i = 0; $i < $local_line1stChPos; $i++) {
			$Regular_EXPR .= '\s';	# add one space each time
		}
	} else {
		badRuleFile();
	}
	
	$i = 0;
	while ($i <= $#linePatternArray) {
		$Regular_EXPR .= '\s+' if ($i > 0);	#insert spaces between words except first one
		if ($linePatternArray[$i] eq "NAME") {
			$Regular_EXPR .= '(\S)';
		} 
		elsif ($linePatternArray[$i] eq "DEC") {
			$Regular_EXPR .= $DEC_pattern;
		}
		elsif ($linePatternArray[$i] eq "HEX") {
			$Regular_EXPR .= $HEX_pattern;
		}
		elsif ($linePatternArray[$i] eq "HEX2") {
			$Regular_EXPR .= $HEX2_pattern;
		} 
		elsif ($linePatternArray[$i] eq "HEX3") {
			$Regular_EXPR .= $HEX3_pattern;    
		}
		elsif ($linePatternArray[$i])	{
			$Regular_EXPR .= '(' . "$linePatternArray[$i]" . ')';
		}
		else {
			badRuleFile();		#error
		}
		$i ++;		
		badRuleFile() if ($i > $#linePatternArray);	#must have a size field
		if ($linePatternArray[$i] eq "n") {
			$Regular_EXPR .= '+'; 		#one or more times
		}
		elsif ($linePatternArray[$i] =~ /\d+/ )	{	# number 
			$Regular_EXPR .= '{' . "$linePatternArray[$i]" . '}';
		}
		else {
			badRuleFile();
		}
		$i++;
	}
	
	$Regular_EXPR .= '\s*$';		#EOL
	if ($EchoDebugInfo) {
		print "Regular_EXPR: ", $Regular_EXPR, "\n";
	}
	return $Regular_EXPR;
}

# read MAP file without summary sections, we need use LinePattern to match key lines;
sub readMapFilenoSummary {
	my(@FILE_HANDLE) = @_;
	@KEY_LINES = ();
	

	
	#while (<$FILE_HANDLE>) {
	foreach $_ (@FILE_HANDLE) {
		chomp;
		/$Regular_EXPR/ and push @KEY_LINES, $_;
	}
	if ($EchoDebugInfo) {
		foreach $eachline (@KEY_LINES) {
			print $eachline, "\n";
		}
	}
}


# translate different formats of data into standard value format (perl could directly understand)
sub trans2Value {
	my($string, $type) = @_;
	#print "String: $string   type: $type \n";
	$ret_hex = 0x0;
	if ($type eq "DEC") {
		$ret_hex += $string;
	} elsif ($type eq "HEX") {
		$tmp = "0x" . $string;	#take care of any length HEX 
		$ret_hex += hex $tmp;
	} elsif ($type eq "HEX2") {
		$tmp = substr $string, 0, length($string)-2; #get rid of last "h"
		#or $tmp = tr/hH// $string
		$tmp = "0x" . $string;	#take care of any length HEX 
		$ret_hex += hex $tmp;
	} elsif ($type eq "HEX3") {
		$tmp = $string;
		$ret_hex += hex $tmp;
	} 
	else {
		die "Uncognized data type: $type\n";
	}
	return $ret_hex;
}

# translate value into hexadecimal represented string 
sub trans2hexString {
	my($value) = @_;
	return sprintf("%x", $value);
}

# process KEY lines and convert them to standard format
# Note: the byte $section_end_hex point is not included in the section,
# mathematical form is [$section_start_hex, $section_end_hex);
sub formatKEYLines {
	
	foreach $eachline(@KEY_LINES) {
		$section_name = "";
		$section_start_hex = 0x0;
		$section_size_hex = 0x0;
		$section_end_hex = 0x0;
		
		@current_line = split (/\s+/, $eachline);
		if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
			shift @current_line;	# is leading by the delimiter
		}
		$section_name = $current_line[$SectionNamePos];
		$section_start_hex = trans2Value($current_line[$SectionStartAddrPos], $SectionStartAddrFmt);
		$section_size_hex = trans2Value($current_line[$SectionSizePos], $SectionSizeFmt);
		$section_end_hex = $section_start_hex + $section_size_hex;
		if ($DefinedSectionCategory) {
			$section_category = $current_line[$SectionCategoryPos];
			push @format_KEY_LINES, $section_name . " " . $section_start_hex . " " . $section_size_hex . " " . $section_end_hex . " " . $section_category;
		} else {
			push @format_KEY_LINES, $section_name . " " . $section_start_hex . " " . $section_size_hex . " " . $section_end_hex;
		}
	}

	if ($EchoDebugInfo) {
		foreach $eachline(@format_KEY_LINES) {
			print $eachline, "\n";
		}
	}
}

# remove redundant/overlapped key lines
#  Here overlapped only means "Contained", we doesn't check plain overlap;
#
# some compilers use start position in a line to identify sections and sub-sections 
# ("ladder" strcture), however, a very long sub-section names may force it to be put 
# at higher position of a line, which will confuse map2IR tool;
#
# address overlapp checking could fix this problem; 
# however, stack/heap space overlap is allowable, although not a good practice;
# i.e., Diab 
#	.abs.003f9800                   003f9800        00000018
#	.abs.00008000                   00008000        00000004
#	.text                           00008010        0000afc0
#	rt_UpdateLogVarWithDiscontiguousData 0000bb0c   00000170
#	rtLocalLoggingSignalsStructFieldNames 0000c378  000000a1
#	rtGlobalLoggingSignalsStructFieldNames 0000c41c 00000081
#	.sdata2                         00012fd0        00000094

sub isDWARFsection {
	my($section_name) = @_;
	foreach $eachname(@DWARF) {
		if ( $section_name =~ /^$eachname$/) {
			return 1;
		}
	}									
	return 0;
}

sub removeOverlapSections {
	@workbuffer = ();
	while (@format_KEY_LINES != () ) {
		$temp = shift @format_KEY_LINES;
		@current_line = split (/\s+/, $temp);
		if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
			shift @current_line;	# is leading by the delimiter
		}		
		$flag = 1;
		for ($i=0; $i <= $#workbuffer; $i++) {
			@current_line2 = split (/\s+/, $workbuffer[$i]);
			if ($current_line2[0] eq "" ) {	# split would keep a empty element if the string
				shift @current_line;	# is leading by the delimiter
			}					
			# will ignore size 0 item and DWARF sections
			if (($current_line2[2] != 0) && ($current_line[2] != 0) && (!isDWARFsection($current_line[0])) && (!isDWARFsection($current_line2[0]))) {
				if (($current_line2[1]<= $current_line[1]) && ($current_line2[3]>= $current_line[3]) ) {
					if ($EchoDebugInfo) {
						print "\tWill discard section", $current_line[0], " for section $current_line2[0]\n";
					}
					$flag = 0;
				} elsif (($current_line2[1]>= $current_line[1]) && ($current_line2[3]<= $current_line[3]) ) {
					if ($EchoDebugInfo) {
						print "\tWill discard section", $current_line2[0], " for section $current_line[0]\n";
					}
					splice(@workbuffer, $i, 1);		#remove
				}
			}	
		}
		if ($flag) {
			push @workbuffer, $temp;
		}
	}	
	@format_KEY_LINES = @workbuffer;
}
 
# group section info into different categories
# all user defined section will be treated as CODE, although it's possible
# use it as data;
sub groupSections {
	next1: foreach $eachline (@format_KEY_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}
		$thislineisknown = 0;
		foreach $eachname(@CODE) {
			if ($linearray[0] =~ /^$eachname$/) {
				push @CODE_LINES, $eachline;
				$thislineisknown = 1;
				#next next1;
			}
		}
		foreach $eachname(@CONST) {
			if ($linearray[0] =~ /^$eachname$/) {
				push @CONST_LINES, $eachline;
				$thislineisknown = 1;
				#next next1;
			}
		}
		foreach $eachname(@DATA) {
			if ($linearray[0] =~ /^$eachname$/) {
				push @DATA_LINES, $eachline;
				$thislineisknown = 1;
				#next next1;
			}
		}
		foreach $eachname(@DWARF) {
			if ($linearray[0] =~ /^$eachname$/) {
				push @DWARF_LINES, $eachline;
				$thislineisknown = 1;
				#next next1;
			}
		}								
		foreach $eachname(@HeapName) {
			if ($linearray[0] =~ /^$eachname$/) {
				push @HEAP_LINES, $eachline;
				$thislineisknown = 1;
				#next next1;
			}
		}							
		foreach $eachname(@StackName) {
			if ($linearray[0] =~ /^$eachname$/) {
				push @STACK_LINES, $eachline;
				$thislineisknown = 1;
				#next next1;
			}
		}											
		if ($DefinedSectionCategory) {
			if ($linearray[4] eq "RAM") {
				push @DATA_LINES, $eachline; # all RAM section be treated as DATA
				$thislineisknown = 1;
				#next next1;
			} elsif ($linearray[4] eq "ROM") {	
				push @CODE_LINES, $eachline; # all ROM section be treated as CODE
				$thislineisknown = 1;
				#next next1;
			}
		}
		# else goes into UKNOWN group
		if ($thislineisknown == 0) {
			push @UNKNOWN_LINES, $eachline;
		}
		 
	}
}

sub writeIRheader {
	my($FILE_HANDLE) = @_;
	use POSIX qw(strftime);
    	$now_string = strftime "%a %b %e %H:%M:%S %Y", gmtime;  
	print($FILE_HANDLE "$now_string");
}
sub writeIRFile {
	my($FILE_HANDLE) = @_;
	
	local($entire_size);
	
	print($FILE_HANDLE "COPYRIGHT = Copyright 2002 The MathWorks, Inc.\n");
	print($FILE_HANDLE "COMPILER = $Compiler\n");
	print($FILE_HANDLE createCompilerOption());
	print($FILE_HANDLE "MAPFILE = $ARGV[0]\n");
	print($FILE_HANDLE "RULEFILE = $ARGV[1]\n");

	#CODE sections
	$entire_size = 0;
	print($FILE_HANDLE "CODE begin\n");
	#print($FILE_HANDLE "section name, start address(dec), section size(dec), end address(dec)\n");
	foreach $eachline(@CODE_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}		
		print($FILE_HANDLE "$linearray[0],$linearray[1],$linearray[2],$linearray[3]\n");
		$entire_size = $entire_size + $linearray[2];
	}
	#print($FILE_HANDLE " entire section size:,, " , "$entire_size\n");
	print($FILE_HANDLE "CODE end\n");
	
	#CONST sections
	$entire_size = 0;
	print($FILE_HANDLE "CONST begin\n");
	#print($FILE_HANDLE "section name, start address(dec), section size(dec), end address(dec)\n");
	foreach $eachline(@CONST_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}		
		print($FILE_HANDLE "$linearray[0],$linearray[1],$linearray[2],$linearray[3]\n");
		$entire_size = $entire_size + $linearray[2];
	}
	#print($FILE_HANDLE " entire section size:,, " , "$entire_size\n");
	print($FILE_HANDLE "CONST end\n");
	
	#DATA sections
	$entire_size = 0;
	print($FILE_HANDLE "DATA begin\n");
	#print($FILE_HANDLE "section name, start address(dec), section size(dec), end address(dec)\n");
	foreach $eachline(@DATA_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}		
		print($FILE_HANDLE "$linearray[0],$linearray[1],$linearray[2],$linearray[3]\n");
		$entire_size = $entire_size + $linearray[2];
	}
	#print($FILE_HANDLE " entire section size:,, " , "$entire_size\n");
	print($FILE_HANDLE "DATA end\n");
	
	#UNKNOWN sections
	$entire_size = 0;
	print($FILE_HANDLE "UNKNOWN begin\n");
	#print($FILE_HANDLE "section name, start address(dec), section size(dec), end address(dec)\n");
	foreach $eachline(@UNKNOWN_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}		
		print($FILE_HANDLE "$linearray[0],$linearray[1],$linearray[2],$linearray[3]\n");
		$entire_size = $entire_size + $linearray[2];
	}
	#print($FILE_HANDLE " entire section size:,, " , "$entire_size\n");
	print($FILE_HANDLE "UNKNOWN end\n");
	
	#DWARF
	$entire_size = 0;
	print($FILE_HANDLE "DWARF begin\n");
	#print($FILE_HANDLE "section name, start address(dec), section size(dec), end address(dec)\n");
	foreach $eachline(@DWARF_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}		
		print($FILE_HANDLE "$linearray[0],$linearray[1],$linearray[2],$linearray[3]\n");
		$entire_size = $entire_size + $linearray[2];
	}
	#print($FILE_HANDLE " entire section size:,, " , "$entire_size\n");
	print($FILE_HANDLE "DWARF end\n");				

	#HEAP
	$entire_size = 0;
	print($FILE_HANDLE "HEAP begin\n");
	#print($FILE_HANDLE "section name, start address(dec), section size(dec), end address(dec)\n");
	foreach $eachline(@HEAP_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}		
		print($FILE_HANDLE "HEAP,$linearray[1],$linearray[2],$linearray[3]\n");
		#$entire_size = $entire_size + $linearray[2];
	}
	#print($FILE_HANDLE " entire section size:,, " , "$entire_size\n");
	print($FILE_HANDLE "HEAP end\n");					

	#STACK
	$entire_size = 0;
	print($FILE_HANDLE "STACK begin\n");
	#print($FILE_HANDLE "section name, start address(dec), section size(dec), end address(dec)\n");
	foreach $eachline(@STACK_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}		
		print($FILE_HANDLE "STACK,$linearray[1],$linearray[2],$linearray[3]\n");
		#$entire_size = $entire_size + $linearray[2];
	}
	#print($FILE_HANDLE " entire section size:,, " , "$entire_size\n");
	print($FILE_HANDLE "STACK end\n");					
	
	#Section Layout Info 
	print($FILE_HANDLE "Section Layout begin\n");
	print($FILE_HANDLE @SL_collection);
	print($FILE_HANDLE "Section Layout end\n");
	
	#module file generated section layout
	print($FILE_HANDLE "Generated Section Layout begin\n");
	print($FILE_HANDLE @Gen_SL_collection);
	print($FILE_HANDLE "Generated Section Layout end\n");
	
	#rtwlib generated section layout
	print($FILE_HANDLE "Rtwlib Section Layout begin\n");
	print($FILE_HANDLE @rtwlib_collection);
	print($FILE_HANDLE "Rtwlib Section Layout end\n");	
	
}

sub readHeapInfo {
	local($firstCharPos) = "n";
	$heap_Regular_EXPR1 = createLinePattern($HeapStartLinePattern, $firstCharPos);
	$heap_Regular_EXPR2 = createLinePattern($HeapEndLinePattern, $firstCharPos);
	while (<MAPFILE>) {
		chomp;
		@current_line = split (/\s+/, $_);
		if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
			shift @current_line;	# is leading by the delimiter
		}
	
		/$heap_Regular_EXPR1/ and 
			$heap_start_hex = trans2Value($current_line[$HeapAddrPos], $HeapAddrFmt);
		
		/$heap_Regular_EXPR2/ and 
			$heap_end_hex = trans2Value($current_line[$HeapAddrPos], $HeapAddrFmt);
		
	}
	if ($heap_start_hex > $heap_end_hex) {	#swap
		$t = $heap_start_hex;
		$heap_start_hex = $heap_end_hex;
		$heap_end_hex = $t;
	}
	$heap_size_hex = $heap_end_hex - $heap_start_hex;
	push @HEAP_LINES, "HEAP" . " " . $heap_start_hex . " " . $heap_size_hex . " " . $heap_end_hex;
}

sub readStackInfo {
	local($firstCharPos) = "n";
	$stack_Regular_EXPR1 = createLinePattern($StackStartLinePattern, $firstCharPos);
	$stack_Regular_EXPR2 = createLinePattern($StackEndLinePattern, $firstCharPos);
	while (<MAPFILE>) {
		chomp;
		@current_line = split (/\s+/, $_);
		if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
			shift @current_line;	# is leading by the delimiter
		}
	
		/$stack_Regular_EXPR1/ and 
			$stack_start_hex = trans2Value($current_line[$StackAddrPos], $StackAddrFmt);
		
		/$stack_Regular_EXPR2/ and 
			$stack_end_hex = trans2Value($current_line[$StackAddrPos], $StackAddrFmt);
		
	}
	if ($stack_start_hex > $stack_end_hex) {	#swap
		$t = $stack_start_hex;
		$stack_start_hex = $stack_end_hex;
		$stack_end_hex = $t;
	}
	$stack_size_hex = $stack_end_hex - $stack_start_hex;
	push @STACK_LINES, "STACK" . " " . $stack_start_hex . " " . $stack_size_hex . " " . $stack_end_hex;	
}

local(@SL_func);
local(@SL_lib);
local(@SL_file);
local(@SL_addr);
local(@SL_size);
local(@SL_section);		# CODE, DATA, CONST
local(@SL_sectionname);		#.text, .init

local(@SL_collection);
local(@DATA_SECTION_MOVED_TBL);
local(@DATA_SECTION_MOVED_WHO_TBL);
#return the which section belong to based on start address and size
# also assign the detail section name to $accurate_section_name;
local($accurate_section_name); # used to transfer section name between calculateSection() and readSectionLayout();
sub calculateSection {
	my($symbol_name, $start_addr, $size) = @_;
	foreach $eachline(@DWARF_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}			
		#if (($linearray[1] <= $start_addr) && (($linearray[1] + $linearray[2]) >= ($start_addr + $size))) {
		if (($linearray[1] <= $start_addr) && (($linearray[1] + $linearray[2]) >= ($start_addr + $size)) && isDWARFsection($symbol_name)) {
			$accurate_section_name = $linearray[0]; #get section name
			return "DWARF";
		}
	}	
	foreach $eachline(@CODE_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}	
		if (($linearray[1] <= $start_addr) && (($linearray[1] + $linearray[2]) >= ($start_addr + $size))) {
			$accurate_section_name = $linearray[0]; #get section name
			return "CODE";
		}
	}
	foreach $eachline(@CONST_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}			
		if (($linearray[1] <= $start_addr) && (($linearray[1] + $linearray[2]) >= ($start_addr + $size))) {
			$accurate_section_name = $linearray[0]; #get section name
			return "CONST";
		}
	}
	$idx = 0;
	foreach $eachline(@DATA_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}			
		if (($linearray[1] <= $start_addr) && (($linearray[1] + $linearray[2]) >= ($start_addr + $size))) {
			$accurate_section_name = $linearray[0]; #get section name
			return "DATA";
		} elsif ($linearray[0] eq $symbol_name) {
			#if it's the 1st time, move current line to CONST section
			if (!isInList($symbol_name, DATA_SECTION_MOVED_TBL)) {
				push @DATA_SECTION_MOVED_TBL, $symbol_name;
				push @DATA_SECTION_MOVED_WHO_TBL, $eachline;				
				splice(@DATA_LINES, $idx, 1);
				push @CONST_LINES, $eachline;
				if ($EchoDebugInfo) {
					print "\nRelocate $symbol_name section from DATA to CONST.\n";
				}				
			}
			#add current symbol into DATA table
			if (!isOverlapSection($start_addr, $size, DATA_LINES)) {
				$symbol_size = $start_addr + $size;
				push @DATA_LINES, $symbol_name . " " . $start_addr . " " . $size . " " . $symbol_size;
			}
			
			if ($EchoDebugInfo) {
				print "added $symbol_name section: from $start_addr size $size, into DATA section.\n";
			}			
		}
		$idx = $idx +1;
	}
	foreach $eachline(@UNKNOWN_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}			
		if (($linearray[1] <= $start_addr) && (($linearray[1] + $linearray[2]) >= ($start_addr + $size))) {
			$accurate_section_name = $linearray[0]; #get section name
			return "UNKNOWN";
		}
	}
	
	if ($EchoDebugInfo) {
		print "\n\n Unmatched Section start from $start_addr, size:$size Found\n\n";
	}
	return "UNKNOWN";			
}

#detect whether it's section name
# Revised: use format_key_lines to compare
sub isSectionName {
	my($symbol) = @_;
	foreach $eachline (@format_KEY_LINES) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}
		
		if ($linearray[0] eq $symbol) {
			return 1;
		}
	}
	if ($EchoDebugInfo) {
		print "$symbol is not section name\n";
	}
	return 0;
}

# whenther the specified paramemerts match section
sub belongToSection {
	my($symbol_name, $start, $size, $section_array) = @_;	
	foreach $eachline(@$section_array) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}
		
		if (($linearray[0] eq $symbol_name) && ($linearray[1] eq $start) && ($linearray[2] eq $size)) {
			return 1;
		}
	}
	return 0;
}

# some section layout info looks like:
# 		.extint         00001f10	000002cc external_interrupt_isr.o
#	 external_interrupt_isr 00001f10	000001c8
#	     save_float_context 00001fa4	00000000
# in this case, we don't want .extint appear in the report;
# however, in following case:
# .abs.00000100   		00000100	00000004
# 		.abs.00000100   00000100	00000004 exception_table.o
# we do want .abs.00000100 appear, 
# 
# in the 3rd case:
#.data           		0000f1d0	00000660
#		.data           003f9820	0000036c multi_target_floatr13.o
#		      AIR_TABLE 003f9820	00000160
# the 1st ".data" is a section definiton, however, its address range is totally different
# from the 2nd ".data" definition. In this case, we'll relocate 1st ".data" into CONST group,
# while promote 2nd ".data" tobe section defnition and put into DATA group.

#
# so the only way we can do both is by detecting whether overlaping sections exists for!
#
# Note: it's different from removeOverlapSections() routine, this time, we want to remove
# "big" symbol names;
#
# It will also remove "DWARF" sections from report
sub removeOverlapSectionLayout {
	local(@workbuffer) = ();
	for ($i = 0; $i<=$#SL_addr; $i++) {
		# remove section who already been relocated 		
		if (belongToSection($SL_func[$i], $SL_addr[$i], $SL_size[$i], DATA_SECTION_MOVED_WHO_TBL)) {
			if ($EchoDebugInfo) {
				print "Will discard symbol $SL_func[$i] [range: $start1 to $end1] as relocated DATA section.\n";
			}
			$SL_addr[$i] = -1;
		}
		
		for ($j = 0; $j <= $#SL_addr; $j ++) {
			if (($i != $j) && ($SL_addr[$i] != -1) && ($SL_addr[$j] != -1)) {
				$start1 = $SL_addr[$i];
				$start2 = $SL_addr[$j];
				$end1 = $SL_addr[$i]+$SL_size[$i];
				$end2 = $SL_addr[$j]+$SL_size[$j];
				if (($start1 <= $start2) && ($end1 >= $end2) && (!isInList($SL_func[$i], Full_Cross_Table)) && ($start2 != $end2) && ($SL_addr[$j] != -1)) {
					if ($EchoDebugInfo) {
						print "Will discard symbol $SL_func[$i] [range: $start1 to $end1] for $SL_func[$j] [range: $start2 to $end2]\n";
					}
					$SL_addr[$i] = -1;
				} elsif (($start2 <= $start1) && ($end2 >= $end1) && (!isInList($SL_func[$j], Full_Cross_Table)) && ($start1 != $end1) && ($SL_addr[$i] != -1) ) {
					if ($EchoDebugInfo) {
						print "Will discard symbol $SL_func[$j] [range: $start2 to $end2] for $SL_func[$i] [range: $start1 to $end1 ]\n";
					}
					$SL_addr[$j] = -1;
				} elsif ($start1 == $end1 ) {
                              		if ($EchoDebugInfo) {
						print "Will discard symbol $SL_func[$i] for 0 size\n";
					}
                              		$SL_addr[$i] = -1;
                        }
			}
		}
	}
	# copy to temp buffer, ignore -1 item
	for($i = 0; $i <= $#SL_addr; $i++) {
		if (($SL_addr[$i] != -1) &&($SL_section[$i] ne "DWARF")){
			push @t1, $SL_func[$i];
			push @t2, $SL_lib[$i];
			push @t3, $SL_file[$i];
			push @t4, $SL_addr[$i];
			push @t5, $SL_size[$i];
			push @t6, $SL_section[$i];
			push @t7, $SL_sectionname[$i];
		}
	}
	# copy back
	@SL_func = @t1;
	@SL_lib = @t2;
	@SL_file = @t3;
	@SL_addr = @t4;
	@SL_size = @t5;
	@SL_section = @t6;
	@SL_sectionname = @t7;
}


# read section layout info, and organize it into list
sub readSectionLayout {
	my(@FILE_HANDLE) = @_;
	local($last_used_pattern1_filename);
	$layout_Regular_EXPR1 = createLinePattern($SectionLayoutLinePattern, "n");
	$layout_Regular_EXPR2 = createLinePattern($SectionLayoutLinePattern2, "n");
	if ($EchoDebugInfo) {
		print $SectionLayoutLinePattern,"\n";
		print $SectionLayoutLinePattern2, "\n";
	}
	#while (<$FILE_HANDLE>) {
	foreach $_ (@FILE_HANDLE) {
		chomp;
		@current_line = split (/\s+/, $_);
		if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
			shift @current_line;	# is leading by the delimiter
		}

		if (/$layout_Regular_EXPR1/ ) {
			if ($EchoDebugInfo) {
				print $_, "\n";
			}
			$funcname = $current_line[$SLFuncNamePos];
			$libname = $current_line[$SLLibNamePos];
			$filename = $current_line[$SLFileNamePos];
			 $last_used_pattern1_filename = $filename;
			   if ($Compiler eq "Diab") {
				local($c1) = index $filename, '[';
				if (($c1 == -1) or ($c1 == 0)) {	#0 for case [COMMON]
					$libname = "NOT_FROM_LIB";
					$filename = $filename;
				} else {
					$c2 = index $filename, ']', $c1;
					$libname = substr $filename, 0, $c1;
					$filename = substr $filename, ($c1+1), ($c2-$c1-1);
				}
			   }		   	
			   
			$funcaddr = trans2Value($current_line[$SLAddrPos], $SLAddrFmt);
			$funcsize = trans2Value($current_line[$SLSizePos], $SLSizeFmt);
			$accurate_section_name = ""; #reinitialize global $accurate_section_name
			#if (!isSectionName($funcname)) {			
				push @SL_section, calculateSection($funcname, $funcaddr, $funcsize);
				push @SL_func, $funcname;
				push @SL_lib, $libname;
				push @SL_file, $filename;
				push @SL_addr, $funcaddr;
				push @SL_size, $funcsize;
				push @SL_sectionname, $accurate_section_name;
			#}
		}
		
		if (/$layout_Regular_EXPR2/) { 
			$funcname = $current_line[$SLFuncNamePos2];
			# special process for codewarrior
			if ($Compiler eq "CodeWarrior") {
				$libname = "NOT_FROM_LIB";
				$filename = $current_line[$SLFileNamePos2];
			}
			# special process for diab
			if ($Compiler eq "Diab") {
				#keep last matched filename in Pattern1
				$filename = $last_used_pattern1_filename; 
				# now extracted libname from filename
				# i.e.: .extint 00001f10  000002cc d:\mpc555.a[external_interrupt_isr.o]
				local($c1) = index $filename, '[';
				if (($c1 == -1) or ($c1 == 0)) {	#0 for case [COMMON]
					$libname = "NOT_FROM_LIB";
					$filename = $filename;
				} else {
					$c2 = index $filename, ']', $c1;
					$libname = substr $filename, 0, $c1;
					$filename = substr $filename, ($c1+1), ($c2-$c1-1);
				}
			}
			$funcaddr = trans2Value($current_line[$SLAddrPos2], $SLAddrFmt);
			$funcsize = trans2Value($current_line[$SLSizePos2], $SLSizeFmt);
			$accurate_section_name = ""; #reinitialize global $accurate_section_name
			#if (!isSectionName($funcname)) {
				push @SL_section, calculateSection($funcname, $funcaddr, $funcsize);
				push @SL_func, $funcname;
				push @SL_lib, $libname;
				push @SL_file, $filename;
				push @SL_addr, $funcaddr;
				push @SL_size, $funcsize;
				push @SL_sectionname, $accurate_section_name;
			#}
		}
	}
	removeOverlapSectionLayout();
	for ($i=0; $i<=$#SL_func; $i++) {
		if ($EchoDebugInfo) {
			print $SL_section[$i], "\t", $SL_func[$i], "\t", $SL_lib[$i], "\t", $SL_file[$i], "\t", $SL_addr[$i], "\t", $SL_size[$i], "\t", $SL_sectionname[$i], "\n";
		}
		push @SL_collection, "$SL_file[$i],$SL_section[$i],$SL_func[$i],$SL_lib[$i],$SL_addr[$i],$SL_size[$i],$SL_sectionname[$i]\n";
	}
	@SL_collection = sort(@SL_collection);
	if ($EchoDebugInfo) {
		print @SL_collection;
	}
}


local(@Gen_File_list);
sub readFileList {
	my($FILE_HANDLE) = @_;			
	while(<$FILE_HANDLE>) {
		chomp;
		@current_line = split(/\s+/, $_);
		if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
			shift @current_line;	# is leading by the delimiter
		}
		foreach $each_file(@current_line) {
			foreach $each_extension(@ModelFileExtension) {
				push @Gen_File_list, $each_file . "." . $each_extension;
			}
		}
	}
	if ($EchoDebugInfo) {
		print @Gen_File_list;
	}
}

local(@RTW_Lib_list);
sub readRTWLIBList {
	my($FILE_HANDLE) = @_;			
	while(<$FILE_HANDLE>) {
		if (!/^#/) {
			chomp;
			@current_line = split(/\s+/, $_);
			if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
				shift @current_line;	# is leading by the delimiter
			}
			foreach $each_file(@current_line) {
				push @RTW_Lib_list, $each_file;
			}
		}
	}
	if ($EchoDebugInfo) {
		print @RTW_Lib_list;
	}
}
	
#detect whether the file/lib is in the specified list
sub isInList {
	my($file_name, $list_variable_name) = @_;
	foreach $each_file(@$list_variable_name) {
		if ($file_name eq $each_file) {
			return 1;
		}
	}
	return 0;
}

#detect whether the specified start_addr and size within section range.
sub isOverlapSection {
	my($start_addr, $size, $section) =@_;
	foreach $eachline(@$section) {
		@linearray = split (/\s+/, $eachline); 	#space/tab seperated string
		if ($linearray[0] eq "" ) {		# split would keep a empty element if the string
			shift @linearray;		# is leading by the delimiter
		}			
		if (($linearray[1] <= $start_addr) && (($linearray[1] + $linearray[2]) >= ($start_addr + $size))) {
			return 1;
		}		
	}
	return 0;
}


local(@Full_Cross_Table); # all symbols belong to cross reference table
local(@Cross_Table);      # module defined symbol only
# Report Accuracy Improvements:
# In diab compiler, 
#		.bss		001096c0	00000100 [COMMON]
#	                 fuel_U 001096c0	00000020
#	                 fuel_B 001096e0	00000030
#	               fuel_rtO 00109710	00000028
#	             fuel_DWork 00109738	00000030
# fuel_U is defined at fuel_prm.h, so it's in [COMMON] section. However,
# fuel_prm.h included by fuel.o, therefore fuel_U needs to be included in module section in
# HTML report. readCross_Ref_Table() function reads cross reference table which attached
# at the end of MAP file, and provides addiational references info.
#      Cross Reference Table
#fuel_B                          [absolute]	        	* fuel.o
#fuel_DWork                      [absolute]	        	* fuel.o
#
# readCross_Ref_Table requires Gen_File_list already generated
sub readCross_Ref_Table {
	my($FILE_HANDLE) = @_;
	$in_cross_ref_table = 0;
	while(<$FILE_HANDLE>) {
		if ($in_cross_ref_table) {
			chomp;
			@current_line = split(/\s+/, $_);
			if ($current_line[0] eq "" ) {	# split would keep a empty element if the string
				shift @current_line;	# is leading by the delimiter
			}
			# following code is to catch pattern
			#     fuel_U       [absolute]	  	  fuel_comm.o
                        #                                       * fuel.o
			if (/^\s+/) {  # leading space
				unshift @current_line, $last_symbol;
			} else {     # leading word
				$last_symbol = $current_line[0];
				push @Full_Cross_Table, $last_symbol, "\n";
			}
				
			#_restgpr_15_l                   .text   	.text   	* restgprl.o(d:\APPLIC~1\diab\4.3g\PPCE\libimpl.a)
			#  we only look at "*" line, where symbol get defined
			if (($current_line[1] eq "*") or ($current_line[2] eq "*") or ($current_line[3] eq "*")) {
				# restgprl.o(d:\APPLIC~1\diab\4.3g\PPCE\libimpl.a)
				$longfileName = $current_line[$#current_line]; 
				# restgpr1.o
				$indexParenth = index($longfileName, "(");
				if ($indexParenth > 0) {
					$shortFileName = substr($longfileName, 0, $indexParenth); 
				} else {
					$shortFileName = $longfileName; 
				}
				# in case filename is in .\phycore555_obj/osek_main.o format,
				# get the file name portion only
				$indexParenth = rindex($shortFileName, "\\");
				if ($indexParenth > 0) {
					$shortFileName = substr($shortFileName, $indexParenth+1, length($shortFileName));
				}
				$indexParenth = rindex($shortFileName, "/");
				if ($indexParenth > 0) {
					$shortFileName = substr($shortFileName, $indexParenth+1, length($shortFileName));
				}
				
				if ($EchoDebugInfo) {
					print $_, "\t", $longfileName, "\t", $shortFileName, "\n";
				}
				if (isInList($shortFileName, Gen_File_list)) {
					push @Cross_Table, $current_line[0], "\n";
				}
			}
		}
		/^\s*Cross Reference Table/ and $in_cross_ref_table = 1;
	}
	if ($EchoDebugInfo) {
		print @Cross_Table;
		print @Full_Cross_Table;
	}
}

#search those section layout info generated from model file 
local(@Gen_SL_collection);
sub searchGenSectionLayout {
	for ($i=0; $i<=$#SL_file; $i++) {
		if (isInList($SL_file[$i], Gen_File_list)) {
			push @Gen_SL_collection, "$SL_file[$i],$SL_section[$i],$SL_func[$i],$SL_lib[$i],$SL_addr[$i],$SL_size[$i],$SL_sectionname[$i]\n";
		} elsif (isInList($SL_func[$i], Cross_Table)) {  # or symbol name is in cross refernece table and referenced by gen_file_list
			push @Gen_SL_collection, "$SL_file[$i],$SL_section[$i],$SL_func[$i],$SL_lib[$i],$SL_addr[$i],$SL_size[$i],$SL_sectionname[$i]\n";
		}
	}
	@Gen_SL_collection = sort(@Gen_SL_collection);
	if ($EchoDebugInfo) {
		print @Gen_SL_collection;
	}
}

local(@rtwlib_collection);
sub searchRtwlibSymbols {
	for ($i=0; $i<=$#SL_lib; $i++) {
		if (isInList($SL_lib[$i], RTW_Lib_list)) {
			push @rtwlib_collection, "$SL_file[$i],$SL_section[$i],$SL_func[$i],$SL_lib[$i],$SL_addr[$i],$SL_size[$i],$SL_sectionname[$i]\n";
		}
	}
	@rtwlib_collection = sort(@rtwlib_collection);
	if ($EchoDebugInfo) {
		print @rtwlib_collection;
	}
}
# main program begin

# check arguments numbers
(($#ARGV+1) eq 3) || (($#ARGV+1) eq 4) || (($#ARGV+1) eq 5) || usage();

#writeIRheader(STDOUT);
# open I/O files

open(MAPFILE, "< $ARGV[0]") 
	or die("Can't read MAP file $ARGV[0]\n");
open(RULEFILE, "< $ARGV[1]")
	or die("Can't read rule file $ARGV[1]\n");
open(OUTFILE, "+> $ARGV[2]")
	or die("Can't write output file $ARGV[2]\n");

# read rule file, assign values to system level variables from rule file
readRuleFile(RULEFILE);

if (($#ARGV+1) >= 4) {
	open(FILELISTFILE, "< $ARGV[3]")
		or die("Can't read file list file $ARGV[3]\n");
	readFileList(FILELISTFILE);
	readCross_Ref_Table(MAPFILE);
	seek(MAPFILE, 0, 0); #rewind MAP file
}

if (($#ARGV+1) >= 5) {
	open(RTWLIBFILE, "< $ARGV[4]")
		or die("Can't read rtwlib file list file $ARGV[4]\n");
	readRTWLIBList(RTWLIBFILE);
}

#createLinePattern() for search "Key lines"
$Regular_EXPR = createLinePattern($LinePattern, $Line1stCharPos);


# search heap and stacks init configuration;
# here we makes the assumption that heap/stack either defined in the same manner
# as other sections in MAP file, or MAP has dedicated lines to describe stack/heap,
#  and these lines must be one for beginning, one for endding
#search heap lines
if (!$HeapDefinedAsSection) {		#if not defined as other sections
	readHeapInfo();
}

#rewind file handle to start position as filehandle already reached EOF
seek(MAPFILE, 0, 0);
#search stack lines
if (!$StackDefinedAsSection) {		#if not defined as other sections
	readStackInfo();
}

#rewind file handle to start position as filehandle already reached EOF
seek(MAPFILE, 0, 0);	
if ($ExistStartLine) {
	$contentsBegun=0;
} else {
	$contentsBegun=1;
}
local(@MAPFILE_Contents);
while(<MAPFILE>) {
	if (/$StartLine.*/) {
		$contentsBegun=1;
	}
	
	if ($contentsBegun) {
		push @MAPFILE_Contents, $_;
	} 
}
#if ($EchoDebugInfo) {
#	print @MAPFILE_Contents;
#}


# search "key lines" in MAP file
if ($ExistSummary) {
	readMapFilewithSummary(@MAPFILE_Contents);
} else {
	readMapFilenoSummary(@MAPFILE_Contents);
}

# convert "Key lines" into "formatted Key lines"
formatKEYLines();

# remove overlapped sections
removeOverlapSections();

# group "formatted Key lines" into each catergory
groupSections();

#rewind file handle to start position becase filehandle already reached EOF
seek(MAPFILE, 0, 0);	
#process section layout info to generate section, file and functions correlationship
readSectionLayout(@MAPFILE_Contents);

searchGenSectionLayout();

searchRtwlibSymbols();
# write to output IR file
writeIRFile(OUTFILE);
# housekeeping	
close(MAPFILE);
close(RULEFILE);
close(OUTFILE);
