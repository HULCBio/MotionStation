function args = fevalexpr(fun)
%FEVALEXPR expression to feval.
%   FEVALEXPR(FUN) returns the expression for the FITTYPE object FUN.
%
%   See also FITTYPE/ARGNAMES, FITTYPE/CHAR.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:35 $

args = fun.expr;
