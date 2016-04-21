function preSave(this, varargin)

%  PRESAVE
%
%  Save properties to allow later reload.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:36:23 $

% Reset the Dirty flag back to false
this.Dirty = false;

Controllers = this.getMPCControllers.getChildren;
for i = 1:length(Controllers)
    LocalMPCDataSave(Controllers(i))
end
Scenarios = this.getMPCSims.getChildren;
for i = 1:length(Scenarios)
    LocalMPCDataSave(Scenarios(i))
end

% ------------------------------------------------------------------------

function LocalMPCDataSave(this)

if isempty(this.Dialog)
    % If dialog panel hasn't been initialized there's nothing to save.
    return
end
Fields = this.SaveFields;
N = length(Fields);
Data = cell(N,1);
for i = 1:N
    Command = sprintf('Data{%i, 1} = this.%s;', i, Fields{i});
    eval(Command);
end
this.SaveData = Data;
