function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE Returns the handle of the Java dialog for left click on
% the tree nodes.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:42 $

if isempty( this.Dialog )
  this.Dialog = getDialogSchema( this, manager );
end
panel = this.Dialog;
