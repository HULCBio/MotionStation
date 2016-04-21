function r = normrnd(mu,sigma,varargin);
%NORMRND Random arrays from the normal distribution.
%   R = NORMRND(MU,SIGMA) returns an array of random numbers chosen from a
%   normal distribution with mean MU and standard deviation SIGMA.  The size
%   of R is the common size of MU and SIGMA if both are arrays.  If either
%   parameter is a scalar, the size of R is the size of the other
%   parameter.
%
%   R = NORMRND(MU,SIGMA,M,N,...) or R = NORMRND(MU,SIGMA,[M,N,...])
%   returns an M-by-N-by-... array.
%
%   See also NORMCDF, NORMFIT, NORMINV, NORMLIKE, NORMPDF, NORMSTAT,
%   RANDOM, RANDN.

%   NORMRND uses Marsaglia's ziggurat method.

%   References:
%      [1] Marsaglia, G. and Tsang, W.W. (1984) "A fast, easily implemented
%          method for sampling from decreasing or symmetric unimodal density
%          functions", SIAM J. Sci. Statist. Computing, 5:349-359.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.13.4.3 $  $Date: 2004/01/24 09:34:48 $

if nargin < 2
    error('stats:normrnd:TooFewInputs','Requires at least two input arguments.');
end

[err, sizeOut] = statsizechk(2,mu,sigma,varargin{:});
if err > 0
    error('stats:normrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
sigma(sigma < 0) = NaN;

r = randn(sizeOut) .* sigma + mu;
