#!/usr/bin/perl 
#
# File: ir2html.pl
#
# Abstract: This file serve the purpose of translating a IR (Internal 
#   Representive) MAP files which generated from multiple compilers vendors into a 
#   HTML formatted report file;  
#
# Arguments:
#           1. input IR file name, normaly with extension .csv;
#	    2. rules file name which define output format named html.rul;
#	    3. output HTML file with extension .csv;
#
# $Revision: 1.1.6.2 $
# $Date: 2004/04/19 01:21:35 $
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

# Revised: 10/31/2001
# Description: Added ability to hyperlink some elements to general HTML files

# strict restriction enforced
#use strict;
use Cwd;

local($EchoDebugInfo) = 0;

# local variables definition, to be read from rules file

local($IRFILE);
local($RULEFILE);
local($OUTFILE);
local($HTMLDIR);
local($addlink);

# dictionary word list and hyper link list to the words
local(@dictWordList);
local(@dictLinkList);

local($Title);		# whether or not show Title
local($Copyright);	# whether or not show copyright
local($Summary);	# whether or not Show summary
local($Details);
local($EntireSummary);
local($EntireDetails);
local($Heap);
local($Stack);
local($MemoryMAPSummary);
local($MemoryMAP);
local($Options);	# whether or not show options 
local($Rulefile);	# whether or not show Rule File used to create IR file
local($MAPfile);	# whether or not include priginal MAP file 
local($RemoveIR);	# whether or not delete IR file 
local($ListSectionName);

local(@MM_LABEL);
local(@MM_TYPES);
local(@MM_CONTENTS);
# subroutines
sub usage {
	print "Usage: IR2HTML IR_MAP_filename HTML_rule_filename output_HTML_filename \n";
	print "Usage: IR2HTML IR_MAP_filename HTML_rule_filename output_HTML_filename code_report_directory_name \n";
	exit();
}

sub readRuleFile {
	my($FILE_HANDLE) = @_;
	while(<$FILE_HANDLE>) {
		@current_line = split(/\s+/, $_);		#break into words
		@comma_deli_words = split(/,+/, $current_line[2]); #break comma seperated
								 #values into words
		/^Title/ and $Title = $current_line[2];
		/^Copyright/ and $Copyright = $current_line[2];
		/^Summary/ and $Summary = $current_line[2];
		/^Details/ and $Details = $current_line[2];
		/^EntireSummary/ and $EntireSummary = $current_line[2];
		/^EntireDetails/ and $EntireDetails = $current_line[2];
		/^Heap/ and $Heap = $current_line[2];
		/^Stack/ and $Stack = $current_line[2];
		/^MemoryMAPSummary/ and $MemoryMAPSummary = $current_line[2];
		/^MemoryMAP/ and $MemoryMAP = $current_line[2];
 		/^Options/ and $Options = $current_line[2];
		/^Rulefile/ and $Rulefile = $current_line[2];
		/^MAPfile/ and $MAPfile = $current_line[2];
		/^RemoveIR/ and $RemoveIR = $current_line[2];
		/^ListSectionName/ and $ListSectionName = $current_line[2];
		if (/^MM_/) {
			if (/^MM_LABEL/) {
				splice(@current_line, 0, 2);
				@MM_LABEL = @current_line;
			} else {
				$MM_type = substr($current_line[0], 3);
				push @MM_TYPES, $MM_type;
				push @MM_CONTENTS, $current_line[2];
			}
		}
		
		#/^/ and $ = $current_line[2];
	}	
}

local($copyright);
local($compiler);
local($mapfile);
local($rulefile);

local(@CODE_LINES);	# formatted key lines belong to CODE category
local(@CONST_LINES);	# formatted key lines belong to CONST category
local(@DATA_LINES);	# formatted key lines belong to DATA category
local(@UNKNOWN_LINES);	# formatted key lines belong to UNKNOWN category
local(@DWARF_LINES);	# formatted key lines belong to DWARF category
local(@STACK_LINES); 	# formatted stack line (should be only one line)
local(@HEAP_LINES);	# formatted heap line (should be only one line)
local(@CODE_SECTIONS);
local(@CONST_SECTIONS);
local(@DATA_SECTIONS);
local(@UNKNOWN_SECTIONS);
local(@DWARF_SECTIONS);

local(@SL_LINES);
local(@Gen_SL_LINES);
local(@RTWLIB_LINES);

local(@CompilerOption_LINES);

