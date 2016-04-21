# $Id: DBI.pm,v 10.14 1999/05/13 01:44:25 timbo Exp $
#
# Copyright (c) 1994,1995,1996,1997,1998  Tim Bunce  England
#
# See COPYRIGHT section in pod text below for usage and distribution rights.
#

require 5.003;

BEGIN {
$DBI::VERSION = 1.08; # ==> ALSO update the version in the pod text below!
}

=head1 NAME

DBI - Database independent interface for Perl

=head1 SYNOPSIS

  use DBI;
 
  @driver_names = DBI->available_drivers;
  @data_sources = DBI->data_sources($driver_name);

  $dbh = DBI->connect($data_source, $username, $auth);
  $dbh = DBI->connect($data_source, $username, $auth, \%attr);
 
  $rv  = $dbh->do($statement);
  $rv  = $dbh->do($statement, \%attr);
  $rv  = $dbh->do($statement, \%attr, @bind_values);

  @row_ary = $dbh->selectrow_array($statement);
  $ary_ref = $dbh->selectall_arrayref($statement);
 
  $sth = $dbh->prepare($statement);
  $sth = $dbh->prepare_cached($statement);
 
  $rv = $sth->bind_param($p_num, $bind_value);
  $rv = $sth->bind_param($p_num, $bind_value, $bind_type);
  $rv = $sth->bind_param($p_num, $bind_value, \%attr);

  $rv = $sth->execute;
  $rv = $sth->execute(@bind_values);
 
  $rc = $sth->bind_col($col_num, \$col_variable);
  $rc = $sth->bind_columns(\%attr, @list_of_refs_to_vars_to_bind);

  @row_ary  = $sth->fetchrow_array;
  $ary_ref  = $sth->fetchrow_arrayref;
  $hash_ref = $sth->fetchrow_hashref;
 
  $ary_ref  = $sth->fetchall_arrayref;

  $rv = $sth->rows;
 
  $rc  = $dbh->commit;
  $rc  = $dbh->rollback;

  $sql = $dbh->quote($string);
 
  $rc  = $h->err;
  $str = $h->errstr;
  $rv  = $h->state;

  $rc  = $dbh->disconnect;
 

=head2 NOTE

This is the DBI specification that corresponds to the DBI version 1.08
($Date: 1999/05/13 01:44:25 $).

The DBI specification is currently evolving quite quickly so it is
important to check that you have the latest copy. The RECENT CHANGES
section below has a summary of user-visible changes and the F<Changes>
file supplied with the DBI holds more detailed change information.

Note also that whenever the DBI changes the drivers take some time to
catch up. Recent versions of the DBI have added many new features
(marked *NEW* in the text) that may not yet be supported by the drivers
you use. Talk to the authors of those drivers if you need the features.

Please also read the DBI FAQ which is installed as a DBI::FAQ module so
you can use perldoc to read it by executing the C<perldoc DBI::FAQ> command.

Extensions to the DBI and other DBI related modules use the C<DBIx::*>
namespace. See L</Naming Conventions and Name Space> and:

  http://www.perl.com/CPAN/modules/by-module/DBIx/

=head2 RECENT CHANGES 

A brief summary of significant user-visible changes in recent versions
(if a recent version isn't mentioned it simply means that there were no
significant user-visible changes in that version).

=over 4 

=item DBI 1.00 - 14th August 1998

Added $dbh->table_info.

=back 

=cut

# The POD text continues at the end of the file.

# DBI file-private variables
my %installed_rootclass;


