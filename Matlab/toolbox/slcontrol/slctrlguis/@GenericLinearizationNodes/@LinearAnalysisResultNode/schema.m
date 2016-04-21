function schema
%  SCHEMA  Defines properties for LinearAnalysisResultNode class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:35:47 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'node');

% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'LinearAnalysisResultNode', supclass);

% Properties
schema.prop(c, 'LinearizedModel', 'MATLAB array');    % LTI Object
schema.prop(c, 'Model', 'MATLAB array');    % Simulink Model
schema.prop(c, 'TrimCondition', 'MATLAB array');    % Opcond object
schema.prop(c, 'ModelJacobian', 'MATLAB array');    % LTI Object
schema.prop(c, 'OpCondData', 'MATLAB array');
schema.prop(c, 'OpConstrData', 'MATLAB array');
schema.prop(c, 'LinearizationIOData', 'MATLAB array');
schema.prop(c, 'LinearizationOptions', 'MATLAB array');
schema.prop(c, 'indx', 'MATLAB array');
schema.prop(c, 'indu', 'MATLAB array');
schema.prop(c, 'indy', 'MATLAB array');
p = schema.prop(c, 'ExplorerTreeManager', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
% p = schema.prop(c, 'Label', 'MATLAB array');
% p.SetFunction = @LocalSetLabel;

p = schema.prop(c, 'Inspector', 'handle'); 
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'InputResultsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'OutputResultsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'StateResultsTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'SelectorComboUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'HiLiteBlocksButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'SummaryAreaUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ExportButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
schema.prop(c, 'InspectorNode', 'MATLAB array');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSetLabel
function NewData = LocalSetLabel(this,NewData)

%% Get the linearization node
% Parent = this.up;
% 
% if ~isempty(Parent)
%     %% Get the index to the child
%     Children = Parent.getChildren;
%     ind = find(Children == this);
%     
%     %% Fire the label changed event
%     eventData = ctrluis.dataevent(Parent,'AnalysisLabelChanged',ind);
%     send(Parent, 'AnalysisLabelChanged',eventData);
% end
