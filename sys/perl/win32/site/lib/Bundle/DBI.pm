# -*- perl -*-

package Bundle::DBI;

$VERSION = '1.03';

1;

__END__

=head1 NAME

Bundle::DBI - A bundle to install DBI and required modules.

=head1 SYNOPSIS

C<perl -MCPAN -e 'install Bundle::DBI'>

=head1 CONTENTS

Storable - for DBD::Proxy and DBI::ProxyServer

Net::Daemon 0.15 - for DBD::Proxy and DBI::ProxyServer

RPC::PlServer 0.2001 - for DBD::Proxy and DBI::ProxyServer

Getopt::Long 2.17 - for DBI::Shell

DBI - for to get to know thyself

=head1 DESCRIPTION

This bundle includes all the modules used by the Perl Database
Interface (DBI) module, created by Tim Bunce.

A I<Bundle> is a module that simply defines a collection of other
modules.  It is used by the L<CPAN> module to automate the fetching,
building and installing of modules from the CPAN ftp archive sites.

This bundle does not deal with the various database drivers (e.g.
DBD::Informix, DBD::Oracle etc), most of which require software from
sources other than CPAN. You'll need to fetch and build those drivers
yourself.

=head1 AUTHORS

Jonathan Leffler, Jochen Wiedmann and Tim Bunce.

=head1 THANKS

To Graham Barr for the Bundle::libnet example.

=cut