sub readIRFile {
	my($FILE_HANDLE) = @_;
	$in_code_section = 0;
	$in_const_section = 0;
	$in_data_section = 0;
	$in_unknown_section = 0;
	$in_dwarf_section = 0;
	$in_stack_section = 0;
	$in_heap_section = 0;
	$in_gen_sl_section = 0;
	$in_compileroption_section = 0;
	
	while(<$FILE_HANDLE>) {
		@current_line = split(/\s+/, $_);		#break into words
		@current_line2 = split(/,+/, $_); 
		#/^COPYRIGHT/ and $copyright = $_;
		/^COMPILER/ and $compiler = $current_line[2];
		/^MAPFILE/ and $mapfile = $current_line[2];
		/^RULEFILE/ and $rulefile = $current_line[2];
		
		/^CODE end/ and $in_code_section = 0;
		
		/^CONST end/ and $in_const_section = 0;
		
		/^DATA end/ and $in_data_section = 0;
		
		/^UNKNOWN end/ and $in_unknown_section = 0;
		
		/^DWARF end/ and $in_dwarf_section = 0;
		
		/^HEAP end/ and $in_heap_section = 0;
		
		/^STACK end/ and $in_stack_section = 0;
		
		/^Section Layout end/ and $in_sl_section = 0;
		
		/^Generated Section Layout end/ and $in_gen_sl_section = 0;
		
		/^Compiler Option end/ and $in_compileroption_section = 0;
		
		/^Rtwlib Section Layout end/ and $in_rtwlib_section = 0;
		
		#/^ begin/ and $in__section = 1;
		#
		#/^/ and $ = $current_line[2];
		
		if ($in_code_section) {
			push @CODE_LINES, $_;
			#print $current_line2[0];
			if (!isInList($current_line2[0], CODE_SECTIONS)) {
				push @CODE_SECTIONS, $current_line2[0];				
			}
		}
		if ($in_const_section) {
			push @CONST_LINES, $_;
			if (!isInList($current_line2[0], CONST_SECTIONS)) {
				push @CONST_SECTIONS, $current_line2[0];
			}
		}
		if ($in_data_section) {
			push @DATA_LINES, $_;
			if (!isInList($current_line2[0], DATA_SECTIONS)) {
				push @DATA_SECTIONS, $current_line2[0];
			}
		}
		if ($in_unknown_section) {
			push @UNKNOWN_LINES, $_;
			if (!isInList($current_line2[0], UNKNOWN_SECTIONS)) {
				push @UNKNOWN_SECTIONS, $current_line2[0];
			}
		}
		if ($in_dwarf_section) {
			push @DWARF_LINES, $_;
			if (!isInList($current_line2[0], DWARF_SECTIONS)) {
				push @DWARF_SECTIONS, $current_line2[0];
			}
		}
		if ($in_stack_section) {
			push @STACK_LINES, $_;
		}
		if ($in_heap_section) {
			push @HEAP_LINES, $_;
		}
		if ($in_sl_section) {
			push @SL_LINES, $_;
		}
		if ($in_gen_sl_section) {
			push @Gen_SL_LINES, $_;
		}
		if ($in_compileroption_section) {
			push @CompilerOption_LINES, $_;
		}
		if ($in_rtwlib_section) {
			push @RTWLIB_LINES, $_;
		}
		
		/^CODE begin/ and $in_code_section = 1;
		/^CONST begin/ and $in_const_section = 1;
		/^DATA begin/ and $in_data_section = 1;
		/^UNKNOWN begin/ and $in_unknown_section = 1;
		/^DWARF begin/ and $in_dwarf_section = 1;
		/^HEAP begin/ and $in_heap_section = 1;
		/^STACK begin/ and $in_stack_section = 1;
		/^Generated Section Layout begin/ and $in_gen_sl_section = 1;
		/^Compiler Option begin/ and $in_compileroption_section = 1;
		/^Rtwlib Section Layout begin/ and $in_rtwlib_section = 1;
		/^Section Layout begin/ and $in_sl_section = 1;
	}
	#print join(" ", @CODE_SECTIONS);
	if ($EchoDebugInfo) {
		print $copyright, "\n";
		print $compiler, "\n";
		print $mapfile, "\n";
		print $rulefile, "\n";
		print @CODE_LINES, "\n";
		print @CONST_LINES, "\n";
		print @DATA_LINES, "\n";
		print @UNKNOWN_LINES, "\n";
		print @DWARF_LINES, "\n";
		print @STACK_LINES, "\n";
		print @HEAP_LINES, "\n";
		print @Gen_SL_LINES, "\n";
		print @CompilerOption_LINES, "\n";
		print @RTWLIB_LINES, "\n";
	}
}

#detect whether the scalar is in the specified array
sub isInList {
	my($file_name, $list_variable_name) = @_;
	foreach $each_file(@$list_variable_name) {
		if ($file_name eq $each_file) {
			return 1;
		}
	}
	return 0;
}

sub RAMorROM {
	my($section_name) = @_;
	if (($section_name eq "CODE") or ($section_name eq "CONST") or ($section_name eq "UNKNOWN")) {
		return "ROM";
	} elsif (($section_name eq "DATA")) {
		return "RAM";
	}
}
		
sub createTitle {
	#my($title) = @_;
	return '<P align="center"> <FONT SIZE=+4 COLOR=#000066><B CLASS="midprod"> Code Profile Report </B></FONT></P>';
}

sub createCopyright {
	return '<p align="right"><font color="#000066" size="+1">&copy The MathWorks, Inc.</font></p>';
}

sub createOptions {
	@options = ();
	push @options, '<P><FONT SIZE=+1 COLOR=#000066><B CLASS="midprod">Compiler: ', "$compiler", "</B></FONT></P>";
	#push @options, '<p><FONT SIZE=+1 COLOR=#000066><B CLASS="midprod">Compiler Options: ', "@CompilerOption_LINES", '</B></FONT></p>';
	return @options;
}

