function out1 = getCell(h, row, col)

% GETCELL Used by java to view the contents of a cell

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:51 $


row = double(row);
col = double(col);

X = h.celldata{(row-1)*length(h.colnames)+col};
if isempty(X)
   out1 = java.lang.String('');
else
   if isnumeric(X)
        out1 = java.lang.String(num2str(X));
   elseif ischar(X)
        out1 = java.lang.String(X);
   end     
end