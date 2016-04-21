function menu = getPopupSchema(this,manager)
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $$ $Date: 2004/04/11 00:36:55 $

[menu, Handles] = LocalDialogPanel(this);
h = this.Handles;
h.PopupMenuItems = Handles.PopupMenuItems;
this.Handles = h;

% --------------------------------------------------------------------------- %
function [Menu, Handles] = LocalDialogPanel(this)
import javax.swing.*;

Menu = JPopupMenu('Linear Analysis Result');

item1 = JMenuItem('Export');
Menu.add(item1);

Handles.PopupMenuItems = [item1];
set(item1, 'ActionPerformedCallback', {@LocalExportAction, this});
set(item1, 'MouseClickedCallback',    {@LocalExportAction, this});

% --------------------------------------------------------------------------- %
function LocalExportAction(eventSrc, eventData, this)
data = get(eventSrc, 'ActionPerformedCallbackData');

%% Export the lti object to the workspace
defaultnames = {sprintf('opspec_%s',this.Model)};
exporteddata = {this.OpSpecData};
export2wsdlg({'Operating Point Specification'},defaultnames,exporteddata)
