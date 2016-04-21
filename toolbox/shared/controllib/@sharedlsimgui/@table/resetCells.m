function l = resetCells(h, cellData)

% RESETCELLS Used by java to write back edited table values to the @table

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:03 $

l = 1;

% deactivate listeners to avoid loop
for L = h.listeners'
    set(L,'Enabled','off');
end

nrows = cellData.length;
ncols = cellData(1).length;
cellArray = cell(nrows,ncols);
for row=1:nrows
    for col=1:ncols
       cellArray{row,col} = char(cellData(row,col));
    end
end
h.celldata = cellArray;

% turn listeners back on
for L = h.listeners'
    L.Enabled = 'on';
end