{
package DBI;

my $Revision = substr(q$Revision: 10.14 $, 10);


use Carp;
use DynaLoader ();
use Exporter ();

BEGIN {
@ISA = qw(Exporter DynaLoader);

# Make some utility functions available if asked for
@EXPORT    = ();		# we export nothing by default
@EXPORT_OK = ('%DBI');	# populated by export_ok_tags:
%EXPORT_TAGS = (
   sql_types => [ qw(
    SQL_ALL_TYPES
	SQL_CHAR SQL_NUMERIC SQL_DECIMAL SQL_INTEGER SQL_SMALLINT
	SQL_FLOAT SQL_REAL SQL_DOUBLE SQL_VARCHAR
	SQL_DATE SQL_TIME SQL_TIMESTAMP
	SQL_LONGVARCHAR SQL_BINARY SQL_VARBINARY SQL_LONGVARBINARY
	SQL_BIGINT SQL_TINYINT
   ) ],
   utils     => [ qw(
	neat neat_list dump_results looks_like_number
   ) ],
);
Exporter::export_ok_tags('sql_types', 'utils');

$DBI::dbi_debug = $ENV{DBI_TRACE} || $ENV{PERL_DBI_DEBUG} || 0;

# If you get an error here like "Can't find loadable object ..."
# then you haven't installed the DBI correctly. Read the README
# then install it again.
bootstrap DBI;
}

use strict;

my $connect_via = "connect";

# check if user wants a persistent database connection ( Apache + mod_perl )
if (substr($ENV{GATEWAY_INTERFACE}||'',0,8) eq 'CGI-Perl' and $INC{'Apache/DBI.pm'}) {
    $connect_via = "Apache::DBI::connect";
    DBI->trace_msg("DBI connect via $INC{'Apache/DBI.pm'}\n") if $DBI::dbi_debug;
}


if ($DBI::dbi_debug) {
    # this is a bit of a handy hack for "DBI_TRACE=/tmp/dbi.log"
    if ($DBI::dbi_debug =~ m/^\d$/) {
	# dbi_debug is number so debug to stderr at that level
	DBI->trace($DBI::dbi_debug);
    }
    else {
	# dbi_debug is a file name to write trace log to.
	# Default level is 2 but if file starts with "digits=" then the
	# digits (and equals) are stripped off and used as the level
	my $level = 2;
	$level = $1 if $DBI::dbi_debug =~ s/^(\d+)=//;
	DBI->trace($level, $DBI::dbi_debug);
    }
}

%DBI::installed_drh = ();  # maps driver names to installed driver handles


# Setup special DBI dynamic variables. See DBI::var::FETCH for details.
# These are dynamically associated with the last handle used.
tie $DBI::err,    'DBI::var', '*err';    # special case: referenced via IHA list
tie $DBI::state,  'DBI::var', '"state';  # special case: referenced via IHA list
tie $DBI::lasth,  'DBI::var', '!lasth';  # special case: return boolean
tie $DBI::errstr, 'DBI::var', '&errstr'; # call &errstr in last used pkg
tie $DBI::rows,   'DBI::var', '&rows';   # call &rows   in last used pkg
sub DBI::var::TIESCALAR{ my $var = $_[1]; bless \$var, 'DBI::var'; }
sub DBI::var::STORE    { Carp::croak("Can't modify \$DBI::${$_[0]} special variable") }
sub DBI::var::DESTROY  { }

{   package DBI::DBI_tie;	# used to catch DBI->{Attrib} mistake
    sub TIEHASH { bless {} }
    sub STORE   { Carp::carp("DBI->{$_[1]} is invalid syntax (you probably want \$h->{$_[1]})");}
    *FETCH = \&STORE;
}
tie %DBI::DBI => 'DBI::DBI_tie';


# --- Dynamically create the DBI Standard Interface

my $std = undef;
my $keeperr = { O=>0x04 };

my @TieHash_IF = (	# Generic Tied Hash Interface
	'STORE'   => { O=>0x10 },
	'FETCH'   => $keeperr,
	'FIRSTKEY'=> $keeperr,
	'NEXTKEY' => $keeperr,
	'EXISTS'  => $keeperr,
	'CLEAR'   => $keeperr,
	'DESTROY' => undef,	# hardwired internally
);
my @Common_IF = (	# Interface functions common to all DBI classes
	func    =>	{				O=>0x06	},
	event   =>	{ U =>[2,0,'$type, @args'],	O=>0x04 },
	'trace' =>	{ U =>[1,3,'[$trace_level, [$filename]]'],	O=>0x04 },
	trace_msg =>	{ U =>[2,2,'$message_text'],	O=>0x04 },
	debug   =>	{ U =>[1,2,'[$debug_level]'],	O=>0x04 }, # old name for trace
	private_data =>	{ U =>[1,1],			O=>0x04 },
	err     =>	$keeperr,
	errstr  =>	$keeperr,
	state   =>	{ U =>[1,1], O=>0x04 },
	_not_impl => $std,
);

my %DBI_IF = (	# Define the DBI Interface:

    dr => {		# Database Driver Interface
	@Common_IF,
	@TieHash_IF,
	'connect'  =>	{ U =>[1,5,'[$db [,$user [,$passwd [,\%attr]]]]'] },
	'connect_cached'=>{U=>[1,5,'[$db [,$user [,$passwd [,\%attr]]]]'] },
	'disconnect_all'=>{ U =>[1,1] },
	data_sources => { U =>[1,2,'[\%attr]' ] },
    },
    db => {		# Database Session Class Interface
	@Common_IF,
	@TieHash_IF,
	commit     	=> { U =>[1,1] },
	rollback   	=> { U =>[1,1] },
	'do'       	=> { U =>[2,0,'$statement [, \%attr [, @bind_params ] ]'] },
	prepare    	=> { U =>[2,3,'$statement [, \%attr]'] },
	prepare_cached	=> { U =>[2,3,'$statement [, \%attr]'] },
	selectrow_array	=> { U =>[2,0,'$statement [, \%attr [, @bind_params ] ]'] },
	selectall_arrayref=>{U =>[2,0,'$statement [, \%attr [, @bind_params ] ]'] },
	handler    	=> { U =>[2,2,'\&handler'] },
	ping       	=> { U =>[1,1] },
	disconnect 	=> { U =>[1,1] },
	quote      	=> { U =>[2,3, '$string [, $data_type ]' ], O=>0x30 },
	rows       	=> $keeperr,

	tables     	=> { U =>[1,1] },
	table_info     	=> { U =>[1,1] },
	type_info_all	=> { U =>[1,1] },
	type_info	=> { U =>[1,2] },
	get_info	=> { U =>[2,2] },
    },
    st => {		# Statement Class Interface
	@Common_IF,
	@TieHash_IF,
	bind_col	=> { U =>[3,4,'$column, \\$var [, \%attr]'] },
	bind_columns	=> { U =>[3,0,'\%attr, \\$var1 [, \\$var2, ...]'] },
	bind_param	=> { U =>[3,4,'$parameter, $var [, \%attr]'] },
	bind_param_inout=> { U =>[4,5,'$parameter, \\$var, $maxlen, [, \%attr]'] },
	execute		=> { U =>[1,0,'[@args]'] },

	fetch    	  => undef, # alias for fetchrow_arrayref
	fetchrow_arrayref => undef,
	fetchrow_hashref  => undef,
	fetchrow_array    => undef,
	fetchrow   	  => undef, # old alias for fetchrow_array

	fetchall_arrayref => { U =>[1,2] },

	blob_read  =>	{ U =>[4,5,'$field, $offset, $len [, \\$buf [, $bufoffset]]'] },
	blob_copy_to_file => { U =>[3,3,'$field, $filename_or_handleref'] },
	dump_results => { U =>[1,5,'$maxfieldlen, $linesep, $fieldsep, $filehandle'] },
	more_results => { U =>[1,1] },
	finish     => 	{ U =>[1,1] },
	cancel     => 	{ U =>[1,1] },
	rows       =>	$keeperr,

	_get_fbav	=> undef,
	_set_fbav	=> undef,
    },
);

my($class, $method);
foreach $class (keys %DBI_IF){
    my %pkgif = %{$DBI_IF{$class}};
    foreach $method (keys %pkgif){
	DBI->_install_method("DBI::${class}::$method", 'DBI.pm',
			$pkgif{$method});
    }
}

# End of init code


END {
    DBI->trace_msg("    -> DBI::END\n") if $DBI::dbi_debug >= 2;
    # Let drivers know why we are calling disconnect_all:
    $DBI::PERL_ENDING = $DBI::PERL_ENDING = 1;	# avoid typo warning
    DBI->disconnect_all() if %DBI::installed_drh;
    DBI->trace_msg("    <- DBI::END complete\n") if $DBI::dbi_debug >= 2;
}



# --- The DBI->connect Front Door methods

sub connect_cached {
    # If using Apache::DBI then keep using it
    # XXX This logic may need reworking at some point
    my $meth = ($connect_via eq "connect") ? "connect_cached" : $connect_via;
    return shift->connect(@_[0..4], $meth);
}

sub connect {
    my $class = shift;
    my($dsn, $user, $pass, $attr, $old_driver, $connect_meth) = @_;
    $connect_meth ||= $connect_via; # $connect_meth not user visible
    my $driver;
    my $dbh;

    # switch $old_driver<->$attr if called in old style
    ($old_driver, $attr) = ($attr, $old_driver) if $attr and !ref($attr);

    $dsn ||= $ENV{DBI_DSN} || $ENV{DBI_DBNAME} || '' unless $old_driver;
    $user = $ENV{DBI_USER} unless defined $user;
    $pass = $ENV{DBI_PASS} unless defined $pass;


    if ($DBI::dbi_debug) {
	local $^W = 0;
	pop @_ if $connect_meth ne 'connect';
	DBI->trace_msg("    -> $class->$connect_meth(".join(", ",@_).")\n");
    }
    Carp::croak('Usage: $class->connect([$dsn [,$user [,$passwd [,\%attr]]]])')
	if (ref $old_driver or ($attr and not ref $attr) or ref $pass);

    # extract dbi:driver prefix from $dsn into $1
    $dsn =~ s/^dbi:(\w*?)(?:\((.*?)\))?://i
			or '' =~ /()/; # ensure $1 etc are empty if match fails
    my $driver_attrib_spec = $2;

    # Set $driver. Old style driver, if specified, overrides new dsn style.
    $driver = $old_driver || $1 || $ENV{DBI_DRIVER}
	or Carp::croak("Can't connect(@_), no database driver specified");

    if ($ENV{DBI_AUTOPROXY} && $driver ne 'Proxy' && $driver ne 'Switch') {
	$dsn = "$ENV{DBI_AUTOPROXY};dsn=dbi:$driver:$dsn";
	$driver = 'Proxy';
	DBI->trace_msg("       DBI_AUTOPROXY: dbi:$driver:$dsn\n");
    }

    unless ($old_driver) { # new-style connect so new default semantics
	$driver_attrib_spec = { split /\s*=>?\s*|\s*,\s*/, $driver_attrib_spec }
	    if $driver_attrib_spec;
	$attr = {
	    PrintError=>1, AutoCommit=>1,
	    ref $attr ? %$attr : (),
	    ref $driver_attrib_spec ? %$driver_attrib_spec : (),
	};
	# XXX to be enabled for DBI v2.0
	#Carp::carp("AutoCommit attribute not specified in DBI->connect")
	#    if $^W && !defined($attr->{AutoCommit});
    }

    my $drh = $class->install_driver($driver) || die "panic: install_driver($driver) failed";

    unless ($dbh = $drh->$connect_meth($dsn, $user, $pass, $attr)) {
	my $msg = "$class->connect failed: ".$drh->errstr;
	if (ref $attr) {
	    Carp::croak($msg) if $attr->{RaiseError};
	    Carp::carp ($msg) if $attr->{PrintError};
	}
	DBI->trace_msg("       $msg\n");
	$! = 0; # for the daft people who do DBI->connect(...) || die "$!";
	return undef;
    }

    # XXX this is inelegant but practical in the short term, sigh.
    if ($installed_rootclass{$class}) {
	$dbh->{RootClass} = $class;
	bless $dbh => $class.'::db';
	my ($outer, $inner) = DBI::_handles($dbh);
	bless $inner => $class.'::db';
    }

    if (ref $attr) {
	my %a = %$attr;
	my $a;
	# handle these attributes first
	foreach $a (qw(RaiseError PrintError AutoCommit)) {
	    next unless exists $a{$a};
	    $dbh->{$a} = $a{$a};
	    delete $a{$a};
	}
	foreach $a (keys %a) {
	    $dbh->{$a} = $a{$a};
	}
    }
    DBI->trace_msg("    <- connect= $dbh\n") if $DBI::dbi_debug;

    $dbh;
}


sub disconnect_all {
    foreach(keys %DBI::installed_drh){
	my $drh = $DBI::installed_drh{$_};
	next unless ref $drh;	# avoid problems on premature death
	$drh->disconnect_all();
    }
}


sub install_driver {		# croaks on failure
    my $class = shift;
    my($driver, $attr) = @_;
    my $drh;

    $driver ||= $ENV{DBI_DRIVER} || '';

    # allow driver to be specified as a 'dbi:driver:' string
    $driver = $1 if $driver =~ s/^DBI:(.*?)://i;

    Carp::croak("usage: $class->install_driver(\$driver [, \%attr])")
		unless ($driver and @_<=3);

    # already installed
    return $drh if $drh = $DBI::installed_drh{$driver};

    DBI->trace_msg("    -> $class->install_driver($driver"
			.") for perl=$] pid=$$ ruid=$< euid=$>\n")
	if $DBI::dbi_debug;

    # --- load the code
    my $driver_class = "DBD::$driver";
    eval "package DBI::_firesafe; require $driver_class";
    if ($@) {
	my $err = $@;
	my $advice = "";
	if ($err =~ /Can't find loadable object/) {
	    $advice = "Perhaps DBD::$driver was statically linked into a new perl binary."
		 ."\nIn which case you need to use that new perl binary."
		 ."\nOr perhaps only the .pm file was installed but not the shared object file."
	}
	elsif ($err =~ /Can't locate.*?DBD\/$driver\.pm in \@INC/) {
	    my @drv = DBI->available_drivers(1);
	    $advice = "Perhaps the DBD::$driver perl module hasn't been fully installed,\n"
		     ."or perhaps the capitalisation of '$driver' isn't right.\n"
		     ."Available drivers: ".join(", ", @drv).".";
	}
	elsif ($err =~ /Can't locate .*? in \@INC/) {
	    $advice = "Perhaps a module that DBD::$driver requires hasn't been fully installed";
	}
	Carp::croak("install_driver($driver) failed: $err$advice\n");
    }
    if ($DBI::dbi_debug) {
	no strict 'refs';
	my $dbd_ver = ${"$driver_class\::VERSION"} || "undef";
	DBI->trace_msg("       install_driver: $driver_class loaded (version $dbd_ver)\n")
    }

    # --- do some behind-the-scenes checks and setups on the driver
    _setup_driver($driver_class);

    # --- run the driver function
    $drh = eval { $driver_class->driver($attr || {}) };
    unless ($drh && ref $drh && !$@) {
	my $advice = "";
	# catch people on case in-sensitive systems using the wrong case
	$advice = "\nPerhaps the capitalisation of DBD '$driver' isn't right."
		if $@ =~ /locate object method/;
	croak("$driver_class initialisation failed: $@$advice");
    }

    $DBI::installed_drh{$driver} = $drh;
    DBI->trace_msg("    <- install_driver= $drh\n") if $DBI::dbi_debug;
    $drh;
}

*driver = \&install_driver;	# currently an alias, may change


sub _setup_driver {
    my $driver_class = shift;
    my $type;
    foreach $type (qw(dr db st)){
	my $class = $driver_class."::$type";
	no strict 'refs';
	push @{"${class}::ISA"},     "DBD::_::$type";
	push @{"${class}_mem::ISA"}, "DBD::_mem::$type";
    }
}


sub init_rootclass {
    my $rootclass = shift;
    no strict 'refs';
    croak("Can't init '$rootclass' without '$rootclass\::db' class.")
	unless defined ${"$rootclass\::db::"}{ISA};

    $installed_rootclass{$rootclass} = 1;
    # may do checks on ::db and ::st classes later
    return 1;
}


*internal = \&DBD::Switch::dr::driver;
#sub internal { return DBD::Switch::dr::driver(@_); }


sub available_drivers {
    my($quiet) = @_;
    my(@drivers, $d, $f);
    local(*DBI::DIR);
    my(%seen_dir, %seen_dbd);
    my $haveFileSpec = eval { require File::Spec };
    foreach $d (@INC){
	chomp($d); # perl 5 beta 3 bug in #!./perl -Ilib from Test::Harness
	my $dbd_dir =
	    ($haveFileSpec ? File::Spec->catdir($d, 'DBD') : "$d/DBD");
	next unless -d $dbd_dir;
	next if $seen_dir{$d};
	$seen_dir{$d} = 1;
	# XXX we have a problem here with case insensitive file systems
	# XXX since we can't tell what case must be used when loading.
	opendir(DBI::DIR, $dbd_dir) || Carp::carp "opendir $dbd_dir: $!\n";
	foreach $f (readdir(DBI::DIR)){
	    next unless $f =~ s/\.pm$//;
	    next if $f eq 'NullP' || $f eq 'Sponge';
	    if ($seen_dbd{$f}){
		Carp::carp "DBD::$f in $d is hidden by DBD::$f in $seen_dbd{$f}\n"
		    unless $quiet;
            } else {
		push(@drivers, $f);
	    }
	    $seen_dbd{$f} = $d;
	}
	closedir(DBI::DIR);
    }
    return sort @drivers;
}

sub data_sources {
    my ($class, $driver, @attr) = @_;
    my $drh = $class->install_driver($driver);
    my @ds = $drh->data_sources(@attr);
    return @ds;
}

sub neat_list {
    my ($listref, $maxlen, $sep) = @_;
    $maxlen = 0 unless defined $maxlen;	# 0 == use internal default
    $sep = ", " unless defined $sep;
    join($sep, map { neat($_,$maxlen) } @$listref);
}


sub dump_results {	# also aliased as a method in DBD::_::st
    my ($sth, $maxlen, $lsep, $fsep, $fh) = @_;
    return 0 unless $sth;
    $maxlen ||= 35;
    $lsep   ||= "\n";
    $fh ||= \*STDOUT;
    my $rows = 0;
    my $ref;
    while($ref = $sth->fetch) {
	print $fh $lsep if $rows++ and $lsep;
	my $str = neat_list($ref,$maxlen,$fsep);
	print $fh $str;	# done on two lines to avoid 5.003 errors
    }
    print $fh "\n$rows rows".($DBI::err ? " ($DBI::err: $DBI::errstr)" : "")."\n";
    $rows;
}



sub connect_test_perf {
    my($class, $dsn,$dbuser,$dbpass, $attr) = @_;
	croak("connect_test_perf needs hash ref as fourth arg") unless ref $attr;
    # these are non standard attributes just for this special method
    my $loops ||= $attr->{dbi_loops} || 5;
    my $par   ||= $attr->{dbi_par}   || 1;	# parallelism
    my $verb  ||= $attr->{dbi_verb}  || 1;
    print "$dsn: testing $loops sets of $par connections:\n";
    require Benchmark;
    require "FileHandle.pm";	# don't let toke.c create empty FileHandle package
    $| = 1;
    my $t0 = new Benchmark;		# not currently used
    my $drh = $class->install_driver($dsn) or Carp::croak("Can't install $dsn driver\n");
    my $t1 = new Benchmark;
    my $loop;
    for $loop (1..$loops) {
	my @cons;
	print "Connecting... " if $verb;
	for (1..$par) {
	    print "$_ ";
	    push @cons, ($drh->connect($dsn,$dbuser,$dbpass)
		    or Carp::croak("Can't connect # $_: $DBI::errstr\n"));
	}
	print "\nDisconnecting...\n" if $verb;
	for (@cons) {
	    $_->disconnect or warn "bad disconnect $DBI::errstr"
	}
    }
    my $t2 = new Benchmark;
    my $td = Benchmark::timediff($t2, $t1);
    printf "Made %2d connections in %s\n", $loops*$par, Benchmark::timestr($td);
	print "\n";
    return $td;
}

*trace_msg = \&DBD::_::common::trace_msg;

# Help people doing DBI->errstr, might even document it one day
# XXX probably best moved to cheaper XS code
sub err    { $DBI::err    }
sub errstr { $DBI::errstr }


# --- Private Internal Function for Creating New DBI Handles

sub _new_handle {
    my($class, $parent, $attr, $imp_data) = @_;

    Carp::croak('Usage: DBI::_new_handle'
	    .'($class_name, parent_handle, \%attr, $imp_data)'."\n"
	    .'got: ('.join(", ",$class, $parent, $attr, $imp_data).")\n")
	unless(@_ == 4	and (!$parent or ref $parent)
			and ref $attr eq 'HASH');

    my $imp_class = $attr->{ImplementorClass} or
	Carp::croak("_new_handle($class): 'ImplementorClass' attribute not given");

    DBI->trace_msg("    New $class (for $imp_class, parent=$parent, id=".($imp_data||'').")\n")
	if $DBI::dbi_debug >= 3;

    # This is how we create a DBI style Object:
    my(%hash, $i, $h);
    $i = tie    %hash, $class, $attr;  # ref to inner hash (for driver)
    $h = bless \%hash, $class;         # ref to outer hash (for application)
    # The above tie and bless may migrate down into _setup_handle()...
    # Now add magic so DBI method dispatch works
    DBI::_setup_handle($h, $imp_class, $parent, $imp_data);

    return $h unless wantarray;
    ($h, $i);
}
# minimum constructors for the tie's (alias to XS version)
sub DBI::st::TIEHASH { bless $_[1] => $_[0] };
*DBI::dr::TIEHASH = \&DBI::st::TIEHASH;
*DBI::db::TIEHASH = \&DBI::st::TIEHASH;


# These three special constructors are called by the drivers
# The way they are called is likey to change.

sub _new_drh {	# called by DBD::<drivername>::driver()
    my ($class, $initial_attr, $imp_data) = @_;
    # Provide default storage for State,Err and Errstr.
    # Note that these are shared by all child handles by default! XXX
    # State must be undef to get automatic faking in DBI::var::FETCH
    my ($h_state_store, $h_err_store, $h_errstr_store) = (undef, 0, '');
    my $attr = {
	'ImplementorClass' => $class,
	# these attributes get copied down to child handles by default
	'Handlers'	=> [],
	'State'		=> \$h_state_store,  # Holder for DBI::state
	'Err'		=> \$h_err_store,    # Holder for DBI::err
	'Errstr'	=> \$h_errstr_store, # Holder for DBI::errstr
	'Debug' 	=> 0,
	%$initial_attr,
	'Type'=>'dr',
    };
    _new_handle('DBI::dr', '', $attr, $imp_data);
}

sub _new_dbh {	# called by DBD::<drivername>::dr::connect()
    my ($drh, $initial_attr, $imp_data) = @_;
    my $imp_class = $drh->{ImplementorClass}
	|| Carp::croak("DBI _new_dbh: $drh has no ImplementorClass");
    substr($imp_class,-4,4) = '::db';
    my $app_class  = ref $drh;
    substr($app_class,-4,4) = '::db';
    my $attr = {
	'ImplementorClass' => $imp_class,
	%$initial_attr,
	'Type'   => 'db',
	'Driver' => (DBI::_handles($drh))[0],
    };
    _new_handle($app_class, $drh, $attr, $imp_data);
}

sub _new_sth {	# called by DBD::<drivername>::db::prepare)
    my ($dbh, $initial_attr, $imp_data) = @_;
    my $imp_class = $dbh->{ImplementorClass}
	|| Carp::croak("DBI _new_sth: $dbh has no ImplementorClass");
    substr($imp_class,-4,4) = '::st';
    my $app_class  = ref $dbh;
    substr($app_class,-4,4) = '::st';
    my $attr = {
	'ImplementorClass' => $imp_class,
	%$initial_attr,
	'Type'     => 'st',
	'Database' => $dbh,
    };
    _new_handle($app_class, $dbh, $attr, $imp_data);
}


} # end of DBI package scope



# --------------------------------------------------------------------
# === The internal DBI Switch pseudo 'driver' class ===

{   package DBD::Switch::dr;
    DBI::_setup_driver('DBD::Switch');	# sets up @ISA
    require Carp;

    $imp_data_size = 0;
    $imp_data_size = 0;	# avoid typo warning
    $err = 0;

    sub driver {
	return $drh if $drh;	# a package global

	my $inner;
	($drh, $inner) = DBI::_new_drh('DBD::Switch::dr', {
		'Name'    => 'Switch',
		'Version' => $DBI::VERSION,
		# the Attribution is defined as a sub as an example
		'Attribution' => sub { "DBI-$DBI::VERSION Switch by Tim Bunce" },
	    }, \$err);
	Carp::croak("DBD::Switch init failed!") unless ($drh && $inner);
	return $drh;
    }

    sub FETCH {
	my($drh, $key) = @_;
	return DBI->trace if $key eq 'DebugDispatch';
	return undef if $key eq 'DebugLog';	# not worth fetching, sorry
	return $drh->DBD::_::dr::FETCH($key);
	undef;
    }
    sub STORE {
	my($drh, $key, $value) = @_;
	if ($key eq 'DebugDispatch') {
	    DBI->trace($value);
	} elsif ($key eq 'DebugLog') {
	    DBI->trace(-1, $value);
	} else {
	    $drh->DBD::_::dr::STORE($key, $value);
	}
    }
}


# --------------------------------------------------------------------
# === OPTIONAL MINIMAL BASE CLASSES FOR DBI SUBCLASSES ===

# We only define default methods for harmless functions.
# We don't, for example, define a DBD::_::st::prepare()

{   package DBD::_::common; # ====== Common base class methods ======
    use strict;

    # methods common to all handle types:

    sub _not_impl {
	my ($h, $method) = @_;
	$h->trace_msg("Driver does not implement the $method method.\n");
	return;	# empty list / undef
    }

    # generic TIEHASH default methods:
    sub FIRSTKEY { }
    sub NEXTKEY  { }
    sub EXISTS   { defined($_[0]->FETCH($_[1])) } # XXX undef?
    sub CLEAR    { Carp::carp "Can't CLEAR $_[0] (DBI)" }
}


