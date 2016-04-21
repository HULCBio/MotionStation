function args = formula(fun)
%FORMULA Function formula.
%   FORMULA(FUN) returns the formula for the INLINE object FUN.
%
%   See also INLINE/ARGNAMES, INLINE/CHAR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 04:21:17 $

args = fun.expr;
