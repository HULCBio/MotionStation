function [VarNames, DataModels] = getmodels(this,Vars,Ws)
% [VarNames, DataModels] = GETMODELS(THIS,VARS,WS) Get the valid data 
%   from a defined workspace WS that are named in a cell array VARS.
%

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/03/24 20:51:44 $

% Loop over to filter based on size an class
Nvars = length(Vars);
isValidType = logical(zeros(Nvars,1));
for ct=1:Nvars,
    isValidType(ct) = this.firstfilter(Vars(ct));
end

sysvar = {Vars(isValidType).name}.';

% Evalin the variables
Nsys = length(sysvar);
DataModels = cell(Nsys,1);

if strcmp(Ws, 'file')
    % get variables from file
    DataModelStruct = load(fullfile(this.LastPath, this.FileName),sysvar{:});
    for ct=1:Nsys
        DataModels(ct) = {DataModelStruct.(sysvar{ct})};
    end
else 
    % get variables from Ws
    for ct=1:Nsys
        DataModels(ct) = {evalin(Ws,sysvar{ct})};
    end
end

% Now loop over second filter now that the variables are known
isValidType = logical(zeros(length(sysvar),1));

for ct=1:length(sysvar)
    isValidType(ct) = this.secondfilter(DataModels{ct});
end

ind = find(isValidType);
% sysvar = sysvar(ind);
VarNames = sysvar(ind);
DataModels = DataModels(ind);
