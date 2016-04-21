function exportedFcnsInfo = sort_exported_fcns_info(exportedFcnsInfo)
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2004/04/15 01:00:27 $

if(~isempty(exportedFcnsInfo))
    names = {exportedFcnsInfo.name};
    [names,indices] = sort(names);
    exportedFcnsInfo = exportedFcnsInfo(indices);
end
