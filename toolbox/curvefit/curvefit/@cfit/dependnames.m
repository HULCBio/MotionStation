function names = dependnames(fun)
%DEPENDNAMES Dependent parameter names.
%   DEPENDNAMES(FUN) returns the names of the dependent parameters of the
%   FITTYPE object FUN as a cell array of strings.
%
%   See also CFIT/INDEPNAMES.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:39:06 $

names = dependnames(fun.fittype);