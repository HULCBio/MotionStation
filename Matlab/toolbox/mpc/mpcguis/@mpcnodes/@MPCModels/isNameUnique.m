function OK = isNameUnique(this, Name, iModel)

% Copyright 2003 The MathWorks, Inc.

% Check existing models to see whether or not proposed name is unique.

for i = 1:length(this.Models)
    if i ~= iModel
        % Note:  don't check the model being renamed
        if strcmp(Name, this.Models(i).Name)
            OK = false;
            return
        end
    end
end
OK = true;
