# Copyright (C) 2003  Free Software Foundation, Inc.      -*- Perl -*-
# Generated from Config.in; do not edit by hand.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.

package Automake::Config;
use strict;

require Exporter;
use vars qw (@ISA @EXPORT);

@ISA = qw (Exporter);
@EXPORT = qw ($APIVERSION $PACKAGE $VERSION $libdir);

use vars qw ($APIVERSION $PACKAGE $VERSION $libdir);

# Parameters set by configure.  Not to be changed.  NOTE: assign
# VERSION as string so that e.g. version 0.30 will print correctly.
$APIVERSION = '1.8';
$PACKAGE = 'automake';
$VERSION = '1.8.5';
$libdir = '/mingw/share/automake-1.8';

1;;

### Setup "GNU" style for perl-mode and cperl-mode.
## Local Variables:
## perl-indent-level: 2
## perl-continued-statement-offset: 2
## perl-continued-brace-offset: 0
## perl-brace-offset: 0
## perl-brace-imaginary-offset: 0
## perl-label-offset: -2
## cperl-indent-level: 2
## cperl-brace-offset: 0
## cperl-continued-brace-offset: 0
## cperl-label-offset: -2
## cperl-extra-newline-before-brace: t
## cperl-merge-trailing-else: nil
## cperl-continued-statement-offset: 2
## End:
