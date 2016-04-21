function schema
%SCHEMA  Defines properties for @mpzplot class (multivariable pole/zero plot).

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:15 $

% Find parent package
pkg = findpackage('resppack');

% Register class (subclass)
c = schema.class(pkg, 'mpzplot', findclass(pkg, 'pzplot'));

% REVISIT: should hide Input*, Output*, and I/Ogrouping props