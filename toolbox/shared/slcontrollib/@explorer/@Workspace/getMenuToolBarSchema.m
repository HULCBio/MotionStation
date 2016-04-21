function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Set the callbacks for the menu items and toolbar buttons.

% Author(s): John Glass, Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:30:28 $

% Create menubar
menubar = com.mathworks.toolbox.control.explorer.MenuBar( ...
                                                 this.getGUIResources, ...
                                                 manager.Explorer ); 

% Create toolbar
toolbar = com.mathworks.toolbox.control.explorer.ToolBar( ...
                                                 this.getGUIResources, ...
                                                 manager.Explorer );

% New Project Menu
h = handle( menubar.getMenuItem('project'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewProject, this };

% New Task Menu
h = handle( menubar.getMenuItem('task'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewTask, this };

% Open Menu
h = handle( menubar.getMenuItem('open'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalOpen, this, manager };

% Save Menu
h = handle( menubar.getMenuItem('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% Close Menu
h = handle( menubar.getMenuItem('close'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalClose, this, manager };

% About menu
h = handle( menubar.getMenuItem('about'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalAbout, this, manager };

% New Project Button
h = handle( toolbar.getToolbarButton('project'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewProject, this };

% New Task Button
h = handle( toolbar.getToolbarButton('task'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewTask, this };

% Open Button
h = handle( toolbar.getToolbarButton('open'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalOpen, this, manager };

% Save Button
h = handle( toolbar.getToolbarButton('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% --------------------------------------------------------------------------
% Local Functions
% --------------------------------------------------------------------------

% --------------------------------------------------------------------------
%% LocalNewProject
function LocalNewProject(es,ed,this)
%% Create the new task dialog and let it handle the rest
newdlg = explorer.NewProjectDialog(this);
awtinvoke(newdlg.Dialog, 'setVisible', true)

% --------------------------------------------------------------------------
%% LocalNewTask
function LocalNewTask(es,ed,this)
%% Create the new task dialog and let it handle the rest
% Find non-MPC projects
theseChildren = setdiff(this.getChildren, ...
    this.find('-class','mpcnodes.MPCGUI','-depth',1));
if isempty(theseChildren)
  newdlg = explorer.NewProjectDialog(this);
else
  newdlg = explorer.NewTaskDialog(this);
end
awtinvoke(newdlg.Dialog, 'setVisible', true)

% --------------------------------------------------------------------------
function LocalOpen(es, ed, this, manager)
manager.loadfrom(this.getChildren);

% --------------------------------------------------------------------------
function LocalSave(es, ed, this, manager)
manager.saveas(this.getChildren)

% --------------------------------------------------------------------------
function LocalClose(es, ed, this, manager)
manager.Explorer.doClose;

% ----------------------------------------------------------------------------- %
function LocalAbout(es,ed,this,manager)
import javax.swing.JOptionPane;

message = sprintf('%s\n%s', 'Control and Estimation Tools Manager 1.0', ...
                            'Copyright 2002-2004, The MathWorks, Inc.');

JOptionPane.showMessageDialog(manager.Explorer, message, ...
                              'About Control and Estimation Tools Manager', ...
                              JOptionPane.PLAIN_MESSAGE);
