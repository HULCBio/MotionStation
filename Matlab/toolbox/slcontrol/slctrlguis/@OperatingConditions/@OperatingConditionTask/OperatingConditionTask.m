function this = OperatingConditionTask(model,opspec)
%  OperatingConditionTask Constructor for @OperatingConditionTask class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:36:44 $

%% Create class instance
this = OperatingConditions.OperatingConditionTask;

if nargin == 0
  % Call when reloading object
  return
end

%% Set the label
this.Label = 'Operating Points';
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 1;
this.Status = 'Compute operating points.';
%% Node name is not editable
this.Editable = 0;
%% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions_folder.gif');
                        
%% Initialize the model
this.Model = model;

%% Set the initial operating condition constraint data
this.OpSpecData = opspec;

%% Set the state ordering cell array
StateOrderList = cell(length(opspec.States),1);
for ct = 1:length(opspec.States)
   if isa(opspec.States(ct),'opcond.StateSpecSimMech')
       StateOrderList{ct} = opspec.States(ct).SimMechBlock;
   else
       StateOrderList{ct} = opspec.States(ct).Block;
   end
end
this.StateOrderList = StateOrderList;

%% Get the options
this.Options = linoptions('DisplayReport','iter');

%% Store the optimization option strings for the dialog
this.OptimChars = struct(...
            'NumericalPertRel',num2str(this.Options.NumericalPertRel),...
            'NumericalXPert',num2str(this.Options.NumericalXPert),...
            'NumericalUPert',num2str(this.Options.NumericalUPert),...
            'DiffMaxChange',num2str(this.Options.OptimizationOptions.DiffMaxChange),...
            'DiffMinChange',num2str(this.Options.OptimizationOptions.DiffMinChange),...
            'MaxFunEvals',num2str(this.Options.OptimizationOptions.MaxFunEvals),...
            'MaxIter',num2str(this.Options.OptimizationOptions.MaxIter),...
            'TolFun',num2str(this.Options.OptimizationOptions.TolFun),...
            'TolX',num2str(this.Options.OptimizationOptions.TolX));

%% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
