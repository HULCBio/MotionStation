function r = trnd(v,varargin)
%TRND   Random arrays from Student's t distribution.
%   R = TRND(V) returns an array of random numbers chosen from Student's t
%   distribution with V degrees of freedom.  The size of R is the size of
%   V.
%
%   R = TRND(V,M,N,...) or R = TRND(V,[M,N,...]) returns an M-by-N-by-...
%   array.
%
%   The t distribution with one degree of freedom is also known as the
%   Cauchy distribution.
%
%   See also TCDF, TINV, TPDF, TSTAT, NCTRND, RANDOM.

%   TRND uses a composition of normal and chi-square random variables.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation,
%           Springer-Verlag, 843pp.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.14.4.3 $  $Date: 2004/01/24 09:37:07 $

if nargin < 1
    error('stats:trnd:TooFewInputs','Requires at least one input argument.');
end

[err, sizeOut] = statsizechk(1,v,varargin{:});
if err > 0
    error('stats:trnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
% Non-integer degrees of freedom are allowed.
v(v <= 0) = NaN;

% Infinite degrees of freedom is equivalent to a normal, and valid.
% Prevent Inf/Inf==NaN for the standardized chi-square in the denom.
v(isinf(v)) = realmax;

% A chi2(v) random variable is just a gam(v/2,2) r.v.
r = randn(sizeOut) .* sqrt(v ./ (2.*randg(v./2,sizeOut)));
