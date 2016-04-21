package Win32::ODBC;

use strict;

use DBI;

# once we've been loaded we don't want perl to load the real Win32::ODBC
$INC{'Win32/ODBC.pm'} = $INC{'Win32/DBIODBC.pm'} || 1;

#my $db = new Win32::ODBC("DSN=$self->{'DSN'};UID=$self->{'UID'};PWD=$self->{'PWD'};");

#EMU --- my $db = new Win32::ODBC("DSN=$DSN;UID=$login;PWD=$password;");
sub new
{
	shift;
	my $connect_line= shift;
	
	my $self= {};
		
	
	$_=$connect_line;
 	/^(DSN=)(.*)(;UID=)(.*)(;PWD=)(.*)(;)$/;

 	#---- DBI CONNECTION VARIABLES

 	$self->{ODBC_DSN}=$2;
 	$self->{ODBC_UID}=$4;
 	$self->{ODBC_PWD}=$6;
	
	
	#---- DBI CONNECTION VARIABLES	
	$self->{DBI_DBNAME}=$self->{ODBC_DSN};
	$self->{DBI_USER}=$self->{ODBC_UID};
	$self->{DBI_PASSWORD}=$self->{ODBC_PWD};
	$self->{DBI_DBD}='ODBC';
        	
	#---- DBI CONNECTION
	$self->{'DBI_DBH'}=DBI->connect($self->{'DBI_DBNAME'},
			$self->{'DBI_USER'},$self->{'DBI_PASSWORD'},$self->{'DBI_DBD'});

	warn "Error($DBI::err) : $DBI::errstr\n" if ! $self->{'DBI_DBH'}; 

        
	#---- RETURN 
	
	bless $self;
}


#EMU --- $db->Sql('SELECT * FROM DUAL');
sub Sql
{
 	my $self= shift;
 	my $SQL_statment=shift;

 #	print " SQL : $SQL_statment \n";
	
	$self->{'DBI_SQL_STATMENT'}=$SQL_statment;
	
	my $dbh=$self->{'DBI_DBH'};

 #	print " DBH : $dbh \n";
	
	my $sth=$dbh->prepare("$SQL_statment");
	
 #	print " STH : $sth \n";
	
	$self->{'DBI_STH'}=$sth;
	
	if ($sth)
	{
		$sth->execute();
	}
	
	#--- GET ERROR MESSAGES
	$self->{DBI_ERR}=$DBI::err;
	$self->{DBI_ERRSTR}=$DBI::errstr;

	if ($sth)
	{
		#--- GET COLUMNS NAMES
		$self->{'DBI_NAME'} = $sth->{NAME};
	}

}
 

#EMU --- $db->FetchRow())
sub FetchRow
{ 
 	my $self= shift;
 	
 	my $sth=$self->{'DBI_STH'};
 	if ($sth)
	{
	 	my @row=$sth->fetchrow;
	 	$self->{'DBI_ROW'}=\@row;

	 	if (scalar(@row)>0)
	 	{
			#-- the row of result is not nul
			#-- return somthing nothing will be return else
			1;
	 	} 	
	}
} 
 
#EMU --- %record = $db->DataHash;
sub DataHash
{ 
 	my $self= shift;
 	 	
 	my $p_name=$self->{'DBI_NAME'};
 	my $p_row=$self->{'DBI_ROW'};

 	my @name=@$p_name;
 	my @row=@$p_row;

 	my %DataHash;
 	my $name;
 	my $row;

	foreach $name (@name)
	{
		my @arr=@$name;
		foreach (@arr)
		{
			#print "lot $name  name  col $_   or ROW= 0 $row[0]  1 $row[1] 2 $row[2] \n ";
			$DataHash{$_}=shift(@row);
		}
		
		
	}

 	#--- Return Hash
 	%DataHash; 	
} 


#EMU --- $db->Error()
sub Error
{ 
 	my $self= shift;
 	 	
 	if ($self->{'DBI_ERR'} ne '')
 	{
		#--- Return error message
		$self->{'DBI_ERRSTR'};
 	}

 	#-- else good no error message 	
 	
} 

 
1;

__END__

=head1 NAME

Win32::DBIODBC - Win32::ODBC emulation layer for the DBI

=head1 SYNOPSIS

  use Win32::DBIODBC;     # instead of use Win32::ODBC

=head1 DESCRIPTION

This is a I<very> basic I<very> alpha quality Win32::ODBC emulation
for the DBI. To use it just replace

	use Win32::ODBC;

in your scripts with

	use Win32::DBIODBC;

or, while experimenting, you can pre-load this module without changing your
scripts by doing

	perl -MWin32::DBIODBC your_script_name

=head1 TO DO

Error handling is virtually non-existant.

=head1 AUTHOR

Tom Horen <tho@melexis.com>

=cut
