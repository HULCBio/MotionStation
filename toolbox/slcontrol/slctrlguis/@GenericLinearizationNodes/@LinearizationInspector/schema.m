function schema
%% SCHEMA  Defines properties for @SimulationStorage class

%%  Author(s): John Glass
%%  Copyright 1986-2004 The MathWorks, Inc.

%% Register class
pkg = findpackage('GenericLinearizationNodes');
c = schema.class(pkg, 'LinearizationInspector');

%% Public attributes
schema.prop(c, 'SystemListBoxUDD', 'MATLAB array');
schema.prop(c, 'PlotBlockLinearizationButtonUDD', 'MATLAB array');
schema.prop(c, 'HiliteBlocksButton', 'MATLAB array');

p = schema.prop(c, 'listeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
