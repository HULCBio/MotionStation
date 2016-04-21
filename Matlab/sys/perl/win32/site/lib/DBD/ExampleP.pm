{
    package DBD::ExampleP;

    use DBI qw(:sql_types);

    @EXPORT = qw(); # Do NOT @EXPORT anything.
    $VERSION = substr(q$Revision: 10.6 $, 9,-1) -1;

#   $Id: ExampleP.pm,v 10.6 1999/05/13 01:44:25 timbo Exp $
#
#   Copyright (c) 1994,1997,1998 Tim Bunce
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file.

    @statnames = qw(dev ino mode nlink
	uid gid rdev size
	atime mtime ctime
	blksize blocks name);
    @statnames{@statnames} = (0 .. @statnames-1);

    @stattypes = (SQL_INTEGER, SQL_INTEGER, SQL_INTEGER, SQL_INTEGER,
	SQL_INTEGER, SQL_INTEGER, SQL_INTEGER, SQL_INTEGER,
	SQL_INTEGER, SQL_INTEGER, SQL_INTEGER,
	SQL_INTEGER, SQL_INTEGER, SQL_VARCHAR);
    @stattypes{@statnames} = @stattypes;

    $drh = undef;	# holds driver handle once initialised
    $err = 0;		# The $DBI::err value
    $gensym = "SYM000"; # used by st::execute() for filehandles

    sub driver{
	return $drh if $drh;
	my($class, $attr) = @_;
	$class .= "::dr";
	($drh) = DBI::_new_drh($class, {
	    'Name' => 'ExampleP',
	    'Version' => $VERSION,
	    'Attribution' => 'DBD Example Perl stub by Tim Bunce',
	    }, ['example implementors private data']);
	$drh;
    }

}


{   package DBD::ExampleP::dr; # ====== DRIVER ======
    $imp_data_size = 0;
    use strict;

    sub connect { # normally overridden, but a handy default
        my($drh, $dbname, $user, $auth)= @_;
        my($this) = DBI::_new_dbh($drh, {
	    'Name' => $dbname,
	    'User' => $user,
	    });
		$this->STORE(Active => 1);
        $this;
    }

    sub data_sources {
	return ("dbi:ExampleP:dir=.");	# possibly usefully meaningless
    }

    sub disconnect_all {
	# we don't need to tidy up anything
    }
    sub DESTROY { undef }
}


