function names = indepnames(fun)
%INDEPNAMES Independent parameter names.
%   INDEPNAMES(FUN) returns the names of the independent parameters of the
%   CFIT object FUN as a cell array of strings.
%
%   See also CFIT/DEPENDNAMES.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:39:12 $

names = indepnames(fun.fittype);