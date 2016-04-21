function this = SISODesignSettings(model)
%%  SISODESIGNSETTINGS Constructor for @SISODesignSettings class

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.7 $  $Date: 2004/04/11 00:37:06 $

%% Create class instance
this = SISODesignNodes.SISODesignSettings;

if nargin == 0
  % Call when reloading object
  return
end

%% Create the node label
this.Label = 'Compensator Design';
%% Store the model name
this.Model = model;
%% Get the linearization settings
this.IOData = getlinio(model);
%% Node name is editable
this.Editable = 1;
this.AllowsChildren = 1;
%% Set the resources
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'simulink_doc.gif');
                        
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);

%% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end

%% Add listeners
this.NodeListeners = handle.listener(this,'ObjectBeingDestroyed',{@LocalDeleteSettings, this});


%-------------------------Internal Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDeleteSettings %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDeleteSettings(es,ed,this)

%% Delete the listeners to SISOTool
delete(this.SISOToolListeners);

%% Delete the SISO design GUI the property for the SISO Design GUI
if ~isempty(this.SISODesignGUI)
    delete(this.SISODesignGUI);
end
