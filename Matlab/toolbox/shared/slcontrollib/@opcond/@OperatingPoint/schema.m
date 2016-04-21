function schema
%SCHEMA  Defines properties for @OperatingPoint class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:08 $

%% Find the package
pkg = findpackage('opcond');

%% Register class
c = schema.class(pkg, 'OperatingPoint');

%% Public attributes
schema.prop(c, 'Model', 'MATLAB array');
schema.prop(c, 'States', 'MATLAB array');        % Model States
schema.prop(c, 'Inputs', 'MATLAB array');        % Model Inputs
p = schema.prop(c, 'Time', 'MATLAB array');
p.FactoryValue = 0;