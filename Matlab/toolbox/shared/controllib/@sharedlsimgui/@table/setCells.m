function setCells(h, cellData)

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:05 $

if strcmp(class(cellData),'cell') % && (length(h.colnames)==0 || size(cellData,2) == length(h.colnames))
    h.celldata = cellData;
else 
    error('Celldata type or size does not match');
end
