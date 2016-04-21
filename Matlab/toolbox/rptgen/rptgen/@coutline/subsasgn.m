function out=subsasgn(A,S,B)
%SUBSASGN subscripted assignment

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:28 $

% this function causes all of the object's fields to be public

out=builtin('subsasgn',A,S,B);