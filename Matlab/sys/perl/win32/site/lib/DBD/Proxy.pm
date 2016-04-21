#   -*- perl -*-
#
#
#   DBD::Proxy - DBI Proxy driver
#
#
#   Copyright (c) 1997,1998  Jochen Wiedmann
#
#   The DBD::Proxy module is free software; you can redistribute it and/or
#   modify it under the same terms as Perl itself. In particular permission
#   is granted to Tim Bunce for distributing this as a part of the DBI.
#
#
#   Author: Jochen Wiedmann
#           Am Eisteich 9
#           72555 Metzingen
#           Germany
#
#           Email: joe@ispsoft.de
#           Phone: +49 7123 14881
#

use strict;

require DBI;
DBI->require_version(1.0201);

use RPC::PlClient 0.2000;



package DBD::Proxy;

use vars qw($VERSION $err $errstr $drh);


$VERSION = "0.2003";

$err = 0;		# holds error code   for DBI::err
$errstr = "";		# holds error string for DBI::errstr
$drh = undef;		# holds driver handle once initialised


sub driver ($$) {
    if (!$drh) {
	my($class, $attr) = @_;

	$class .= "::dr";

	$drh = DBI::_new_drh($class, {
	    'Name' => 'Proxy',
	    'Version' => $VERSION,
	    'Err'    => \$DBD::Proxy::err,
	    'Errstr' => \$DBD::Proxy::errstr,
	    'Attribution' => 'DBD::Proxy by Jochen Wiedmann',
	    });
    }
    $drh;
}


package DBD::Proxy::dr; # ====== DRIVER ======

$DBD::Proxy::dr::imp_data_size = 0;

sub connect ($$;$$) {
    my($drh, $dsn, $user, $auth)= @_;
    my($dsnOrig) = $dsn;

    my %attr;
    my ($var, $val);
    while (length($dsn)) {
	if ($dsn =~ /^dsn=(.*)/) {
	    $attr{'dsn'} = $1;
	    last;
	}
	if ($dsn =~ /^(.*?);(.*)/) {
	    $var = $1;
	    $dsn = $2;
	} else {
	    $var = $dsn;
	    $dsn = '';
	}
	if ($var =~ /^(.*?)=(.*)/) {
	    $var = $1;
	    $val = $2;
	    $attr{$var} = $val;
	}
    }

    my $err = '';
    if (!defined($attr{'hostname'})) { $err .= " Missing hostname."; }
    if (!defined($attr{'port'}))     { $err .= " Missing port."; }
    if (!defined($attr{'dsn'}))      { $err .= " Missing remote dsn."; }

    # Create a cipher object, if requested
    my $cipherRef = undef;
    if ($attr{'cipher'}) {
	$cipherRef = eval { $attr{'cipher'}->new(pack('H*',
							$attr{'key'})) };
	if ($@) { $err .= " Cannot create cipher object: $@."; }
    }
    my $userCipherRef = undef;
    if ($attr{'userkey'}) {
	my $cipher = $attr{'usercipher'} || $attr{'cipher'};
	$userCipherRef = eval { $cipher->new(pack('H*', $attr{'userkey'})) };
	if ($@) { $err .= " Cannot create usercipher object: $@."; }
    }

    return DBI::set_err($drh, 1, $err) if $err; # Returns undef

    # Create an RPC::PlClient object.
    my($client, $msg) = eval { RPC::PlClient->new(
	'peeraddr'	=> $attr{'hostname'},
	'peerport'	=> $attr{'port'},
	'socket_proto'	=> 'tcp',
	'application'	=> $attr{dsn},
	'user'		=> $user || '',
	'password'	=> $auth || '',
	'version'	=> $DBD::Proxy::VERSION,
	'cipher'	=> $cipherRef,
	'debug'		=> $attr{debug}   || 0,
	'timeout'	=> $attr{timeout} || undef,
	'logfile'	=> $attr{logfile} || undef
    ) };

    return DBI::set_err($drh, 1, "Cannot log in to DBI::ProxyServer: $@")
	if $@; # Returns undef
    return DBI::set_err($drh, 1, "Constructor didn't return a handle: $msg")
	unless ($msg =~ /^((?:\w+|\:\:)+)=(\w+)/); # Returns undef

    $msg = RPC::PlClient::Object->new($1, $client, $msg);

    # Switch to user specific encryption mode, if desired
    if ($userCipherRef) {
	$client->{'cipher'} = $userCipherRef;
    }

    # create a 'blank' dbh
    my $this = DBI::_new_dbh($drh, {
	    'Name' => $dsnOrig,
	    'proxy_dbh' => $msg,
	    'proxy_client' => $client,
	    'RowCacheSize' => $attr{'RowCacheSize'} || 20
   });

    foreach $var (keys %attr) {
	if ($var =~ /proxy_/) {
	    $this->{$var} = $attr{$var};
	}
    }

    $this;
}


