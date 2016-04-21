function [m,v]= normstat(mu,sigma);
%NORMSTAT Mean and variance for the normal distribution.
%   [M,V] = NORMSTAT(MU,SIGMA) returns the mean and variance of the normal
%   distribution with mean MU and standard deviation SIGMA.  The sizes of M
%   and V are the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%
%   See also NORMCDF, NORMFIT, NORMINV, NORMLIKE, NORMPDF, NORMRND.

%   References:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.1 $  $Date: 2003/11/01 04:27:42 $

if nargin < 2
    error('stats:normstat:TooFewInputs',...
          'Requires at least two input arguments.');
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

try
    m = mu + zeros(size(sigma)); % expand m's size to match sigma if necessary
    v = sigma.^2 + zeros(size(mu)); % expand v's size to match mu if necessary
catch
    error('stats:normstat:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
m(isnan(v)) = NaN;
v(isnan(m)) = NaN;