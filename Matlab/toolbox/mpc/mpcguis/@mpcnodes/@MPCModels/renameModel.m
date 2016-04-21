function renameModel(this, Name, iModel)

% renameModel(this, Name, iModel)
%
% Rename the plant model in the "iModel" position to "Name"
% "this" is the MPCModels node

%  Author(s):  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.4 $ $Date: 2004/04/16 22:09:33 $

Model = this.Model(iModel);
OldName = Model.Name;
Model.Name = Name;

% Is the model being chnaged a LinearizationResult node?
modelNodes = this.getChildren;
I = find(strcmp(get(modelNodes,{'Label'}),OldName));

% Update Labels list
this.Labels{iModel} = Name;

% Find all controllers using this model, and change references

Controllers = this.getMPCControllers.getChildren;
UsedIn = Controllers.find('ModelName',OldName);
for i = 1:length(UsedIn)
    UsedIn(i).ModelName = Name;
end

% Find all scenarios using this model, and change references

Scenarios = this.getMPCSims.getChildren;
UsedIn = Scenarios.find('PlantName',OldName);
for i = 1:length(UsedIn)
    UsedIn(i).PlantName = Name;
end

% Update any linearization result node names. This will fire the node
% listener which updates the table, which will be a no-op becuase the
% former model name has chnaged in the table and no longer matches the name
% of the node
if ~isempty(I)
   modelNodes(I(1)).Label = Name;
end