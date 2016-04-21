function t = privisvector(v)
%PRIVISVECTOR  True for a vector.
%   PRIVISVECTOR(V) returns 1 if V is a vector and 0 otherwise.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:26:00 $

t = ndims(v)==2 & min(size(v))<=1;