# create Module files Summary 
sub createSummary {
	@returnlines = ();
	local(@RAM_LINES) = ();
	local(@ROM_LINES) = ();
 	local($ram_sum) = 0;
 	local($rom_sum) = 0;
 	local($ram_rtw_sum) = 0;
 	local($rom_rtw_sum) = 0;
 	foreach $eachline(@Gen_SL_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		$temp = '<TR><TD><p align="left">' . $comma_deli_words[2] . '</TD><TD><p align="left">' . $comma_deli_words[0] . '</TD><TD><p align="left">' .  $comma_deli_words[6] . '</TD><TD><p align="left">' .  $comma_deli_words[5] . '</TD>';
 		if (RAMorROM($comma_deli_words[1]) eq "RAM") {
 			push @RAM_LINES, $temp;
 			$ram_sum += $comma_deli_words[5];
 		} elsif (RAMorROM($comma_deli_words[1]) eq "ROM") {
 			push @ROM_LINES, $temp;
 			$rom_sum += $comma_deli_words[5];
 		} 
 	}
 	foreach $eachline(@RTWLIB_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		$temp = '<TR><TD><p align="left">' . $comma_deli_words[2] . '</TD><TD><p align="left">' . $comma_deli_words[0] . '</TD><TD><p align="left">' .  $comma_deli_words[6] . '</TD><TD><p align="left">' .  $comma_deli_words[5] . '</TD>';
 		if (RAMorROM($comma_deli_words[1]) eq "RAM") {
 			push @RAM_LINES, $temp;
 			$ram_rtw_sum += $comma_deli_words[5];
 		} elsif (RAMorROM($comma_deli_words[1]) eq "ROM") {
 			push @ROM_LINES, $temp;
 			$rom_rtw_sum += $comma_deli_words[5];
 		} 
 	} 	
	push @returnlines, '<P CLASS="margin">';
 	push @returnlines, '<FONT SIZE=+2 COLOR=#000066><A NAME=Summary><B CLASS="midprod">', "Model Memory Summary", '</B></A></FONT>';
 	push @returnlines, '<P CLASS="margin">', "\n";	
	#push @returnlines, '<p><FONT SIZE=+2 COLOR=#000066><A NAME=Summary>Module Summary</A></FONT></p>';
	push @returnlines, '<CENTER>';
	push @returnlines, '<TABLE BORDER="1" CELLSPACING="1" CELLPADDING="1" WIDTH="100%" BGCOLOR="#ffffff">';
	push @returnlines, '<tr><td><p align="left"><b>Memory Regions</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
	push @returnlines, '<tr><td><p align="left">Read/Write Memory Usage(without rtwlib)</td>', '<td><p align="left">' . $ram_sum . '</td></tr>';
	push @returnlines, '<tr><td><p align="left">Read Only Memory Usage(without rtwlib)</td>', '<td><p align="left">' . $rom_sum . '</td></tr>';
	push @returnlines, '<tr><td><p align="left"><font color="#008000">Read/Write Memory Usage(with rtwlib)</font></td>', '<td><p align="left"><font color="#008000">' . ($ram_sum + $ram_rtw_sum) . '</font></td></tr>';
	push @returnlines, '<tr><td><p align="left"><font color="#008000">Read Only Memory Usage(with rtwlib)</font></td>', '<td><p align="left"><font color="#008000">' . ($rom_sum + $rom_rtw_sum) . '</font></td></tr>';
	push @returnlines, '</TABLE>';
	push @returnlines, '</CENTER>';
	return @returnlines;
}

# translate $symbol into hyper link if exists match in dictionary;
sub transSymbol2link {
	my($symbol) = @_;
	local($returnlink);
	for ($i=0; $i<=$#dictWordList; $i++) {
		if ($symbol eq $dictWordList[$i]) {
			$returnlink = $dictLinkList[$i] . " $symbol " . '</A>';
			return  $returnlink;
		}
	}
	return $symbol;
}

