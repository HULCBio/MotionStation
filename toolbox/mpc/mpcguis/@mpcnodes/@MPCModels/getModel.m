function MPCModel = getModel(this, Name)

% Copyright 2003 The MathWorks, Inc.

% Return Name (an MPCModel) from the MPCModels list.  Returns []
% if the model isn't in the list

% Larry Ricker

for i = 1:length(this.Models)
    if strcmp(this.Models(i).Name, Name)
        MPCModel = this.Models(i);
        return
    end
end

MPCModel = [];
