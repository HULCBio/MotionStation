#!/usr/local/bin/perl
#
# script for building the HTML search databases for the Help system's
# Search capability.  Typically, there is one search database
# built for each product.  As an argument, specify the pathname
# of the directory subtree to be indexed.
#
# $Revision: 1.3.4.1 $  $Date: 2004/04/20 21:29:18 $
#

$searchdbase = "index.db";
$verbosemode = 1;
$debugmode = 0;
$helproot = $ENV{PWD} . "/";
$subdir = "./";
@omit_items = ();  # string expressions of files or directories to omit from the database
$omit_count = 0;

# process arguments
$argcount = $#ARGV + 1;
for ($i=0; $i < $argcount; ++$i) {
  if ($ARGV[$i] eq "-o") {
    if ($i == $argcount-1) {
      print "No output file specified.\n";
      exit(1);
    }
    else {
      ++$i;
      $searchdbase = $ARGV[$i];
    };
  }
  elsif ($ARGV[$i] eq "-debug") {
    $debugmode = 1;
  }
  elsif ($ARGV[$i] eq "-nv") {
    $verbosemode = 0;
  }
  elsif ($ARGV[$i] eq "-omit") {
    if ($i == $argcount-1) {
      print "You did not specify the item to omit.\n";
      exit(1);
    }
    else {
      ++$i;
      $omit_items[$omit_count++] = $ARGV[$i];
    };
  }
  else {
    $subdir = $ARGV[$i] . "/"; 
    $subdir =~ s|//$|/|; 
  };
};

#
require 5;
use DB_File;    # Access DB databases
use Fcntl;      # Needed for above...
use File::Find; # Directory searching
$DB_File::DB_BTREE->{cachesize} = 10_000_000; # 10meg cache
$DB_File::DB_BTREE->{psize} = 32*1024; # 32k pages
undef $/; # Don't obey line boundaries
$currentKey = 0;
@exclusion_list = ("an", "the", "of" );

############################################################################

# Delete old search database and attach %indexdb to database
$rcode = unlink($subdir . $searchdbase);
if ($rcode == 0) {truncate($subdir . $searchdbase, 0);}; # can't delete, so truncate
tie(%indexdb,'DB_File',$subdir . $searchdbase,
    O_RDWR | O_CREAT, 0644, $DB_File::DB_BTREE);
find(\&IndexFile,"$subdir");
&FlushWordCache();
untie(%indexdb); # release database

###########################################################################

sub IndexFile {
    if(!-f) { return; }

    $myfilename = $File::Find::name;

    ## Omit certain files
    if (($myfilename =~ m|tocframe\.html| ) ||
        ($myfilename =~ m|ixframe\.html| )) { 
       return;
    };
    ## Also, omit the file if it matches anything on the omit list.
    for ($i=0; $i <= $#omit_items ; $i++) {
       if ($myfilename =~ m|$omit_items[$i]| ) {
          return;
       };
    };

    if(/\.html?$/) { # Handle HTML files
        if ($verbosemode == 1) {
	   print "$File::Find::name\n";
        };
	open(HTML_FILE,$_) || die "Can't open $_: $!";
	my($text) = <HTML_FILE>; # Read entire file
        close(HTML_FILE);

	# If there is a "See Also" section, chop it off
	if ($text =~ m|<a name\=\"seeal_sec\">|)
          {
           # Remove from header to next header or end of file.
           $text =~ s|<a name\=\"seeal_sec\"></a><!-- H2 -->|<a name="seeal_sec"></a>|;
           $text .= "<!-- H2 -->";
	   $text =~ s|<a name\=\"seeal_sec\">.*?<!-- H2 -->||s;
          };

        # Remove material in bottom page footer
	if ($text =~ m|<table.*<img src\=\"b_prev.gif\".*</table>|)
          {
           # Remove from header to end of file.
	   $text =~ s|<table.*<img src\=\"b_prev.gif\".*</table>||;
          };

        # Remove material in FRAMESET files
	if ($text =~ m|<frameset.*>|)
          {
           # Remove material between HEAD tags.
	   $text =~ s|<head.*?</head>||s;
           # Remove material between SCRIPT tags.
	   $text =~ s|<script.*?</script>||s;
          };

        # Strip out all HTML tags 
	$text =~ s/<[^>]*>//g; 
        # Convert non-breaking space entities to spaces
	$text =~ s|&nbsp;| |g; 

	# Index all the words under the current key
	# Map key to this filename
#	$indexdb{pack("xn",$currentKey)} = $File::Find::name;
	$myfilename = $File::Find::name;
	$fullpathname = $helproot . $myfilename;
	open(INFILE, $fullpathname) || die "cannot open $fullpathname for reading\n";
	$count = read(INFILE, $firstline, 5000);

	$docname = "";
	$docnameStartPos = index($firstline, "<!-- DOCNAME:");
	if ($docnameStartPos > -1)
	{
	    $docnameline = substr($firstline, $docnameStartPos + 13, 80);
	    $docnameEndPos = index($docnameline, "-->");
	    $docname = substr($docnameline, 0, $docnameEndPos);
	    $docname =~ s|^ *||;
	    $docname =~ s| *$||;
	};

        $title = "";
        $skip_this_one = 0;
        if ($firstline =~ m|<title>.*</title>|i)
        {
           $title = $&;
           if (($title =~ m|: Table of Contents|) || ($title =~ m|: Index|))
           {
              $skip_this_one = 1;
           };
           $title =~ s|<.*?>||g;
           if (($docname eq "") && ($title =~ m|.*\(.*\) *?$|))
           {
              $docname = $&;
              $docname =~ s|^.*?\(||;
              $docname =~ s|\) *?$||;
           };
           $title =~ s|\(.*?\)||;
           $title =~ s| *:: *$||;
        };

        $title2 = "";
        if ($firstline =~ m|<!-- CHAPNAME:.*?>|)
        {
           $title2 = $&;
           if ($title2 =~ m|: Index -->|)
           {
              $skip_this_one = 1;
           };
           $title2 =~ s|<!-- CHAPNAME: ||;
           $title2 =~ s| *-->||;
        }
        elsif ($title =~ m| :: |) 
        {
           $title2 = $title;
           $title2 =~ s|^.*? :: *||;
        }


        $title3 = "";
        if ($firstline =~ m|<!-- CHUNKNAME:.*?>|)
        {
           $title3 = $&;
           $title3 =~ s|<!-- CHUNKNAME: ||;
           $title3 =~ s| *-->||;
        }
        elsif ($firstline =~ m|<!-- FNAME:.*?-->|)
        {
           $title3 = $&;
           $title3 =~ s|<!-- FNAME:||;
           $title3 =~ s| *-->||;
        }
        elsif ($title =~ m| :: |) 
        {
           $title3 = $title;
           $title3 =~ s| :: .*||;
        }
        elsif ($firstline =~ m|<!-- H1.*|)
        {
           $title3 = $&;
        }
        elsif ($firstline =~ m|<h1>.*|)
        {
           $title3 = $&;
        }
        elsif ($firstline =~ m|<!-- H2.*|)
        {
           $title3 = $&;
        }
        elsif ($firstline =~ m|<h2>.*|)
        {
           $title3 = $&;
        }
        elsif ($firstline =~ m|<h3>.*|)
        {
           $title3 = $&;
        };

        ## provide substitute title strings if needed
        if ($title eq "")
        {
           $shortfilename = $myfilename;
           $shortfilename =~ s|^.*/||;
           $substitutetitle = $shortfilename;
        } else
        {
           $substitutetitle = $title;
        };

        if ($title3 eq "")
        {
           $title3 = $substitutetitle;
        };
        if ($title2 eq "")
        {
           $title2 = $substitutetitle;
        };
        if ($docname eq "")
        {
           $docname = $substitutetitle;
        };

        ## clean up title strings
        $docname = cv_entities($docname);
        $title2 =~ s| *$||;
        $title2 =~ s|<.*?>||g;
        $title2 =~ s|&nbsp;||g;
        $title2 = cv_entities($title2);
        $title3 =~ s| *$||;
        $title3 =~ s|<.*?>||g;
        $title3 =~ s|&nbsp;||g;
        $title3 = cv_entities($title3);

        ## tack on platform identifier for the install guide files.
        if ($docname =~ m|Installing and Using MATLAB on Mac OS X|)
        {
           $title2 =~ s|$| (Mac)|;
        }
        elsif ($docname =~ m|MATLAB Installation Guide for Windows|)
        {
           $title2 =~ s|$| (Windows)|;
        }
        elsif ($docname =~ m|MATLAB Installation Guide for Unix|)
        {
           $title2 =~ s|$| (Unix)|;
        };

        ## index this file
	if (($title3 ne "") && ($skip_this_one == 0))
	{
	    my($wordsIndexed) = &IndexWords($text,$currentKey);
	    $line = $myfilename . "::" . $docname . "::" . $title2 . "::" . $title3;
	    if ($debugmode == 1) {
	       print "$line\n";
            };
	    $indexdb{pack("xn",$currentKey)} = $line;
	    $currentKey++;
	}
	close(INFILE);

	$fileCount++;
	if($fileCount > 500) {
	    &FlushWordCache();
	    $fileCount=0;
	}
    }
}

###########################################################################

sub IndexWords {
    my($words, $fileKey) = @_;
    my(%worduniq); # for unique-ifying word list
    # Split text into Array of words
    my(@words) = split(/[^a-zA-Z0-9\xc0-\xff\+\_\-\.#%']+/, lc $words);
    @words = grep { $worduniq{$_}++ == 0 } # Remove duplicates
	     grep { s/^[^a-zA-Z0-9\xc0-\xff\-#%]+//; $_ } # Strip leading punct
	     grep { s/'$//; $_ } # Strip trailing apostrophe
	     grep { s/\.$//; $_ } # Strip trailing period
             grep { length > 1 } # Must be longer than one character
             grep { /[a-zA-Z0-9\xc0-\xff]/ } # must have an alphanumeric
             @words;

    ## exclude words on the exclusion list
    foreach (@exclusion_list) {
        $w = $_; 
        @words = grep {!/^$w$/ } @words;
    }

    # For each word, add key to word database
    foreach (sort @words) {
	my($a) = $wordcache{$_};
	$a .= pack "n",$fileKey;
        $wordcache{$_} = $a;
    }

    # Return count of words indexed
    return scalar(@words);
}

###########################################################################
# Flush temporary in-memory %wordcache to disk database %indexdb

sub FlushWordCache {
    my($word,$entry);
    # Do merge in sorted order to improve cache response of on-disk DB
    foreach $word (sort keys %wordcache) {
	$entry = $wordcache{$word};
	if(defined $indexdb{$word}) {
	    my($codedList);
	    $codedList = $indexdb{$word};
	    $entry = &MergeLists($codedList,$entry);
	}

	# Store merged list into database
	$indexdb{$word} = $entry;
    }
    %wordcache = (); # Empty the holding queue
}

###########################################################################

sub MergeLists {
    my($list);
    # Simply append all the lists
    foreach (@_) { $list .= $_; }
    # Now, remove any duplicate entries
    my(@unpackedList) = unpack("n*",$list); # Unpack into integers
    my(%uniq); # sort and unique-ify
    @unpackedList = grep { $uniq{$_}++ == 0 }
                    sort { $a <=> $b }
                    @unpackedList;
    return pack("n*",@unpackedList); # repack
}

###########################################################################

sub cv_entities
{
  local($strng) = @_ ;

  $strng =~ s|&#151;|-|g;  # short dash from XML conversion
  $strng =~ s|&#8212;|--|g;  # long dash from XML conversion
  $strng =~ s|&micro;|&#181;|g;  # mu, via its character code

  while ($strng =~ m|&#.*?;|)
    {
     $ccode = $&;
     $ccode =~ s|&#||;
     $ccode =~ s|;||;
     $cchar = chr($ccode);
     $strng =~ s|&#.*?;|$cchar|;
    };

  $strng =~ s|&lt;|<|g;
  $strng =~ s|&gt;|>|g;
  $strng =~ s|&amp;|&|g;

  return($strng);

} # end cv_entities

###########################################################################