{   package DBD::_::dr;  # ====== DRIVER ======
    @ISA = qw(DBD::_::common);
    use strict;

    sub connect { # normally overridden, but a handy default
	my ($drh, $dsn, $user, $auth) = @_;
	my ($this) = DBI::_new_dbh($drh, {
	    'Name' => $dsn,
	    'User' => $user,
	});
	$this;
    }


    sub connect_cached {
	my $drh = shift;
	my ($dsn, $user, $auth, $attr)= @_;

	# Needs support at dbh level to clear cache before complaining about
	# active children. The XS template code does this. Drivers not using
	# the template must handle clearing the cache themselves.
	my $cache = $drh->FETCH('CachedKids');
	$drh->STORE('CachedKids', $cache = {}) unless $cache;

	my $key = join "~", $dsn, $user||'', $auth||'', $attr ? %$attr : ();
	my $dbh = $cache->{$key};
	return $dbh if $dbh && $dbh->FETCH('Active') && $dbh->ping;
	$dbh = $drh->connect(@_);
	$cache->{$key} = $dbh;	# replace, even if it failed
	return $dbh;
    }


    sub disconnect_all {	# Driver must take responsibility for this
	# XXX Umm, may change later.
	Carp::croak("Driver has not implemented the disconnect_all method.");
    }

    sub data_sources {
	shift->_not_impl('data_sources');
    }

}


