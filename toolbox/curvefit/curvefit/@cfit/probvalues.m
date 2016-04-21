function probs = probvalues(fun)
%PROBVALUES Problem parameter values.
%   PROBVALUES(FUN) returns the values of the problem parameters of the
%   CFIT object FUN as a row vector.
%
%   See also CFIT/COEFFVALUES, FITTYPE/FORMULA.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:40:57 $

if isempty(fun.probValues)
   probs = {};
else
   probs = [fun.probValues{:}];
end
