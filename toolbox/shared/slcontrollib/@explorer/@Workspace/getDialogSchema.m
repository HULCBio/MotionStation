function DialogPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA Construct the dialog panel

% Author(s): Bora Eryilmaz, John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:30:26 $

% First create the GUI panel
DialogPanel = com.mathworks.toolbox.control.workspace.Workspace;

% Get the handles
Handles = this.Handles;

% Add the handle
Handles.PanelManager = explorer.DefaultFolderPanel(DialogPanel, this, manager);

% Store the handles
this.Handles = Handles;

% New button callback
h = handle( DialogPanel.getNewButton, 'callbackproperties' );
h.ActionPerformedCallback = { @LocalNewProject, this };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalNewProject - Callback to launch the new project dialog
function LocalNewProject(es,ed,this)

%% Create the new task dialog and let it handle the rest
newdlg = explorer.NewProjectDialog(this);
awtinvoke(newdlg.Dialog, 'setVisible', true)