{   package DBD::_::db;  # ====== DATABASE ======
    @ISA = qw(DBD::_::common);
    use strict;

    sub disconnect  {
	shift->_not_impl('disconnect');
    }

    # Drivers are required to implement *::db::DESTROY to encourage tidy-up
    sub DESTROY  { Carp::croak("Driver has not implemented DESTROY for @_") }

    sub quote {
	my ($dbh, $str, $data_type) = @_;
	return "NULL" unless defined $str;
	unless ($data_type) {
	    $str =~ s/'/''/g;		# ISO SQL2
	    return "'$str'";
	}
	# Optimise for standard numerics which need no quotes
	return $str if $data_type == DBI::SQL_INTEGER
		    || $data_type == DBI::SQL_SMALLINT
		    || $data_type == DBI::SQL_DECIMAL
		    || $data_type == DBI::SQL_FLOAT
		    || $data_type == DBI::SQL_REAL
		    || $data_type == DBI::SQL_DOUBLE
		    || $data_type == DBI::SQL_NUMERIC;
	my $ti = $dbh->type_info($data_type);
	# XXX needs checking
	my $lp = $ti ? $ti->{LITERAL_PREFIX} || "" : "'";
	my $ls = $ti ? $ti->{LITERAL_SUFFIX} || "" : "'";
	# XXX don't know what the standard says about escaping
	# in the 'general case' (where $lp != "'").
	# So we just do this and hope:
	$str =~ s/$lp/$lp$lp/g
		if $lp && $lp eq $ls && ($lp eq "'" || $lp eq '"');
	return "$lp$str$ls";
    }

    sub rows { -1 }	# here so $DBI::rows 'works' after using $dbh

    sub do {
	my($dbh, $statement, $attr, @params) = @_;
	my $sth = $dbh->prepare($statement, $attr) or return undef;
	$sth->execute(@params) or return undef;
	my $rows = $sth->rows;
	($rows == 0) ? "0E0" : $rows;
    }

    sub selectrow_array {
	my ($dbh, $stmt, $attr, @bind) = @_;
	my $sth = (ref $stmt) ? $stmt
			      : $dbh->prepare($stmt, $attr);
	return unless $sth;
	$sth->execute(@bind) || return;
	my @row = $sth->fetchrow_array;
	$sth->finish;
	return $row[0] unless wantarray;
	return @row;
    }

    sub selectall_arrayref {
	my ($dbh, $stmt, $attr, @bind) = @_;
	my $sth = (ref $stmt) ? $stmt
			      : $dbh->prepare($stmt, $attr);
	return unless $sth;
	$sth->execute(@bind) || return;
	return $sth->fetchall_arrayref;
    }

    sub prepare_cached {
	my ($dbh, $statement, $attr, @params) = @_;
	# Needs support at dbh level to clear cache before complaining about
	# active children. The XS template code does this. Drivers not using
	# the template must handle clearing the cache themselves.
	my $cache = $dbh->FETCH('CachedKids');
	$dbh->STORE('CachedKids', $cache = {}) unless $cache;
	my $key = join " | ", $statement, $attr ? %$attr : ();
	my $sth = $cache->{$key};
	if ($sth) {
	    Carp::croak("prepare_cached($statement) statement handle $sth is still active")
		if $sth->FETCH('Active');
	    return $sth;
	}
	$sth = $dbh->prepare($statement, $attr);
	$cache->{$key} = $sth if $sth;
	return $sth;
    }

    sub ping {
	shift->_not_impl('ping');
	"0 but true";	# special kind of true 0
    }

    sub commit {
	shift->_not_impl('commit');
    }
    sub rollback {
	shift->_not_impl('rollback');
    }

    sub get_info {
	shift->_not_impl("get_info @_");
    }

    sub table_info {
	shift->_not_impl('table_info');
    }

    sub tables {
	my ($dbh, @args) = @_;
	my $sth = $dbh->table_info(@args);
	return unless $sth;
	my ($row, @tables);
	while($row = $sth->fetch) {
	    my $name = $row->[2];
	    if ($row->[1]) {
		my $schema = $row->[1];
		# a little hack
		my $quote = ($schema eq uc($schema)) ? '' : '"';
		$name = "$quote$schema$quote.$name"
	    }
	    push @tables, $name;
	}
	return @tables;
    }

    sub type_info_all {
	my ($dbh) = @_;
	$dbh->_not_impl('type_info_all');
	my $ti = [ {} ];
	return $ti;
    }

    sub type_info {
	my ($dbh, $data_type) = @_;
	my $tia = $dbh->type_info_all;
	return unless @$tia;
	Carp::croak "Invalid result structure from $dbh->type_info_all"
	    unless ref($tia) eq 'ARRAY' && ref($tia->[0]) eq 'HASH';
	my $idx_hash = $tia->[0];
	my @ti;
	# --- simple DATA_TYPE match filter
	if (defined($data_type) && $data_type != DBI::SQL_ALL_TYPES()) {
	    my $dt_idx = $idx_hash->{DATA_TYPE};
	    unless (defined $dt_idx) {
		Carp::croak "No DATA_TYPE field in type_info_all result";
		# XXX search for a "suitable" type (e.g. DECIMAL)
	    }
	    @ti = grep { $_->[$dt_idx] == $data_type } @{$tia}[1..$#$tia];
	}
	else {
	    @ti = @{$tia}[1..$#$tia];
	}
	# --- format results into list of hash refs
	my $idx_fields = keys %$idx_hash;
	my @idx_names  = keys %$idx_hash;
	my @idx_values = values %$idx_hash;
	my @out = map {
	    Carp::croak
		"type_info_all result has $idx_fields keys but ".(@$_)." fields"
		if @$_ != $idx_fields;
	    my %h; @h{@idx_names} = @{$_}[ @idx_values ]; \%h;
	} @ti;
	return $out[0] unless wantarray;
	return @out;
    }
}


{   package DBD::_::st;  # ====== STATEMENT ======
    @ISA = qw(DBD::_::common);
    use strict;

    sub cancel  { undef }
    sub bind_param { Carp::croak("Can't bind_param, not implement by driver") }

    sub fetchrow_hashref {
	my $sth = shift;
	my $name = shift || 'NAME';
	# This may be recoded in XS. It could work with fb_av and bind_col.
	# Probably best to add an AV*fields_hvav to dbih_stc_t and set it up
	# on the first call to fetchhash which alternate name/value pairs.
	# This implementation is just rather simple and not very optimised.
	# Notes for XS implementation: since apps may add entries to the hash
	# before the next fetch we need to check the key count and, if changed,
	# scan the hash and delete inappropriate keys.
	my $row = $sth->fetch or return undef;
	my %hash;
	@hash{ @{ $sth->FETCH($name) } } = @$row;
	return \%hash;
    }

    sub fetchall_arrayref {
	my $sth = shift;
	my $slice= shift || [];	# XXX not documented: may change
	my $mode = ref $slice;
	my @rows;
	my $row;
	if ($mode eq 'ARRAY') {
	    # we copy the array here because fetch (currently) always
	    # returns the same array ref. XXX
	    if (@$slice) {
		push @rows, [ @{$row}[ @$slice] ] while($row = $sth->fetch);
	    }
	    else {
		push @rows, [ @$row ] while($row = $sth->fetch);
	    }
	}
	elsif ($mode eq 'HASH') {
	    my @o_keys = keys %$slice;
	    if (@o_keys) {
		my %i_names = map {  (lc($_)=>$_) } @{ $sth->{NAME} };
		my @i_keys  = map { $i_names{lc($_)} } @o_keys;
		while ($row = $sth->fetchrow_hashref) {
		    my %hash;
		    @hash{@o_keys} = @{$row}{@i_keys};
		    push @rows, \%hash;
		}
	    }
	    else {
		# XXX assumes new ref each fetchhash
		push @rows, $row while ($row = $sth->fetchrow_hashref);
	    }
	}
	else { Carp::croak("fetchall_arrayref($mode) invalid") }
	return \@rows;
    }

    *dump_results = \&DBI::dump_results;

    sub blob_copy_to_file {	# returns length or undef on error
	my($self, $field, $filename_or_handleref, $blocksize) = @_;
	my $fh = $filename_or_handleref;
	my($len, $buf) = (0, "");
	$blocksize ||= 512;	# not too ambitious
	local(*FH);
	unless(ref $fh) {
	    open(FH, ">$fh") || return undef;
	    $fh = \*FH;
	}
	while(defined($self->blob_read($field, $len, $blocksize, \$buf))) {
	    print $fh $buf;
	    $len += length $buf;
	}
	close(FH);
	$len;
    }

    sub more_results {
	shift->{syb_more_results};	# handy grandfathering
    }

    # Drivers are required to implement *::st::DESTROY to encourage tidy-up
    sub DESTROY  { Carp::croak("Driver has not implemented DESTROY for @_") }
}

{   # See install_driver
    { package DBD::_mem::dr; @ISA = qw(DBD::_mem::common);	}
    { package DBD::_mem::db; @ISA = qw(DBD::_mem::common);	}
    { package DBD::_mem::st; @ISA = qw(DBD::_mem::common);	}
    # DBD::_mem::common::DESTROY is implemented in DBI.xs
}

1;
__END__

=head1 DESCRIPTION

The Perl DBI is a database access Application Programming Interface
(API) for the Perl Language.  The DBI defines a set of functions,
variables and conventions that provide a consistent database interface
independant of the actual database being used.

It is important to remember that the DBI is just an interface. A thin
layer of 'glue' between an application and one or more Database Drivers.
It is the drivers which do the real work. The DBI provides a standard
interface and framework for the drivers to operate within.


=head2 Architecture of a DBI Application

             |<- Scope of DBI ->|
                  .-.   .--------------.   .-------------.
  .-------.       | |---| XYZ Driver   |---| XYZ Engine  |
  | Perl  |       |S|   `--------------'   `-------------'
  | script|  |A|  |w|   .--------------.   .-------------.
  | using |--|P|--|i|---|Oracle Driver |---|Oracle Engine|
  | DBI   |  |I|  |t|   `--------------'   `-------------'
  | API   |       |c|...
  |methods|       |h|... Other drivers
  `-------'       | |...
                  `-'

The API is the Application Perl-script (or Programming) Interface.  The
call interface and variables provided by DBI to perl scripts. The API
is implemented by the DBI Perl extension.

The 'Switch' is the code that 'dispatches' the DBI method calls to the
appropriate Driver for actual execution.  The Switch is also
responsible for the dynamic loading of Drivers, error checking/handling
and other duties. The DBI and Switch are generally synonymous.

The Drivers implement support for a given type of Engine (database).
Drivers contain implementations of the DBI methods written using the
private interface functions of the corresponding Engine.  Only authors
of sophisticated/multi-database applications or generic library
functions need be concerned with Drivers.

=head2 Notation and Conventions

  DBI     static 'top-level' class name
  $dbh    Database handle object
  $sth    Statement handle object
  $drh    Driver handle object (rarely seen or used in applications)
  $h      Any of the $??h handle types above
  $rc     General Return Code  (boolean: true=ok, false=error)
  $rv     General Return Value (typically an integer)
  @ary    List of values returned from the database, typically a row of data
  $rows   Number of rows processed (if available, else -1)
  $fh     A filehandle
  undef   NULL values are represented by undefined values in perl
  \%attr  Reference to a hash of attribute values passed to methods

Note that Perl will automatically destroy database and statement objects
if all references to them are deleted.

Handle object attributes are shown as:

C<  $h-E<gt>{attribute_name}>   (I<type>)

where I<type> indicates the type of the value of the attribute (if it's
not a simple scalar):

  \$   reference to a scalar: $h->{attr}       or  $a = ${$h->{attr}}
  \@   reference to a list:   $h->{attr}->[0]  or  @a = @{$h->{attr}}
  \%   reference to a hash:   $h->{attr}->{a}  or  %a = %{$h->{attr}}


=head2 Outline Usage

First you need to load the DBI module:

  use DBI;

(also adding C<use strict;> is recommended), then you need to
L</connect> to your data source and get a I<handle> for that
connection:

  $dbh = DBI->connect($dsn, $user, $password,
                      { RaiseError => 1, AutoCommit => 0 });

Since connecting can be expensive you generally just connect at the
start of your program and disconnect at the end.

Explicitly defining the required AutoCommit behaviour is strongly
recommended and may become mandatory in a later version.

The DBI allows an application to `prepare' statements for later
execution.  A prepared statement is identified by a statement handle.
We'll call the perl variable $sth.

Typical method call sequence for a select statement:

  prepare,
    execute, fetch, fetch, ...
    execute, fetch, fetch, ...
    execute, fetch, fetch, ...

for example:

  $sth = $dbh->prepare("select foo, bar from table where baz=?");

  $sth->execute( $baz );

  while ( @row = $sth->fetchrow_array ) {
    print "@row\n";
  }

Typical method call sequence for a non-select statement:

  prepare,
    execute,
    execute,
    execute.

for example:

  $sth = $dbh->prepare("insert into table(foo,bar,baz) values (?,?,?)");

  while(<CSV>) {
    chop;
    my ($foo,$bar,$baz) = split /,/;
	$sth->execute( $foo, $bar, $baz );
  }

To commit your changes to the database (when L</AutoCommit> is off):

  $dbh->commit;  # or call $dbh->rollback; to undo changes

Finally, when you have finished working with the data source you should
L</disconnect> from it:

  $dbh->disconnect;


=head2 General Interface Rules & Caveats

The DBI does not have a concept of a `current session'. Every session
has a handle object (i.e., a $dbh) returned from the connect method and
that handle object is used to invoke database related methods.

Most data is returned to the perl script as strings (null values are
returned as undef).  This allows arbitrary precision numeric data to be
handled without loss of accuracy.  Be aware that perl may not preserve
the same accuracy when the string is used as a number.

Dates and times are returned as character strings in the native format
of the corresponding Engine.  Time Zone effects are Engine/Driver
dependent.

Perl supports binary data in perl strings and the DBI will pass binary
data to and from the Driver without change. It is up to the Driver
implementors to decide how they wish to handle such binary data.

Multiple SQL statements may not be combined in a single statement
handle, e.g., a single $sth (some drivers do support this).

Non-sequential record reads are not supported in this version of the
DBI. E.g., records can only be fetched in the order that the database
returned them and once fetched they are forgotten.

Positioned updates and deletes are not directly supported by the DBI.
See the description of the CursorName attribute for an alternative.

Individual Driver implementors are free to provide any private
functions and/or handle attributes that they feel are useful.
Private driver functions can be invoked using the DBI C<func> method.
Private driver attributes are accessed just like standard attributes.

Many methods have an optional \%attr parameter which can be used to
pass information to the driver implementing the method. Except where
specifically documented the \%attr parameter can only be used to pass
driver specific hints. In general you can ignore \%attr parameters
or pass it as undef.

Character sets: Most databases which understand character sets have a
default global charset and text stored in the database is, or should
be, stored in that charset (if it's not then that's the fault of either
the database or the application that inserted the data). When text is
fetched it should be (automatically) converted to the charset of the
client (presumably based on the locale). If a driver needs to set a
flag to get that behaviour then it should do so. It should not require
the application to do that.


=head2 Naming Conventions and Name Space

The DBI package and all packages below it C<DBI::*> are reserved for
use by the DBI. Extensions and related modules use the C<DBIx::>
namespace. Package names beginning with C<DBD::> are reserved for use
by DBI database drivers.  All environment variables used by the DBI
or DBD's begin with 'DBI_' or 'DBD_'.

The letter case used for attribute names is significant and plays an
important part in the portability of DBI scripts.  The case of the
attribute name is used to signify who defined the meaning of that name
and its values.

  Case of name  Has a meaning defined by
  ------------  ------------------------
  UPPER_CASE    Standards, e.g.,  X/Open, SQL92 etc (portable)
  MixedCase     DBI API (portable), underscores are not used.
  lower_case    Driver or Engine specific (non-portable)

It is of the utmost importance that Driver developers only use
lowercase attribute names when defining private attributes. Private
attribute names must be prefixed with the driver name or suitable
abbreviation (e.g., ora_ for Oracle, ing_ for Ingres etc).

Driver Specific Prefix Registry:

  ora_     DBD::Oracle
  ing_     DBD::Ingres
  odbc_    DBD::ODBC
  syb_     DBD::Sybase
  db2_     DBD::DB2
  ix_      DBD::Informix
  f_       DBD::File
  csv_     DBD::CSV
  file_    DBD::TextFile
  xbase_   DBD::XBase
  solid_   DBD::Solid
  proxy_   DBD::Proxy
  msql_    DBD::mSQL
  mysql_   DBD::mysql


=head2 Placeholders and Bind Values

Some drivers support Placeholders and Bind Values. These drivers allow
a database statement to contain placeholders, sometimes called
parameter markers, that indicate values that will be supplied later,
before the prepared statement is executed.  For example, an application
might use the following to insert a row of data into the SALES table:

  insert into sales (product_code, qty, price) values (?, ?, ?)

or the following, to select the description for a product:

  select description from products where product_code = ?

The C<?> characters are the placeholders.  The association of actual
values with placeholders is known as binding and the values are
referred to as bind values.

When using placeholders with the SQL C<LIKE> qualifier you must
remember that the placeholder substitutes for the whole string.
So you should use "... LIKE ? ..." and include any wildcard
characters in the value that you bind to the placeholder.

B<Null Values>

Undefined values or C<undef> can be used to indicate null values.
However, care must be taken in the particular case of trying to use
null values to qualify a select statement. Consider:

  select description from products where product_code = ?

Binding an undef (NULL) to the placeholder will I<not> select rows
which have a NULL product_code! Refer to the SQL manual for your database
engine or any SQL book for the reasons for this.  To explicitly select
NULLs you have to say "where product_code is NULL" and to make that
general you have to say:

  ... WHERE (product_code = ? OR (? IS NULL AND product_code IS NULL))

and bind the same value to both placeholders.

B<Performance>

Without using placeholders, the insert statement above would have to
contain the literal values to be inserted and it would have to be
re-prepared and re-executed for each row. With placeholders, the insert
statement only needs to be prepared once. The bind values for each row
can be given to the execute method each time it's called. By avoiding
the need to re-prepare the statement for each row the application
typically runs many times faster! Here's an example:

  my $sth = $dbh->prepare(q{
    INSERT INTO sales (product_code, qty, price) VALUES (?, ?, ?)
  }) || die $dbh->errstr;
  while (<>) {
      chop;
      my ($product_code, $qty, $price) = split /,/;
      $sth->execute($product_code, $qty, $price) || die $dbh->errstr;
  }
  $dbh->commit || die $dbh->errstr;

See L</execute> and L</bind_param> for more details.

The C<q{...}> style quoting used in this example avoids clashing with
quotes that may be used in the SQL statement. Use the double-quote like
C<qq{...}> operator if you want to interpolate variables into the string.
See L<perlop/"Quote and Quote-like Operators"> for more details.

See L</bind_column> for a related method used to associate perl
variables with the I<output> columns of a select statement.


=head2 SQL - A Query Language

Most DBI drivers require applications to use a dialect of SQL (the
Structured Query Language) to interact with the database engine.  These
links provide useful information and further links about SQL, the
first is a good tutorial with much useful information and many links:

  http://www.geocities.com/ResearchTriangle/Node/9672/sqltut.html
  http://www.jcc.com/sql_stnd.html
  http://www.contrib.andrew.cmu.edu/~shadow/sql.html

The DBI itself does not mandate or require any particular language to
be used.  It is language independant. In ODBC terms the DBI is in
'pass-thru' mode (individual drivers might not be). The only requirement
is that queries and other statements must be expressed as a single
string of letters passed as the first argument to the L</prepare> method.

For an interesting diversion on the I<real> history of RDBMS and SQL,
from the people who made it happen, see

  http://ftp.digital.com/pub/DEC/SRC/technical-notes/SRC-1997-018-html/sqlr95.html

Follow the "And the rest" and "Intergalactic dataspeak" links for the
SQL history.

=head1 THE DBI CLASS

=head2 DBI Class Methods

=over 4

=item B<connect>

  $dbh = DBI->connect($data_source, $username, $password) || die $DBI::errstr;
  $dbh = DBI->connect($data_source, $username, $password, \%attr) || die $DBI::errstr;

Establishes a database connection (session) to the requested data_source.
Returns a database handle object if the connect succeeds. Use
$dbh->disconnect to terminate the connection.

If the connect fails (see below) it returns undef and sets $DBI::err
and $DBI::errstr (it does I<not> set $! etc). Generally you should test
the return status of connect and print $DBI::errstr if it has failed.

Multiple simultaneous connections to multiple databases through multiple
drivers can be made via the DBI. Simply make one connect call for each
and keep a copy of each returned database handle.

The $data_source value should begin with 'dbi:driver_name:'.  The
driver_name part sprcifies the driver that will be used to make the
connection (letter case is significant).

As a convenience, if the $data_source parameter is undefined or empty the
DBI will substitute the value of the environment variable DBI_DSN.
If just the driver_name part is empty (i.e., data_source prefix is 'dbi::')
the environment variable DBI_DRIVER is used. If neither variable is set
then the connect dies.

Examples of $data_source values:

  dbi:DriverName:database_name
  dbi:DriverName:database_name@hostname:port
  dbi:DriverName:database=database_name;host=hostname;port=port

There is I<no standard> for the text following the driver name. Each
driver is free to use whatever syntax it wants. The only requirement the
DBI makes is that all the information is supplied in a single string.
You must consult the documentation for the drivers you are using for a
description of the syntax they require.  (Where a driver author needs
to define a syntax for the data_source it is recommended that
they follow the ODBC style, the last example above.)

If the environment variable DBI_AUTOPROXY is defined (and the driver in
$data_source is not 'Proxy') then the connect request will
automatically be changed to:

  dbi:Proxy:$ENV{DBI_AUTOPROXY};dsn=$data_source

and passed to the DBD::Proxy module. DBI_AUTOPROXY would typically be
"hostname=...;port=...". See L<DBD::Proxy> for more details.

If $username or $password are I<undefined> (rather than just empty)
then the DBI will substitute the values of the DBI_USER and DBI_PASS
environment variables respectively.  The use of the environment for
these values is not recommended for security reasons. The mechanism is
only intended to simplify testing.

DBI->connect automatically installs the driver if it has not been
installed yet. Driver installation I<always> returns a valid driver
handle or it I<dies> with an error message which includes the string
'install_driver' and the underlying problem. So, DBI->connect will die
on a driver installation failure and will only return undef on a
connect failure, for which $DBI::errstr will hold the error.

The $data_source argument (with the 'dbi:...:' prefix removed) and the
$username and $password arguments are then passed to the driver for
processing. The DBI does not define I<any> interpretation for the
contents of these fields.  The driver is free to interpret the
data_source, username and password fields in any way and supply
whatever defaults are appropriate for the engine being accessed
(Oracle, for example, uses the ORACLE_SID and TWO_TASK env vars if no
data_source is specified).

The AutoCommit and PrintError attributes for each connection default to
I<on> (see L</AutoCommit> and L</PrintError> for more information).
However, it is B<strongly recommended> that AutoCommit is I<explicitly>
defined as required rather than rely on the default. Future versions of
the DBI may issue a warning if AutoCommit is not explicitly defined.

The \%attr parameter can be used to alter the default settings of the
PrintError, RaiseError, AutoCommit and other attributes. For example:

  $dbh = DBI->connect($data_source, $user, $pass, {
	PrintError => 0,
	AutoCommit => 0
  });

You can also define connection attribute values within the $data_source
parameter. For example

  dbi:DriverName(PrintError=>0,Taint=>1):...

Individual attributes values specified in this way take precedence over
any conflicting values specified via the \%attrib parameter to C<connect()>.

Portable applications should not assume that a single driver will be
able to support multiple simultaneous sessions. Though most do.

Where possible each session ($dbh) is independent from the transactions
in other sessions. This is useful where you need to hold cursors open
across transactions, e.g., use one session for your long lifespan
cursors (typically read-only) and another for your short update
transactions.

For compatibility with old DBI scripts the driver can be specified by
passing its name as the fourth argument to connect (instead of \%attr):

  $dbh = DBI->connect($data_source, $user, $pass, $driver);

In this 'old-style' form of connect the $data_source should not start
with 'dbi:driver_name:' and, even if it does, the embedded driver_name
will be ignored. The $dbh->{AutoCommit} attribute is I<undefined>. The
$dbh->{PrintError} attribute is off. And the old DBI_DBNAME env var is
checked if DBI_DSN is not defined. I<This 'old-style' connect will be
withdrawn in a future version>.


=item B<available_drivers>

  @ary = DBI->available_drivers;
  @ary = DBI->available_drivers($quiet);

Returns a list of all available drivers by searching for DBD::* modules
through the directories in @INC. By default a warning will be given if
some drivers are hidden by others of the same name in earlier
directories. Passing a true value for $quiet will inhibit the warning.


=item B<data_sources>

  @ary = DBI->data_sources($driver);
  @ary = DBI->data_sources($driver, \%attr);

Returns a list of all data sources (databases) available via the named
driver. The driver will be loaded if not already. If $driver is empty
or undef then the value of the DBI_DRIVER environment variable will be
used.

Data sources will be returned in a form suitable for passing to the
L</connect> method, i.e., they will include the "dbi:$driver:" prefix.

Note that many drivers have no way of knowing what data sources might
be available for it and thus, typically, return an empty or incomplete
list.


=item B<trace>

  DBI->trace($trace_level)
  DBI->trace($trace_level, $trace_filename)

DBI trace information can be enabled for all handles using this DBI
class method. To enable trace information for a specific handle use
the similar $h->trace method described elsewhere.

Use $trace_level 2 to see detailed call trace information including
parameters and return values.  The trace output is detailed and
typically I<very> useful. Much of the trace output is formatted using
the L</neat> function and thus strings in the trace output may be
edited and truncated by it.

Use $trace_level 0 to disable the trace.

Initially trace output is written to STDERR.  If $trace_filename is
specified then the file is opened in append mode and I<all> trace
output (including that from other handles) is redirected to that file.
Further calls to trace without a $trace_filename do not alter where
the trace output is sent.

See also the $h->trace() method and L</DEBUGGING> for information
about the DBI_TRACE environment variable.


=back


=head2 DBI Utility Functions

=over 4

=item B<neat>

  $str = DBI::neat($value, $maxlen);

Return a string containing a neat (and tidy) representation of the
supplied value.

Strings will be quoted (but internal quotes will not be escaped).
Values I<known> to be numeric will be unquoted. Undefined (NULL) values
will be shown as C<undef> (without quotes). Unprintable characters will
be replaced by dot (.).

For result strings longer than $maxlen the result string will be
truncated to $maxlen-4 and C<...'> will be appended.  If $maxlen is 0
or undef it defaults to $DBI::neat_maxlen which, in turn, defaults to 400.

This function is designed to format values for human consumption.
It is used internally by the DBI for L</trace> output. It should
typically I<not> be used for formating values for database use
(see also L</quote>).

=item B<neat_list>

  $str = DBI::neat_list(\@listref, $maxlen, $field_sep);

Calls DBI::neat on each element of the list and returns a string
containing the results joined with $field_sep. $field_sep defaults
to C<", ">.

=item B<looks_like_number>

  @bool = DBI::looks_like_number(@array);

Returns true for each element that looks like a number.
Returns false for each element that does not look like a number.
Returns undef for each element that is undefined or empty.

=back


=head2 DBI Dynamic Attributes

These attributes are always associated with the last handle used.

Where an attribute is equivalent to a method call, then refer to
the method call for all related documentation.

B<Warning:> these attributes are provided as a convenience but they
do have limitations. Specifically, because they are associated with
the last handle used, they should only be used I<immediately> after
calling the method which 'sets' them. They have a 'short lifespan'.

If in any doubt, use the corresponding method call.

=over 4

=item B<$DBI::err>

Equivalent to $h->err.

=item B<$DBI::errstr>

Equivalent to $h->errstr.

=item B<$DBI::state>

Equivalent to $h->state.

=item B<$DBI::rows>

Equivalent to $h->rows. Please refer to the L</rows> method documentation.

=back


=head1 METHODS COMMON TO ALL HANDLES

=over 4

=item B<err>

  $rv = $h->err;

Returns the native database engine error code from the last driver
function called.

=item B<errstr>

  $str = $h->errstr;

Returns the native database engine error message from the last driver
function called.

=item B<state>

  $str = $h->state;

Returns an error code in the standard SQLSTATE five character format.
Note that the specific success code C<00000> is translated to C<0>
(false). If the driver does not support SQLSTATE then state will
return C<S1000> (General Error) for all errors.

=item B<trace>

  $h->trace($trace_level);
  $h->trace($trace_level, $trace_filename);

DBI trace information can be enabled for a specific handle (and any
future children of that handle) by setting the trace level using the
trace method.

Use $trace_level 2 to see detailed call trace information including
parameters and return values.  The trace output is detailed and
typically I<very> useful.

Use $trace_level 0 to disable the trace.

Initially trace output is written to STDERR.  If $trace_filename is
specified then the file is opened in append mode and I<all> trace
output (including that from other handles) is redirected to that file.
Further calls to trace without a $trace_filename do not alter where
the trace output is sent.

See also the DBI->trace() method and L</DEBUGGING> for information
about the DBI_TRACE environment variable. The L</neat> function is
often used to format trace information and thus strings in the trace
output may be edited and truncated by it.

=item B<trace_msg>

  $h->trace_msg($message_text);

Writes $message_text to trace file if trace is enabled for $h or
for the DBI as a whole. Can also be called as DBI->trace_msg($msg).
See L</trace>.

=item B<func>

  $h->func(@func_arguments, $func_name);

The func method can be used to call private non-standard and
non-portable methods implemented by the driver. Note that the function
name is given as the I<last> argument.

This method is not directly related to calling stored procedures.
Calling stored procedures is currently not defined by the DBI.
Some drivers, such as DBD::Oracle, support it in non-portable ways.
See driver documentation for more details.

=back


=head1 ATTRIBUTES COMMON TO ALL HANDLES

These attributes are common to all types of DBI handles.

Some attributes are inherited by I<child> handles. That is, the value
of an inherited attribute in a newly created statement handle is the
same as the value in the parent database handle. Changes to attributes
in the new statement handle do not affect the parent database handle
and changes to the database handle do not affect I<existing> statement
handles, only future ones.

Attempting to set or get the value of an unknown attribute is fatal,
except for private driver specific attributes (which all have names
starting with a lowercase letter).

Example:

  $h->{AttributeName} = ...;	# set/write
  ... = $h->{AttributeName};	# get/read

=over 4

=item B<Warn> (boolean, inherited)

Enables useful warnings for certain bad practices. Enabled by default. Some
emulation layers, especially those for perl4 interfaces, disable warnings.
Since warnings are generated using the perl warn() function they can be
intercepted using the perl $SIG{__WARN__} hook.

=item B<Active> (boolean, read-only)

True if the handle object is 'active'. This is rarely used in
applications. The exact meaning of active is somewhat vague at the
moment. For a database handle it typically means that the handle is
connected to a database ($dbh->disconnect should set Active off).  For
a statement handle it I<typically> means that the handle is a select
that may have more data to fetch ($dbh->finish or fetching all the data
should set Active off).

=item B<Kids> (integer, read-only)

For a driver handle, Kids is the number of currently existing database
handles that were created from that driver handle.  For a database
handle, Kids is the number of currently existing statement handles that
were created from that database handle.

=item B<ActiveKids> (integer, read-only)

Like Kids (above), but only counting those that are Active (as above).

=item B<CachedKids> (hash ref)

For a database handle, returns a reference to the cache (hash) of
statement handles created by the L</prepare_cached> method.  For a
driver handle, it would return a reference to the cache (hash) of
statement handles created by the (not yet implemented) connect_cached
method.

=item B<CompatMode> (boolean, inherited)

Used by emulation layers (such as Oraperl) to enable compatible behaviour
in the underlying driver (e.g., DBD::Oracle) for this handle. Not normally
set by application code.

=item B<InactiveDestroy> (boolean)

This attribute can be used to disable the database related effect of
DESTROY'ing a handle (which would normally close a prepared statement
or disconnect from the database etc). It is specifically designed for
use in UNIX applications which 'fork' child processes. Either the
parent or the child process, but not both, should set InactiveDestroy
on all their handles. For a database handle, this attribute does not
disable an I<explicit> call to the disconnect method, only the implicit
call from DESTROY.

=item B<PrintError> (boolean, inherited)

This attribute can be used to force errors to generate warnings (using
warn) in addition to returning error codes in the normal way.  When set
on, any method which results in an error occuring will cause the DBI to
effectively do a warn("$class $method failed: $DBI::errstr") where $class
is the driver class and $method is the name of the method which failed. E.g.,

  DBD::Oracle::db prepare failed: ... error text here ...

By default DBI->connect sets PrintError on (except for old-style connect
usage, see L</connect> for more details).

If desired, the warnings can be caught and processed using a $SIG{__WARN__}
handler or modules like CGI::ErrorWrap.

=item B<RaiseError> (boolean, inherited)

This attribute can be used to force errors to raise exceptions rather
than simply return error codes in the normal way. It defaults to off.
When set on, any method which results in an error occuring will cause
the DBI to effectively do a die("$class $method failed: $DBI::errstr")
where $class is the driver class and $method is the name of the method
which failed. E.g.,

  DBD::Oracle::db prepare failed: ... error text here ...

If PrintError is also on then the PrintError is done before the
RaiseError unless no __DIE__ handler has been defined, in which case
PrintError is skipped since the die will print the message.

If you want to temporarily turn RaiseError off (inside a library function
that is likely to fail for example), the recommended way is like this:

  {
    local $h->{RaiseError} = 0 if $h->{RaiseError};
    ...
  }

The original value will automatically and reliably be restored by perl
regardless of how the block is exited. The C<... if $h->{RaiseError}> is
optional but makes the code slightly faster in the common case.
The same logic applies to other attributes, including RaiseError.

B<Sadly this doesn't work> for perl versions upto and including 5.004_04.
For backwards compatibility could just use C<eval { ... }> instead.


=item B<ChopBlanks> (boolean, inherited)

This attribute can be used to control the trimming of trailing space
characters from I<fixed width> character (CHAR) fields. No other field
types are affected, even where field values have trailing spaces.

The default is false (it is possible that that may change).
Applications that need specific behaviour should set the attribute as
needed. Emulation interfaces should set the attribute to match the
behaviour of the interface they are emulating.

Drivers are not required to support this attribute but any driver which
does not must arrange to return undef as the attribute value.


=item B<LongReadLen> (unsigned integer, inherited)

This attribute may be used to control the maximum length of 'long'
('blob', 'memo' etc.) fields which the driver will I<read> from the
database automatically when it fetches each row of data.  The
LongReadLen attribute only relates to fetching/reading long values it
is I<not> involved in inserting/updating them.

A value of 0 means don't automatically fetch any long data (fetch
should return undef for long fields when LongReadLen is 0).

