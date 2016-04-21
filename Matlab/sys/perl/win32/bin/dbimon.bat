@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S "%0" %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
goto endofperl
@rem ';
#!perl
#line 14
#
#   dbimon - DBI monitor
#
#   Copyright (C) 1997, 1998: Jochen Wiedmann
#
#
#   This program implements a simple SQL shell. You can enter queries via
#   a comfortable ReadLine interface and retrieve result tables in different
#   output modes:
#
#   Author:  Jochen Wiedmann
#            Am Eisteich 9
#            72555 Metzingen
#            Germany
#
#            Email: joe@ispsoft.de
#            Phone: +49 7123 14887
#
#   dbimon is based on pmsql, which is
#
#   Copyright 1994-1997  Andreas König
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
############################################################################
#
#   Required modules
#
require 5.004;
use Carp ();
use strict;      # Enable for testing only, disable for distributions
# users won't like this for eval's
use DBI ();
use Term::ReadLine ();
use Data::ShowTable ();



############################################################################
#
#   Constants
#
my $VERSION = "1.19_19";

my @VALID_VARS = ("escapeChar", "less", "listWrapMargin", "maxTableWidth",
		  "noEscape", "quoteChar", "sepChar", "showMode");
	

############################################################################
#
#   Global variables
#

my $term = undef;
my $prompt = "dbimon> ";
my $batchMode = 0;
my $debugging = 0;

my $driver;
my $dbh;
my $dsn;
my $user;
my $password;
my $attribs;

# Variables that may be modified via the 'set' command
my $escapeChar      = '"';
my $less            = '';
my $listWrapMargin  = $Data::ShowTable::List_Wrap_Margin;
my $maxTableWidth   = $Data::ShowTable::Max_Table_Width;
my $noEscape        = 0;
my $quoteChar       = '"';
my $sepChar         = ';';
my $showMode        = $Data::ShowTable::Show_Mode;


############################################################################
#
#   Name:    FormatTypeName, FormatDefaultSize, FormatMaxSize
#
#   Purpose: Compatibility kludge for statement attributes missing in
#            DBI.
#
#   Inputs:  $sth - statement handle
#
#   Returns: Reference to attribute of values, one for each column
#
############################################################################

sub FormatTypeName ($) {
    my $sth = shift;
    my ($types, $ref);
    $@ = '';
    $ref = eval { $sth->{format_type_name} };
    if ($@  ||  !$ref) {
	$@ = '';
	$types = eval { $sth->{TYPE} };
	if ($@  ||  !$types) {
	    my($num) = scalar(@{$sth->{NAME}});
	    $ref = [];
	    while ($num--) {
		push(@$ref, 'char');
	    }
	} else {
	    my ($t, $type);
	    $ref = [];
	    while ($t = shift @$types) {
		my $found = 0;
		foreach $type (@DBI::sql_types) {
		    if (defined &{$type}  &&  &{$type}() == $t) {
			push(@$ref, $type);
			$found = 1;
			last;
		    }
		}
		if (!$found) {
		    push(@$ref, 'char');
		}
	    }
	}
    }
    $ref;
}

sub FormatDefaultSize ($) {
    my $sth = shift;
    $@ = '';
    my $ref = eval { $sth->{format_default_size} };
    if ($@  ||  !$ref) {
	$ref = [];
    }
    $ref;
}

sub FormatMaxSize ($) {
    my $sth = shift;
    $@ = '';
    my $ref = eval { $sth->{format_max_size} };
    if ($@  ||  !$ref) {
	$@ = '';
	$ref = eval { $sth->{sol_length} };
	if ($@  ||  !$ref) {
	    $ref = [];
	}
    }
    $ref;
}


############################################################################
#
#   Name:    FindExe
#
#   Purpose: Try's to find an executable in the users PATH
#
#   Inputs:  $exe - executable name
#            $path - reference to array of directory names
#
#   Returns: absolute path name of executable, if found; empty string
#            otherwise
#
############################################################################

sub FindExe ($$) {
    my($exe,$path) = @_;
    my($dir);
    for $dir (@$path) {
        my $abs = "$dir/$exe";
        if (-x $abs) {
            return $abs;
        }
    }
    '';
}


############################################################################
#
#   Name:    Connect
#
#   Purpose: Attempts to connect to a database.
#
#   Inputs:  $dsn - datasource name, for example "DBI:mysql:test"
#            $user - user name
#            $pwd - password
#
#   Returns: database handle or 'undef' in case of problems
#
############################################################################

