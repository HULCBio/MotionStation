function y = evpdf(x,mu,sigma)
%EVPDF Extreme value probability density function (pdf).
%   Y = EVPDF(X,MU,SIGMA) returns the pdf of the type 1 extreme value
%   distribution with location parameter MU and scale parameter SIGMA,
%   evaluated at the values in X.  The size of Y is the common size of the
%   input arguments.  A scalar input functions as a constant matrix of the
%   same size as the other inputs.
%   
%   Default values for MU and SIGMA are 0 and 1, respectively.
%
%   The type 1 extreme value distribution is also known as the Gumbel
%   distribution.  If Y has a Weibull distribution, then X=log(Y) has the
%   type 1 extreme value distribution.
%
%   See also EVCDF, EVFIT, EVINV, EVLIKE, EVRND, EVSTAT, PDF.

%   References:
%     [1] Lawless, J.F. (1982) Statistical Models and Methods for Lifetime Data, Wiley,
%         New York.
%     [2} Meeker, W.Q. and L.A. Escobar (1998) Statistical Methods for Reliability Data,
%         Wiley, New York.
%     [3] Crowder, M.J., A.C. Kimber, R.L. Smith, and T.J. Sweeting (1991) Statistical
%         Analysis of Reliability Data, Chapman and Hall, London

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $  $Date: 2004/01/24 09:33:29 $

if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    z = (x - mu) ./ sigma;
    y = exp(z - exp(z)) ./ sigma;
catch
    error('stats:evpdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Force a 0 for extreme right tail, instead of getting exp(Inf-Inf)==NaN
y(z == Inf) = 0;