sub disconnect_all { }

sub DESTROY { undef }


package DBD::Proxy::db; # ====== DATABASE ======

$DBD::Proxy::db::imp_data_size = 0;

use vars qw(%ATTR $AUTOLOAD);

%ATTR = (
    'Warn' => 'local',
    'Active' => 'local',
    'Kids' => 'local',
    'CachedKids' => 'local',
    'PrintError' => 'local',
    'RaiseError' => 'local',
    'RowCacheSize' => 'inherited'
);

sub AUTOLOAD {
    my $method = $AUTOLOAD;
    print "Autoloading method: $method\n";
    $method =~ s/(.*::(.*)):://;
    my $class = $1;
    my $type = $2;
    my %expand =
	( 'method' => $method,
	  'class' => $class,
	  'type' => $type,
	  'h' => "DBI::_::$type"
	);
    my $method_code = UNIVERSAL::can($expand{'h'}, $method) ?
	q/package ~class~;
          sub ~method~ {
            my $h = shift;
	    my @result = eval { $h->{'proxy_~type~h'}->~method~(@_) };
            return DBI::set_err($h, 1, $@) if $@;
            wantarray ? @result : $result[0];
          }
	 / :
        q/package ~class~;
	  sub ~method~ {
	    my $h = shift;
	    my @result = eval { $h->{'proxy_~type~h'}->func(@_, '~method~') };
	    return DBI::set_err($h, 1, $@) if $@;
	    wantarray ? @result : $result[0];
          }
         /;
    $method_code =~ s/\~(\w+)\~/$expand{$1}/eg;
    print "$method_code\n";
    eval $method_code;
    die $@ if $@;
    goto &$AUTOLOAD;
}

sub DESTROY {
    # Just to avoid that DESTROY is autoloaded ...
}

sub disconnect ($) {
    my($dbh) = @_;
    # XXX this should call $rdbh->disconnect to get the right
    # disconnect behaviour. It should not undef these values.
    # A proxy_no_disconnect option could be added (like for finish)
    # to let people trade safety for speed if they need to.
    undef $dbh->{'proxy_dbh'};    # Bug in Perl 5.004; would prefer delete
    undef $dbh->{'proxy_client'};
    1;
}


sub STORE ($$$) {
    my($dbh, $attr, $val) = @_;
    my $type = $ATTR{$attr} || 'remote';

    if ($attr =~ /^proxy_/  ||  $type eq 'inherited') {
	$dbh->{$attr} = $val;
	return 1;
    }

    if ($type eq 'remote') {
	my $result = eval { $dbh->{'proxy_dbh'}->STORE($attr => $val) };
	return DBI::set_err($dbh, 1, $@) if $@; # returns undef
	return $result;
    }
    return $dbh->SUPER::STORE($attr => $val);
}

sub FETCH ($$) {
    my($dbh, $attr) = @_;
    my $type = $ATTR{$attr} || 'remote';

    if ($attr =~ /^proxy_/  ||  $type eq 'inherited') {
	return $dbh->{$attr};
    }

    return $dbh->SUPER::FETCH($attr) unless $type eq 'remote';

    my $result = eval { $dbh->{'proxy_dbh'}->FETCH($attr) };
    return DBI::set_err($dbh, 1, $@) if $@;
    return $result;
}

sub prepare ($$;$) {
    my($dbh, $stmt, $attr) = @_;

    # We *could* send the statement over the net immediately, but the
    # DBI specs allows us to defer that until the first 'execute'.
    # XXX should make this configurable
    my $sth = DBI::_new_sth($dbh, {
	    'Statement' => $stmt,
	    'proxy_attr' => $attr,
	    'proxy_params' => []
    });
    $sth;
}

sub quote {
    my $dbh = shift;
    my $proxy_quote = $dbh->{proxy_quote} || 'remote';

    return $dbh->SUPER::quote(@_)
	if $proxy_quote eq 'local' && @_ == 1;

    # For the common case of only a single argument
    # (no $data_type) we could learn and cache the behaviour.
    # Or we could probe the driver with a few test cases.
    # Or we could add a way to ask the DBI::ProxyServer
    # if $dbh->can('quote') == \&DBI::_::db::quote.
    # Tim
    #
    # Sounds all *very* smart to me. I'd rather suggest to
    # implement some of the typical quote possibilities
    # and let the user set
    #    $dbh->{'proxy_quote'} = 'backslash_escaped';
    # for example.
    # Jochen

    my $result = eval { $dbh->{'proxy_dbh'}->quote(@_) };
    return DBI::set_err($dbh, 1, $@) if $@;
    return $result;
}

