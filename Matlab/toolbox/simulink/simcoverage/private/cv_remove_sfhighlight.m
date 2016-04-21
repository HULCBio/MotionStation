function cv_remove_sfhighlight(modelcovId)
% Function to remove model coverage highlighting from 
% Stateflow.
%
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $

    [mFiles, mexFiles]=inmem; 
    if ~any(strcmp(mexFiles,'sf'))
        return;
    end
    
    try
        modelName = cv('get',modelcovId,'modelcov.name');
        machineId = sf('find','all','machine.name',modelName);
    catch
        machineId = [];
    end
    
    if ~isempty(machineId)
        sf('ClearAltStyles',machineId);
        sf('Redraw',machineId);
    end
        
   