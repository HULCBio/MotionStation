function t = ismatrix(v)
%ISMATRIX  True for a matrix.
%   ISMATRIX(V) returns 1 if V is a 2-dimensional matrix and 0 otherwise.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:27:37 $

t = ndims(v)==2;
