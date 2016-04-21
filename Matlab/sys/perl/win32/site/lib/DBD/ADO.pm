
{
    package DBD::ADO;

    require DBI;
    require Carp;

    @EXPORT = ();
    $VERSION = substr(q$Revision: 1.10 $, 9,-1) -1;

#   $Id: ADO.pm,v 1.10 1999/05/13 01:44:25 timbo Exp $
#
#   Copyright (c) 1999, Phlip & Tim Bunce
#
#   You may distribute under the terms of either the GNU General Public
#   License or the Artistic License, as specified in the Perl README file.

    $drh = undef;       # holds driver handle once initialised
    $err = 0;           # The $DBI::err value

    sub driver{
        return $drh if $drh;
        my($class, $attr) = @_;
        $class .= "::dr";
        ($drh) = DBI::_new_drh($class, {
            'Name' => 'ADO',
            'Version' => $VERSION,
            'Attribution' => 'DBD ADO for Win32 by Phlip & Tim Bunce',
	});
        return $drh;
    }


    sub errors {
	my $Conn = shift;
	my $err_ary = [];

	my $lastError = Win32::OLE->LastError;
	push @$err_ary, ($lastError+0).": $lastError" if $lastError;

	my $Errors = $Conn->Errors();
	my $err;
	foreach $err (Win32::OLE::in($Errors)) {
	    next if $err->{Number} == 0; # Skip warnings
	    push @$err_ary, "$err->{Number}: $error->{Description}";
	}
	$Errors->Clear;
	return join "\n", @$err_ary;
    }
}


# ADO.pm lexically scoped constants
my $ado_consts;



{   package DBD::ADO::dr; # ====== DRIVER ======
    $imp_data_size = 0;

    sub connect { my ($drh, $dsn, $user, $auth) = @_;

  	require Win32::OLE;

	unless ($ado_consts) {
	    require Win32::OLE::Const;
	    my $name = "Microsoft ActiveX Data Objects 2\\.0 Library";
	    $ado_consts = Win32::OLE::Const->Load($name)
		|| die "Unable to load Win32::OLE::Const ``$name'' ".Win32::OLE->LastError;
	}

	local $Win32::OLE::Warn = 0;
	my $conn = Win32::OLE->new('ADODB.Connection');
       
	my $lastError = Win32::OLE->LastError;
	return DBI::set_err($drh, 1,
		"Can't create 'ADODB.Connection': $lastError")
	    if $lastError;

	##  ODBC rule - Null is not the same as an empty password...
	$auth = '' if !defined $auth;
	$conn->Open ($dsn, $user, $auth);
	$lastError = DBD::ADO::errors($conn);
	return DBI::set_err( $drh, 1, 
		  "Can't connect to '$dsn': $lastError")
	    if $lastError;

	my ($this) = DBI::_new_dbh($drh, {
	    Name => $dsn,
	    User => $user,
	    ado_conn => $conn,
	});

	return $this;
    }

    sub disconnect_all { }
    sub DESTROY { }
}


{   package DBD::ADO::db; # ====== DATABASE ======
    $imp_data_size = 0;
    use strict;

    sub prepare {
	my($dbh, $statement, $attribs) = @_;
	my ($outer, $sth) = DBI::_new_sth($dbh, {
	    'Statement'   => $statement,
	});
	$sth->{ado_conn} = $dbh->{ado_conn};
	$outer;
    }

    sub FETCH {
        my ($dbh, $attrib) = @_;
        # In reality this would interrogate the database engine to
        # either return dynamic values that cannot be precomputed
        # or fetch and cache attribute values too expensive to prefetch.
        return 1 if $attrib eq 'AutoCommit';
        # else pass up to DBI to handle
        return $dbh->DBD::_::db::FETCH($attrib);
    }

    sub STORE {
        my ($dbh, $attrib, $value) = @_;
        # would normally validate and only store known attributes
        # else pass up to DBI to handle
        if ($attrib eq 'AutoCommit') {
            return 1 if $value; # is already set
            croak("Can't disable AutoCommit");
        }
        return $dbh->DBD::_::db::STORE($attrib, $value);
    }

    sub DESTROY { }

}