# create module files detail 
sub createDetails {
	@returnlines = ();
	local(@RAM_LINES) = ();
	local(@ROM_LINES) = ();
 	local($ram_sum) = 0;
 	local($rom_sum) = 0;
 	local($ram_rtw_sum) = 0;
 	local($rom_rtw_sum) = 0;
 	foreach $eachline(@Gen_SL_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		$temp = '<TR><TD><p align="left">' . transSymbol2link($comma_deli_words[2]) . '</TD><TD><p align="left">' . $comma_deli_words[0] . '</TD><TD><p align="left">' .  $comma_deli_words[6] . '</TD><TD><p align="left">' .  $comma_deli_words[5] . '</TD>';
 		if (RAMorROM($comma_deli_words[1]) eq "RAM") {
 			push @RAM_LINES, $temp;
 			$ram_sum += $comma_deli_words[5];
 		} elsif (RAMorROM($comma_deli_words[1]) eq "ROM") {
 			push @ROM_LINES, $temp;
 			$rom_sum += $comma_deli_words[5];
 		} 
 	}
 	foreach $eachline(@RTWLIB_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		$temp = '<TR><TD><p align="left"><font color="#008000">' . transSymbol2link($comma_deli_words[2]) . '</font></TD><TD><p align="left"><font color="#008000">' . $comma_deli_words[0] . '</font></TD><TD><p align="left"><font color="#008000">' .  $comma_deli_words[6] . '</font></TD><TD><p align="left"><font color="#008000">' .  $comma_deli_words[5] . '</font></TD>';
 		if (RAMorROM($comma_deli_words[1]) eq "RAM") {
 			push @RAM_LINES, $temp;
 			$ram_rtw_sum += $comma_deli_words[5];
 		} elsif (RAMorROM($comma_deli_words[1]) eq "ROM") {
 			push @ROM_LINES, $temp;
 			$rom_rtw_sum += $comma_deli_words[5];
 		} 
 	} 		
 	push @returnlines, '<P CLASS="margin">';
 	push @returnlines, '<FONT SIZE=+2 COLOR=#000066><A NAME=Details><B CLASS="midprod">', "Model Memory Detail", '</B></A></FONT>';
 	push @returnlines, '<P CLASS="margin">', "\n";	
	#push @returnlines, '<p><FONT SIZE=+2 COLOR=#000066><A NAME=Details>Module Detail</A></FONT></p>';
	push @returnlines, '<CENTER>';
	push @returnlines, '<TABLE BORDER="1" CELLSPACING="1" CELLPADDING="1" WIDTH="100%" BGCOLOR="#ffffff">';
	push @returnlines, '<tr><td><p align="left"><b>Read/Write Memory Usage (with <font color="#008000">rtwlib</font>)</b></td><td><p align="left"><b>File</b></td><td><p align="left"><b>Section</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
	push @returnlines, @RAM_LINES;
	#push @returnlines, '<tr><td> &nbsp</td></tr>';
	push @returnlines, '<tr><td><p align="left"><b>Read Only Memory Usage (with <font color="#008000">rtwlib</font>)</b></td><td><p align="left"><b>File</b></td><td><p align="left"><b>Section</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
	push @returnlines, @ROM_LINES;
	push @returnlines, '</TABLE>';
	push @returnlines, '</CENTER>';
	return @returnlines;
}

sub createEntireSummary {
	@returnlines = ();
	local(@RAM_LINES) = ();
	local(@ROM_LINES) = ();
 	local($ram_sum) = 0;
 	local($rom_sum) = 0;
 	foreach $eachline(@SL_LINES) {
 		@comma_deli_words = split(/,/, $eachline); #break comma seperated line
 		$temp = '<TR><TD><p align="left">' . $comma_deli_words[2] . '</TD><TD><p align="left">' . $comma_deli_words[0] . '</TD><TD><p align="left">' .  $comma_deli_words[6] . '</TD><TD><p align="left">' .  $comma_deli_words[5] . '</TD>';
 		if (RAMorROM($comma_deli_words[1]) eq "RAM") {
 			push @RAM_LINES, $temp;
 			$ram_sum += $comma_deli_words[5];
 		} elsif (RAMorROM($comma_deli_words[1]) eq "ROM") {
 			push @ROM_LINES, $temp;
 			$rom_sum += $comma_deli_words[5];
 		} 
 	}
 	push @returnlines, '<P CLASS="margin">';
 	push @returnlines, '<FONT SIZE=+2 COLOR=#000066><A NAME=EntireSummary><B CLASS="midprod">', "Entire Memory Summary", '</B></A></FONT>';
 	push @returnlines, '<P CLASS="margin">', "\n";	 	
	#push @returnlines, '<p><FONT SIZE=+2 COLOR=#000066><A NAME=EntireSummary>Entire Code Summary</A></FONT></p>';
	push @returnlines, '<TABLE BORDER="1" CELLSPACING="1" CELLPADDING="1" WIDTH="100%" BGCOLOR="#ffffff">';
	push @returnlines, '<tr><td><p align="left"><b>Memory Regions and Section Mapping</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
	if ($ListSectionName) {
		$RAM_string = 'Read/Write Memory Usage (' . join(" ", @DATA_SECTIONS) . ')';
		$ROM_string = 'Read Only Memory Usage (' . join(" ", @CONST_SECTIONS) . join(" ", @CODE_SECTIONS) . join(" ", @UNKNOWN_SECTIONS) . ')';
	}
	
	push @returnlines, '<tr><td><p align="left">' . $RAM_string . '</td>', '<td><p align="left">' . $ram_sum . '</td></tr>';
	push @returnlines, '<tr><td><p align="left">' . $ROM_string . '</td>', '<td><p align="left">' . $rom_sum . '</td></tr>';
	push @returnlines, '</TABLE>';
	return @returnlines;	
}

