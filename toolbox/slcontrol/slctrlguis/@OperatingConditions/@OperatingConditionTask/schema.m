function schema
%%  SCHEMA  Defines properties for OperatingConditionTask class

%%  Author(s): John Glass
%%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:36:57 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'OperatingConditionTask', supclass);

%% Properties
schema.prop(c, 'StateIndecies', 'MATLAB array');
schema.prop(c, 'InputIndecies', 'MATLAB array');
schema.prop(c, 'OutputIndecies', 'MATLAB array');

schema.prop(c,'Model', 'string');
schema.prop(c,'OpSpecData', 'MATLAB array');
schema.prop(c,'StateOrderList', 'MATLAB array');
schema.prop(c,'Options','MATLAB array');
schema.prop(c,'OptimChars','MATLAB array');

%% Table data
schema.prop(c, 'StateSpecTableData', 'MATLAB array');
schema.prop(c, 'InputSpecTableData', 'MATLAB array');
schema.prop(c, 'OutputSpecTableData', 'MATLAB array');
schema.prop(c, 'SimulationTimesData', 'MATLAB array');
schema.prop(c, 'StatusAreaText', 'MATLAB array');

%% Java handles
p = schema.prop(c, 'OpCondSelectionPanelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'OpCondSpecPanelUDD', 'MATLAB array'); 
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'DeleteOpCondButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ImportOpCondButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ComputeOpCondButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'OpCondTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'InputConstrTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'InputConstrTableFixedCheckBoxUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'OutputConstrTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'OutputConstrTableFixedCheckBoxUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'StateConstrTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'StateConstrTableFixedCheckBoxUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'StateConstrTableSteadyStateCheckBoxUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'MenuHandlesUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

%% Events
schema.event(c,'OpPointDataChanged');