{   package DBD::ADO::st; # ====== STATEMENT ======
    $imp_data_size = 0;
    use strict;

    use Win32::OLE::Variant;

    sub execute {
	my ($sth) = @_;
	my $conn = $sth->{ado_conn};
	my $sql  = $sth->{Statement};

	my $rows = Variant(VT_I4|VT_BYREF, 0);
	my $rs = $conn->Execute($sql, $rows, $ado_consts->{adCmdText});

	local $Win32::OLE::Warn = 0;
	my $lastError = DBD::ADO::errors($conn);
	return DBI::set_err( $sth, 1, 
		  "Can't execute statement '$sql': $lastError")
	    if $lastError;

	$sth->{ado_rs} = $rs;
	my $NUM_OF_FIELDS = $rs->Fields->Count;

	$sth->trace_msg("$conn->Execute=$rs. NUM_OF_FIELDS=$NUM_OF_FIELDS, rows=$rows\n");

	unless ($NUM_OF_FIELDS > 0) {	# assume non-select statement
	    return $rows;
	}

	$sth->STORE(NUM_OF_FIELDS => $NUM_OF_FIELDS);
	$sth->{ado_first} = $rs->BOF && !$rs->EOF;
	$sth->{NAME} = [ map { $rs->Fields($_)->Name } 0..$NUM_OF_FIELDS-1 ];

	# We need to return any true value for a successful select,
	# but returning $rs might be useful for some (non-portable) ADO applications.
	return $rs;
    }


    sub fetch {			# XXX needs error checking added
	my ($sth) = @_;
	my $rs = $sth->{ado_rs};

	if ($sth->{ado_first}) {
	    $sth->{ado_first} = 0;
	}
	else {
	    $rs->MoveNext if !$rs->EOF;	# check for errors
	}

	if ($rs->EOF) {
	    $sth->finish;
	    $sth->{ado_rs} = undef;
	    return undef;
	}

	my $NUM_OF_FIELDS = $sth->FETCH('NUM_OF_FIELDS');

	my $row = [ map { $rs->Fields($_)->Value } 0..$NUM_OF_FIELDS-1 ];

	return $sth->_set_fbav($row);
    }
    *fetchrow_arrayref = \&fetch;


    sub finish {
        my ($sth) = @_;
        my $rs = $sth->{ado_rs};
	$rs->Close () if $rs and $rs->State & $ado_consts->{adStateOpen};
        $sth->STORE(Active => 0);
	#  undef $sth->{ado_rs};
    }

    sub FETCH {
        my ($sth, $attrib) = @_;
        # would normally validate and only fetch known attributes
        # else pass up to DBI to handle
        return $sth->DBD::_::dr::FETCH($attrib);
    }

    sub STORE {
        my ($sth, $attrib, $value) = @_;
        # would normally validate and only store known attributes
        # else pass up to DBI to handle
        return $sth->DBD::_::dr::STORE($attrib, $value);
    }

    sub DESTROY { }
}

1;
__END__

=head1 NAME

DBD::ADO - A DBI driver for Microsoft ADO (Active Data Objects)

=head1 SYNOPSIS

  use DBI;

  $dbh = DBI->connect("dbi:ADO:dsn", $user, $passwd);

  # See the DBI module documentation for full details

=head1 DESCRIPTION

To be written

=head1 ADO

It is strongly recommended that you use the latest version of ADO
(2.1 at the time this was written). You can download it from:

  http://www.microsoft.com/Data/download.htm

=head1 AUTHORS

Phlip and Tim Bunce. With many thanks to Jan Dubois, Jochen Wiedmann
and Thomas Lowery for debuggery and general help.

=cut

ADO Reference book:  ADO 2.0 Programmer's Reference, David Sussman and
Alex Homer, Wrox, ISBN 1-861001-83-5. If there's anything better please
let me know.

