function r = exprnd(mu,varargin)
%EXPRND Random arrays from exponential distribution.
%   R = EXPRND(MU) returns an array of random numbers chosen from the
%   exponential distribution with location parameter MU.  The size of R is
%   the size of MU.
%
%   R = EXPRND(MU,M,N,...) or R = EXPRND(MU,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also EXPCDF, EXPFIT, EXPINV, EXPLIKE, EXPPDF, EXPSTAT, RANDOM.

%   EXPRND uses the inversion method.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.14.4.3 $  $Date: 2004/01/24 09:33:39 $

if nargin < 1
    error('stats:exprnd:TooFewInputs','Requires at least one input argument.');
end

[err, sizeOut] = statsizechk(1,mu,varargin{:});
if err > 0
    error('stats:exprnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
mu(mu < 0) = NaN;

% Generate uniform random values, and apply the exponential inverse CDF.
r = -mu .* log(rand(sizeOut)); % == expinv(u, mu)

