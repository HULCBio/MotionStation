function allds = cfgetalldatasets
%GETALLDATASETS Returns a cell array containing all datasets

%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:39:49 $
%   Copyright 2001-2004 The MathWorks, Inc.

dsdb=getdsdb;
child=down(dsdb);
allds = {};
while ~isempty(child)
   allds{length(allds)+1} = child;
   child=right(child);
end
