function y = normpdf(x,mu,sigma)
%NORMPDF Normal probability density function (pdf).
%   Y = NORMPDF(X,MU,SIGMA) returns the pdf of the normal distribution with
%   mean MU and standard deviation SIGMA, evaluated at the values in X.
%   The size of Y is the common size of the input arguments.  A scalar
%   input functions as a constant matrix of the same size as the other
%   inputs.
%
%   Default values for MU and SIGMA are 0 and 1 respectively.
%
%   See also NORMCDF, NORMFIT, NORMINV, NORMLIKE, NORMRND, NORMSTAT.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.4.1 $  $Date: 2003/11/01 04:27:39 $

if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    y = exp(-0.5 * ((x - mu)./sigma).^2) ./ (sqrt(2*pi) .* sigma);
catch
    error('stats:normpdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
