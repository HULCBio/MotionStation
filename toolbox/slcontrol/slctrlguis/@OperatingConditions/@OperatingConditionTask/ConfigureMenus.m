function DialogPanel = ConfigureMenus(this)
%  ConfigureMenus  Set the callbacks for the menu items.  This should be
%  called after getDialogSchema is completed.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:37:42 $

%% Get the existing menu handles
handles = this.MenuHandlesUDD;

%% Get the handles to the components in the top level menus
if isempty(this.MenuBar)
    this.MenuBar = this.getMenuBarInterface(slctrlexplorer);
end
topmenus = this.MenuBar.getComponents;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Tools Menus
toolsmenu = topmenus(3);
tools_ch = toolsmenu.getMenuComponents;

%% New Task
handles.linearizationsettings = tools_ch(1);
set(handles.linearizationsettings, 'ActionPerformedCallback', {@LocalOptimizationSettings,this});

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Toolbar
if isempty(this.ToolBar)
    this.ToolBar = this.getToolBarInterface(slctrlexplorer);
end
toolbar = this.Toolbar;

%% Get the toolbar components
toolcomponents = toolbar.getComponents;

for ct = 1:length(toolcomponents)
    switch char(toolcomponents(ct).getToolTipText)
        case 'Task Options'
            handles.settingstoolbar = toolcomponents(ct);
            set(handles.settingstoolbar, 'ActionPerformedCallback', {@LocalOptimizationSettings,this}); 
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Store the handles in the node object
this.MenuHandlesUDD = handles;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLinearizationSettings
function LocalOptimizationSettings(es,ed,this)

%% Call the constructor that displays the options
dlg = jDialogs.LinOptionsDialog(this);
dlg.JavaPanel.show;