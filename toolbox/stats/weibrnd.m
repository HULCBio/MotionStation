function r = weibrnd(a,b,varargin)
%WEIBRND Random arrays from the Weibull distribution.
%   R = WEIBRND(A,B) returns an array of random numbers chosen from the
%   Weibull distribution with parameters A and B.  The size of R is the
%   common size of A and B if both are arrays.  If either parameter is a
%   scalar, the size of R is the size of the other parameter.
%
%   R = WEIBRND(A,B,M,N,...) or R = WEIBRND(A,B,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also WBLCDF, WBLFIT, WBLINV, WBLLIKE, WBLPDF, WBLRND, WBLSTAT, RANDOM.

%   WEIBRND uses the inversion method. 

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.2 $  $Date: 2003/11/01 04:29:48 $

if nargin < 2
    error('stats:weibrnd:TooFewInputs','Requires two input arguments.'); 
end

[err, sizeOut] = statsizechk(2,a,b,varargin{:});
if err > 0
    error('stats:weibrnd:InputSizeMismatch','Size information is inconsistent.');
end

% Return NaN for elements corresponding to illegal parameter values.
a(a <= 0) = NaN;
b(b <= 0) = NaN;

% Generate uniform random values, and apply the Weibull inverse CDF.
r = (-log(rand(sizeOut))./a) .^ (1 ./ b);
