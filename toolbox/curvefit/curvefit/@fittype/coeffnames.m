function coeffs = coeffnames(fun)
%COEFFNAMES Coefficient names.
%   COEFFNAMES(FUN) returns the names of the coefficients of the
%   FITTYPE object FUN as a cell array of strings.
%
%   See also FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.5.2.1 $  $Date: 2004/02/01 21:41:27 $

if isempty(fun.coeff)
   coeffs = {};
else
   coeffs = cellstr(fun.coeff);
end
