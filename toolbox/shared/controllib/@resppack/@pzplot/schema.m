function schema
%  SCHEMA  Defines properties for @pzplot class

%  Author(s): Bora Eryilmaz
%  Revised:   Kamesh Subbarao, 10-29-2001
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:11 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'respplot');

% Register class (subclass)
c = schema.class(pkg, 'pzplot', supclass);

% Properties
p = schema.prop(c, 'FrequencyUnits', 'string');  % Frequency units
p.FactoryValue = 'rad/sec';
