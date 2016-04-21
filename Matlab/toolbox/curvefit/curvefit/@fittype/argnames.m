function args = argnames(fun)
%ARGNAMES Argument names.
%   ARGNAMES(FUN) returns the names of the input arguments of the
%   FITTYPE object FUN as a cell array of strings.
%
%   See also FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:22 $

args = cellstr(fun.args);
