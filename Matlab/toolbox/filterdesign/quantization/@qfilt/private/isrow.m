function t = isrow(v)
%ISROW  True for a row vector.
%   ISROW(V) returns 1 if V is a row vector and 0 otherwise.
 
%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/12 23:25:56 $

t = privisvector(v) & size(v,1)<=1;
