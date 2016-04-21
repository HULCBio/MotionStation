function y = lognpdf(x,mu,sigma)
%LOGNPDF Lognormal probability density function (pdf).
%   Y = LOGNPDF(X,MU,SIGMA) returns the pdf of a lognormal distribution
%   with log mean MU and log standard deviation SIGMA, evaluated at the
%   values in X.  The size of Y is the common size of the input arguments.
%   A scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   Default values for MU and SIGMA are 0 and 1 respectively.
%
%   See also LOGNCDF, LOGNFIT, LOGNINV, LOGNLIKE, LOGNRND, LOGNSTAT.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.15.4.2 $  $Date: 2004/01/24 09:34:24 $

if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

% Negative data would create complex values, potentially creating spurious
% NaNi's in other elements of y.  Map them, and zeros, to the far right
% tail, whose pdf will be zero.
x(x <= 0) = Inf;

try
    y = exp(-0.5 * ((log(x) - mu)./sigma).^2) ./ (x .* sqrt(2*pi) .* sigma);
catch
    error('stats:lognpdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