{   package DBD::ExampleP::db; # ====== DATABASE ======
    $imp_data_size = 0;
    use strict;

    sub prepare {
	my($dbh, $statement)= @_;

	my($fields, $param)
		= $statement =~ m/^select\s+(.*?)\s+from\s+(\S*)/i;
	return $dbh->DBI::set_err(1, "Syntax error in select statement")
		unless defined $fields and defined $param;

	my @fields = ($fields eq '*')
			? keys %DBD::ExampleP::statnames
			: split(/\s*,\s*/, $fields);

	my @bad = map {
	    defined $DBD::ExampleP::statnames{$_} ? () : $_
	} @fields;
	return $dbh->DBI::set_err(1, "Unknown field names: @bad")
		if @bad;

	my ($outer, $sth) = DBI::_new_sth($dbh, {
	    'Statement'     => $statement,
	}, ['example implementors private data']);

	$sth->{'dbd_param'}->[1] = $param if $param !~ /\?/;

	$outer->STORE('NAME' => \@fields);
	$outer->STORE('NULLABLE' => [ (0) x @fields ]);
	$outer->STORE('NUM_OF_FIELDS' => scalar(@fields));
	$outer->STORE('NUM_OF_PARAMS' => ($param !~ /\?/) ? 0 : 1);

	$outer;
    }

    sub table_info {
	my $dbh = shift;

	# Return a list of all subdirectories
	my $dh = "DBD::ExampleP::".++$DBD::ExampleP::gensym;
	my $haveFileSpec = eval { require File::Spec };
	my $dir = $haveFileSpec ? File::Spec->curdir() : ".";
	my @list;
	{
	    no strict 'refs';
	    opendir($dh, $dir)
		or return $dbh->DBI::set_err(int($!),
					"Failed to open directory $dir: $!");
	    while (defined(my $file = readdir($dh))) {
		next unless -d $file;
		my($dev, $ino, $mode, $nlink, $uid) = stat(_);
		my $pwnam = undef; # eval { scalar(getpwnam($uid)) } || $uid;
		push(@list, [ $dir, $pwnam, $file, 'TABLE']);
	    }
	    close($dh);
	}
	# We would like to simply do a DBI->connect() here. However,
	# this is wrong if we are in a subclass like DBI::ProxyServer.
	$dbh->{'dbd_sponge_dbh'} ||= DBI->connect("DBI:Sponge:")
	    or return $dbh->DBI::set_err($DBI::err,
				    "Failed to connect to DBI::Sponge: "
				    . $DBI::errstr);

	my $attr =
	    {'rows' => \@list,
	     'NUM_OF_FIELDS' => 4,
	     'NAME' => ['TABLE_QUALIFIER', 'TABLE_OWNER', 'TABLE_NAME',
			'TABLE_TYPE'],
	     'TYPE' => [DBI::SQL_VARCHAR(), DBI::SQL_VARCHAR(),
			DBI::SQL_VARCHAR(), DBI::SQL_VARCHAR()],
	     'NULLABLE' => [1, 1, 1, 1]
	    };
	my $sdbh = $dbh->{'dbd_sponge_dbh'};
	my $sth = $sdbh->prepare("SHOW TABLES FROM $dir", $attr)
	    or return $dbh->DBI::set_err($sdbh->err(), $sdbh->errstr());
	$sth;
    }

    sub type_info_all {
	my ($dbh) = @_;
	my $ti = [
	    {	TYPE_NAME	=> 0,
		DATA_TYPE	=> 1,
		COLUMN_SIZE	=> 2,
		LITERAL_PREFIX	=> 3,
		LITERAL_SUFFIX	=> 4,
		CREATE_PARAMS	=> 5,
		NULLABLE	=> 6,
		CASE_SENSITIVE	=> 7,
		SEARCHABLE	=> 8,
		UNSIGNED_ATTRIBUTE=> 9,
		FIXED_PREC_SCALE=> 10,
		AUTO_UNIQUE_VALUE => 11,
		LOCAL_TYPE_NAME	=> 12,
		MINIMUM_SCALE	=> 13,
		MAXIMUM_SCALE	=> 14,
	    },
	    [ 'VARCHAR', DBI::SQL_VARCHAR, 1024, "'","'", undef, 0, 1, 1, 0, 0,0,undef,0,0 ],
	    [ 'INTEGER', DBI::SQL_INTEGER,   10, "","",   undef, 0, 0, 1, 0, 0,0,undef,0,0 ],
	];
	return $ti;
    }


    sub disconnect {
	shift->STORE(Active => 0);
	return 1;
    }

    sub FETCH {
	my ($dbh, $attrib) = @_;
	# In reality this would interrogate the database engine to
	# either return dynamic values that cannot be precomputed
	# or fetch and cache attribute values too expensive to prefetch.
	return 1                         if $attrib eq 'AutoCommit';
	# else pass up to DBI to handle
	return $dbh->SUPER::FETCH($attrib);
    }

    sub STORE {
	my ($dbh, $attrib, $value) = @_;
	# would normally validate and only store known attributes
	# else pass up to DBI to handle
	if ($attrib eq 'AutoCommit') {
	    return 1 if $value;	# is already set
	    Carp::croak("Can't disable AutoCommit");
	}
	return $dbh->SUPER::STORE($attrib, $value);
    }
    sub DESTROY {
	my $dbh = shift;
	$dbh->disconnect if $dbh->FETCH('Active');
	undef
    }

    # This is an example to demonstrate the use of driver-specific
    # methods via $dbh->func().
    #
    # Use it as follows:
    #
    #   my @tables = $dbh->func($re, 'examplep_tables');
    #
    # Returns all the tables that match the regular expression $re.
    sub examplep_tables {
	my $dbh = shift; my $re = shift;
	grep { $_ =~ /$re/ } $dbh->tables();
    }
}


