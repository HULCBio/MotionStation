function A=subsref(A,S)
%SUBSREF subscripted reference

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:14 $

% this function causes all of the object's fields to be public

A=builtin('subsref',A,S);
