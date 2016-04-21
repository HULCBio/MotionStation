function getLoadedModels(this);
%getLoadedModels Get the models that are currently loaded

% Author(s): John Glass
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:30:08 $

import java.lang.* java.awt.* javax.swing.*;

%% Create an empty default list model
ListObject = this.Dialog.getlistModel;

%% Find all the open models
models = find_system('type','block_diagram','BlockDiagramType','model');

%% Find all SISO LTI blocks
for ct = 1:length(models)
    ListObject.addElement(models{ct});
end
