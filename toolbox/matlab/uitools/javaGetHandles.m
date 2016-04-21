function cellArray = javaGetHandles (objArray)
% Returns a cell array of Java handles to all the objects in the argument array.
% This is a utility function used by the plot tool.

% Copyright 2002 The MathWorks, Inc.

cellArray = cell (1, length(objArray));
for i = 1:length(objArray)
     cellArray(i) = java (handle (objArray(i)));
end
