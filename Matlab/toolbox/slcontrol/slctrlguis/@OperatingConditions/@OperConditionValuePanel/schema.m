function schema
%%  SCHEMA  Defines properties for OperConditionResult class

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.5 $  $Date: 2004/04/11 00:36:38 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'node');

%% Register class (subclass) in package
inpkg = findpackage('OperatingConditions');
c = schema.class(inpkg, 'OperConditionValuePanel', supclass);

%% Properties
schema.prop(c, 'Model', 'string');
schema.prop(c, 'OpPoint', 'MATLAB array');
schema.prop(c, 'OpReport', 'MATLAB array');
schema.prop(c, 'StateIndecies', 'MATLAB array');
schema.prop(c, 'StateTableData', 'MATLAB array');
schema.prop(c, 'InputIndecies', 'MATLAB array');
schema.prop(c, 'InputTableData', 'MATLAB array');

%% Java Handles
p = schema.prop(c, 'InputCondTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'StateCondTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
