function t = isscalar(v)
%ISSCALAR  True for a scalar or empty.
%   ISSCALAR(V) returns 1 if V is a scalar and 0 otherwise.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:27:28 $

t = ndims(v)==2 & prod(size(v))<=1;
