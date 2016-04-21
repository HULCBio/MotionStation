function menu = getPopupInterface(this, manager)
% GETPOPUPINTERFACE Return the handle of the Java popup menu for right click on
% the tree nodes.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:45 $

if isempty( this.PopupMenu )
  this.PopupMenu = getPopupSchema( this, manager );
end

menu = this.PopupMenu;
