function r = raylrnd(b,varargin)
%RAYLRND Random arrays from the Rayleigh distribution.
%   R = RAYLRND(B) returns an array of random numbers chosen from the
%   Rayleigh distribution with parameter B.  The size of R is the size of
%   B.
%
%   R = RAYLRND(B,M,N,...) or R = RAYLRND(B,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also RAYLCDF, RAYLINV, RAYLPDF, RAYLSTAT, RANDOM.

%   RAYLRND uses a transformation method, expressing a Rayleigh
%   random variable in terms of a chi-square random variable.

%   Reference:
%      [1] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.4.3 $  $Date: 2004/01/24 09:36:46 $

if nargin < 1
    error('stats:raylrnd:TooFewInputs','Requires at least one input argument.'); 
end

[err, sizeOut] = statsizechk(1,b,varargin{:});
if err > 0
    error('stats:raylrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
b(b < 0) = NaN;

% Generate chi-squared 2 d.f. random values and take their sqrt.
r = sqrt(randn(sizeOut).^2 + randn(sizeOut).^2) .* b;
