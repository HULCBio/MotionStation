function deleteSelectedModel(this, Model)

% Copyright 2004 The MathWorks, Inc.


% Delete the selected model

Num = length(this.Models);
if Num > 1
    this.Models = this.Models(~ismember(this.Models,Model));

    % Repair any controllers or scenarios that referred to this model
    NewName = this.Models(1).Name;
    Controllers = this.getMPCControllers.getChildren;
    UsedInC = Controllers.find('ModelName', Model.Name);
    Scenarios = this.getMPCSims.getChildren;
    UsedInS = Scenarios.find('PlantName', Model.Name);
    NameChanged = false;
    if ~isempty(UsedInC)
        for i = 1:length(UsedInC)
            UsedInC(i).ModelName = NewName;
            UsedInC(i).Model = this.Models(1);
        end
        NameChanged = true;
    end
    if ~isempty(UsedInS)
        for i = 1:length(UsedInS)
            UsedInS(i).PlantName = NewName;
        end
        NameChanged = true;
    end
    if NameChanged
        Message = sprintf(['Model "%s" was being used in at least', ...
            ' one controller or scenario.\n\nAll references to "%s"', ...
            ' have been replaced by "%s"'], Model.Name, Model.Name, ...
            NewName);
        warndlg(Message,'Model Deletion');        
    end

else
    Root = this.up;
    Question = sprintf( ['"%s" is your only model.  Deleting it', ...
        ' will reset project "%s" to its initial state.', ...
        '\n\nAll data you have entered will be erased.', ...
        '\n\nDo you wish to delete model "%s"?'], Model.Name, ...
        Root.Label, Model.Name);
    ButtonName=questdlg(Question,'Delete confirmation', 'Yes', 'No', 'No');
    if strcmp(ButtonName,'No')
        return
    end
    Root.clearTool;
end
    
%% Update the list
this.RefreshModelList;

% If this model is the result of linearization, delete the corresponding
% node. Don't worry abound the node deletion listener ping-ponging becuase
% the model will be gone from the table when the node deletion listener
% fires
ModelNodes = this.getChildren;
I = find(strcmp(Model.Name,get(ModelNodes,{'Label'})));
if ~isempty(I)
    this.removeNode(ModelNodes(I(1)));
end
