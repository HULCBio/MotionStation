function schema
%  SCHEMA  Defines properties for @xyplot class

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:15 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'respplot');

% Register class (subclass)
c = schema.class(pkg, 'xyplot', supclass);