sub Connect (@) {
    my ($ndsn, $nuser, $npassword) = @_;
    my ($dbh);

    if (!defined($ndsn)  ||  $ndsn eq '') {
	print "Missing datasource name.\n";
	return undef;
    }
    if ($ndsn !~ /^dbi:/i) {
	$ndsn = "DBI:$ndsn";
    }

    $dbh = eval { DBI->connect($ndsn, $nuser, $npassword); };
    if ($@) {
	print "Failed to connect, perhaps driver problems: $@\n";
	return undef;
    }
    if (!defined($dbh)) {
	my $errmsg = $DBI::errstr;
	print "Failed to connect: $errmsg\n";
	if (!$batchMode  &&  !defined($npassword)  ||  $npassword eq '') {
	    $@ = '';
	    eval { require Term::ReadKey; };
	    my($readKeyAvailable) = $@ ? 0 : 1;
	    print "This might be due to a missing password. If so, enter\n";
	    print "the password, otherwise just type return: ";
	    if ($readKeyAvailable) {
		Term::ReadKey::ReadMode('noecho');
		$npassword = Term::ReadKey::ReadLine(0);
		Term::ReadKey::ReadMode('restore');
		print "\n";
	    } else {
		$npassword = <STDIN>;
	    }
	    chomp $npassword;
	    if (defined($npassword)  &&  $npassword ne '') {
		$dbh = DBI->connect($ndsn, $nuser, $npassword);;
		if (!defined($dbh)) {
		    print "Failed to connect: ", $DBI::errstr, "\n";
		}
	    }
	}
    }

    if ($dbh) {
	if ($ndsn =~ /^dbi\:([^\:]+)\:(.*)/i) {
	    $driver = $1;
	    my($rdsn) = $2;
	    if ($driver eq 'mSQL'  ||  $driver eq 'mysql') {
		my($class) = "DBD::$driver";
		my($hash) = {};
		$class->_OdbcParse($rdsn, $hash, ["database"]);
		if ($hash->{'database'}) {
		    $prompt = "$driver:" . $hash->{'database'} . "> ";
		}
	    }
	} else {
	    $driver = undef;
	}
	$dsn = $ndsn;
	$user = $nuser;
	$password = $npassword;
    }

    $dbh;
}


############################################################################
#
#   Name:    Output
#
#   Purpose: Formats and prints a query result.
#
#   Inputs:  $sth - statement handle of query, 'execute' called on
#                this sth
#
#   Returns: Nothing
#
############################################################################

sub Output ($) {
    my ($sth) = @_;
    my $restoreStdout = 0;

    if (!$batchMode  &&  $less  &&  $less ne 'stdout') {
	if (!open(SAVEOUT, ">&STDOUT")) {
	    print STDERR "Cannot redirect STDOUT: $!\n";
	    return;
	}
	if (!open(STDOUT, "| $less")) {
	    print STDERR "Cannot open pipe to pager $less: $!\n";
	    open(STDOUT, ">&SAVEOUT");
	    close(SAVEOUT);
	    return;
	}
	$restoreStdout = 1;
    }

    if ($showMode eq 'Export') {
	# Output for export is somewhat simpler ...
	my(@res);
	my($ePattern, $qPattern, $null, $ref, $quote);

	# Create a pattern for escaping one column; we escape the
	# $escapeChar, the $quoteChar and \0.
	$quote = defined($quoteChar) ? $quoteChar : "";
	if (defined($escapeChar)  &&  $escapeChar ne '') {
	    $ePattern = $escapeChar;
	    $ePattern =~ s/(\W)/\\$1/g;
	    if ($quote ne '') {
		$qPattern = $quote;
		$qPattern =~ s/(\W)/\\$1/g;
		if ($ePattern) {
		    $ePattern = "$ePattern|$qPattern";
		} else {
		    $ePattern = $qPattern;
		}
	    }
	    $ePattern = "$ePattern|\\0";
	} else {
	    $ePattern = '';
	}
	$null = 0;

	# Now the true output
	while (defined($ref = $sth->fetchrow_arrayref())) {
	    my $add = '';
	    my $word;
	    foreach $word (@$ref) {
		if ($ePattern) {
		    $word =~ s/($ePattern)/$escapeChar$1/g;
		}
		printf ("%s%s%s%s", $add, $quote, $word, $quote);
		$add = $sepChar;
	    }
	    print "\n";
	}
    } else {
	my @rowCache;
	my ($fillCache) = 0;
	my ($useCache) = 0;
	my ($numFields, $titles, $types, $widths);
	eval {
	    $titles = $sth->{'NAME'} || [];
	    $types = FormatTypeName($sth);
	    $widths = FormatDefaultSize($sth);
	};
	my $row_sub = sub ($) {
	    if (shift) {
		if ($fillCache) {
		    $fillCache = 0;
		    $useCache = 1;
		    return 1;
		}
		if (!$widths  ||  @$widths != @$titles) {
		    $fillCache = 1;
		    return 1;
		}
		my $col;
		foreach $col (@$widths) {
		    if (!defined(@$widths)) {
			$fillCache = 1;
			return 1;
		    }
		}
		return 0;
	    }
	    my $ref;
	    if ($useCache) {
		$ref = shift @rowCache;
	    } else {
		$ref = $sth->fetchrow_arrayref;
		if ($ref  &&  $fillCache) {
		    push(@rowCache, [@$ref]);
		}
	    }
	    $ref ? @$ref : ();
	};
        Data::ShowTable::ShowTable { 'titles' => $titles,
				     'widths' => $widths,
				     'types' => $types,
				     'row_sub' => $row_sub,
				     'show_mode' => $showMode,
				     'wrap_margin' => $listWrapMargin,
				     'max_width' => $maxTableWidth,
				     'no_escape' => $noEscape
				   };
    }

    if ($restoreStdout) {
	close(STDOUT);
	open(STDOUT, ">&SAVEOUT");
	close(SAVEOUT);
    }
}


