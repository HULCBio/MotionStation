function schema
%SCHEMA  Class definition for @respsource (abstract response source).

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:50 $

% Register class (subclass)
pkg = findpackage('resppack');
superclass = findclass(findpackage('wrfc'),'datasource');
c = schema.class(pkg, 'respsource', superclass);
