function [m,v]= lognstat(mu,sigma);
%LOGNSTAT Mean and variance for the lognormal distribution.
%   [M,V] = LOGNSTAT(MU,SIGMA) returns the mean and variance of the
%   lognormal distribution with log mean MU and log standard deviation
%   SIGMA.  The sizes of M and V are the common size of the input arguments.
%   A scalar input functions as a constant matrix of the same size as the
%   other inputs.
%
%   See also LOGNCDF, LOGNFIT, LOGNINV, LOGNLIKE, LOGNPDF, LOGNRND.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.2 $  $Date: 2004/01/24 09:34:26 $

if nargin < 2
    error('stats:lognstat:TooFewInputs',...
          'Requires at least two input arguments.');
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

s2 = sigma .^ 2;

try
    m = exp(mu + 0.5 * s2);
    v = exp(2*mu + s2) .* (exp(s2)-1);
catch
    error('stats:lognstat:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
