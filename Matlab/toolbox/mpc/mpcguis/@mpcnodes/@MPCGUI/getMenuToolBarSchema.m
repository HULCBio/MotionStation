function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Create menubar and toolbar.  Also, set the callbacks
% for the menu items and toolbar buttons.

% Author(s):  Larry Ricker
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/10 23:36:17 $

% Create menubar
menubar = com.mathworks.toolbox.control.explorer.MenuBar( ...
                                                  this.getGUIResources, ...
                                                  manager.Explorer );
drawnow
% Create toolbar
toolbar = com.mathworks.toolbox.control.explorer.ToolBar( ...
                                                  this.getGUIResources, ...
                                                  manager.Explorer );
drawnow
% Menu callbacks

this.Handles.PlantMenu = menubar.getMenuItem('model');
set( this.Handles.PlantMenu, 'ActionPerformedCallback', ...
    { @LocalModelSelected, this } );
this.Handles.ObjectMenu = menubar.getMenuItem('object');
set( this.Handles.ObjectMenu, 'ActionPerformedCallback', ...
    { @LocalObjectSelected, this } );
this.Handles.ExportMenu = menubar.getMenuItem('export');
set( this.Handles.ExportMenu, 'ActionPerformedCallback', ...
    { @LocalExportSelected, this } );
this.Handles.SimulateMenu = menubar.getMenuItem('simulate');
set(handle(this.Handles.SimulateMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalNewSimulation, this } );
this.Handles.SaveMenu = menubar.getMenuItem('save');
set(handle(this.Handles.SaveMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalSaveSelected, this} );
this.Handles.OpenMenu = menubar.getMenuItem('open');
set(handle(this.Handles.OpenMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalLoadSelected, this} );
this.Handles.ExitMenu = menubar.getMenuItem('exit');
set(handle(this.Handles.ExitMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalExitSelected, this } );
this.Handles.ProjectMenu = menubar.getMenuItem('project');
set(handle(this.Handles.ProjectMenu,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalProjectSelected } );

% Toolbar button callbacks
this.Handles.SimulateButton = toolbar.getToolbarButton('simulate');
set(handle(this.Handles.SimulateButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalNewSimulation, this } );
this.Handles.SaveButton = toolbar.getToolbarButton('save');
set(handle(this.Handles.SaveButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalSaveSelected, this} );
this.Handles.OpenButton = toolbar.getToolbarButton('open');
set(handle(this.Handles.OpenButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalLoadSelected, this} );
this.Handles.ProjectButton = toolbar.getToolbarButton('project');
set(handle(this.Handles.ProjectButton,'callbackproperties'), ...
    'ActionPerformedCallback', { @LocalProjectSelected } );
                            
% Initial menu state
Controllers = this.getMPCControllers.getChildren;
if length(Controllers) <= 0
    % No controllers to export yet
    setJavaLogical(this.Handles.ExportMenu.getAction,'setEnabled',0);
end
Scenarios = this.getMPCSims.getChildren;
if length(Scenarios) <= 0
    % No scenarios to simulate yet
    setJavaLogical(this.Handles.SimulateMenu.getAction,'setEnabled',0);
end

% --------------------------------------------------------------------------- %
function LocalModelSelected(eventSrc, eventData, this)
% Open the model import dialog window
I = this.Handles.ImportLTI;
I.javasend('Show' ,'dummy', I);

% --------------------------------------------------------------------------- %
function LocalObjectSelected(eventSrc, eventData, this)
% Show the mpc object import window
I = this.Handles.ImportMPC;
I.javasend('Show' ,'dummy', I);

% --------------------------------------------------------------------------- %
function LocalExportSelected(eventSrc, eventData, this)
this.Handles.mpcExporter.show;

% --------------------------------------------------------------------------- %
function LocalNewSimulation(eventSrc, eventData, this)
% Run the current scenario
this.getMPCSims.runSimulation;

% ------------------------------------------------------------------------
function LocalSaveSelected(eventSrc, eventData, this)
% Save the mpc design.  Default the file name to the root node label.
if isempty(this.SaveAs)
    FileName = this.Label;
else
    FileName = this.SaveAs;
end
% Remove any white space from proposed file name
iBlank = find(isspace(FileName));
if ~isempty(iBlank)
    FileName(iBlank) = '';
end
this.SaveAs = FileName;

this.TreeManager.saveas(this);

% ------------------------------------------------------------------------
function LocalLoadSelected(eventSrc, eventData, this)
% Load a project
this.TreeManager.loadfrom(this);

% ------------------------------------------------------------------------
function LocalExitSelected(eventSrc, eventData, this)
% Exit the project
this.closeTool;

% ------------------------------------------------------------------------
function LocalProjectSelected(eventSrc, eventData)
% Create a new project
newMPCproject;
