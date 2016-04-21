function derexpr = derivexpr(fun)
% DERIVEXPR Derivative expression.
%   DERIVEXPR(FUN) returns the derivative expression of the
%   FITTYPE object FUN. At this time, it is always a function handle.
%
%   See also FITTYPE/INTEGEXPR, FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:41:30 $

derexpr = fun.derexpr;