sub table_info {
    my $dbh = shift;
    my $rdbh = $dbh->{'proxy_dbh'};
    my($numFields, $names, $types, @rows) = eval { $rdbh->table_info(@_) };
    my $sth = DBI::_new_sth($dbh, {
        'Statement' => "SHOW TABLES",
	'proxy_params' => [],
	'proxy_data' => \@rows,
	'proxy_attr_cache' => { 'NAME' => $names, 'TYPE' => $types }
    });
    $sth->SUPER::STORE('NUM_OF_FIELDS' => $numFields);
    return $sth;
}

sub type_info_all {
    my $dbh = shift;
    my $result = eval { $dbh->{'proxy_dbh'}->type_info_all(@_) };
    return DBI::set_err($dbh, 1, $@) if $@;
    return $result;
}


package DBD::Proxy::st; # ====== STATEMENT ======

$DBD::Proxy::st::imp_data_size = 0;

use vars qw(%ATTR);

%ATTR = (
    'Warn' => 'local',
    'Active' => 'local',
    'Kids' => 'local',
    'CachedKids' => 'local',
    'PrintError' => 'local',
    'RaiseError' => 'local',
    'RowsInCache' => 'local',
    'RowCacheSize' => 'inherited',
    'NULLABLE' => 'cache_only',
    'NAME' => 'cache_only',
    'TYPE' => 'cache_only',
    'PRECISION' => 'cache_only',
    'SCALE' => 'cache_only',
    'NUM_OF_FIELDS' => 'cache_only',
    'NUM_OF_PARAMS' => 'cache_only'
);

*AUTOLOAD = \&DBD::Proxy::db::AUTOLOAD;

sub execute ($@) {
    my $sth = shift;
    my $params = @_ ? \@_ : $sth->{'proxy_params'};

    undef $sth->{'proxy_data'};

    my $dbh = $sth->{'Database'};
    my $client = $dbh->{'proxy_client'};
    my $rsth = $sth->{proxy_sth};

    my ($numFields, $numParams, $numRows, $names, $types, @outParams);

    if (!$rsth) {
	my $rdbh = $dbh->{'proxy_dbh'};

	($rsth, $numFields, $numParams, $names, $types, $numRows, @outParams) =
	    eval { $rdbh->prepare($sth->{'Statement'},
				  $sth->{'proxy_attr'}, $params) };
	return DBI::set_err($sth, 1, $@) if $@;
	return DBI::set_err($sth, 1,
			    "Constructor didn't return a handle: $rsth")
	    unless ($rsth =~ /^((?:\w+|\:\:)+)=(\w+)/);

	$rsth = RPC::PlClient::Object->new($1, $client, $rsth);

	$sth->{'proxy_sth'} = $rsth;
 	$sth->SUPER::STORE('NUM_OF_FIELDS' => $numFields);
 	$sth->SUPER::STORE('NUM_OF_PARAMS' => $numParams);
    } else {
	my $attrCache = $sth->{'proxy_attr_cache'};
	$numFields = $attrCache->{'NUM_OF_FIELDS'};
	$numParams = $attrCache->{'NUM_OF_PARAMS'};
	$names = $attrCache->{'NAME'};
	$types = $attrCache->{'TYPE'};
	($numRows, @outParams) = eval { $rsth->execute($params) };
	return DBI::set_err($sth, 1, $@) if $@;
    }
    $sth->{'proxy_rows'} = $numRows;
    $sth->{'proxy_attr_cache'} = {
	    'NUM_OF_FIELDS' => $numFields,
	    'NUM_OF_PARAMS' => $numParams,
	    'NAME'          => $names
    };
    $sth->SUPER::STORE('Active' => 1) if $numFields; # is SELECT

    if (@outParams) {
	foreach my $p (@$params) {
	    if (ref($p)  &&  @$p > 2) {
		my $ref = shift @outParams;
		${$p->[0]} = $$ref;
	    }
	}
    }

    $sth->{'proxy_rows'} || '0E0';
}

