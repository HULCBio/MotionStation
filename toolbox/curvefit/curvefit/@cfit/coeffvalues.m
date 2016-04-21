function coeffs = coeffvalues(fun)
%COEFFVALUES Coefficient values.
%   COEFFVALUES(FUN) returns the values of the coefficients of the
%   CFIT object FUN as a row vector.
%
%   See also CFIT/PROBVALUES, FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:39:04 $

if isempty(fun.coeffValues)
   coeffs = {};
else
   coeffs = [fun.coeffValues{:}];
end