############################################################################
#
#   Name:    RelShow
#
#   Purpose: Display list of dsn's, tables or fields
#
#   Inputs:  $dsn - undef, if list of dsn's should be displayed,
#                otherwise dsn being displayed
#            $table - undef, if list of tables should be displayed,
#                otherwise table being displayed
#
#   Returns: Nothing
#
############################################################################

sub DisplayList ($$) {        # XXX Replace this with ShowDatabases() and
    my ($header, $l) = @_;    # ShowTables() as soon as they work. :-(

    local( $::current_row ) = 0;
    my $row_sub	= sub {
	&Data::ShowTable::ShowRow($_[0], \$::current_row, $l);
    };
    Data::ShowTable::ShowTable {'titles' => [$header],
				'types' => ['char'],
				'widths' => [ ],
				'row_sub' => $row_sub};
}

sub DsnList() {
    my @l;
    eval { @l = DBI->data_sources($driver); };
    if ($@) {
	@l = ();
    }
    @l;
}

sub TableList ($) {
    my ($rdsn) = shift;
    if ($rdsn !~ /\:/) {
	$rdsn = "DBI:$driver:$rdsn";
    } elsif ($rdsn !~ /\:[^\:]+\:/) {
	$rdsn = "DBI:$rdsn";
    }
    my (@l, $ndbh);
    eval {
	if ($dsn ne $rdsn) {
	    my $ndbh = DBI->connect($rdsn, $user, $password);
	    if ($ndbh) {
		@l = $ndbh->func("_ListTables");
		$ndbh->disconnect;
	    }
	} else {
	    @l = $dbh->func("_ListTables");
	}
    };
    if ($@) {
	@l = ();
    }
    @l;
}

sub FieldList($$;$) {
    my ($rdsn, $table, $dbhRef) = @_;
    if ($rdsn !~ /\:/) {
	$rdsn = "DBI:$driver:$rdsn";
    } elsif ($rdsn !~ /\:[^\:]+\:/) {
	$rdsn = "DBI:$rdsn";
    }
    my ($sth);
    eval {
	if ($dsn ne $rdsn) {
	    my $ndbh = DBI->connect($rdsn, $user, $password);
	    if ($ndbh) {
		$sth = $ndbh->prepare("LISTFIELDS $table");
		$sth->execute;
		($sth, $ndbh);
	    } else {
		(undef);
	    }
	} else {
	    $sth = $dbh->prepare("LISTFIELDS $table");
	    $sth->execute;
	    ($sth);
	}
    };
}

sub RelShow (;$$) {
    my($dsn, $table) = @_;

    if (!defined($dsn)) {
	#
	#  relshow
	#
	if (!defined($driver)) {
	    print("Cannot display datasources: Unable to determine driver\n",
		  " name in dsn $dsn.\n");
	} else {
	    my @l = DsnList();
	    if ($@) {
		print "Cannot get dsn list, perhaps a driver problem: $@.\n";
	    } elsif (!@l) {
		print "No databases found.\n";
	    } else {
	      DisplayList('DSN list', \@l);
	    }
	}
	return;
    }

    if (!defined($table)) {
	#
	# relshow database
	#
	my @l = TableList($dsn);
	if (!@l) {
	    print "No tables found.\n";
	} else {
	    DisplayList("Table list", \@l);
	}
	return;
    }

    my ($sth, $ndbh) = FieldList($dsn, $table);

    if ($@) {
	print "Cannot get list, perhaps a driver problem: $@.\n";
    } else {
	#
	# relshow database table
	#
	if (!$sth) {
	    print "Cannot get table list, error", $dbh->errstr, "\n";
	} else {
	    my ($fLen, $tLen, $lLen, $nLen) = (length("Field"),
					       length("Type"),
					       length("Length"),
					       length("Not Null"));
	    my ($numFields, $fRef, $tRef, $lRef, $nRef);
	    eval {
		my $ref;
		$numFields = $sth->{'NUM_OF_FIELDS'};
		if (defined($ref = $sth->{'NAME'})  &&  ref($ref) eq 'ARRAY') {
		    $fRef = [@$ref];
		}
		if (defined($ref = $sth->{'NULLABLE'})  &&
		    ref($ref) eq 'ARRAY') {
		    $nRef = [@$ref];
		}
		if (defined($ref = FormatTypeName($sth))  &&
		    ref($ref) eq 'ARRAY') {
		    $tRef = [@$ref];
		}
		if (defined($ref = FormatMaxSize($sth))  &&
		    ref($ref) eq 'ARRAY') {
		    $lRef = [@$ref];
		}
	    };
	    my $col_num = 0;

	    my $row_sub = sub ($) {
		my ($name, $type, $len, $nullable);
		if (shift) {
		    $col_num = 0;
		    return 1;
		}
		if ($col_num >= $numFields) {
		    return ();
		}
		if (!$fRef  ||  (ref($fRef) ne 'ARRAY')  ||
		    !defined($name = $$fRef[$col_num])) {
		    $name = "unknown";
		}
		if (!$tRef  ||  (ref($tRef) ne 'ARRAY')  ||
		    !defined($type = $$tRef[$col_num])) {
		    $name = "unknown";
		}
		if (!$lRef  ||  (ref($lRef) ne 'ARRAY')  ||
		    !defined($len = $$lRef[$col_num])) {
		    $len = "N/A";
		}
		if (!$nRef  ||  (ref($nRef) ne 'ARRAY')  ||
		    !defined($nullable = $$nRef[$col_num])) {
		    $len = "N/A";
		} else {
		    $nullable = $nullable ? "Y" : "N";
		}
		$col_num++;
		($name, $type, $len, $nullable);
	    };

	    Data::ShowTable::ShowTable {'titles' => ['Field', 'Type',
						     'Length', 'Nullable'],
					'types' =>  ['char', 'char', 'int',
						     'char'],
					'widths' => [],
					'row_sub' => $row_sub};
	}
    }

    if ($ndbh) {
	undef $sth;
	$ndbh->disconnect;
    }
}


