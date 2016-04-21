function map = getmap(map, idx)
% GETMAP xPC Target private function.
%
%    Do not call this function directly.

%   This function is for use with the CAN bit (un)packing block(s). It
%   takes a matrix map which is 5 x n, transposes it to make it n x 5,
%   and then returns only those rows whose first element match 'idx'.
%   In those rows, the first element is skipped.
%   Thus, if idx == 1, you get those rows (of the transposed matrix)
%   whose first element is 1. However, the first element itself (1 in this
%   case) is not returned. Also, the rows are sorted in the column order
%   [3 4 1 2].
%
%   This function is called from the TLC file of the (un)packing block.


% $Revision: 1.1 $ $Date: 2002/09/25 22:32:11 $
% Copyright 1996-2002 The MathWorks, Inc.

map = map';
map = int8(sortrows(map(map(:, 1) == idx, 2 : end), [3,4,1,2]));