sub fetch ($) {
    my $sth = shift;

    my $data = $sth->{'proxy_data'};

    if(!$data  ||  !@$data) {
	return undef unless $sth->SUPER::FETCH('Active');

	my $rsth = $sth->{'proxy_sth'};
	if (!$rsth) {
	    die "Attempt to fetch row without execute";
	}
	my $num_rows = $sth->FETCH('RowCacheSize') || 20;
	my @rows = eval { $rsth->fetch($num_rows) };
	return DBI::set_err($sth, 1, $@) if $@;
	unless (@rows == $num_rows) {
	    undef $sth->{'proxy_data'};
	    # server side has already called finish
	    $sth->SUPER::STORE(Active => 0);
	}
	return undef unless @rows;
	$sth->{'proxy_data'} = $data = [@rows];
    }
    my $row = shift @$data;
    return $sth->_set_fbav($row);
}
*fetchrow_arrayref = \&fetch;

sub rows ($) {
    my($sth) = @_;
    $sth->{'proxy_rows'};
}

sub finish ($) {
    my($sth) = @_;
    return 1 unless $sth->SUPER::FETCH('Active');
    my $rsth = $sth->{'proxy_sth'};
    $sth->SUPER::STORE('Active' => 0);
    return 0 unless $rsth; # Something's out of sync
    my $no_finish = exists($sth->{'proxy_no_finish'})
 	? $sth->{'proxy_no_finish'}
	: $sth->{Database}->{'proxy_no_finish'};
    unless ($no_finish) {
	my $result = eval { $rsth->finish() };
	return DBI::set_err($sth, 1, $@) if $@;
	return $result;
    }
    1;
}

sub STORE ($$$) {
    my($sth, $attr, $val) = @_;
    my $type = $ATTR{$attr} || 'remote';

    if ($attr =~ /^proxy_/  ||  $type eq 'inherited') {
	$sth->{$attr} = $val;
	return 1;
    }

    if ($type eq 'cache_only') {
	return 0;
    }

    if ($type eq 'remote') {
	my $rsth = $sth->{'proxy_sth'}  or  return undef;
	my $result = eval { $rsth->STORE($attr => $val) };
	return DBI::set_err($sth, 1, $@) if ($@);
	return $result;
    }
    return $sth->SUPER::STORE($attr => $val);
}

sub FETCH ($$) {
    my($sth, $attr) = @_;

    if ($attr =~ /^proxy_/) {
	return $sth->{$attr};
    }

    my $type = $ATTR{$attr} || 'remote';
    if ($type eq 'inherited') {
	if (exists($sth->{$attr})) {
	    return $sth->{$attr};
	}
	return $sth->{'Database'}->{$attr};
    }

    if ($type eq 'cache_only'  &&
	exists($sth->{'proxy_attr_cache'}->{$attr})) {
	return $sth->{'proxy_attr_cache'}->{$attr};
    }

    if ($type ne 'local') {
	my $rsth = $sth->{'proxy_sth'}  or  return undef;
	my $result = eval { $rsth->FETCH($attr) };
	return DBI::set_err($sth, 1, $@) if $@;
	return $result;
    } elsif ($attr eq 'RowsInCache') {
	my $data = $sth->{'proxy_data'};
	$data ? @$data : 0;
    } else {
	$sth->SUPER::FETCH($attr);
    }
}

sub bind_param ($$$@) {
    my $sth = shift; my $param = shift;
    $sth->{'proxy_params'}->[$param-1] = [@_];
}
*bind_param_inout = \&bind_param;

sub DESTROY {
    # Just to avoid autoloading DESTROY ...
}


1;


__END__

=head1 NAME

DBD::Proxy - A proxy driver for the DBI

=head1 SYNOPSIS

  use DBI;

  $dbh = DBI->connect("dbi:Proxy:hostname=$host;port=$port;dsn=$db",
                      $user, $passwd);

  # See the DBI module documentation for full details

=head1 DESCRIPTION

DBD::Proxy is a Perl module for connecting to a database via a remote
DBI driver.

This is of course not needed for DBI drivers which already
support connecting to a remote database, but there are engines which
don't offer network connectivity.

Another application is offering database access through a firewall, as
the driver offers query based restrictions. For example you can
restrict queries to exactly those that are used in a given CGI
application.

Speaking of CGI, another application is (or rather, will be) to reduce
the database connect/disconnect overhead from CGI scripts by using
proxying the connect_cached method. The proxy server will hold the
database connections open in a cache. The CGI script then trades the
database connect/disconnect overhead for the DBD::Proxy
connect/disconnect overhead which is typically much less.
I<Note that the connect_cached method is new and still experimental.>


=head1 CONNECTING TO THE DATABASE