############################################################################
#
#   Name:    GetOrSetVal
#
#   Purpose: Display and modify one internal variable
#
#   Inputs:  $key - variable name
#            $val - variable value; optional; variable will only be
#                queried, if $val is undef
#            $complete - if TRUE, this parameter asks for completion
#                of $val
#
#   Returns: List with variable name and current (probably modified)
#            value. $key is undef, if variable name was invalid.
#
############################################################################

sub GetOrSetVal (@) {
    my ($key, $val, $complete) = @_;

    if ($key =~ /^e(s(c(a(p(e(c(h(ar?)?)?)?)?)?)?)?)?$/i) {
	if ($complete) {
	    return (); # No completion available
	}
	if (defined($val)) {
	    $escapeChar = $val;
	}
	$val = $escapeChar ? $escapeChar : "off";
	$key = "escapeChar";
    } elsif ($key =~ /^le(ss?)?$/i) {
	if ($complete) {
	    return (); # No completion available
	}
	if (defined($val)) {
	    if ($val  &&  $val ne 'stdout'  &&  ! -x $val) {
		print "No such executable: $val\n";
		print "Keeping old value.\n";
	    } else {
		$less = $val;
	    }
	}
	$val = ($less && $less ne 'stdout') ? $less : "off";
	$key = "less";
    } elsif ($key =~ /^li(s(t(w(r(a(p(m(a(r(g(in?)?)?)?)?)?)?)?)?)?)?)?$/i) {
	if ($complete) {
	    return (); # No completion available
	}
	if (defined($val)) {
	    if ($val =~ /^\d+$/) {
		$listWrapMargin = $val;
	    } elsif ($val eq "off") {
		$maxTableWidth = '';
	    } else {
		print "Illegal value for maxTableWidth: $val\n";
		print "Keeping old value.\n";
	    }
	}
	$val = ($maxTableWidth ne '') ? $maxTableWidth : "off";
	$key = "maxTableWidth";
    } elsif ($key =~ /^maxt(a(b(l(e(w(i(d(th?)?)?)?)?)?)?)?)?$/i) {
	if ($complete) {
	    return (); # No completion available
	}
	if (defined($val)) {
	    if ($val =~ /^\d+$/) {
		$maxTableWidth = $val;
	    } elsif ($val eq "off") {
		$maxTableWidth = '';
	    } else {
		print "Illegal value for maxTableWidth: $val\n";
		print "Keeping old value.\n";
	    }
	}
	$val = ($maxTableWidth ne '') ? $maxTableWidth : "off";
	$key = "maxTableWidth";
    } elsif ($key =~ /n(o(e(s(c(a(pe?)?)?)?)?)?)?$/i) {
	if ($complete) {
	    if ($val =~ /^on$/i) {
		return ('on');
	    } elsif ($val =~ /^off?$/i) {
		return ('off');
	    } elsif ($val =~ /^o?$/i) {
		return ('on', 'off');
	    } else {
		return ();
	    }
	}
	if (defined($val)) {
	    if ($val =~ /^on$/i) {
		$noEscape = 1;
	    } elsif ($val =~ /^off?$/i) {
		$noEscape = 0;
	    } else {
		print "Unknown value, use either 'on' or 'off'.\n";
		print "Keeping old value.\n";
	    }
	}
	$val = $noEscape ? 'on' : 'off';
    } elsif ($key =~ /q(u(o(t(e(c(h(ar?)?)?)?)?)?)?)?/i) {
	if ($complete) {
	    return (); # No completion available
	}
	if (defined($val)) {
	    $quoteChar = $val;
	}
	$val = $quoteChar ? $quoteChar : "off";
	$key = "quoteChar";
    } elsif ($key =~ /se(p(c(h(ar?)?)?)?)?/i) {
	if ($complete) {
	    return (); # No completion available
	}
	if (defined($val)) {
	    $sepChar = $val;
	}
	$val = $sepChar ? $sepChar : "off";
	$key = "sepChar";
    } elsif ($key =~ /^sh(o(w(m(o(de?)?)?)?)?)?$/i) {
	if ($complete) {
	    if ($val =~ /^b(ox?)?$/i) {
		return ('Box');
	    } elsif ($val =~ /^e(x(p(o(rt?)?)?)?)?$/i) {
		return ('Export');
	    } elsif ($val =~ /^h(t(ml?)?)?$/i) {
		return ('HTML');
	    } elsif ($val =~ /^l(i(st?)?)?$/i) {
		return ('List');
	    } elsif ($val =~ /^t(a(b(le?)?)?)?$/i) {
		return ('List');
	    } elsif ($val eq '') {
		return ('Box', 'Export', 'HTML', 'List', 'Table');
	    } else {
		return ();
	    }
	}
	if (defined($val)) {
	    if ($val =~ /^b(ox?)?$/i) {
		$showMode = 'Box';
	    } elsif ($val =~ /^t(a(b(le?)?)?)?$/i) {
		$showMode = 'Table';
	    } elsif ($val =~ /^l(i(st?)?)?$/i) {
		$showMode = 'List';
	    } elsif ($val =~ /^h(t(ml?)?)?$/i) {
		$showMode = 'HTML';
	    } elsif ($val =~ /^e(x(p(o(rt?)?)?)?)?$/i) {
		$showMode = 'Export';
	    } else {
		print "Unknown show mode: $val\n";
		print "Possible modes are: Box, Table, List, HTML, Export\n";
		print "Keeping old value.\n";
	    }
	}
	$val = $showMode;
	$key = "showMode";
    } else {
	if ($complete) {
	    return ();
	}
	$key = undef;
    }

    ($key, $val);
}