{   package DBD::ExampleP::st; # ====== STATEMENT ======
    $imp_data_size = 0;
    use strict; no strict 'refs'; # cause problems with filehandles

    sub bind_param {
	my($sth, $param, $value, $attribs) = @_;
	$sth->{'dbd_param'}->[$param] = $value;
    }

    sub execute {
	my($sth, @dir) = @_;
	my $dir;
	if (@dir) {
	    $dir = $dir[0];
	} else {
	    $dir = $sth->{'dbd_param'}->[1];
	    unless (defined $dir) {
		$sth->DBI::set_err(2, "No bind parameter supplied");
		return undef;
	    }
	}
	$sth->finish;
	$sth->{dbd_datahandle} = "DBD::ExampleP::".++$DBD::ExampleP::gensym;
	#
	# If the users asks for directory "long_list_4532", then we fake a
	# directory with files "file4351", "file4350", ..., "file0".
	#
	if ($dir =~ /^long_list_\d+$/) {
	    $sth->{dbd_datahandle} = $dir;
	} else {
	    opendir($sth->{dbd_datahandle}, $dir)
		or return $sth->DBI::set_err(2, "opendir($dir): $!");
	    $sth->{dbd_dir} = $dir;
	}
	1;
    }

    sub fetch {
	my $sth = shift;
	my $dh = $sth->{dbd_datahandle};

	my %s; # fancy a slice of a hash?
	if ($dh =~ /^long_list_(\d+)$/) {
	    my $num = $1;
	    unless ($num) {
		$sth->finish();
		return;
	    }
	    $sth->{dbd_datahandle} = "long_list_" . --$num;
	    my $time = time;
	    @s{@DBD::ExampleP::statnames} =
		( 2051,      # dev
		  1000+$num, # ino
		  0644,      # mode
		  2,         # nlink
		  $>,        # uid
		  $),        # gid
		  0,         # rdev
		  1024,      # size
	          $time,     # atime
	          $time,     # mtime
	          $time,     # ctime
		  512,       # blksize
		  2,         # blocks
		  "file$num" # name
		)
	} else {
	    my $f = readdir($dh);
	    unless($f){
		$sth->finish;     # no more data so finish
		return;
	    }
	    # put in all the data fields
	    @s{@DBD::ExampleP::statnames} =
		(stat("$sth->{'dbd_dir'}/$f"), $f);
	}

	# return just what fields the query asks for
	my @new = @s{ @{$sth->{NAME}} };

	#my $row = $sth->_get_fbav;
	#@$row =  @new;
	#$row->[0] = $new[0]; $row->[1] = $new[1]; $row->[2] = $new[2];
	return $sth->_set_fbav(\@new);
    }
    *fetchrow_arrayref = \&fetch;

    sub finish {
	my $sth = shift;
	return undef unless $sth->{dbd_datahandle};
	closedir($sth->{dbd_datahandle});
	$sth->{dbd_datahandle} = undef;
	return 1;
    }

    sub FETCH {
	my ($sth, $attrib) = @_;
	# In reality this would interrogate the database engine to
	# either return dynamic values that cannot be precomputed
	# or fetch and cache attribute values too expensive to prefetch.
	if ($attrib eq 'TYPE'){
	    my @t = @DBD::ExampleP::stattypes{@{$sth->{NAME}}};
	    return \@t;
	}
	# else pass up to DBI to handle
	return $sth->SUPER::FETCH($attrib);
    }

    sub STORE {
	my ($sth, $attrib, $value) = @_;
	# would normally validate and only store known attributes
	# else pass up to DBI to handle
	return $sth->{$attrib}=$value
	    if $attrib eq 'NAME' or $attrib eq 'NULLABLE';
	return $sth->SUPER::STORE($attrib, $value);
    }

    sub DESTROY { undef }
}

1;