The default is typically 0 (zero) bytes but may vary between drivers.
Most applications fetching long fields will set this value to slightly
larger than the longest long field value which will be fetched.

Changing the value of LongReadLen for a statement handle I<after> it's
been prepare()'d I<will typically have no effect> so it's usual to
set LongReadLen on the $dbh before calling prepare.

Note that the value used here has a direct effect on the memory used
by the application, so don't be too generous. It's also a good idea
to use values which are just smaller than a power of 2, e.g., 2**16-2
which is 65534 bytes.

See L</LongTruncOk> about truncation behaviour.

=item B<LongTruncOk> (boolean, inherited)

This attribute may be used to control the effect of fetching a long
field value which has been truncated (typically because it's longer
than the value of the LongReadLen attribute).

By default LongTruncOk is false and fetching a truncated long value
will cause the fetch to fail. (Applications should always take care to
check for errors after a fetch loop in case an error, such as a divide
by zero or long field truncation, caused the fetch to terminate
prematurely.)

If a fetch fails due to a long field truncation when LongTruncOk is
false, many drivers will allow you to continue fetching further rows.

See also L</LongReadLen>.

=item B<Taint> (boolean, inherited)

If this attribute it set to some true value and Perl is running in
taint mode (e.g., started with the C<-T> option), then a) all data
fetched from the database is tainted, and b) the arguments to most DBI
method calls are checked for being tainted. I<This may change.>

The attribute defaults to off, if when perl is started with the C<-T>
option. See L<perlsec> for more about taint mode.  If Perl is not
running in taint mode, this attribute has no effect.

Currently only fetched data is tainted. It is likely that the results
of other DBI method calls, and the value of fetched attributes, will
also be tainted in future versions. That change may well break your
applications unless you take great care now. If you use DBI Taint mode,
please report your experience and any suggestions for changes.


=item B<private_*>

The DBI provides a way to store extra information in a DBI handle as
'private' attributes. The DBI will allow you to store and retreive any
attribute which has a name starting with 'private_'. It is I<strongly>
recommended that you use just I<one> private attribute (e.g., use a
hash ref) I<and> give it a long and unambiguous name that includes the
module or application that the attribute relates to (e.g.,
'private_YourFullModuleName_thingy').

=back


=head1 DBI DATABASE HANDLE OBJECTS

=head2 Database Handle Methods

=over 4

=item B<selectrow_array>

  @row_ary = $dbh->selectrow_array($statement);
  @row_ary = $dbh->selectrow_array($statement, \%attr);
  @row_ary = $dbh->selectrow_array($statement, \%attr, @bind_values);

This utility method combines L</prepare>, L</execute> and
L</fetchrow_array> into a single call. If called in a list context it
returns the first row of data from the statement. If called in a scalar
context it returns the first field of the first row. The $statement
parameter can be a previously prepared statement handle in which case
the prepare is skipped.

In any method fails, and L</RaiseError> is not set, selectrow_array
will return an empty list (or undef in scalar context).

=item B<selectall_arrayref>

  $ary_ref = $dbh->selectall_arrayref($statement);
  $ary_ref = $dbh->selectall_arrayref($statement, \%attr);
  $ary_ref = $dbh->selectall_arrayref($statement, \%attr, @bind_values);

This utility method combines L</prepare>, L</execute> and L</fetchall_arrayref>
into a single call. The $statement parameter can be a previously prepared 
statement handle in which case the prepare is skipped.

In any method fails, and L</RaiseError> is not set, selectall_arrayref
will return undef.

=item B<prepare>

  $sth = $dbh->prepare($statement)          || die $dbh->errstr;
  $sth = $dbh->prepare($statement, \%attr)  || die $dbh->errstr;

Prepares a I<single> statement for later execution by the database
engine and returns a reference to a statement handle object.

The returned statement handle can be used to get attributes of the
statement and invoke the L</execute> method. See L</Statement Handle Methods>.

Note that prepare should never execute a statement, even if it is not a
select statement, it only I<prepares> it for execution. (Having said that,
some drivers, notably Oracle 7, will execute data definition statements
such as create/drop table when they are prepared. In practice this is
rarely a problem.)

Drivers for engines which don't have the concept of preparing a
statement will typically just store the statement in the returned
handle and process it when $sth->execute is called. Such drivers are
likely to be unable to give much useful information about the
statement, such as $sth->{NUM_OF_FIELDS}, until after $sth->execute
has been called. Portable applications should take this into account.

In general DBI drivers do I<not> parse the contents of the statement
(other than simply counting any L</Placeholders>). The statement is
passed directly to the database engine (sometimes known as pass-thru
mode). This has advantages and disadvantages. On the plus side, you can
access all the functionality of the engine being used. On the downside,
you're limited if using a simple engine and need to take extra care if
attempting to write applications to be portable between engines.

Portable applications should not assume that a new statement can be
prepared and/or executed while still fetching results from a previous
statement.

Some command-line SQL tools use statement terminators, like a semicolon,
to indicate the end of a statement. Such terminators should not be
used with the DBI.


=item B<prepare_cached>

  $sth = $dbh->prepare_cached($statement)          || die $dbh->errstr;
  $sth = $dbh->prepare_cached($statement, \%attr)  || die $dbh->errstr;

Like L</prepare> except that the statement handled returned will be stored
in a hash associated with the $dbh. If another call is made to prepare_cached
with the I<same parameter values> then the corresponding cached $sth
will be returned (and the database server will not be contacted).

This cacheing can be useful in some applications but it can also cause
problems and should be used with care. Currently a warning will be
generated if the cached $sth being returned is active (i.e., is a
select that may still have data to be fetched).

The cache can be accessed (and cleared) via the L</CachedKids> attribute.


=item B<do>

  $rc  = $dbh->do($statement)           || die $dbh->errstr;
  $rc  = $dbh->do($statement, \%attr)   || die $dbh->errstr;
  $rv  = $dbh->do($statement, \%attr, @bind_values) || ...

Prepare and execute a single statement. Returns the number of rows
affected (-1 if not known or not available) or undef on error.

This method is typically most useful for I<non-select> statements which
either cannot be prepared in advance (due to a limitation of the
driver) or which do not need to be executed repeatedly. It should not
be used for select statements.

The default do method is logically similar to:

  sub do {
      my($dbh, $statement, $attr, @bind_values) = @_;
      my $sth = $dbh->prepare($statement, $attr) or return undef;
      $sth->execute(@bind_values) or return undef;
      my $rows = $sth->rows;
      ($rows == 0) ? "0E0" : $rows; # always return true if no error
  }

Example:

  my $rows_deleted = $dbh->do(q{
      delete from table
      where status = ?
  }, undef, 'DONE') || die $dbh->errstr;

Using placeholders and C<@bind_values> with the C<do> method can be
useful because it avoids the need to correctly quote any variables
in the $statement.

The C<q{...}> style quoting used in this example avoids clashing with
quotes that may be used in the SQL statement. Use the double-quote like
C<qq{...}> operator if you want to interpolate variables into the string.
See L<perlop/"Quote and Quote-like Operators"> for more details.

=item B<commit>

  $rc  = $dbh->commit     || die $dbh->errstr;

Commit (make permanent) the most recent series of database changes
if the database supports transactions.

If the database supports transactions and AutoCommit is on then the
commit should issue a "commit ineffective with AutoCommit" warning.

See also L</Transactions>.

=item B<rollback>

  $rc  = $dbh->rollback   || die $dbh->errstr;

Roll-back (undo) the most recent series of uncommitted database
changes if the database supports transactions.

If the database supports transactions and AutoCommit is on then the
rollback should issue a "rollback ineffective with AutoCommit" warning.

See also L</Transactions>.


=item B<disconnect>

  $rc = $dbh->disconnect  || warn $dbh->errstr;

Disconnects the database from the database handle. Typically only used
before exiting the program. The handle is of little use after disconnecting.

The transaction behaviour of the disconnect method is, sadly,
undefined.  Some database systems (such as Oracle and Ingres) will
automatically commit any outstanding changes, but others (such as
Informix) will rollback any outstanding changes.  Applications not
using AutoCommit should explicitly call commit or rollback before
calling disconnect.

The database is automatically disconnected (by the DESTROY method) if
still connected when there are no longer any references to the handle.
The DESTROY method for each driver I<should> implicitly call rollback to
undo any uncommitted changes. This is I<vital> behaviour to ensure that
incomplete transactions don't get committed simply because Perl calls
DESTROY on every object before exiting. Also, do not rely on the order
of object destruction during 'global destruction', it is undefined.

Generally if you want your changes to be commited or rolled back when
you disconnect then you should explicitly call L</commit> or L</rollback>
before disconnecting.

If you disconnect from a database while you still have active statement
handles you will get a warning. The statement handles should either be
cleared (destroyed) before disconnecting or the finish method called on
each one.


=item B<ping>

  $rc = $dbh->ping;

Attempts to determine, in a reasonably efficient way, if the database
server is still running and the connection to it is still working.

The default implementation currently always returns true without
actually doing anything. Individual drivers should implement this
function in the most suitable manner for their database engine.

Very few applications would have any use for this method. See the
specialist Apache::DBI module for one example usage.


=item B<table_info> *NEW*

B<Warning:> This method is experimental and may change or disappear.

  $sth = $dbh->table_info;

Returns an active statement handle that can be used to fetch
information about tables and views that exist in the database.

The handle has at least the following fields in the order show
below. Other fields, after these, may also be present.

B<TABLE_CAT>: Table catalogue identifier. NULL (undef) if not
applicable to data source (usually the case). Empty if not applicable
to the table.

B<TABLE_SCHEM>: The name of the schema containing the TABLE_NAME value.
NULL (undef) if not applicable to data source. Empty if not applicable
to the table.

B<TABLE_NAME>: Name of the table (or view, synonym, etc).

B<TABLE_TYPE>: One of the following: "TABLE", "VIEW", "SYSTEM TABLE",
"GLOBAL TEMPORARY", "LOCAL TEMPORARY", "ALIAS", "SYNONYM" or a data
source specific type identifier.

