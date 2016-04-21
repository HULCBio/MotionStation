function out1 = getCells(h)

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:52 $

% extract cell string data and convert to 2d java cell array
import java.lang.*

cellstrs = h.celldata;
s = size(cellstrs);
out1  = javaArray('java.lang.String',s(1),s(2));
for row=1:s(1)
    for col=1:s(2)
        out1(row,col) = String(cellstrs(row,col));
    end
end
