function ListObject = getLoadedModels(this);
% getLoadedModels

% Author(s): John Glass
% Copyright 1986-2004 The MathWorks, Inc.

import java.lang.* java.awt.* javax.swing.*;

%% Create an empty default list model
ListObject = DefaultListModel;

%% Find all the open models
models = find_system('type','block_diagram');

%% Find all SISO LTI blocks
for ct = 1:length(models)
  if ~strcmp(models{ct},'simulink') && ~strcmp(models{ct},'simulink3')
    ListObject.addElement(models{ct});
  end
end