B<REMARKS>: A description of the table. May be NULL (undef).

Note that table_info might not return records for all tables.
Applications can use any valid table regardless of whether it's
returned by table_info.  See also L</tables>.

=item B<tables> *NEW*

B<Warning:> This method is experimental and may change or disappear.

  @names = $dbh->tables;

Returns a list of table and view names.  This list should include all
tables which can be used in a select statement without further
qualification. That typically means all the tables and views owned by
the current user and all those accessible via public synonyms/aliases
(excluding non-metadata system tables and views).

Note that table_info might not return records for all tables.
Applications can use any valid table regardless of whether it's
returned by tables.  See also L</table_info>.


=item B<type_info_all> *NEW*

B<Warning:> This method is experimental and may change or disappear.

  $type_info_all = $dbh->type_info_all;

Returns a reference to an array which holds information about each data
type variant supported by the database and driver. The array and its
contents should be treated as read-only.

The first item is a reference to a hash of Name => Index pairs. The
following items are references to arrays, one per supported data type
variant. The leading hash defines the names and order of the fields
within the following list of arrays. For example:

  $type_info_all = [
    {   TYPE_NAME         => 0,
	DATA_TYPE         => 1,
	COLUMN_SIZE       => 2,     # was PRECISION originally
	LITERAL_PREFIX    => 3,
	LITERAL_SUFFIX    => 4,
	CREATE_PARAMS     => 5,
	NULLABLE          => 6,
	CASE_SENSITIVE    => 7,
	SEARCHABLE        => 8,
	UNSIGNED_ATTRIBUTE=> 9,
	FIXED_PREC_SCALE  => 10,    # was MONEY originally
	AUTO_UNIQUE_VALUE => 11,    # was AUTO_INCREMENT originally
	LOCAL_TYPE_NAME   => 12,
	MINIMUM_SCALE     => 13,
	MAXIMUM_SCALE     => 14,
	NUM_PREC_RADIX    => 15,
    },
    [ 'VARCHAR', SQL_VARCHAR,
	undef, "'","'", undef,0, 1,1,0,0,0,undef,1,255, undef
    ],
    [ 'INTEGER', SQL_INTEGER,
	undef,  "", "", undef,0, 0,1,0,0,0,undef,0,  0, 10
    ],
  ];

Note that more than one row may have the same value in the DATA_TYPE
field if there are different ways to spell the type name and/or there
are varients of the type with different attributes (e.g., with and
without AUTO_UNIQUE_VALUE set, with and without UNSIGNED_ATTRIBUTE etc).

The rows are ordered by DATA_TYPE first and then by how closely each
type maps to the corresponding ODBC SQL data type, closest first.

The meaning of the fields is described in the documentation for
the L</type_info> method. The index values shown above (e.g.,
NULLABLE => 6) are for illustration only. Drivers may define the
fields with a different order.

This method is not normally used directly. The L</type_info> method
provides a more useful interface to the data.

=item B<type_info> *NEW*

B<Warning:> This method is experimental and may change or disappear.

  @type_info = $dbh->type_info($data_type);

Returns a list of hash references holding information about one or more
variants of $data_type (or a type I<reasonably compatible> with it).

If $data_type is SQL_ALL_TYPES then the list will contain hashes for
all data type variants supported by the database and driver.

The list is ordered by DATA_TYPE first and then by how closely each
type maps to the corresponding ODBC SQL data type, closest first.

The keys of the hash follow the same letter case conventions as the
rest of the DBI (see L</Naming Conventions and Name Space>). The
following items should exist:

=over 4

=item TYPE_NAME (string)

Data type name for use in CREATE TABLE statements etc.

=item DATA_TYPE (integer)

SQL data type number.

=item COLUMN_SIZE (integer)

For numeric types this is either the total number of digits (if the
NUM_PREC_RADIX value is 10) or the total number of bits allowed in the
column (if NUM_PREC_RADIX is 2).

For string types this is the maximum size of the string in bytes.

For date and interval types this is the maximum number of characters
needed to display the value.

=item LITERAL_PREFIX (string)

Characters used to prefix a literal. Typically "'" for characters,
possibly "0x" for binary values passed as hex.  NULL (undef) is
returned for data types where this is not applicable.


=item LITERAL_SUFFIX (string)

Characters used to suffix a literal. Typically "'" for characters.
NULL (undef) is returned for data types where this is not applicable.

=item CREATE_PARAMS (string)

Parameters for a data type definition. For example, CREATE_PARAMS for a
DECIMAL would be "precision,scale". For a VARCHAR it would be "max length".
NULL (undef) is returned for data types where this is not applicable.

=item NULLABLE (integer)

Indicates whether the data type accepts a NULL value:
0 = no, 1 = yes, 2 = unknown.

=item CASE_SENSITIVE (boolean)

Indicates whether the data type is case sensitive in collations and
comparisons.

=item SEARCHABLE (integer)

Indicates how the data type can be used in a WHERE clause:

  0 - cannot be used in a WHERE clause
  1 - only with a LIKE predicate
  2 - all comparison operators except LIKE
  3 - can be used in a WHERE clause with any comparison operator

=item UNSIGNED_ATTRIBUTE (boolean)

Indicates whether the data type is unsigned.  NULL (undef) is returned
for data types where this is not applicable.

=item FIXED_PREC_SCALE (boolean)

Indicates whether the data type always has the same precision and scale
(such as a money type).  NULL (undef) is returned for data types where
this is not applicable.

=item AUTO_UNIQUE_VALUE (boolean)

Indicates whether a column of this data type is automatically set to a
unique value whenever a new row is inserted.  NULL (undef) is returned
for data types where this is not applicable.

=item LOCAL_TYPE_NAME (string)

Localised version of the TYPE_NAME for use in dialogue with users.
NULL (undef) is returned if a localised name is not available (in which
case TYPE_NAME should be used).

=item MINIMUM_SCALE (integer)

The minimum scale of the data type. If a data type has a fixed scale
then MAXIMUM_SCALE holds the same value.  NULL (undef) is returned for
data types where this is not applicable.

=item MAXIMUM_SCALE (integer)

The maximum scale of the data type. If a data type has a fixed scale
then MINIMUM_SCALE holds the same value.  NULL (undef) is returned for
data types where this is not applicable.

=item NUM_PREC_RADIX (integer)

The radix value of the data type. For approximate numeric types this
contains the value 2 and COLUMN_SIZE holds the number of bits. For
exact numeric types this contains the value 10 and COLUMN_SIZE holds
the number of decimal digits. NULL (undef) is returned for data types
where this is not applicable.

=back


=item B<quote>

  $sql = $dbh->quote($value);
  $sql = $dbh->quote($value, $data_type);

Quote a string literal for use as a literal value in an SQL statement
by I<escaping> any special characters (such as quotation marks)
contained within the string I<and> adding the required type of outer
quotation marks.

  $sql = sprintf "select foo from bar where baz = %s",
                $dbh->quote("Don't\n");

For most database types quote would return C<'Don''t'> (including the
outer quotation marks).

An undefined $value value will be returned as the string NULL (without
quotation marks).

If $data_type is supplied it is used to try to determine the required
quoting behaviour by using the information returned by L</type_info>.
As a special case, the standard numeric types are optimised to return
$value without calling type_info.

Quote will probably I<not> be able to deal with all possible input
(such as binary data or data containing newlines) and is not related in
any way with escaping or quoting shell meta-characters. There is no
need to quote values being used with L</"Placeholders and Bind Values">.

=back


=head2 Database Handle Attributes

This section describes attributes specific to database handles.

Changes to these database handle attributes do not affect any other
existing or future database handles.

Attempting to set or get the value of an unknown attribute is fatal,
except for private driver specific attributes (which all have names
starting with a lowercase letter).

Example:

  $h->{AutoCommit} = ...;	# set/write
  ... = $h->{AutoCommit};	# get/read

=over 4

=item B<AutoCommit>  (boolean)

If true then database changes cannot be rolled-back (undone).  If false
then database changes automatically occur within a 'transaction' which
must either be committed or rolled-back using the commit or rollback
methods.

Drivers should always default to AutoCommit mode. (An unfortunate
choice largely forced on the DBI by ODBC and JDBC conventions.)

Attempting to set AutoCommit to an unsupported value is a fatal error.
This is an important feature of the DBI. Applications which need
full transaction behaviour can set $dbh->{AutoCommit} = 0 (or via
L</connect>) without having to check the value was assigned okay.

For the purposes of this description we can divide databases into three
categories:

  Database which don't support transactions at all.
  Database in which a transaction is always active.
  Database in which a transaction must be explicitly started ('BEGIN WORK').

B<* Database which don't support transactions at all>

For these databases attempting to turn AutoCommit off is a fatal error.
Commit and rollback both issue warnings about being ineffective while
AutoCommit is in effect.

B<* Database in which a transaction is always active>

These are typically mainstream commercial relational databases with
'ANSI standard' transaction behaviour.

If AutoCommit is off then changes to the database won't have any
lasting effect unless L</commit> is called (but see also
L</disconnect>). If L</rollback> is called then any changes since the
last commit are undone.

If AutoCommit is on then the effect is the same as if the DBI were to
have called commit automatically after every successful database
operation. In other words, calling commit or rollback explicitly while
AutoCommit is on would be ineffective because the changes would
have already been commited.

Changing AutoCommit from off to on should issue a L</commit> in most drivers.

Changing AutoCommit from on to off should have no immediate effect.

For databases which don't support a specific auto-commit mode, the
driver has to commit each statement automatically using an explicit
COMMIT after it completes successfully (and roll it back using an
explicit ROLLBACK if it fails).  The error information reported to the
application will correspond to the statement which was executed, unless
it succeeded and the commit or rollback failed.

B<* Database in which a transaction must be explicitly started>

For these database the intention is to have them act like databases in
which a transaction is always active (as described above).

To do this the DBI driver will automatically begin a transaction when
AutoCommit is turned off (from the default on state) and will
automatically begin another transaction after a L</commit> or L</rollback>.

In this way, the application does not have to treat these databases as a
special case.

See L</disconnect> for other important notes about transactions.


=item B<Driver>  (handle)

Holds the handle of the parent Driver. The only recommended use for this
is to find the name of the driver using

  $dbh->{Driver}->{Name}


=item B<Name>  (string)

Holds the 'name' of the database. Usually (and recommended to be) the
same as the "dbi:DriverName:..." string used to connect to the database
but with the leading "dbi:DriverName:" removed.


=item B<RowCacheSize>  (integer) *NEW*

A hint to the driver indicating the size of local row cache the
application would like the driver to use for future select statements.
If a row cache is not implemented then setting RowCacheSize is ignored
and getting the value returns undef.

Some RowCacheSize values have special meaning:

  0 - Automatically determine a reasonable cache size for each select
  1 - Disable the local row cache
 >1 - Cache this many rows
 <0 - Cache as many rows fit into this much memory for each select.

Note that large cache sizes may require very large amount of memory
(cached rows * maximum size of row) and that a large cache will cause
a longer delay for the first fetch and when the cache needs refilling.

See also L</RowsInCache> statement handle attribute.

=back


=head1 DBI STATEMENT HANDLE OBJECTS

=head2 Statement Handle Methods

=over 4

=item B<bind_param>

  $rc = $sth->bind_param($p_num, $bind_value)  || die $sth->errstr;
  $rv = $sth->bind_param($p_num, $bind_value, \%attr)     || ...
  $rv = $sth->bind_param($p_num, $bind_value, $bind_type) || ...

The bind_param method can be used to I<bind> (assign/associate) a value
with a I<placeholder> embedded in the prepared statement. Placeholders
are indicated with question mark character (C<?>). For example:

  $dbh->{RaiseError} = 1;        # save having to check each method call
  $sth = $dbh->prepare("select name, age from people where name like ?");
  $sth->bind_param(1, "John%");  # placeholders are numbered from 1
  $sth->execute;
  DBI::dump_results($sth);

Note that the C<?> is not enclosed in quotation marks even when the
placeholder represents a string.  Some drivers also allow C<:1>, C<:2>
etc and C<:name> style placeholders in addition to C<?> but their use
is not portable.  Undefined bind values or C<undef> are be used to
indicate null values.

Some drivers do not support placeholders.

With most drivers placeholders can't be used for any element of a
statement that would prevent the database server validating the
statement and creating a query execution plan for it. For example:

  "select name, age from ?"         # wrong (will probably fail)
  "select name, ?   from people"    # wrong (but may not 'fail')

Also, placeholders can only represent single scalar values, so this
statement, for example, won't work as expected for more than one value:

  "select name, age from people where name in (?)"    # wrong

B<Data Types for Placeholders>

The C<\%attr> parameter can be used to hint at the data type the
placeholder should have. Typically the driver is only interested in
knowing if the placeholder should be bound as a number or a string.

  $sth->bind_param(1, $value, { TYPE => SQL_INTEGER });

As a short-cut for this common case, the data type can be passed
directly inplace of the attr hash reference. This example is
equivalent to the one above:

  $sth->bind_param(1, $value, SQL_INTEGER);

The TYPE value indicates the I<standard> (non-driver-specific) type for
this parameter. To specify the driver-specific type the driver I<may>
support a driver-specific attribute, e.g., { ora_type => 97 }.  The
data type for a placeholder cannot be changed after the first
bind_param call (but it can be left unspecified, in which case it
defaults to the previous value).

Perl only has string and number scalar data types. All database types
that aren't numbers are bound as strings and must be in a format the
database will understand.

As an alternative to specifying the data type in the bind_param call,
you can let the driver pass the value as the default type (VARCHAR)
then use an SQL function to convert the type within the statement.
E.g.,

  insert into price(code, price) values (?, convert(money,?))

The convert function used here is just an example. The actual function
and syntax will vary between different databases (and so is obviously
non-portable).

See also L</"Placeholders and Bind Values"> for more information.


=item B<bind_param_inout>

  $rc = $sth->bind_param_inout($p_num, \$bind_value, $max_len)  || die $sth->errstr;
  $rv = $sth->bind_param_inout($p_num, \$bind_value, $max_len, \%attr)     || ...
  $rv = $sth->bind_param_inout($p_num, \$bind_value, $max_len, $bind_type) || ...

This method acts like L</bind_param> but also enables values to be
I<output from> (updated by) the statement. The statement is typically
a call to a stored procedure. The $bind_value must be passed as a
I<reference> to the actual value to be used.

Note that unlike L</bind_param>, the $bind_value variable is I<not>
read when bind_param_inout is called. Instead, the value in the
variable is read at the time L</execute> is called.

The additional $max_len parameter specifies the minimum amount of
memory to allocate to $bind_value for the new value. If the value is too
big to fit then the execute should fail. If unsure what value to use,
pick a generous length larger than the longest value that would ever be
returned.  The only cost of using a very large value is memory.

It is expected that few drivers will support this method. The only
driver currently known to do so is DBD::Oracle (DBD::ODBC may support
it in a future release). Therefore it should I<not> be used for database
independent applications.

Undefined values or C<undef> are be used to indicate null values.
See also L</"Placeholders and Bind Values"> for more information.


=item B<execute>

  $rv = $sth->execute                || die $sth->errstr;
  $rv = $sth->execute(@bind_values)  || die $sth->errstr;

