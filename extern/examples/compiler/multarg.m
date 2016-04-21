function [a, b] = multarg(x, y)
% multargp.c calls this M-file.

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
%
a = (x + y) * pi; 
b = svd(svd(a)); 