sub createEntireDetails {
	@returnlines = ();
	local(@RAM_LINES) = ();
	local(@ROM_LINES) = ();
 	local($ram_sum) = 0;
 	local($rom_sum) = 0;
 	foreach $eachline(@SL_LINES) {
 		@comma_deli_words = split(/,/, $eachline); #break comma seperated line
 		$temp = '<TR><TD><p align="left">' . transSymbol2link($comma_deli_words[2]) . '</TD><TD><p align="left">' . $comma_deli_words[0] . '</TD><TD><p align="left">' .  $comma_deli_words[6] . '</TD><TD><p align="left">' .  $comma_deli_words[5] . '</TD>';
 		if (RAMorROM($comma_deli_words[1]) eq "RAM") {
 			push @RAM_LINES, $temp;
 			$ram_sum += $comma_deli_words[5];
 		} else {
 			push @ROM_LINES, $temp;
 			$rom_sum += $comma_deli_words[5];
 		} 
 	}
 	push @returnlines, '<P CLASS="margin">';
 	push @returnlines, '<FONT SIZE=+2 COLOR=#000066><A NAME=EntireDetails><B CLASS="midprod">', "Entire Memory Detail", '</B></A></FONT>';
 	push @returnlines, '<P CLASS="margin">', "\n";	 	 	
	#push @returnlines, '<p><FONT SIZE=+2 COLOR=#000066><A NAME=EntireDetails>Entire Code Detail</A></FONT></p>';
	push @returnlines, '<TABLE BORDER="1" CELLSPACING="1" CELLPADDING="1" WIDTH="100%" BGCOLOR="#ffffff">';
	push @returnlines, '<tr><td><p align="left"><b>Read/Write Memory Usage</b></td><td><p align="left"><b>File</b></td><td><p align="left"><b>Section</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
	push @returnlines, @RAM_LINES;
	#push @returnlines, '<tr><td> &nbsp</td></tr>';
	push @returnlines, '<tr><td><p align="left"><b>Read Only Memory Usage</b></td><td><p align="left"><b>File</b></td><td><p align="left"><b>Section</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
	push @returnlines, @ROM_LINES;
	push @returnlines, '</TABLE>';
	return @returnlines;		
}

sub createHeap {
	@returnlines = ();
  	#heap section
  	#push @summary, '<TR><TD><FONT SIZE=+1 COLOR=#000066>HEAP</FONT></TD></TR>';
  	push @returnlines, '<TR><TD>  </TD></TR>';
 	$sum = 0;
 	foreach $eachline(@HEAP_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		push @returnlines, '<TR><TD>' . $comma_deli_words[0] . '</TD><TD>' . $comma_deli_words[1] . '</TD><TD>' .  $comma_deli_words[3] . '</TD><TD>' .  $comma_deli_words[2] . '</TD>';
 		$sum = $sum + $comma_deli_words[2];
 	}
 	#push @returnlines, '<TR><TD></TD><TD></TD><TD></TD><TD>' . $sum . '</TD></TR>';	
	return @returnlines;
}

sub createStack {
	@returnlines = ();
 	#Stack section
 	#push @summary, '<TR><TD><FONT SIZE=+1 COLOR=#000066>STACK</FONT></TD></TR>';
 	push @returnlines, '<TR><TD>  </TD></TR>';
 	$sum = 0;
 	foreach $eachline(@STACK_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		push @returnlines, '<TR><TD>' . $comma_deli_words[0] . '</TD><TD>' . $comma_deli_words[1] . '</TD><TD>' .  $comma_deli_words[3] . '</TD><TD>' .  $comma_deli_words[2] . '</TD>';
 		$sum = $sum + $comma_deli_words[2];
 	}
 	#push @returnlines, '<TR><TD></TD><TD></TD><TD></TD><TD>' . $sum . '</TD></TR>';	
	return @returnlines;
}


sub createRulefile {
	@rule = ();
	push @rule, '<p><A NAME="rule"><FONT SIZE=+2 COLOR=#000066> <B CLASS="midprod">Rule File</B></FONT></A></p>';
	$filelink = sprintf("%s\\%s\">%s", getcwd(), $rulefile, $rulefile);
	#push @rule, '<p<FONT SIZE=+1 COLOR=#000066><a href="file:///H:/Documents/RAMROMReport.doc">Rule File</a></FONT></p>';
	push @rule, '<p<FONT SIZE=+1 COLOR=#000066><a href="file:///' . $filelink . '</a></FONT></p>';
	return @rule;
}

sub createMAPfile {
	@mapfile = ();
	push @mapfile, '<p><A NAME="MAPfile"><FONT SIZE=+2 COLOR=#000066> <B CLASS="midprod"><a href="matlab: edit ' . $mapfile . ' ">Original MAP File</B></FONT></A></p>';
	#open(MAPFILE, "< $mapfile") 
	#	or die("Can't read MAP file $mapfile\n");
	#push @mapfile, '<pre>';
	#while(<MAPFILE>) {
	#	push @mapfile, $_;
	#}		
	push @mapfile, '</pre>';
	#$filelink = sprintf("%s\\%s\">%s", getcwd(), $mapfile, $mapfile);
	#push @mapfile, '<p<FONT SIZE=+1 COLOR=#000066><a href="file:///' . $filelink . '</a></FONT></p>';
	return @mapfile;
}

