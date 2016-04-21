function names = probnames(fun)
%PROBNAMES Problem dependent parameter names.
%   PROBNAMES(FUN) returns the names of the problem dependent parameters of the
%   FITTYPE object FUN as a cell array of strings.
%
%   See also FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.1 $  $Date: 2004/02/01 21:42:54 $

if isempty(fun.prob)
   names = {};
else
   names = cellstr(fun.prob);
end
