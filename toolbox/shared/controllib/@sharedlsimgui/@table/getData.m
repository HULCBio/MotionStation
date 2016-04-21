function out1 = getdata(h)

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:54 $

nrows = size(h.celldata,1);
ncols = size(h.celldata,2);

out1 = javaArray('java.lang.String',nrows,ncols);
for row=1:nrows
    for col=1:ncols
        cellval = h.celldata{row,col};
        if isempty(cellval)
            cellval = ' ';
        end
        out1(row,col) = java.lang.String(cellval);
    end
end