Perform whatever processing is necessary to execute the prepared
statement.  An undef is returned if an error occurs, a successful
execute always returns true regardless of the number of rows affected
(even if it's zero, see below). It is always important to check the
return status of execute (and most other DBI methods) for errors.

For a I<non-select> statement, execute returns the number of rows
affected (if known). If no rows were affected then execute returns
"0E0" which Perl will treat as 0 but will regard as true. Note that it
is I<not> an error for no rows to be affected by a statement. If the
number of rows affected is not known then execute returns -1.

For I<select> statements execute simply 'starts' the query within the
Engine. Use one of the fetch methods to retreive the data after
calling execute.  The execute method does I<not> return the number of
rows that will be returned by the query (because most Engines can't
tell in advance), it simply returns a true value.

If any arguments are given then execute will effectively call
L</bind_param> for each value before executing the statement.
Values bound in this way are usually treated as SQL_VARCHAR types
unless the driver can determine the correct type (which is rare) or
bind_param (or bind_param_inout) has already been used to specify the
type.


=item B<fetchrow_arrayref>

  $ary_ref = $sth->fetchrow_arrayref;
  $ary_ref = $sth->fetch;    # alias

Fetches the next row of data and returns a reference to an array
holding the field values.  Null field values are returned as undef.
This is the fastest way to fetch data, particularly if used with
$sth->bind_columns.

If there are no more rows I<or> an error occurs then fetchrow_arrayref
returns an undef. You should check $sth->err afterwards (or use the
RaiseError attribute) to discover if the undef returned was due to an
error.

Note that I<currently> the I<same> array ref will be returned for each
fetch so don't store the ref and then use it after a later fetch.

=item B<fetchrow_array>

 @ary = $sth->fetchrow_array;

An alternative to C<fetchrow_arrayref>. Fetches the next row of data
and returns it as an array holding the field values.  Null values are
returned as undef.

If there are no more rows I<or> an error occurs then fetchrow_array
returns an empty list. You should check $sth->err afterwards (or use
the RaiseError attribute) to discover if the empty list returned was
due to an error.

=item B<fetchrow_hashref>

 $hash_ref = $sth->fetchrow_hashref;
 $hash_ref = $sth->fetchrow_hashref($name);

An alternative to C<fetchrow_arrayref>. Fetches the next row of data
and returns it as a reference to a hash containing field name and field
value pairs.  Null values are returned as undef.

If there are no more rows I<or> an error occurs then fetchrow_hashref
returns an undef. You should check $sth->err afterwards (or use the
RaiseError attribute) to discover if the undef returned was due to an
error.

The optional $name parameter specifies the name of the statement handle
attribute to use to get the field names. It defaults to 'L</NAME>'.

The keys of the hash are the same names returned by $sth->{$name}. If
more than one field has the same name there will only be one entry in
the returned hash for those fields.

Note that using fetchrow_hashref is currently I<not portable> between
databases because different databases return fields names with
different letter cases (some all uppercase, some all lower, and some
return the letter case used to create the table). This will be addressed
in a future version of the DBI.

Because of the extra work fetchrow_hashref and perl have to perform it
is not as efficient as fetchrow_arrayref or fetchrow_array and is not
recommended where performance is very important. Currently a new hash
reference is returned for each row.  This is likely to change in the
future so don't rely on it.


=item B<fetchall_arrayref>

  $tbl_ary_ref = $sth->fetchall_arrayref;
  $tbl_ary_ref = $sth->fetchall_arrayref( $slice_array_ref );
  $tbl_ary_ref = $sth->fetchall_arrayref( $slice_hash_ref  );

The C<fetchall_arrayref> method can be used to fetch all the data to be
returned from a prepared and executed statement handle. It returns a
reference to an array which contains one reference per row.

If there are no rows to return, fetchall_arrayref returns a reference
to an empty array. If an error occurs fetchall_arrayref returns the
data fetched thus far, which may be none.  You should check $sth->err
afterwards (or use the RaiseError attribute) to discover if the data is
complete or was truncated due to an error.

When passed an array reference, fetchall_arrayref uses L</fetchrow_arrayref>
to fetch each row as an array ref. If the parameter array is not empty
then it is used as a slice to select individual columns by index number.

With no parameters, fetchall_arrayref acts as if passed an empty array ref.

When passed a hash reference, fetchall_arrayref uses L</fetchrow_hashref>
to fetch each row as a hash ref. If the parameter hash is not empty
then it is used as a slice to select individual columns by name. The
names should be lower case regardless of the letter case in $sth->{NAME}.
The values of the hash should be set to 1.

For example, to fetch just the first column of every row you can use:

  $tbl_ary_ref = $sth->fetchall_arrayref([0]);

To fetch the second to last and last column of every row you can use:

  $tbl_ary_ref = $sth->fetchall_arrayref([-2,-1]);

To fetch only the fields called foo and bar of every row you can use:

  $tbl_ary_ref = $sth->fetchall_arrayref({ foo=>1, bar=>1 });

The first two examples return a ref to an array of array refs. The last
returns a ref to an array of hash refs.


=item B<finish>

  $rc  = $sth->finish;

Indicates that no more data will be fetched from this statement handle
before it is either executed again or destroyed.  I<It is rarely needed>
but can sometimes be helpful in very specific situations in order to
allow the server to free up resources currently being held (such as
sort buffers).

When all the data has been fetched from a select statement the driver
should automatically call finish for you. So you should not normally
need to call it explicitly.

Consider a query like

  SELECT foo FROM table WHERE bar=? ORDER BY foo

where you want to select just the first (smallest) foo value from a
very large table. When executed the database server will have to use
temporary buffer space to store the sorted rows. If, after executing
the handle and selecting one row, the handle won't be re-executed for
some time and won't be destroyed, the finish method can be used to tell
the server that the buffer space can be freed.

Calling finish resets the L</Active> attribute for the statement.  It
may also make some statement handle attributes, like NAME and TYPE etc.,
unavailable if they have not already been accessed (and thus cached).

The finish method does not affect the transaction status of the
session.  It has nothing to do with transactions. It's mostly an
internal 'housekeeping' method that is rarely needed. There's no need
to call finish if you're about to destroy or re-execute the statement
handle.  See also L</disconnect> and the L</Active> attribute.


=item B<rows>

  $rv = $sth->rows;

Returns the number of rows affected by the last row affecting command,
or -1 if not known or not available.

Generally you can only rely on a row count after a I<non>-select
C<execute> (for some specific operations like update and delete) or
after fetching I<all> the rows of a select statement.

For select statements it is generally not possible to know how many
rows will be returned except by fetching them all.  Some drivers will
return the number of rows the application has fetched I<so far> but
others may return -1 until all rows have been fetched.  So, use of the
rows method, or $DBI::rows, with select statements is I<not>
recommended.


=item B<bind_col>

  $rc = $sth->bind_col($column_number, \$var_to_bind);

Binds an output column (field) of a select statement to a perl variable.
You do not need to do this but it can be useful for some applications.

Whenever a row is fetched from the database the corresponding perl
variable is automatically updated. There is no need to fetch and assign
the values manually. This makes using bound variables very efficient.
See bind_columns below for an example.  Note that column numbers count
up from 1.

The binding is performed at a very low level using perl aliasing so
there is no extra copying taking place. So long as the driver uses the
correct internal DBI call to get the array the fetch function returns,
it will automatically support column binding.

For maximum portability between drivers, bind_col should be called after
execute.

The L</bind_param> method performs a similar function for input variables.

=item B<bind_columns>

  $rc = $sth->bind_columns(@list_of_refs_to_vars_to_bind);

Calls L</bind_col> for each column of the select statement.  You do not
need to bind columns but it can be useful for some applications.
The bind_columns method will die if the number of references does not
match the number of fields.

For maximum portability between drivers, bind_columns should be called after
execute.

For example:

  $dbh->{RaiseError} = 1; # do this, or check every call for errors
  $sth = $dbh->prepare(q{ select region, sales from sales_by_region });
  $sth->execute;
  my ($region, $sales);

  # Bind perl variables to columns:
  $rv = $sth->bind_columns(\$region, \$sales);

  # you can also use perl's \(...) syntax (see perlref docs):
  #     $sth->bind_columns(\($region, $sales));

  # Column binding is the most efficient way to fetch data
  while ($sth->fetch) {
      print "$region: $sales\n";
  }

For compatibility with old scripts, if the first parameter is undef or
a hash reference it will be ignored.


=item B<dump_results>

  $rows = $sth->dump_results($maxlen, $lsep, $fsep, $fh);

Fetches all the rows from $sth, calls DBI::neat_list for each row and
prints the results to $fh (defaults to C<STDOUT>) separated by $lsep
(default C<"\n">). $fsep defaults to C<", "> and $maxlen defaults to 35.

This method is designed as a handy utility for prototyping and
testing queries. Since it uses L</neat_list> which uses L</neat> which
formats and edits the string for reading by humans, it's not recomended
for data transfer applications.

=back


=head2 Statement Handle Attributes

This section describes attributes specific to statement handles. Most
of these attributes are read-only.

Changes to these statement handle attributes do not affect any other
existing or future statement handles.

Attempting to set or get the value of an unknown attribute is fatal,
except for private driver specific attributes (which all have names
starting with a lowercase letter).

Example:

  ... = $h->{NUM_OF_FIELDS};	# get/read

Note that some drivers cannot provide valid values for some or all of
these attributes until after $sth->execute has been called.

See also L</finish> for the effect it may have on some attributes.

=over 4

=item B<NUM_OF_FIELDS>  (integer, read-only)

Number of fields (columns) the prepared statement will return. Non-select
statements will have NUM_OF_FIELDS == 0.


=item B<NUM_OF_PARAMS>  (integer, read-only)

The number of parameters (placeholders) in the prepared statement.
See SUBSTITUTION VARIABLES below for more details.


=item B<NAME>  (array-ref, read-only)

Returns a I<reference> to an array of field names for each column. The
names may contain spaces but should not be truncated or have any
trailing space. Note that the names have the letter case (upper, lower
or mixed) as returned by the driver being used. Portable applications
should use L</NAME_lc> or L</NAME_uc>.

  print "First column name: $sth->{NAME}->[0]\n";

=item B<NAME_lc>  (array-ref, read-only)

Like L</NAME> but always returns lowercase names.

=item B<NAME_uc>  (array-ref, read-only)

Like L</NAME> but always returns uppercase names.

=item B<TYPE>  (array-ref, read-only) *NEW*

Returns a I<reference> to an array of integer values for each
column. The value indicates the data type of the corresponding column.

The values used correspond to the international standards (ANSI X3.135
and ISO/IEC 9075) which, in general terms, means ODBC. Driver specific
types which don't exactly match standard types should generally return
the same values as an ODBC driver supplied by the makers of the
database. That might include private type numbers in ranges the vendor
has officially registered. See:

  ftp://jerry.ece.umassd.edu/isowg3/dbl/SQL_Registry

Where there's no vendor supplied ODBC driver to be compatible with, the
DBI driver can use type numbers in the range now I<officially> reserved
for use by the DBI: -9999 to -9000.

All possible values for TYPE should have at least one entry in the
output of the C<type_info_all()> method (see L</type_info_all>).

=item B<PRECISION>  (array-ref, read-only) *NEW*

Returns a I<reference> to an array of integer values for each
column.  For nonnumeric columns the value generally refers to either
the maximum length or the defined length of the column.  For numeric
columns the value refers to the maximum number of significant digits
used by the data type (without considering a sign character or decimal
point).  Note that for floating point types (REAL, FLOAT, DOUBLE) the
'display size' can be up to 7 characters greater than the precision
(for the sign + decimal point + the letter E + a sign + 2 or 3 digits).

=item B<SCALE>  (array-ref, read-only) *NEW*

Returns a I<reference> to an array of integer values for each column.
NULL (undef) values indicate columns where scale is not applicable.

=item B<NULLABLE>  (array-ref, read-only)

Returns a I<reference> to an array indicating the possibility of each
column returning a null: 0 = no, 1 = yes, 2 = unknown.

  print "First column may return NULL\n" if $sth->{NULLABLE}->[0];


=item B<CursorName>  (string, read-only)

Returns the name of the cursor associated with the statement handle if
available. If not available or the database driver does not support the
C<"where current of ..."> SQL syntax then it returns undef.


=item B<Statement>  (string, read-only) *NEW*

Returns the statement string passed to the L</prepare> method.


=item B<RowsInCache>  (integer, read-only) *NEW*

If the driver supports a local row cache for select statements then
this attribute holds the number of un-fetched rows in the cache. If the
driver doesn't, then it returns undef. Note that some drivers pre-fetch
rows on execute, others wait till the first fetch.

See also the L</RowCacheSize> database handle attribute.

=back


=head1 FURTHER INFORMATION

=head2 Transactions

Transactions are a fundamental part of any robust database system. They
protect against errors and database corruption by ensuring that sets of
related changes to the database take place in atomic (indivisible,
all-or-nothing) units.

This section applies to databases which support transactions and where
AutoCommit is I<off>.  See L</AutoCommit> for details of using AutoCommit
with various types of database.

The recommended way to implement robust transactions in Perl
applications is to make use of S<C<eval { ... }>> (which is very fast,
unlike S<C<eval "...">>).

  eval {
      foo(...)   # do lots of work here
      bar(...)   # including inserts
      baz(...)   # and updates
  };
  if ($@) {
      # $@ contains $DBI::errstr if DBI RaiseError caused die
      $dbh->rollback;
      # add other application on-error-clean-up code here
  }
  else {
      $dbh->commit;
  }

The code in foo(), or any other code executed from within the curly braces,
can be implemented in this way:

  $h->method(@args) || die $h->errstr

or the $h->{RaiseError} attribute can be set on. With RaiseError set
the DBI will automatically die if any DBI method call on that
handle (or a child handle) fails, so you don't have to test the return
value of each method call. See L</RaiseError> for more details.

A major advantage of the eval approach is that the transaction will be
properly rolled back if I<any> code in the inner application dies
for I<any> reason. The major advantage of using the $h->{RaiseError}
attribute is that all DBI calls will be checked automatically. Both
techniques are strongly recommended.


=head2 Handling BLOB / LONG / Memo Fields

Many databases support 'blob' (binary large objects), 'long' or similar
datatypes for holding very long strings or large amounts of binary
data in a single field. Some databases support variable length long
values over 2,000,000,000 bytes in length.

Since values of that size can't usually be held in memory and because
databases can't usually know in advance the length of the longest long
that will be returned from a select statement (unlike other data
types) some special handling is required.

In this situation the value of the $h->{LongReadLen} attribute is used
to determine how much buffer space to allocate when I<fetching> such
fields.  The $h->{LongTruncOk} attribute is used to determine how to
behave if a fetched value can't fit into the buffer.

When trying to insert long or binary values, placeholders should be used
since there are often limits on the maximum size of an (insert)
statement and the L</quote> method generally can't cope with binary
data.  See L</Placeholders and Bind Values>.


=head2 Simple Examples

Here's a complete example program to select and fetch some data:

  my $dbh = DBI->connect("dbi:DriverName:db_name", $user, $password)
      || die "Can't connect to $data_source: $DBI::errstr";

  my $sth = $dbh->prepare( q{
          SELECT name, phone
          FROM mytelbook
  }) || die "Can't prepare statement: $DBI::errstr";

  my $rc = $sth->execute
      || die "Can't execute statement: $DBI::errstr";

  print "Query will return $sth->{NUM_OF_FIELDS} fields.\n\n";
  print "Field names: @{ $sth->{NAME} }\n";

  while (($name, $phone) = $sth->fetchrow_array) {
      print "$name: $phone\n";
  }
  # check for problems which may have terminated the fetch early
  die $sth->errstr if $sth->err;

  $dbh->disconnect;

Here's a complete example program to insert some data from a file:
(this example uses RaiseError to avoid needing to check each call)

  my $dbh = DBI->connect("dbi:DriverName:db_name", $user, $password, {
      RaiseError => 1, AutoCommit => 0
  });

  my $sth = $dbh->prepare( q{
      INSERT INTO table (name, phone) VALUES (?, ?)
  });

  open FH, "<phone.csv" or die "Unable to open phone.csv: $!";
  while (<FH>) {
      chop;
      my ($name, $phone) = split /,/;
      $sth->execute($name, $phone);
  }
  close FH;

  $dbh->commit;
  $dbh->disconnect;

Converting fetched NULLs (undefined values) to empty strings:

  while($row = $sth->fetchrow_arrayref) {
    # this is a fast and simple way to deal with nulls:
    foreach (@$row) { $_ = '' unless defined }
    print "@$row\n";
  }

The C<q{...}> style quoting used in these example avoids clashing with
quotes that may be used in the SQL statement. Use the double-quote like
C<qq{...}> operator if you want to interpolate variables into the string.
See L<perlop/"Quote and Quote-like Operators"> for more details.


=head2 Threads and Thread Safety

Perl versions 5.004_50 and later support threads on many platforms.
The DBI should build on these platforms but currently has made I<no>
attempt to be thread safe.


=head2 Signal Handling and Canceling Operations

The first thing to say is that signal handling in Perl is currently
I<not> safe. There is I<always> a small risk of Perl crashing and/or
core dumping when, or after, handling a signal.  (The risk was reduced
with 5.004_04 but is still present.)

The two most common uses of signals in relation to the DBI are for
canceling operations when the user types Ctrl-C (interrupt), and for
implementing a timeout using alarm() and $SIG{ALRM}.

To assist in implementing these operations the DBI provides a C<cancel>
method for statement handles. The cancel method should abort the current
operation and is designed to be called from a signal handler.

However, it must be stressed that: a) few drivers implement this at
the moment (the DBI provides a default method that just returns undef),
b) even if implemented there is still a possibility that the statement
handle, and possibly the parent database handle, will not be usable
afterwards.

