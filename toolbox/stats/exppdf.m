function y = exppdf(x,mu)
%EXPPDF Exponential probability density function.
%   Y = EXPPDF(X,MU) returns the pdf of the exponential distribution with
%   location parameter MU, evaluated at the values in X.  The size of P is
%   the common size of the input arguments.  A scalar input functions as a
%   constant matrix of the same size as the other input.
%
%   The default value for MU is 1.
%
%   See also EXPCDF, EXPFIT, EXPINV, EXPLIKE, EXPRND, EXPSTAT, PDF.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London.

%     Copyright 1993-2004 The MathWorks, Inc. 
%     $Revision: 2.12.4.2 $  $Date: 2004/01/24 09:33:38 $

if nargin < 2
    mu = 1;
end

% Return NaN for out of range parameters.
mu(mu <= 0) = NaN;

try
    z = x ./ mu;
catch
    error('stats:exppdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
y = exp(-z) ./ mu;

% Force zero for negative x values.
y(z < 0) = 0;
