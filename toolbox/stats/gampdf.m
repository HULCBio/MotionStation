function y = gampdf(x,a,b)
%GAMPDF Gamma probability density function.
%   Y = GAMPDF(X,A,B) returns the gamma probability density function with
%   shape and scale parameters A and B, respectively, at the values in X.
%   The size of Y is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   Some references refer to the gamma distribution with a single
%   parameter.  This corresponds to the default of B = 1.
%
%   See also GAMCDF, GAMFIT, GAMINV, GAMLIKE, GAMRND, GAMSTAT.

%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, section 26.1.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.10.2.5 $  $Date: 2004/01/24 09:33:56 $

if nargin < 2
    error('stats:gampdf:TooFewInputs','Requires at least two input arguments');
elseif nargin < 3
    b = 1;
end

% Return NaN for out of range parameters.
a(a <= 0) = NaN;
b(b <= 0) = NaN;

try
    z = x ./ b;

    % Negative data would create complex values, potentially creating
    % spurious NaNi's in other elements of y.  Map them to the far right
    % tail, which will be forced to zero.
    z(z < 0) = Inf;

    % Prevent LogOfZero warnings.
    warn = warning('off','MATLAB:log:logOfZero');
    u = (a - 1) .* log(z) - z - gammaln(a);
    warning(warn);
catch
    if exist('warn','var'), warning(warn); end
    error('stats:gampdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

% Get the correct limit for z == 0.
u(z == 0 & a == 1) = 0;
% These two cases work automatically
%  u(z == 0 & a < 1) = Inf;
%  u(z == 0 & a > 1) = -Inf;

% Force a 0 for extreme right tail, instead of getting exp(Inf-Inf)==NaN
u(z == Inf & isfinite(a)) = -Inf;
% Force a 0 when a is infinite, instead of getting exp(Inf-Inf)==NaN
u(z < Inf & a == Inf) = -Inf;

y = exp(u) ./ b;
