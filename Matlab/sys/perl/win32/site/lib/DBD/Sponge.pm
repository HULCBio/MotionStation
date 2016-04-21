{
    package DBD::Sponge;

    require DBI;
    require Carp;

    @EXPORT = qw(); # Do NOT @EXPORT anything.
    $VERSION = substr(q$Revision: 10.4 $, 9,-1);

#   $Id: Sponge.pm,v 10.4 1999/05/13 01:44:25 timbo Exp $
#
#   Copyright (c) 1994, Tim Bunce
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file.

    $drh = undef;	# holds driver handle once initialised
    $err = 0;		# The $DBI::err value

    sub driver{
	return $drh if $drh;
	my($class, $attr) = @_;
	$class .= "::dr";
	($drh) = DBI::_new_drh($class, {
	    'Name' => 'Sponge',
	    'Version' => $VERSION,
	    'Attribution' => 'DBD Sponge (fake cursor driver) by Tim Bunce',
	    });
	$drh;
    }

    1;
}


{   package DBD::Sponge::dr; # ====== DRIVER ======
    $imp_data_size = 0;
    # we use default (dummy) connect method
    sub disconnect_all { }
    sub DESTROY { }
}


{   package DBD::Sponge::db; # ====== DATABASE ======
    $imp_data_size = 0;
    use strict;

    sub prepare {
	my($dbh, $statement, $attribs) = @_;
	my $rows = $attribs->{'rows'}
	    || Carp::croak("No rows attribute supplied to prepare");
	delete $attribs->{'rows'};
	my ($outer, $sth) = DBI::_new_sth($dbh, {
	    'Statement'   => $statement,
	    'rows'        => $rows,
	});
	# we need to set NUM_OF_FIELDS
	my $numFields;
	if ($attribs->{'NUM_OF_FIELDS'}) {
	    $numFields = $attribs->{'NUM_OF_FIELDS'};
	} elsif ($attribs->{'NAME'}) {
	    $numFields = @{$attribs->{NAME}};
	} elsif ($attribs->{'TYPE'}) {
	    $numFields = @{$attribs->{TYPE}};
	} elsif (my $firstrow = $rows->[0]) {
	    $numFields = scalar @$firstrow;
	} else {
	    DBI::set_err($dbh, 1, 'Cannot determine NUM_OF_FIELDS');
	    return undef;
	}
	$sth->STORE('NUM_OF_FIELDS' => $numFields);
	$sth->{NAME} = $attribs->{NAME}
		|| [ map { "col$_" } 1..$numFields ];
	$sth->{TYPE} = $attribs->{TYPE}
		|| [ (DBI::SQL_VARCHAR()) x $numFields ];

	$outer;
    }

    sub type_info_all {
	my ($dbh) = @_;
	my $ti = [
	    {	TYPE_NAME	=> 0,
		DATA_TYPE	=> 1,
		PRECISION	=> 2,
		LITERAL_PREFIX	=> 3,
		LITERAL_SUFFIX	=> 4,
		CREATE_PARAMS	=> 5,
		NULLABLE	=> 6,
		CASE_SENSITIVE	=> 7,
		SEARCHABLE	=> 8,
		UNSIGNED_ATTRIBUTE=> 9,
		MONEY		=> 10,
		AUTO_INCREMENT	=> 11,
		LOCAL_TYPE_NAME	=> 12,
		MINIMUM_SCALE	=> 13,
		MAXIMUM_SCALE	=> 14,
	    },
	    [ 'VARCHAR', DBI::SQL_VARCHAR, undef, "'","'", undef, 0, 1, 1, 0, 0,0,undef,0,0 ],
	];
	return $ti;
    }

    sub FETCH {
        my ($dbh, $attrib) = @_;
        # In reality this would interrogate the database engine to
        # either return dynamic values that cannot be precomputed
        # or fetch and cache attribute values too expensive to prefetch.
        return 1 if $attrib eq 'AutoCommit';
        # else pass up to DBI to handle
        return $dbh->SUPER::FETCH($attrib);
    }

    sub STORE {
        my ($dbh, $attrib, $value) = @_;
        # would normally validate and only store known attributes
        # else pass up to DBI to handle
        if ($attrib eq 'AutoCommit') {
            return 1 if $value; # is already set
            croak("Can't disable AutoCommit");
        }
        return $dbh->SUPER::STORE($attrib, $value);
    }

    sub DESTROY { }

}


{   package DBD::Sponge::st; # ====== STATEMENT ======
    $imp_data_size = 0;
    use strict;

    sub execute {
	my ($sth) = @_;
	1;
    }

    sub fetch {
	my ($sth) = @_;
	my $row = shift @{$sth->{'rows'}};
	unless ($row) {
	    $sth->STORE(Active => 0);
	    return undef;
	}
	return $sth->_set_fbav($row);
    }
    *fetchrow_arrayref = \&fetch;

    sub FETCH {
	my ($sth, $attrib) = @_;
	# would normally validate and only fetch known attributes
	# else pass up to DBI to handle
	return $sth->SUPER::FETCH($attrib);
    }

    sub STORE {
	my ($sth, $attrib, $value) = @_;
	# would normally validate and only store known attributes
	# else pass up to DBI to handle
	return $sth->SUPER::STORE($attrib, $value);
    }

    sub DESTROY { }
}

1;
