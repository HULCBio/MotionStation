function schema
%  SCHEMA  Defines properties for @rlplot class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:58 $

% Find parent package
pkg = findpackage('resppack');

% Register class (subclass)
c = schema.class(pkg, 'rlplot', findclass(pkg, 'pzplot'));