############################################################################
#
#   Name:    Set
#
#   Purpose: Display and modify internal variables
#
#   Inputs:  @args - command line arguments
#
#   Returns: Nothing
#
############################################################################

sub Set (@) {
    if (!@_) {
	# Display complete list of arguments
	printf("Current settings:\n" .
	       "                less: %s\n" .
	       "            showMode: %s\n",
	       (GetOrSetVal("less"))[1], (GetOrSetVal("showMode"))[1]);
        if ($showMode eq 'Export') {
	    printf("          escapeChar: %s\n" .
		   "           quoteChar: %s\n" .
		   "             sepChar: %s\n",
		   (GetOrSetVal("escapeChar"))[1],
		   (GetOrSetVal("quoteChar"))[1],
		   (GetOrSetVal("sepChar"))[1]);
	} elsif ($showMode eq 'Box') {
	    printf("       maxTableWidth: %s\n",
		   (GetOrSetVal("maxTableWidth"))[1]);
	} elsif ($showMode eq 'HTML') {
	    printf("       maxTableWidth: %s\n" .
		   "            noEscape: %s\n",
		   (GetOrSetVal("maxTableWidth"))[1],
		   (GetOrSetVal("noEscape"))[1]);
	} elsif ($showMode eq 'List') {
	    printf("      listWrapMargin: %s\n" .
		   "       maxTableWidth: %s\n",
		   (GetOrSetVal("listWrapMargin"))[1],
		   (GetOrSetVal("maxTableWidth"))[1]);
	}
    } elsif (@_ == 1  ||  @_ == 2) {
	my($key, $val) = @_;
	($key, $val) = GetOrSetVal($key, $val);
	if (!defined($key)) {
	    printf("Unknown variable: %s.\n", $key);
	} else {
	    printf("Current value of %s: %s\n", $key, $val);
	}
    } else {
	print "Usage: set [<var> [<val]]\n";
    }
}


############################################################################
#
#   Name:    Complete
#
#   Purpose: Simple completion function for ReadLine
#
#   Inputs:  $word - word to complete
#            $line - line to complete
#            $pos - ?
#
#   Returns: Word to complete
#
############################################################################

sub complete_database ($) {
    my $word = shift;
    grep /^(.*\:)\Q$word/, DsnList();
}

sub complete_table ($$) {
    my($word,$line) = @_;
    my($rdsn) = $line =~ /^r\w+\s+(\w+)/;
    if ($debugging) {
	print STDERR "word[$word] line[$line] dsn[$rdsn]\n";
    }
    $rdsn ||= $dsn;
    if (!$rdsn) {
	return ();
    }
    grep /^\Q$word/, TableList($dsn);
}

sub complete_table_or_field {
    my($word,$line) = @_;
    my(@result) = ();
    if ($debugging){
	print STDERR "word[$word] line[$line]\n";
    }
    if ($line =~ /(delete|select)\s.*from\s+\Q$word\E$/i  ||
	$line =~ /^update\s+\Q$word\E$/i ||
	$line =~ /^insert\s.*into\s+\Q$word\E$/i) {
	@result = grep /^\Q$word/, TableList($dsn);
    } elsif ($line =~ /^delete\s.*\sfrom\s+(\w+)/i  ||
	     $line =~ /^select\s.*\sfrom\s+(\w+)/i  ||
	     $line =~ /^update\s+(\w+)/i            ||
	     $line =~ /^insert\s.*into\s+(\w+)/i) {
	my $table = $1;
	if ($table) {
	    my $sth = FieldList($dsn, $table);
	    if ($sth) {
		my $names = $sth->{'NAME'};
		if (ref($names) eq 'ARRAY') {
		    @result = grep /^\Q$word/, @$names;
		}
	    }
	}
    }
    @result;
}

sub complete_for_relshow ($$) {
    my($word, $line) = @_;
    my @t = split(' ', $line);
    if (@t == 1  ||  @t == 2  &&  $word eq $t[1]) {
	complete_database($word);
    } else {
	complete_table($word, $line);
    }
}

sub complete_for_set ($$) {
    my($word, $line) = @_;
    my @t = split(' ', $line);
    if (@t == 1  ||  @t == 2  &&  $word eq $t[1]) {
	grep /^\Q$word/, @VALID_VARS;
    } elsif ((@t == 2 && $word eq '') ||  @t == 3  &&  $word eq $t[2]) {
	my ($key) = $t[1]  ||  '';
	my ($val) = $t[2]  ||  '';
	GetOrSetVal($t[1], $t[2], 1);
    } else {
	();
    }
}