Before connecting to a remote database, you must ensure, that a Proxy
server is running on the remote machine. There's no default port, so
you have to ask your system administrator for the port number. See
L<DBI::ProxyServer(3)> for details.

Say, your Proxy server is running on machine "alpha", port 3334, and
you'd like to connect to an ODBC database called "mydb" as user "joe"
with password "hello". When using DBD::ODBC directly, you'd do a

  $dbh = DBI->connect("DBI:ODBC:mydb", "joe", "hello");

With DBD::Proxy this becomes

  $dsn = "DBI:Proxy:hostname=alpha;port=3334;dsn=DBI:ODBC:mydb";
  $dbh = DBI->connect($dsn, "joe", "hello");

You see, this is mainly the same. The DBD::Proxy module will create a
connection to the Proxy server on "alpha" which in turn will connect
to the ODBC database.

Refer to the L<DBI(3)> documentation on the C<connect> method for a way
to automatically use DBD::Proxy without having to change your code.

DBD::Proxy's DSN string has the format

  $dsn = "DBI:Proxy:key1=val1; ... ;keyN=valN;dsn=valDSN";

In other words, it is a collection of key/value pairs. The following
keys are recognized:

=over 4

=item hostname

=item port

Hostname and port of the Proxy server; these keys must be present,
no defaults. Example:

    hostname=alpha;port=3334

=item dsn

The value of this attribute will be used as a dsn name by the Proxy
server. Thus it must have the format C<DBI:driver:...>, in particular
it will contain colons. The I<dsn> value may contain semicolons, hence
this key *must* be the last and it's value will be the complete
remaining part of the dsn. Example:

    dsn=DBI:ODBC:mydb

=item cipher

=item key

=item usercipher

=item userkey

By using these fields you can enable encryption. If you set,
for example,

    cipher=$class:key=$key

then DBD::Proxy will create a new cipher object by executing

    $cipherRef = $class->new(pack("H*", $key));

and pass this object to the RPC::PlClient module when creating a
client. See L<RPC::PlClient(3)>. Example:

    cipher=IDEA:key=97cd2375efa329aceef2098babdc9721

The usercipher/userkey attributes allow you to use two phase encryption:
The cipher/key encryption will be used in the login and authorisation
phase. Once the client is authorised, he will change to usercipher/userkey
encryption. Thus the cipher/key pair is a B<host> based secret, typically
less secure than the usercipher/userkey secret and readable by anyone.
The usercipher/userkey secret is B<your> private secret.

Of course encryption requires an appropriately configured server. See
<DBD::ProxyServer(3)/CONFIGURATION FILE>.

=item debug

Turn on debugging mode

=item stderr

This attribute will set the corresponding attribute of the RPC::PlClient
object, thus logging will not use syslog(), but redirected to stderr.
This is the default under Windows.

    stderr=1

=item logfile

Similar to the stderr attribute, but output will be redirected to the
given file.

    logfile=/dev/null

=item RowCacheSize

The DBD::Proxy driver supports this attribute (which is DBI standard,
as of DBI 1.02). It's used to reduce network round-trips by fetching
multiple rows in one go. The current default value is 20, but this may
change.


=item proxy_no_finish

This attribute can be used to reduce network traffic: If the
application is calling $sth->finish() then the proxy tells the server
to finish the remote statement handle. Of course this slows down things
quite a lot, but is prefectly good for reducing memory usage with
persistent connections.

However, if you set the I<proxy_no_finish> attribute to a TRUE value,
either in the database handle or in the statement handle, then finish()
calls will be supressed. This is what you want, for example, in small
and fast CGI applications.

=item proxy_quote

This attribute can be used to reduce network traffic: By default calls
to $dbh->quote() are passed to the remote driver.  Of course this slows
down things quite a lot, but is the safest default behaviour.
  
However, if you set the I<proxy_quote> attribute to the value 'C<local>'
either in the database handle or in the statement handle, and the call
to quote has only one parameter, then the local default DBI quote
method will be used (which will be faster but may be wrong).

=back


=head1 AUTHOR AND COPYRIGHT

This module is Copyright (c) 1997, 1998

    Jochen Wiedmann
    Am Eisteich 9
    72555 Metzingen
    Germany

    Email: joe@ispsoft.de
    Phone: +49 7123 14887

The DBD::Proxy module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. In particular permission
is granted to Tim Bunce for distributing this as a part of the DBI.


=head1 SEE ALSO

L<DBI(3)>, L<RPC::PlClient(3)>, L<Storable(3)>

=cut
