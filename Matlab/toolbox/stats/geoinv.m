function x = geoinv(y,p)
%GEOINV Inverse of the geometric cumulative distribution function.
%   X = GEOCDF(Y,P) returns the inverse cdf of the geometric distribution
%   with probability parameter P, evaluated at the values in Y.  Because
%   the geometric distribution is discrete, GEOINV returns the smallest
%   integer X such that the value of the cdf at X equals or exceeds Y.  The
%   size of X is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other input.
%
%   See also GEOCDF, GEOPDF, GEORND, GEOSTAT.

%   References:
%      [1] Abramowitz, M. and Stegun, I.A. (1964) Handbook of Mathematical
%          Functions, Dover, New York, 1046pp., sec. 26.1.24.
%      [2] Evans, M., Hastings, N., and Peacock, B. (1993) Statistical
%          Distributions, 2nd ed., Wiley, 170pp.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.4.2 $  $Date: 2004/01/16 20:09:21 $

if nargin < 2
    error('stats:geoinv:TooFewInputs','Requires two input arguments.');
end

k = (0 < y & y < 1);
if all(k(:))
    numer = log(1-y);
else
    % Return NaN for out of range probabilities: y<0 | 1<y | isnan(y).
    numer = repmat(NaN,size(y));
    numer(k) = log(1-y(k));
    numer(y == 0) = 0;
    numer(y == 1) = -Inf; % avoid log(0) warnings
end

peps = eps(class(p));
k = (peps < p & p < 1);
if all(k(:))
    denom = log(1-p);
else
    % Return NaN for out of range parameters: p<=0 | 1<p | isnan(p).
    denom = repmat(NaN,size(p));
    denom(0 < p & p <= peps) = -p(0 < p & p <= peps); % log(1-p) for small p
    denom(k) = log(1-p(k));
    denom(p == 1) = -Inf; % avoid log(0) warnings
end

% Because the geometric distribution is discrete, very small errors in
% computing the ratio log(1-y)/log(1-p) here can create +1 errors in the
% result, making geoinv(geocdf(x,p),p) sometimes equal to x+1.  We subtract
% a small amount from that ratio, and so that the jumps in geoinv are
% shifted a bit to the right, and geoinv(geocdf(x,p),p) will be correct
% more of the time.

try
    % log(1-y) and log(1-p) "really" should both be negative, and
    % the abs() here keeps the correct sign for their ratio when
    % roundoff (or y==0) makes one of them exactly zero. 
    x = ceil(abs(numer ./ denom) - 1 - sqrt(peps));
catch
    error('stats:geoinv:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
% When y==0 or p==1, x should be zero, instead of ceil(0-1).
x(x < 0) = 0;

% Force a 0 for y==1 and p==1, instead of a -Inf/-Inf==NaN.
x(y == 1 & p == 1) = 0;
