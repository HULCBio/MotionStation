function this = BlockLinearizationSettings(model,block)
%%  BLOCKLINEARIZATIONSETTINGS Constructor for @BlockLinearizationSettings class
%%
%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.
%%	$Revision: 1.1.6.8 $  $Date: 2004/04/11 00:35:18 $

%% Create class instance
this = BlockLinearizationNodes.BlockLinearizationSettings;

if nargin == 0
  % Call when reloading object
  return
end

%% Create the node label
this.Label = sprintf('Block Linearizations: %s',get_param(block,'Name'));
%% Store the model name
this.Model = model;
%% Store the block handle
this.Block = block;
%% Node name is not editable
this.Editable = 0;
this.AllowsChildren = 1;
%% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';

%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'simulink_doc.gif');
                        
%% Set the status property
this.Status = 'Block linearization settings.';
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);

%% Add required nodes
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
