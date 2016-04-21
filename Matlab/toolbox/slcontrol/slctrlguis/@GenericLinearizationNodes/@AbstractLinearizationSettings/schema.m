function schema
%  SCHEMA  Defines properties for AbstractLinearizationSettings class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

% Register class (subclass) in package
c = schema.class(findpackage('GenericLinearizationNodes'), 'AbstractLinearizationSettings', supclass);

% Properties
p = schema.prop(c, 'OpCondSelectionPanelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'AnalysisResultsDeleteButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'AnalysisResultsPanelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'AnalysisResultsTableUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'AnalysisResultsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'CreateConditionButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ViewConditionButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'MenuHandlesUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

p = schema.prop(c, 'LinearizationSettings', 'MATLAB array');
p.FactoryValue = struct('BlockReduction','on',...
                        'IgnoreDiscreteStates','off',...
                        'SampleTime',-1,...
                        'UseModelPerturbation','off');
                    
% Listeners
p = schema.prop(c, 'OperatingConditionsListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'LinearizationResultsListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Events
schema.event(c,'AnalysisLabelChanged'); 