sub Complete ($$$) {
    my($word, $line, $pos) = @_;
    $word ||= '';
    $line ||= '';
    $pos ||= 0;
    if ($debugging) {
	print STDERR "complete line[$line] word[$word] pos[$pos]\n";
    }

    # Remove preceding white space
    $line =~ s/^\s*//;

    if ($pos == 0) {
	grep /^$word/i, ('!', '?', 'delete from', 'dsn', 'insert into',
			 'quit', 'relshow', 'select', 'set', 'update');
    } elsif ($line =~ /^dsn?/i) {
	complete_database($word);
    } elsif ($line =~ /^de(l(e(te?)?)?)?/i) {
	complete_table_or_field($word,$line);
    } elsif ($line =~ /^i(n(s(e(rt?)?)?)?)?/i) {
	complete_table_or_field($word,$line);
    } elsif ($line =~ /^r(e(l(s(h(ow?)?)?)?)?)?/i) {
	complete_for_relshow($word,$line);
    } elsif ($line =~ /^sel(e(ct?)?)?/i) {
	complete_table_or_field($word,$line);
    } elsif ($line =~ /^set/i) {
	complete_for_set($word, $line);
    } elsif ($line =~ /^u(p(d(a(te?)?)?)?)?/i) {
	complete_table_or_field($word,$line);
    } else {
	();
    }
}

sub CompleteGnu ($$$) {
    my($word, $line, $pos) = @_;
    my(@poss) = Complete($word, $line, $pos);
    $attribs->{'completion_word'} = \@poss;
    return;
}


############################################################################
#
#   Name:    Quit
#
#   Purpose: Programs destructor
#
#   Inputs:  None
#
#   Returns: Nothing.
#
############################################################################

sub Quit () {
    if (defined($dbh)) {
	$dbh->disconnect;
	$dbh = undef;
    }
}
END { Quit(); }


############################################################################
#
#   Name:    Help
#
#   Purpose: Print help message
#
#   Inputs:  None
#
#   Returns: Nothing.
#
############################################################################

sub Help () {
    print qq{
d[sn] <dsn>                  Disconnect from current dsn and connect to <dsn>
r[elshow] [<dsn> [<table>]]  Display list of dsn´s, tables, fields.
s[et] [<var> [<val>]]        Display or set values of internal variables.
! <anything>                 Eval <anything> in perl
?                            Print this message
q[uit]                       Leave dbimon

Any other line will be passed as a query to the DMBS.
};
}


############################################################################
#
#   Name:    Usage
#
#   Purpose: Print usage message
#
#   Inputs:  None
#
#   Returns: Nothing, exits with error status
#
############################################################################

sub Usage () {
    print STDERR qq{
Usage: $0 [options] dsn [user [password]]

Possible options are:
    -h | -help | --help     Print this message
    -b | -batch | --batch   Batch mode

dbimon $VERSION Copyright (C) 1997 Jochen Wiedmann
};
    exit 1;
}


############################################################################
#
#   This is main().
#
############################################################################

