#!/usr/bin/perl 
#
# File: hookup.pl
#
# Abstract: This file will link the profiling report into HTML preort by modify the existing 
#		xxx_contents.html file;	It do the modification by search "Additional information</A></TD><TR>"
#		then insert a link into the table which points to the profiling report file;
# 
# Arguments:
#           1. xxx_contents.html file name, which is to be modified;
#	    2. the profiling report html file name;
#
# $Revision: 1.1.6.1 $
# $Date: 2003/04/23 06:26:07 $
#
# Copyright 2003 The MathWorks, Inc.

local($EchoDebugInfo) = 0;

# subroutines
local(@filebuffer);

sub usage {
	print "Usage: hookup HTML_report_filename profiling_report_filename \n";
	exit();
}

# main program begin

# check arguments numbers
(($#ARGV+1) eq 2) || usage();

# open for read and write
open(HTMLFILE, "+< $ARGV[0]") 
	or die("Can't read HTML_report file $ARGV[0]\n");
# generate new table element
#
# <TR><TD><A HREF="%<rptSurveyFileName>#additional_information" TARGET="rtwreport_document_frame">Additional information</A></TD><TR>
$newline = '<TR><TD><A HREF="' . "$ARGV[1]" . '"' . ' TARGET="rtwreport_document_frame">Code profile report</A></TD><TR>' . "\n";
#$newline = "<TR><TD><A HREF=$ARGV[1] TARGET=\"rtwreport_document_frame\">Profiling Report<\/A><\/TD><TR>\n";

while(<HTMLFILE>) {
	if (/Code profile report<\/A><\/TD><TR>\n$/) {
		if ($EchoDebugInfo) {
			print "Already exists link\n";
		}
		exit();
	}
}

seek(HTMLFILE, 0, 0);
@filebuffer = ();
while(<HTMLFILE>) {
	push @filebuffer, $_;
	# insert new line in proper position
	if (/Additional information<\/A><\/TD><TR>\n$/) {
		push @filebuffer, $newline;
	}
}

close(HTMLFILE);

# open for write
open(HTMLFILE, "> $ARGV[0]") or die("Can't write to HTML_report file $ARGV[0]\n");
print (HTMLFILE @filebuffer);

# house keeping
close(HTMLFILE);
