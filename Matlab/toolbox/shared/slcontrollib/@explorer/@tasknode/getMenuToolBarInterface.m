function [menubar, toolbar] = getMenuToolBarInterface(this, manager)
% GETMENUTOOLBARINTERFACE Returns the handles of the Java menubar & toolbar
% associated with this object.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:56 $

if isempty( this.MenuBar )
  [this.MenuBar, this.ToolBar] = getMenuToolBarSchema( this, manager );
end

menubar = this.MenuBar;
toolbar = this.ToolBar;
