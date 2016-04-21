function args = formula(fun)
%FORMULA Function formula.
%   FORMULA(FUN) returns the formula for the FITTYPE object FUN.
%
%   See also FITTYPE/ARGNAMES, FITTYPE/CHAR.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:38 $

args = fun.defn;
