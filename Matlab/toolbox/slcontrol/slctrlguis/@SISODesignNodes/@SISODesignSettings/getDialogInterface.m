function panel = getDialogInterface(this, manager)
% GETDIALOGINTERFACE

% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.

if isempty(this.Dialog)
    this.Dialog = getDialogSchema(this);
else
    % Update the model with the settings
    setlinio(this.Model,this.IOData);
end
panel = this.Dialog;
