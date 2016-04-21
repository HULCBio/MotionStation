function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Set the callbacks for the menu items and toolbar buttons.

% Author(s): John Glass, B. Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:35:29 $

% Create menubar
menubar = com.mathworks.toolbox.control.explorer.MenuBar( ...
                                                  this.getGUIResources, ...
                                                  manager.Explorer );

% Create toolbar
toolbar = com.mathworks.toolbox.control.explorer.ToolBar( ...
                                                  this.getGUIResources, ...
                                                  manager.Explorer );

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New Project Menu
handles.newproject = menubar.getMenuItem('project');
set( handles.newproject, 'ActionPerformedCallback', {@LocalNewProject,this} );

% New Task Menu
handles.newtask    = menubar.getMenuItem('task');
set( handles.newtask, 'ActionPerformedCallback', {@LocalNewTask,this} );

% Load Menu
h = handle( menubar.getMenuItem('load'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalLoad, this, manager };

% Save Menu
h = handle( menubar.getMenuItem('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% Settings Tools Menu
handles.settings    = menubar.getMenuItem('settings');
set( handles.settings, 'ActionPerformedCallback', {@LocalLinearizationSettings,this} );

% Close Menu
h = handle( menubar.getMenuItem('close'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalClose, this, manager };

% About Help Menu
h = handle( menubar.getMenuItem('about'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalAboutSCD,this};

% Simulink Control Design Help
h = handle( menubar.getMenuItem('scdhelp'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalSCDHelp,this};

% What is Linearization Help
h = handle( menubar.getMenuItem('whatislin'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalGenHelp,'whatislin'};

% Linearizing Models Help
h = handle( menubar.getMenuItem('linmodels'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalGenHelp,'linearizing_models'};

% IO Help
h = handle( menubar.getMenuItem('ios'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalGenHelp,'analysis_ios'};

% Operating Point Spec
h = handle( menubar.getMenuItem('opspec'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalGenHelp,'op_points'};

% Analysis Results
h = handle( menubar.getMenuItem('results'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalGenHelp,'analyzing'};

% Custom Views
h = handle( menubar.getMenuItem('customviews'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalGenHelp,'custom_views'};

% Export and Save
h = handle( menubar.getMenuItem('exportsave'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalGenHelp,'exporting'};

% Demos Menu
h = handle( menubar.getMenuItem('demos'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSCDDemos };

%% TOOLBAR
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New Project Button
h = handle( toolbar.getToolbarButton('project'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalNewProject,this};

% New Task Button
h = handle( toolbar.getToolbarButton('task'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalNewTask,this};

% Load Button
h = handle( toolbar.getToolbarButton('load'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalLoad, this, manager };

% Save Button
h = handle( toolbar.getToolbarButton('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Store the handles in the node object
this.MenuHandlesUDD = handles;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalNewTask
function LocalNewTask(es,ed,this)

%% Create the new task dialog and let it handle the rest
newdlg = explorer.NewTaskDialog(this.up);
awtinvoke(newdlg.Dialog,'setVisible',true);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalNewProject
function LocalNewProject(es,ed,this)

%% Create the new project dialog and let it handle the rest
[FRAME,WSHANDLE] = slctrlexplorer;
newdlg = explorer.NewProjectDialog(WSHANDLE);
awtinvoke(newdlg.Dialog,'setVisible',true);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLinearizationSettings
function LocalLinearizationSettings(es,ed,this)

%% Call the constructor that displays the options
dlg = jDialogs.LinOptionsDialog(this);
awtinvoke(dlg.JavaPanel.getTabbedPane,'setSelectedIndex',0);
awtinvoke(dlg.JavaPanel,'setVisible',true);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLoad
function LocalLoad(es,ed,this, manager)
manager.loadfrom(this.up);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSave
function LocalSave(es,ed,this, manager)
manager.saveas(this.up)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalClose
function LocalClose(es,ed,this,manager)
manager.Explorer.doClose;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalAboutSCD
function LocalAboutSCD(es,ed,this)

msgbox('Simulink Control Designer V1.0','About Simulink Control Designer','modal')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSCDHelp
function LocalSCDHelp(es,ed,this)

helpview([docroot '/toolbox/slcontrol/slcontrol_product_page.html'])

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSCDDemos
function LocalSCDDemos(es,ed)

demo('simulink','Simulink Control Design')

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalGenHelp
function LocalGenHelp(es,ed,str)

helpview([docroot '/toolbox/slcontrol/slcontrol.map'], str)
