function schema
% SCHEMA  Defines properties for @SimulationOperatingConditionStorage class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:36:40 $

%% Register class
pkg = findpackage('LinearizationObjects');
c = schema.class(pkg, 'SimulationOperatingConditionStorage');

%% Public attributes

%% Property for the storage of the linearization event information
schema.prop(c, 'LinearizationEvent', 'MATLAB array');

%% Property for the storage of the linearization result
schema.prop(c, 'OpCond', 'MATLAB array');
schema.prop(c, 'Linearizations', 'MATLAB array');
schema.prop(c, 'Jacobians', 'MATLAB array');
schema.prop(c, 'TimeEventObj', 'MATLAB array');
schema.prop(c, 'Time', 'MATLAB array');

%% Property to store the block name if linearizing a block
schema.prop(c, 'Block', 'handle');

%% Property for the empty operating conditions
schema.prop(c, 'EmptyOpCond', 'MATLAB array');