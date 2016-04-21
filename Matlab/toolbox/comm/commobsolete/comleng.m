function y = comleng(y, x, str)
%COMLENG Make y the same length as x.
%
%WARNING: This is an obsolete function and may be removed in the future.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.13 $

comempty(y, str);
if length(y) < length(x)
    y = [y; y(length(y))*ones(length(x) - length(y), 1)];
end;
