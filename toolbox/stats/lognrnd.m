function r = lognrnd(mu,sigma,varargin);
%LOGNRND Random arrays from the lognormal distribution.
%   R = LOGNRND(MU,SIGMA) returns an array of random numbers chosen from
%   the lognormal distribution with log mean MU and log standard deviation
%   SIGMA.  The size of R is the common size of MU and SIGMA if both are
%   arrays.  If either parameter is a scalar, the size of R is the size
%   of the other parameter.
%
%   R = LOGNRND(MU,SIGMA,M,N,...) or R = LOGNRND(MU,SIGMA,[M,N,...])
%   returns an M-by-N-by-... array.
%
%   See also LOGNCDF, LOGNFIT, LOGNINV, LOGNLIKE, LOGNPDF, LOGNSTAT, 
%   RANDOM, RANDN.

%   LOGNRND uses a transformation of a normal random variable.

%   References:
%      [1] Marsaglia, G. and Tsang, W.W. (1984) "A fast, easily implemented
%          method for sampling from decreasing or symmetric unimodal density
%          functions", SIAM J. Sci. Statist. Computing, 5:349-359.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.4.3 $  $Date: 2004/01/24 09:34:25 $

if nargin < 2
    error('stats:lognrnd:TooFewInputs','Requires at least two input arguments.');
end

[err, sizeOut] = statsizechk(2,mu,sigma,varargin{:});
if err > 0
    error('stats:lognrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
sigma(sigma < 0) = NaN;

r = exp(randn(sizeOut) .* sigma + mu);
