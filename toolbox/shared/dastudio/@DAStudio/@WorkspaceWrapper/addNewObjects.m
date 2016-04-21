function addNewObjects(h, objectType, newNames)

    if (isempty(h.wrappedWorkspace))
        ws = 'base';
    else
        ws = h.wrappedWorkspace;
    end

    if strcmp(objectType, 'double')
      objectType = 'zeros(1,1)';
    end

    for i=1:length(newNames),
      evalin(ws ,[newNames{i} ' = ' objectType ';']);
    end


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:32 $
