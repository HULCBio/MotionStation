function names = indepnames(fun)
%INDEPNAMES Independent parameter names.
%   INDEPNAMES(FUN) returns the names of the independent parameters of the
%   FITTYPE object FUN as a cell array of strings.
%
%   See also FITTYPE/DEPENDNAMES, FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:41 $

names = cellstr(fun.indep);