function r = ncx2rnd(v,delta,varargin)
%NCX2RND Random arrays from the noncentral chi-square distribution.
%   R = NCX2RND(V,DELTA) returns an array of random numbers chosen from the
%   noncentral chi-square distribution with parameters V and DELTA.  The
%   size of R is the common size of V and DELTA if both are arrays.  If
%   either parameter is a scalar, the size of R is the size of the other
%   parameter.
%
%   R = NCX2RND(V,DELTA,M,N,...) or R = NCX2RND(V,DELTA[,M,N,...]) returns
%   an M-by-N-by-... array.
%
%   See also NCX2CDF, NCX2INV, NCX2PDF, NCX2STAT, CHI2RND, RANDOM.

%   NCX2RND generates values using the sum of a "zero d.f." noncentral
%   chi-square and a central chi-square with v d.f.  See Johnson, Kotz,
%   and Balakrishnan, eqns 29.5b-c.

%   Reference:
%      [1] Johnson, N.L., Kotz, S., and Balakrishnan, N, (1995) Continuous
%          Univariate Distributions, Vol. 2, 2nd ed., Wiley.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.11.4.3 $  $Date: 2004/01/24 09:34:44 $

if nargin < 2
    error('stats:ncx2rnd:TooFewInputs','Requires at least two input arguments.');
end

[err, sizeOut] = statsizechk(2,v,delta,varargin{:});
if err > 0
    error('stats:ncx2rnd:InputSizeMismatch','Size information is inconsistent.');
end
ndimsOut = numel(sizeOut);

v(v <= 0) = NaN;
delta(delta < 0) = NaN;

% Sum a zero d.f. ncx2, and a v d.f chi2
r = 2.*randg(poissrnd(delta./2, sizeOut)) + 2.*randg(v./2,sizeOut);