{
    my ($arg);
    my ($dsn, $user, $password);

    #   Initialize $less
    {
	my @path = split ":", $ENV{PATH};
	if (exists($ENV{DBIMON_PAGER})) {
	    $less = $ENV{DBIMON_PAGER};
	} elsif (exists($ENV{PAGER})) {
	    $less = $ENV{PAGER};
	} elsif (!defined($less = FindExe("less", [@path]))  &&
		 !defined($less = FindExe("more", [@path]))) {
	    $less = '';
	}
    }

    while (defined($arg = shift @ARGV)) {
	if ($arg eq "-h"  ||  $arg eq "-help"  ||  $arg eq "--help") {
	    Usage();
	} elsif ($arg eq "-b"  ||  $arg eq "-batch"  ||  $arg eq "--batch") {
	    $batchMode = 1;
	} elsif ($arg eq "-d"  ||  $arg eq "-debug"  ||  $arg eq "--debug") {
	    $debugging = 1;
	} else {
	    if (!defined($dsn)) {
		$dsn = $arg;
	    } elsif (!defined($user)) {
		$user = $arg;
	    } elsif (!defined($password)) {
		$password = $arg;
	    } else {
		Usage();
	    }
	}
    }
    if (!defined($dsn)) {
	Usage();
    }

    if (!($dbh = Connect($dsn, $user, $password))) {
	print STDERR "Cannot connect: $DBI::errstr\n";
	exit 1;
    }

    if (!$batchMode) {
	$term = Term::ReadLine->new("dbimon $VERSION");
	my ($rl_package) = $term->ReadLine;
	my ($rl_avail);
	if ($rl_package eq "Term::ReadLine::Gnu") {
	    $attribs = $term->Attribs;
	    $attribs->{'attempted_completion_function'} = \&CompleteGnu;
	    $attribs->{'completion_entry_function'} =
		$attribs->{'list_completion_function'};
	    $rl_avail = 'enabled';
	} else {
	    $readline::rl_completion_function = 'main::Complete';
	    if ($rl_package eq 'Term::ReadLine::Perl'  ||
		$rl_package eq 'Term::ReadLine::readline_pl') {
		$rl_avail = 'enabled';
	    } else {
		$rl_avail = "available (get Term::ReadKey and"
		    . " Term::ReadLine::[Perl|GNU])";
	    }
	}

	my $serverinfo = eval { $dbh->func('getserverinfo'); };
	if (!defined($serverinfo)  ||  !$@) {
	    $serverinfo = 'No server information available';
	}
	print("DBImon $VERSION - the interactive DBI monitor\n",
	      "Copyright (C) 1997, Jochen Wiedmann\n",
	      "$serverinfo\n",
	      "Readline support $rl_avail\n\n");
    }

    # Main loop
    my $line;
    while ($batchMode ? defined($line = <STDIN>) :
	   defined($line = $term->readline($prompt))) {
	# Remove preceding and trailing blanks, ignore empty lines
	$line =~ s/^\s+//;
	$line =~ s/\s+$//;
	if ($line =~ /^$/) {
	    next;
	}
	
	# Handle Perl evaluation
	if ($line =~ /^\!/) {
	    my $command = $';
	    $command =~ s/^\s+//;
	    if ($command !~ /^$/) {
		if (!$batchMode) {
		    $term->addhistory($command);
		}
		# Disable warnings
		$^W = 0; eval $command;
		if ($@) {
		    warn $@;
		}
		$^W = 1;
		print "\n";
	    }
	    next;
	}
	
	# Help mode
	if ($line =~ /^\?/) {
	    Help();
	    next;
	}
	
	# Perhaps this is a command?
	my ($command, @args) = split(' ', $line);
	if (!defined($command)) {
	    next;
	}
	
	if ($command =~ /^d(sn?)?$/i) {
	    if (@args) {
		my($ndbh);
		my($ndsn, $nuser, $npassword) = @args;
		if (!($ndbh = Connect($ndsn, $nuser, $npassword))) {
		    print "Cannot connect: $DBI::errstr\n";
		} else {
		    $dbh->disconnect;
		    $dbh = $ndbh;
		    $dsn = $args[0];
		}
	    }
	    print "Current DSN is: $dsn\n";
	} elsif ($command =~ /^q(u(it?)?)?$/i) {
	    if (!$batchMode) {
		print "Goodbye\n";
	    }
	    last;
	} elsif ($command =~ /^r(e(l(s(h(ow?)?)?)?)?)?$/i) {
	    if (@args > 2) {
		print "Usage: relshow [<dsn> [<table>]]\n";
	    } else {
		my ($dsn, $table) = @args;
		RelShow($dsn, $table);
	    }
	} elsif ($command =~ /^s(et?)?$/i) {
	    if (@args > 2) {
		print "Usage: set [<var> [<val>]]\n";
	    } else {
		my ($key, $val) = @args;
		Set(@args);
	    }
	} else {
	    # This is a query
	    $line =~ s/(\\[qgp]|\;)$//;

	    my $sth = $dbh->prepare($line);
	    if (!defined($sth)) {
		printf("Prepare error: %s\n", $dbh->errstr);
		next;
	    }
	    my $rows = $sth->execute;
	    if (!$rows) {
		printf("Execute error: %s\n", $dbh->errstr);
		next;
	    }
	    if ($sth->{'NUM_OF_FIELDS'} == 0) {
		if (!$batchMode) {
		    if ($rows != -1) {
			print "Query affected $rows rows.\n";
		    } else {
			print "Query affected unknown number of rows.\n";
		    }
		}
		next;  # Query with no result
	    }

	    # Now for the hard part: Create a table output
	    Output($sth);
	    $sth->finish;
	}
    }

    exit 0;
}


__END__

=head1 NAME

dbimon - interactive shell with readline for DBI

=head1 SYNOPSIS

C<dbimon E<lt>dsnE<gt> [E<lt>userE<gt> [E<lt>passwordE<gt>]]>

=head1 DESCRIPTION

dbimon lets you talk to a running SQL server via the database independent
Perl interface DBI. dbimon was inspired by Andreas Koenig's pmsql and
borrows both design ideas and code from it. Thus the look and feel is
almost identical to pmsql, in particular the following holds:

=over 4

=item *

The output is formatted much in the same way as by the msql or mysql
monitor (see below), the msqlexport command and the relshow (mysqlshow)
programs, which are coming with msql or mysql.

=item *

The additional capability is a connection to a readline interface (if
available) and a pipe to your favorite pager.

=item *

Additionally you may switch between hosts and databases within one session
and you don't have to type the nasty C<\g> or C<;> (a trailing C<\g>, C<\q>,
and C<\p> will be ignored).

=back

If a command starts with one of the following reserved words, it's
treated specially, otherwise it is passed on verbatim to the DBMS.
Output from the daemon is piped to your pager specified by either the
DBIMON_PAGER or the PAGER environment variable. If both are undefined,
the PATH is searched for either "less" or "more" and the first program
found is taken. If no pager can be determined or your pager
variable is empty or set to C<stdout>, the program writes to unfiltered
STDOUT.

=over 2

=item C<?>

print usage summary

=item C<dsn E<lt>dsnE<gt>

Connects to the given E<lt>dsnE<gt>, the old connection is closed.

=item C<q[uit]>

Leave dbimon.

=item C<re[lshow] [E<lt>dsnE<gt> [E<lt>tableE<gt>]]>

