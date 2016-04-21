# -*- perl -*-

use strict;
require ExtUtils::MakeMaker;
require Config;
require DBI::DBD;
use lib "..";

use vars qw($MyConfig $MyCfg);
if (!defined($MyConfig)) {
    require ".status";
}

$MyCfg = $MyConfig->{'Mysql'};

my($lcDriver) = lc 'Mysql';
my(%hash) = %{$MyConfig->{"X_$lcDriver"}};
$hash{'NAME'} = 'DBD::mysql';
$hash{'OBJECT'} = '$(O_FILES)';
$hash{'VERSION'} = $MyConfig->{'DBD_VERSION'};
$hash{'clean'} = { 'FILES' => '*.xsi' };
$hash{'PMLIBDIRS'} = $MyConfig->{"install_${lcDriver}perl"} ? ["lib"] : [];
if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
    $hash{'CAPI'} = 'TRUE' if $Config::Config{'archname'} =~ /-object\b/i;
}
ExtUtils::MakeMaker::WriteMakefile(%hash);


package MY;

sub postamble {
    my($self) = shift;
    my($driver, $dbdDriver, $lcDriver);
    if ($self->{'NAME'} eq 'DBD::mSQL') {
	$driver = 'Msql';
	$dbdDriver = 'mSQL';
	$lcDriver = 'msql';
    } elsif ($self->{'NAME'} eq 'DBD::mSQL1') {
	$driver = 'Msql1';
	$dbdDriver = 'mSQL1';
	$lcDriver = 'msql1';
    } elsif ($self->{'NAME'} eq 'DBD::mysql') {
	$driver = 'Mysql';
	$dbdDriver = 'mysql';
	$lcDriver = 'mysql';
    } else {
	return '';
    }
    my($pa) = "\n" . $::MyConfig->{"postamble_$lcDriver"};

    # we must be careful of quotes for Win32 here.
    my ($dir, $dbiDir);
    foreach $dir ($self->{INSTALLSITEARCH}, @INC) {
	if (-f "$dir/auto/DBI/Driver.xst") {
	    $dbiDir = $dir;
	    last;
	}
    }
    if (!$dbiDir) {
	die "Unable to detect location of 'Driver.xst'.\n";
    }

    $pa .= '
DBI_DRIVER_XST_DIR=' . $dbiDir . '/auto/DBI
DBI_DRIVER_XST=$(DBI_DRIVER_XST_DIR)/Driver.xst

$(BASEEXT).xs: $(BASEEXT).xsi

$(BASEEXT).c: $(BASEEXT).xsi

$(BASEEXT).xsi: $(DBI_DRIVER_XST)
	perl -p -e "s/\~DRIVER\~/$(BASEEXT)/g" < $(DBI_DRIVER_XST) > $(BASEEXT).xsi
';

    $pa;
}


sub libscan {
    my($self, $path) = @_;
    if ($path =~ /\~$/) {
	undef;
    } else {
	$path;
    }
}


sub const_loadlibs {
    my $self = shift;
    my $str = $self->SUPER::const_loadlibs(@_);
    if (my $el = $::MyCfg->{'EXTRA_LIBS'}) {
	$str =~ s/((?:EXTRALIBS|LDLOADLIBS)\s+=\s+)/$1$el /sg;
    }
    if (my $fl = $::MyCfg->{'FINAL_LIBS'}) {
        $str =~ s/((?:EXTRALIBS|LDLOADLIBS)\s+=\s+.*?)(\r?\n)/$1 $fl$2/sg;
    }
    $str;
}