sub createMemoryMAPSummary {
	@summary = ();
	$MM_Title = join(" ", @MM_LABEL);
	push @summary, '<p><A NAME="MemoryMAPSummary"><FONT SIZE=+2 COLOR=#000066> <B CLASS="midprod">Memory MAP Summary: ' . $MM_Title . '</B></FONT></A></p>';
	push @summary, '<TABLE BORDER="1" CELLSPACING="1" CELLPADDING="1" WIDTH="100%" BGCOLOR="#ffffff">';
	push @summary, '<tr><td><p align="left"><b>Memory Type and Section Mapping</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
	
	$CODE_size = 0;
	foreach $eachline(@CODE_LINES) {
		@comma_deli_words = split(/,+/, $eachline);
		$CODE_size = $CODE_size + $comma_deli_words[2];
	}
	#print "\nCODE: ", $CODE_size, "\n";

	$CONST_size = 0;
	foreach $eachline(@CONST_LINES) {
		@comma_deli_words = split(/,+/, $eachline);
		$CONST_size = $CONST_size + $comma_deli_words[2];
	}
	#print "\nCONST: ", $CONST_size, "\n";
	
	$DATA_size = 0;
	foreach $eachline(@DATA_LINES) {
		@comma_deli_words = split(/,+/, $eachline);
		$DATA_size = $DATA_size + $comma_deli_words[2];
	}
	#print "\nDATA: ", $DATA_size, "\n";
	
	$UNKNOWN_size = 0;
	foreach $eachline(@UNKNOWN_LINES) {
		@comma_deli_words = split(/,+/, $eachline);
		$UNKNOWN_size = $UNKNOWN_size + $comma_deli_words[2];
	}
	#print "\nUNKNOWN: ", $UNKNOWN_size, "\n";
	
	$DWARF_size = 0;
	foreach $eachline(@DWARF_LINES) {
		@comma_deli_words = split(/,+/, $eachline);
		$DWARF_size = $DWARF_size + $comma_deli_words[2];
	}
	#print "\nDWARF: ", $DWARF_size, "\n";
	
	$idx = 0;
	foreach $eachcol (@MM_TYPES) {
		$MM_size = 0;
		$MM_header = '';
		if (index($MM_CONTENTS[$idx], 'CODE') >=0) {
			$MM_size = $MM_size + $CODE_size;
			$MM_header = $MM_header . join(" ", @CODE_SECTIONS);
		}
		if (index($MM_CONTENTS[$idx], 'CONST') >=0) {
			$MM_size = $MM_size + $CONST_size;
			$MM_header = $MM_header . join(" ", @CONST_SECTIONS);
		}
		if (index($MM_CONTENTS[$idx], 'DATA') >=0) {
			$MM_size = $MM_size + $DATA_size;
			$MM_header = $MM_header . join(" ", @DATA_SECTIONS);
		}
		if (index($MM_CONTENTS[$idx], 'UNKNOWN') >=0) {
			$MM_size = $MM_size + $UNKNOWN_size;
			$MM_header = $MM_header . join(" ", @UNKNOWN_SECTIONS);
		}
		if (index($MM_CONTENTS[$idx], 'DWARF') >=0) {
			$MM_size = $MM_size + $DWARF_size;
			$MM_header = $MM_header . join(" ", @DWARF_SECTIONS);
		}
		push @summary, '<tr><td><p align="left">' . $eachcol . ' (' . $MM_header . ')</td><td><p align="left">' . $MM_size . '</td></tr>';
		$idx = $idx +1;
	}
	push @summary, '</TABLE>';
	return @summary;
}

