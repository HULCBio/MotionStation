function schema
%%  SCHEMA  Defines properties for OperConditionResult class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:36:32 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'node');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'OperConditionResultPanel', supclass);

%% Properties
schema.prop(c, 'OpPoint', 'MATLAB array');
schema.prop(c, 'OpReport', 'MATLAB array');
schema.prop(c, 'OperatingConditionSummary', 'MATLAB array');

schema.prop(c, 'StateIndecies', 'MATLAB array');
schema.prop(c, 'InputIndecies', 'MATLAB array');
schema.prop(c, 'OutputIndecies', 'MATLAB array');

%% Java Handles
p = schema.prop(c, 'SelectorComboUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'InputResultsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'OutputResultsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'StateResultsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';