If cancel returns true then it is implemented and has successfully
invoked the database engine's own cancel function. If it returns false
then cancel failed (undef if not implemented).


=head1 DEBUGGING

In addition to the L</trace> method you can enable the same trace
information by setting the DBI_TRACE environment variable before
starting perl.

On unix-like systems using a bourne-like shell you can do this easily
for a single command:

  DBI_TRACE=2 perl your_test_script.pl

If DBI_TRACE is set to a non-numeric value then it is assumed to
be a file name and the trace level will be set to 2 with all trace
output will be appended to that file.

See also the L</trace> method.


=head1 WARNING AND ERROR MESSAGES

(This section needs more words about causes and remedies.)

=head2 Fatal Errors

=over 4

=item Can't call method "prepare" without a package or object reference

The $dbh handle you're using to call prepare is probably undefined because
the preceeding connect failed. You should always check the return status of
DBI methods, or use the L</RaiseError> attribute.

=item Can't call method "execute" without a package or object reference

The $sth handle you're using to call execute is probably undefined because
the preceeding prepare failed. You should always check the return status of
DBI methods, or use the L</RaiseError> attribute.

=item Database handle destroyed without explicit disconnect

=item DBI/DBD internal version mismatch

=item DBD driver has not implemented the AutoCommit attribute

=item Can't [sg]et %s->{%s}: unrecognised attribute

=item panic: DBI active kids (%d) > kids (%d)

=item panic: DBI active kids (%d) < 0 or > kids (%d)

=back

=head2 Warnings

=over 4

=item DBI Handle cleared whilst still holding %d cached kids!

=item DBI Handle cleared whilst still active!

=item DBI Handle has uncleared implementors data

=item DBI Handle has %d uncleared child handles

=back

=head1 SEE ALSO

=head2 Database Documentation

SQL Language Reference Manual.

=head2 Books and Journals

 Programming Perl 2nd Ed. by Larry Wall, Tom Christiansen & Randal Schwartz.
 Learning Perl by Randal Schwartz.

 Dr Dobb's Journal, November 1996.
 The Perl Journal, April 1997.

=head2 Manual Pages

L<perl(1)>, L<perlmod(1)>, L<perlbook(1)>

=head2 Mailing List

The dbi-users mailing list is the primary means of communication among
uses of the DBI and its related modules. Subscribe and unsubscribe via:

 http://www.fugue.com/dbi

Mailing list archives are held at:

 http://www.rosat.mpe-garching.mpg.de/mailing-lists/PerlDB-Interest/
 http://www.xray.mpe.mpg.de/mailing-lists/#dbi
 http://outside.organic.com/mail-archives/dbi-users/
 http://www.coe.missouri.edu/~faq/lists/dbi.html

=head2 Assorted Related WWW Links

The DBI 'Home Page' (not maintained by me):

 http://www.symbolstone.org/technology/perl/DBI

Other DBI related links:

 http://eskimo.tamu.edu/~jbaker/dbi-examples.html
 http://tegan.deltanet.com/~phlip/DBUIdoc.html
 http://dc.pm.org/perl_db.html
 http://wdvl.com/Authoring/DB/Intro/toc.html
 http://www.hotwired.com/webmonkey/backend/tutorials/tutorial1.html

Other database related links:

 http://www.jcc.com/sql_stnd.html

Commercial and Data Warehouse Links

 http://www.datamining.org
 http://www.olapcouncil.org
 http://www.idwa.org
 http://www.knowledgecenters.org/dwcenter.asp
 http://pwp.starnetinc.com/larryg/
 http://www.data-warehouse.

Recommended Perl Programming Links

 http://language.perl.com/style/

=head2 FAQ

Please also read the DBI FAQ which is installed as a DBI::FAQ module so
you can use perldoc to read it by executing the C<perldoc DBI::FAQ> command.

=head1 AUTHORS

DBI by Tim Bunce.  This pod text by Tim Bunce, J. Douglas Dunlop,
Jonathan Leffler and others.  Perl by Larry Wall and the
perl5-porters.

=head1 COPYRIGHT

The DBI module is Copyright (c) 1995-1999 Tim Bunce. England.
All rights reserved.

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the Perl README file.

=head1 ACKNOWLEDGEMENTS

I would like to acknowledge the valuable contributions of the many
people I have worked with on the DBI project, especially in the early
years (1992-1994). In no particular order: Kevin Stock, Buzz Moschetti,
Kurt Andersen, Ted Lemon, William Hails, Garth Kennedy, Michael Peppler,
Neil S. Briscoe, Jeff Urlwin, David J. Hughes, Jeff Stander,
Forrest D Whitcher, Larry Wall, Jeff Fried, Roy Johnson, Paul Hudson,
Georg Rehfeld, Steve Sizemore, Ron Pool, Jon Meek, Tom Christiansen,
Steve Baumgarten, Randal Schwartz, and a whole lot more.

=head1 TRANSLATIONS

A German translation of this manual and other Perl module docs (all
probably slightly out of date) is available, thanks to O'Reilly, at:

  http://www.oreilly.de/catalog/perlmodger/manpages.html

Some other translations:

 http://cronopio.net/perl/                              - Spanish
 http://member.nifty.ne.jp/hippo2000/dbimemo.htm        - Japanese


=head1 SUPPORT / WARRANTY

The DBI is free software. IT COMES WITHOUT WARRANTY OF ANY KIND.

Commercial support for Perl and the DBI, DBD::Oracle and
Oraperl modules can be arranged via The Perl Clinic.
See http://www.perlclinic.com for more details.

=head1 TRAINING

References to DBI related training resources. No recommendation implied.

  http://www.treepax.co.uk
  http://www.keller.com/dbweb

=head1 OUTSTANDING ISSUES TO DO

	data types (ISO type numbers and type name conversions)
	error handling
	data dictionary methods
	test harness support methods
	portability
	blob_read
	etc

=head1 FREQUENTLY ASKED QUESTIONS

See the DBI FAQ for a more comprehensive list of FAQs. Use the
C<perldoc DBI::FAQ> command to read it.

=head2 How fast is the DBI?

To measure the speed of the DBI and DBD::Oracle code I modified
DBD::Oracle such that you can set an attribute which will cause the
same row to be fetched from the row cache over and over again (without
involving Oracle code but exercising *all* the DBI and DBD::Oracle code
in the code path for a fetch).

The results (on my lightly loaded old Sparc 10) fetching 50000 rows using:

	1 while $csr->fetch;

were:
	one field:   5300 fetches per cpu second (approx)
	ten fields:  4000 fetches per cpu second (approx)

Obviously results will vary between platforms (newer faster platforms
can reach around 50000 fetches per second) but it does give a feel for
the maximum performance: fast.  By way of comparison, using the code:

	1 while @row = $csr->fetchrow_array;

(fetchrow_array is roughly the same as ora_fetch) gives:

	one field:   3100 fetches per cpu second (approx)
	ten fields:  1000 fetches per cpu second (approx)

Notice the slowdown and the more dramatic impact of extra fields.
(The fields were all one char long. The impact would be even bigger for
longer strings.)

Changing that slightly to represent actually _doing_ something in perl
with the fetched data:

    while(@row = $csr->fetchrow_array) {
        $hash{++$i} = [ @row ];
    }

gives:	ten fields:  500 fetches per cpu second (approx)

That simple addition has *halved* the performance.

I therefore conclude that DBI and DBD::Oracle overheads are small
compared with Perl language overheads (and probably database overheads).

So, if you think the DBI or your driver is slow, try replacing your
fetch loop with just:

	1 while $csr->fetch;

and time that. If that helps then point the finger at your own code. If
that doesn't help much then point the finger at the database, the
platform, the network etc. But think carefully before pointing it at
the DBI or your driver.

(Having said all that, if anyone can show me how to make the DBI or
drivers even more efficient, I'm all ears.)


=head2 Why doesn't my CGI script work right?

Read the information in the references below.  Please do I<not> post
CGI related questions to the dbi-users mailing list (or to me).

 http://www.perl.com/perl/faq/idiots-guide.html
 http://www3.pair.com/webthing/docs/cgi/faqs/cgifaq.shtml
 http://www.perl.com/perl/faq/perl-cgi-faq.html
 http://www-genome.wi.mit.edu/WWW/faqs/www-security-faq.html
 http://www.boutell.com/faq/
 http://www.perl.com/perl/faq/

General problems and good ideas:

 Use the CGI::ErrorWrap module.
 Remember that many env vars won't be set for CGI scripts

=head2 How can I maintain a WWW connection to a database?

For information on the Apache httpd server and the mod_perl module see

  http://perl.apache.org/

=head2 What about ODBC?

A DBD::ODBC module is available.

=head2 Does the DBI have a year 2000 problem?

No. The DBI has no knowledge or understanding of dates at all.

Individual drivers (DBD::*) may have some date handling code but are
unlikely to have year 2000 related problems within their code. However,
your application code which I<uses> the DBI and DBD drivers may have
year 2000 related problems if it has not been designed and written well.

See also the "Does Perl have a year 2000 problem?" section of the Perl FAQ:

  http://www.perl.com/CPAN/doc/FAQs/FAQ/PerlFAQ.html

=head1 KNOWN DRIVER MODULES

=over 4

=item Altera - DBD::Altera

 Author:  Dimitrios Souflis
 Email:   dsouflis@altera.gr

=item ODBC - DBD::ODBC

 Author:  Tim Bunce
 Email:   dbi-users@fugue.com

=item Oracle - DBD::Oracle

 Author:  Tim Bunce
 Email:   dbi-users@fugue.com

=item Ingres - DBD::Ingres

 Author:  Henrik Tougaard
 Email:   ht@datani.dk,  dbi-users@fugue.com

=item mSQL - DBD::mSQL

 Author:  Jochen Wiedmann
 Email:   joe@ispsoft.de, msql-mysql-modules@tcx.se

=item MySQL - DBD::mysql

 Author:  Jochen Wiedmann
 Email:   joe@ispsoft.de, msql-mysql-modules@tcx.se

=item DB2 - DBD::DB2

 Email: db2perl@ca.ibm.com
 URL: http://www.software.ibm.com/data/db2/perl

=item Empress - DBD::Empress

=item Velocis - DBD::Velocis

=item Informix - DBD::Informix

 Author:  Jonathan Leffler
 Email:   jleffler@informix.com, j.leffler@acm.org, dbi-users@fugue.com

=item Solid - DBD::Solid

 Author:  Thomas Wenrich
 Email:   wenrich@site58.ping.at, dbi-users@fugue.com

=item Postgres - DBD::Pg

 Author:  Edmund Mergl
 Email:   E.Mergl@bawue.de, dbi-users@fugue.com

=item Illustra - DBD::Illustra

 Author:  Peter Haworth
 Email:   pmh@edison.ioppublishing.com, dbi-users@fugue.com

=item Fulcrum SearchServer - DBD::Fulcrum

 Author:  Davide Migliavacca
 Email:   davide.migliavacca@inferentia.it

=item XBase (dBase) - DBD::XBase

 Author:  Honza Pazdziora
 Email:   adelton@fi.muni.cz

=item CSV files - DBD::CSV

 Author:  Jochen Wiedmann
 Email:   joe@ispsoft.de, see also
          http://mail.healthquiz.com/mailman/listinfo/dbd-csv

=back

=head1 OTHER RELATED WORK AND PERL MODULES

=over 4

=item Apache::DBI by E.Mergl@bawue.de

To be used with the Apache daemon together with an embedded perl
interpreter like mod_perl. Establishes a database connection which
remains open for the lifetime of the http daemon. This way the CGI
connect and disconnect for every database access becomes superfluous.

=item JDBC Server by Stuart 'Zen' Bishop <zen@bf.rmit.edu.au>

The server is written in Perl. The client classes that talk to it are 
of course in Java. Thus, a Java applet or application will be able to 
comunicate via the JDBC API with any database that has a DBI driver installed.
The URL used is in the form jdbc:dbi://host.domain.etc:999/Driver/DBName.
It seems to be very similar to some commercial products, such as jdbcKona.

=item Remote Proxy DBD support

As of DBI 1.02, a complete implementation of a DBD::Proxy driver and the
DBI::ProxyServer are part of the DBI distribution.

Besides, contact

  Carl Declerck <carl@miskatonic.inbe.net>
  Terry Greenlaw <z50816@mip.mar.lmco.com>

Carl is developing a generic proxy object module which could form the basis
of a DBD::Proxy driver in the future. Terry is doing something similar.

=item SQL Parser

	Hugo van der Sanden <hv@crypt.compulink.co.uk>
	Stephen Zander <stephen.zander@mckesson.com>

Based on the O'Reilly lex/yacc book examples and byacc.

See also the SQL::Statement module, a very simple SQL parser and engine,
base of the DBD::CSV driver.

=back

=cut
