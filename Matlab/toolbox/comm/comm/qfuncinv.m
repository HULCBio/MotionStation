function y = qfuncinv(x)
%QFUNCINV  Inverse Q function.
%   Y = QFUNCINV(X) returns the argument of the Q function at which the Q function's
%   value is X.  X must be a real array with elements between 0 and 1, inclusive.
%
%   For a scalar X, the Q function is 1 minus the cumulative distribution function of
%   the standardized normal random variable evaluated at X.  The Q function is
%   defined as:
%
%     Q(x) = 1/sqrt(2*pi) * integral from x to inf of exp(-t^2/2) dt
%
%   The Q function is related to the complementary error function (erfc) according to
%
%     Q(x) = 0.5 * erfc(x/sqrt(2))
%
%   See also QFUNC, ERF, ERFC, ERFCX, ERFINV, ERFCINV.

%   Copyright 1996-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/10/20 12:42:41 $

if (~isreal(x) || ischar(x))
  error('The argument of the inverse Q function must be a real array.'); 
end;

% The erfcinv function performs error checking for all real arguments that are
% outside the range 0<X<1

y = sqrt(2) * erfcinv(2*x);
return;