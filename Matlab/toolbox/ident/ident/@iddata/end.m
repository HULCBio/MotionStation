function endidx = end(dat,k,n)
%IDDATA/END returns the index of the last entry of a single-experiment
%    IDDATA object

%   Author: L. Ljung 23-10-03
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1 $   $Date: 2003/10/26 14:21:13 $
endidx = size(dat,k);
if length(endidx)>1
    error(['In range selection, ''end'' can only be used for single experiment iddata objects.'])
end