function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.6.2 $  $Date: 2003/09/01 09:20:28 $

if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
end
panel = this.Dialog;