Without arguments this lists possible data sources by calling DBI's
I<data_sources> method. Data sources are driver dependent, the driver
of the last connection will be used. Unfortunately DBI offers no
possibilities of specifying a hostname or similar dsn attributes,
so you can hardly list a remote hosts dsns, for example.

If a C<dsn> is given, dbimon will connect to the given dsn and list
its tables. If both C<dsn> and C<table> are present, dbimon will list
the tables fields.

The latter possibilities are not supported by the DBI - these work
with private methods. Currently they are implemented for DBD::mSQL
and DBD::mysql.

=item C<se[t] [E<lt>varE<gt> [E<lt>valE<gt>]]

This command displays and modifies dbimon's internal variables.
Without arguments, all variables and their current settings are
listed. With a variable name only you query the variables value.
The two argument form modifies a variable. Supported variables
are:

=over 4

=item showMode

This variable controls the output of an SQL result table. Possible values
are C<Box>, C<Export>, C<List>, C<Table> and C<HTML>. These correspond
to modes of the I<Data::ShowTable> module with the exception of C<Export>:
This is handled by dbimon internally, as I<Data::ShowTable> doesn't
offer such a mode. The C<Export> mode is well suited for exporting data to
other database systems. See L<Data::ShowTable(3)>.

=item less

This is the pager variable. You can turn off paging by setting this
to 'stdout'.

=item listWrapMargin

=item maxTableWidth

=item noEscape

These correspond to the variables C<$List_Wrap_Margin>, C<$Max_Table_Width>
and C<$No_Escape> of the I<Data::ShowTable> module. See L<Data::ShowTable(3)>.

=item escapeChar

=item quoteChar

=item sepChar

For C<Export> mode dbimon will use these variables. Columns are
surrounded by the I<quoteChar>, separated by the I<sepChar> and
the I<escapeChar> is used for inserting these special characters.
The defaults are well suited for Excel (I<escapeChar> = C<">,
I<quoteChar> = C<"> and I<sepChar> = C<;>), thus a row with the
values 1, 'walrus' and 'Nat "King" Cole' will be displayed as

  "1";"walrus";"Nat ""King"" Cole"

=back

=item C<! EXPR>

Eval the EXPR in perl

=back

=head2 Completion

dbimon comes with some basic completion definitions that are far from
being perfect. Completion means, you can use the TAB character to run
some lookup routines on the current dsn or table and use the results
to save a few keystrokes.

The completion mechanism is very basic, and I'm not intending to
refine it in the near future. Feel free to implement your own
refinements and let me know, if you have something better than what we
have here.

=head1 DRIVER REQUIREMENTS

This section is mostly for authors of DBI drivers. If you are interested
in using dbimon only, skip it.

Dbimon should in theory work with any DBI driver. However, DBI is too
restricted for really comfortable work. Thus I decided to use some
very basic possibilities of the DBD::mSQL and DBD::mysql drivers. It
should be easy to add these to any driver and dbimon doesn't depend
on them: All requests for these variables are braced with eval's so
that dbimon can either insert defaults or refuse to execute the
respective commands.

I'll be happy to drop these additional requirements as soon as the
DBI gets extended in an appropriate way and adopt my sources, but
for now, here's what I suggest:

=over 2

=item format_default_size

A statement handle attribute; reference to an array of values, one
for each column. The values contain the actual maximum size of all
values to be distinguished from the theroretical maximum. For example,
if you have a column of type char(64), but the values actually have 30
characters or less, then the value 30 will be supplied by the driver.

The driver is free, not to implement this attribute or to implement
it only for certain columns, but he must supply C<undef> for other
values.

DBD::mysql implements this by reading the max_length attribute of
a result. DBD::mSQL does not offer such an attribute, but it holds
the complete result in memory, so I could easily add the attribute
by scanning all rows. (Perhaps faster than relying on dbimons builtin
possibility.)

The array ref is passed to I<Data::ShowTable::ShowTable> as the
I<widths> attribute.

=item format_max_size

Similar to I<format_default_size>, but this is the theoretical maximum
size. Again, the driver is free not to implement this attribute or
implement it for certain columns only, but he must supply C<undef>
for all other columns.

These values are displayed in the C<relshow database tables> command.

=item format_type_name

Reference to an array of type names; for example DBD::mSQL will insert
the type name C<int> for a column of type I<INT_TYPE>. The driver
should implement this attribute.

This array is passed to I<Data::ShowTable::ShowTable> as the I<types>
argument.

=item C<@list = $dbh-E<gt>func('_ListTables')>

Lists the tables of the dsn corresponding to I<$dbh>.

=item C<$sth = $dbh-E<gt>prepare("LISTFIELDS $table")>

Returns a statement handle describing the fields of a table. This could,
for example, be implemented by a

  SELECT * FROM table WHERE 0 = 1

(Of course I can imagine better solutions ... :-)

=back

=head1 SEE ALSO

You need a readline package installed to get the advantage of a
readline interface. If you don't have it, you won't be able to use the
arrow keys in a meaningful manner. Term::ReadKey and Term::ReadLine do
not come with the perl distribution but are available from CPAN (see
http://www.perl.com/CPAN).

See L<pmsql (1)>, L<DBI (3)>, L<Term::ReadKey (3)>, L<Term::ReadLine (3)>,
__END__
:endofperl
