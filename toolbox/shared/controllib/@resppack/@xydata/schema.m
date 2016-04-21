function schema
%   SCHEMA  Defines properties for @xydata class

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:14 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'respdata');

% Register class (subclass)
c = schema.class(pkg, 'xydata', supclass);

% Public attributes
% Data
schema.prop(c, 'Time',   'MATLAB array');      % Time vector, t
schema.prop(c, 'Input',  'MATLAB array');      % Input vector, U(t)
schema.prop(c, 'Output', 'MATLAB array');      % Output vector, Y(t)

% Units
p = schema.prop(c, 'TimeUnits',   'string');     % Time units
p.FactoryValue = 'sec';
schema.prop(c, 'InputUnits',  'string vector');  % Input units
schema.prop(c, 'OutputUnits', 'string vector');  % Output units
