function args = argnames(fun)
%ARGNAMES Argument names.
%   ARGNAMES(FUN) returns the names of the input arguments of the
%   INLINE object FUN as a cell array of strings.
%
%   See also INLINE/FORMULA.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:21:05 $

args = cellstr(fun.args);
