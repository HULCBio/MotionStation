function [item, idx] = privateGetNamedEntry(collection, name, ignoreCase)
%PRIVATEGETNAMEDENTRY Retreive an entry from a COM collection by name.
%

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:01:18 $

item = [];

if (ignoreCase)
    for idx = 1:collection.Count
        if (strcmpi(collection.Item(idx).Name, name) == 1)
            item = collection.Item(idx);
            return;
        end
    end
else
    for idx = 1:collection.Count
        if (strcmp(collection.Item(idx).Name, name) == 1)
            item = collection.Item(idx);
            return;
        end
    end
end

idx = [];

