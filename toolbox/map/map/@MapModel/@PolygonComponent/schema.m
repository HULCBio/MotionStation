function schema
%SCHEMA Define the PolygonComponent class

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:47 $

pkg = findpackage('MapModel');
c = schema.class(pkg,'PolygonComponent',findclass(pkg,'VectorComponent'));

