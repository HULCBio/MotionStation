function schema
%SCHEMA  Defines properties for @TimeEvent class

%  Author(s): John Glass
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:36:45 $

%% Find the package
pkg = findpackage('LinearizationObjects');

%% Register class
c = schema.class(pkg, 'TimeEvent');

%% Public attributes
%% Property for the simulink model
p = schema.prop(c, 'Model', 'MATLAB array');
p = schema.prop(c, 'Times', 'MATLAB array');
p = schema.prop(c, 'Block', 'MATLAB array');
p = schema.prop(c, 'Ts', 'MATLAB array');
p = schema.prop(c, 'linopts', 'MATLAB array');
p = schema.prop(c, 'IO', 'MATLAB array');
p = schema.prop(c, 'BlocktoLinearize', 'MATLAB array');
p = schema.prop(c, 'LinearizeFlag', 'MATLAB array');
p.FactoryValue = false;