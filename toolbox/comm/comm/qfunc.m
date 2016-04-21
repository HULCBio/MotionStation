function y = qfunc(x)
%QFUNC  Q function.
%   Y = QFUNC(X) returns 1 minus the cumulative distribution function of the 
%   standardized normal random variable for each element of X.  X must be a real
%   array. The Q function is defined as:
%
%     Q(x) = 1/sqrt(2*pi) * integral from x to inf of exp(-t^2/2) dt
%
%   It is related to the complementary error function (erfc) according to
%
%     Q(x) = 0.5 * erfc(x/sqrt(2))
%
%   See also QFUNCINV, ERF, ERFC, ERFCX, ERFINV, ERFCINV.

%   Copyright 1996-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/10/20 12:42:40 $

if (~isreal(x) || ischar(x))
  error('The argument of the Q function must be a real array.'); 
end
y = 0.5 * erfc(x/sqrt(2));
return;