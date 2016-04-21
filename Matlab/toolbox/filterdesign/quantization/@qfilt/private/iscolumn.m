function t = iscolumn(v)
%ISCOLUMN  True for a column vector.
%   ISCOLUMN(V) returns 1 if V is a column vector and 0 otherwise.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/12 23:25:55 $

t = privisvector(v) & size(v,2)<=1;