# create memory map
sub createMemoryMAP {
	@returnlines = ();
	local(@ENTIRE_LINES) = ();
	local(@temp) = ();
	local($last_end_addr) = 0;
	local($last_section);
 	push @returnlines, '<P CLASS="margin">';
 	push @returnlines, '<FONT SIZE=+2 COLOR=#000066><A NAME=MemoryMAP><B CLASS="midprod">', "Memory MAP", '</B></A></FONT>';
 	push @returnlines, '<P CLASS="margin">', "\n";	 	 		
	#push @returnlines, '<H4><FONT SIZE=+2 COLOR=#000000><A NAME=MemoryMAP>Memory MAP</A></FONT></H4>';
 	push @returnlines, '<TABLE BORDER="1" CELLSPACING="1" CELLPADDING="1" WIDTH="100%" BGCOLOR="#ffffff">';
 	push @ENTIRE_LINES, @CODE_LINES;
 	push @ENTIRE_LINES, @DATA_LINES;
 	push @ENTIRE_LINES, @CONST_LINES;
 	push @ENTIRE_LINES, @UNKNOWN_LINES;
 	#push @ENTIRE_LINES, @DWARF_LINES;
 	push @ENTIRE_LINES, @STACK_LINES;
 	push @ENTIRE_LINES, @HEAP_LINES;
 	foreach $eachline(@ENTIRE_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		 # do sprintf to make sure sort by value, not by character!
 		#$comma_deli_words[1] = sprintf("0x%08x", $comma_deli_words[1]);
 		push @temp, "$comma_deli_words[1],$comma_deli_words[0],$comma_deli_words[2],$comma_deli_words[3]";
 	}
 	if ($EchoDebugInfo) {
 		print "\n\n";
 		print @temp;
 	}
 	#@ENTIRE_LINES = sort(@temp);	# sort by start address
 	@ENTIRE_LINES = sort {$a <=> $b}(@temp); # sort by number other than string
 	if ($EchoDebugInfo) {
 		print "\n\n";
 		print @ENTIRE_LINES;
 	}
 	push @returnlines, '<tr><td><p align="left"><b>Section</b></td><td><p align="left"><b>Start Address</b></td><td><p align="left"><b>End Address</b></td><td><p align="left"><b>Size [in bytes]</b></td></tr>';
		#@comma_deli_words = split(/,+/, $ENTIRE_LINES[0]);
		#$last_end_addr = $comma_deli_words[0] + 1;
 	
 	# merge duplicate sections
 	local(@temp_buffer)=();
 	
 	foreach $eachline(@ENTIRE_LINES) {
            @comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		if ($comma_deli_words[0] eq "" ) {		# split would keep a empty element if the string
			shift @comma_deli_words;		# is leading by the delimiter
		}			
 		if ( ($eachline eq $temp_buffer[$#temp_buffer] ) or ($comma_deli_words[2] == 0) ) {
 			# skip duplicate line
 			if ($EchoDebugInfo) {
 				print "skip $eachline";
 			}
 		} else {
 			push @temp_buffer, $eachline;
 		} 		
 	}
 	@ENTIRE_LINES = @temp_buffer;
 	
 	# merge continuous sections
 	local(@temp_buffer)=();
 	foreach $eachline(@ENTIRE_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
 		if ($comma_deli_words[0] eq "" ) {		# split would keep a empty element if the string
			shift @comma_deli_words;		# is leading by the delimiter
		}			
 		@comma_deli_words2 = split(/,+/, $temp_buffer[$#temp_buffer]);
 			if (($comma_deli_words[1] eq $comma_deli_words2[1]) && ($comma_deli_words[0] == $comma_deli_words2[3]) ) {
 				$comma_deli_words2[3] = $comma_deli_words[3];
 				$comma_deli_words2[2] = $comma_deli_words2[3] - $comma_deli_words2[0];
 				pop @temp_buffer; 
 				push @temp_buffer, join(",", @comma_deli_words2);
 				#print "   ", join(",", @comma_deli_words2);
 			} else {
 				#if(! ($comma_deli_words[1] eq $comma_deli_words2[1])) {
 				#	print "because name not same: ", $comma_deli_words[1]," ",$comma_deli_words2[1], "\n";
 				#}
 				#if (!($comma_deli_words[0] == $comma_deli_words2[3])) {
 				#	print "because address not same: ", $comma_deli_words[0], " ", $comma_deli_words2[3], "\n";
 				#}
 				#print              $eachline;
 				push @temp_buffer, $eachline;
 			} 			
 		$idx = $idx +1;
 	}                
 	@ENTIRE_LINES = @temp_buffer;
 	foreach $eachline(@ENTIRE_LINES) {
 		@comma_deli_words = split(/,+/, $eachline); #break comma seperated line
		local($emptysize) = $comma_deli_words[0] - $last_end_addr;
		#print "h "," ", int($comma_deli_words[3]), "\n";
		# without this line below, $last_end_addr will become negative number
		sprintf("%d", int($comma_deli_words[3]));
 		#if (hex($comma_deli_words[0]) > hex($last_end_addr)) {
 		if (int($emptysize) >= 1) {
 			#print "haha  ", int($emptysize), " ", $comma_deli_words[0], " ", $last_end_addr, "\n";
 			push @returnlines, '<TR><td><p align="left"><font color="#800080">', "empty space", '</font></td><td><p align="left"><font color="#800080">', sprintf("0x%x", $last_end_addr), '</font></td><td><p align="left"><font color="#800080">', sprintf("0x%x", $comma_deli_words[0]), '</font></td><td><p align="left"><font color="#800080">', sprintf("0x%08x", $emptysize), '</font></td></TR>';
 			#$last_end_addr = $comma_deli_words[3];
 		}
 		push @returnlines, '<TR><td><p align="left">', $comma_deli_words[1], '</td><td><p align="left">', sprintf("0x%x", $comma_deli_words[0]), '</td><td><p align="left">', sprintf("0x%x", $comma_deli_words[3]), '</td><td><p align="left">', sprintf("0x%08x", $comma_deli_words[2]), '</td></TR>';
 		$last_end_addr = int($comma_deli_words[3]);
 	}

  	push @returnlines, '</TABLE>';
	return @returnlines;
}

sub createJumpTable {
	local(@returnlines);
	push @returnlines, '<UL>';
	if ($Summary) {
		push @returnlines, '<LI><A HREF=' . "$ARGV[2]#Summary" . ' TARGET="rtwreport_document_frame">Model Memory Summary</A><BR></LI>';
	}	
	if ($EntireSummary) {
		push @returnlines, '<LI><A HREF=' . "$ARGV[2]#EntireSummary" . ' TARGET="rtwreport_document_frame">Entire Memory Summary</A><BR></LI>';
	}		
	if ($MemoryMAPSummary) {
		push @returnlines, '<LI><A HREF=' . "$ARGV[2]#MemoryMAPSummary" . ' TARGET="rtwreport_document_frame">Memory MAP Summary</A><BR></LI>';
	}
	if ($Details) {
		push @returnlines, '<LI><A HREF=' . "$ARGV[2]#Details" . ' TARGET="rtwreport_document_frame">Model Memory Detail</A><BR></LI>';
	}	
	if ($EntireDetails) {
		push @returnlines, '<LI><A HREF=' . "$ARGV[2]#EntireDetails" . ' TARGET="rtwreport_document_frame">Entire Memory Detail</A><BR></LI>';
	}	
	if ($MemoryMAP) {
		push @returnlines, '<LI><A HREF=' . "$ARGV[2]#MemoryMAP" . ' TARGET="rtwreport_document_frame">Memory MAP</A><BR></LI>';
	}
	if ($Rulefile) {
		push @returnlines, '<LI><A HREF=' . "$ARGV[2]#Rulefile" . ' TARGET="rtwreport_document_frame">Module Detail</A><BR></LI>';
	}
	if ($MAPfile) {
		push @returnlines, '<LI><A HREF=' . '"matlab: edit ' . $mapfile . '" >Original MAP file</A><BR></LI>';
	}
	
	push @returnlines, '</UL>';
	return @returnlines;
}
	
sub writeHTMLFile {
	my($FILE_HANDLE) = @_;
	if ($Title) {
		print($FILE_HANDLE createTitle());
	}
	if ($Copyright) {
		print($FILE_HANDLE createCopyright());
	}	
	#use POSIX qw(strftime);
    	#$now_string = strftime "%a %b %e %H:%M:%S %Y", gmtime;  
	#print($FILE_HANDLE "$now_string");
	
	if ($Options) {
		print($FILE_HANDLE createOptions());
	}	
	
	print($FILE_HANDLE createJumpTable());
	
	if ($Summary) {
		print($FILE_HANDLE createSummary());
	}	
	if ($EntireSummary) {
		print($FILE_HANDLE createEntireSummary());
	}	
	if ($MemoryMAPSummary) {
		print($FILE_HANDLE createMemoryMAPSummary());
	}	
	if ($Details) {
		print($FILE_HANDLE createDetails());
	}	
	if ($EntireDetails) {
		print($FILE_HANDLE createEntireDetails());
	}	
	if ($MemoryMAP) {
		print ($FILE_HANDLE createMemoryMAP());
	}
	if ($Rulefile) {
		print ($FILE_HANDLE createRulefile());
	}
	if ($MAPfile) {
		#print ($FILE_HANDLE createMAPfile());
	}
}


# go through directory and gather the anchor symbol table
sub createDictionaryList {
	my($DIR_NAME) = @_;
	opendir(HTMLDIR, "$DIR_NAME")
		or die("Can't open HTML code report directory $ARGV[3]\n");
	local($FILEHANDLE);
	if ($DIR_NAME eq ".") {
		$DIR_NAME = "";
	}
	
	foreach $file (readdir HTMLDIR) {
		if (-d $file) {
			if ($EchoDebugInfo) {
				print "$file is a directory\n";
			}
		} else {
			if ($EchoDebugInfo) {
				print "Now Processing file: $file\n";
			}
			open(FILEHANDLE, "< $DIR_NAME$file") or die("Can't read file $DIR_NAME$file \n");
			while (<FILEHANDLE>) {
				# look for legal C identifier which is defined as anchor in HTML
				# C: A valid identifier is a sequence of one or more letters, digits or underline symbols ( _ ). 
				if (/<A NAME=(\S)+>[_a-zA-Z0-9]+<\/A>/) {
					local($anchor1);
					local($anchor2);
					local($anchor);
					local($word1);
					local($word2);
					local($word);
					local($hyperlink);
					$anchor1 = index $_, '<A NAME=';	#index of '<'
					$anchor1 += length('<A NAME=');		#index of the char next to '='
					$anchor2 = index $_, '>', $anchor1;	#index of next '>'
					$anchor = substr $_, $anchor1, ($anchor2 - $anchor1); #between them is the anchor
					
					$word1 = $anchor2 + 1;	#start of C identifier
					$word2 = index $_, '</A>', $word1; #end of it
					$word = substr $_, $word1, ($word2 - $word1);
					
					#<A HREF=HIL_export_h.html#type_D_Work_HIL TARGET="rtwreport_document_frame"> D_Work_HIL </A> 
					# '</A>' will be appended later
					$hyperlink = '<A HREF=' . "$file" . '#' . "$anchor" . ' TARGET="rtwreport_document_frame">';
					push @dictWordList, $word;
					push @dictLinkList, $hyperlink;
					if ($EchoDebugInfo) {
						print "$_  \n anchor is: $hyperlink \t word is: \t$word\n";
					}
				}
			}
		}
	}
	closedir HTMLDIR;
}


# here begins main routine

# check arguments numbers
(($#ARGV+1) eq 3) || (($#ARGV+1) eq 4) || usage();

# open I/O files

open(IRFILE, "< $ARGV[0]") 
	or die("Can't read IR file $ARGV[0]\n");
open(RULEFILE, "< $ARGV[1]")
	or die("Can't read HTML rule file $ARGV[1]\n");
open(OUTFILE, "+> $ARGV[2]")
	or die("Can't write to output file $ARGV[2]\n");

if (($#ARGV+1) eq 4) {
	#opendir(HTMLDIR, "$ARGV[3]")
	#	or die("Can't open HTML code report directory $ARGV[3]\n");
	createDictionaryList($ARGV[3]);
}



# read rule file, assign values to system level variables from rule file
readRuleFile(RULEFILE);

# read IR file
readIRFile(IRFILE);

writeHTMLFile(OUTFILE);

# housekeeping	
close(IRFILE);
close(RULEFILE);
close(OUTFILE);

# delete IR file if necessary
if ($RemoveIR) {
	unlink($ARGV[0]);
}
