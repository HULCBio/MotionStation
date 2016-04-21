function r = betarnd(a,b,varargin);
%BETARND Random arrays from beta distribution.
%   R = BETARND(A,B) returns an array of random numbers chosen from the
%   beta distribution with parameters A and B.  The size of R is the common
%   size of A and B if both are arrays.  If either parameter is a scalar,
%   the size of R is the size of the other parameter.
%
%   R = BETARND(A,B,M,N,...) or R = BETARND(A,B,[M,N,...]) returns an
%   M-by-N-by-... array.
%
%   See also BETACDF, BETAINV, BETAPDF, BETASTAT, RANDOM.

%   BETARND uses a transformation method, expressing a beta random variable
%   in terms of gamma random variables (Devroye, page 430).

%   Reference:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.4.2 $  $Date: 2003/11/01 04:25:06 $

if nargin < 2
    error('stats:betarnd:TooFewInputs','Requires at least two input arguments.');
end

[err, sizeOut] = statsizechk(2,a,b,varargin{:});
if err > 0
    error('stats:betarnd:InputSizeMismatch',...
          'Size information is inconsistent.');
end

% Generate gamma random values and take ratio of the first to the sum.
g1 = randg(a,sizeOut); % could be Infs or NaNs
g2 = randg(b,sizeOut); % could be Infs or NaNs
r = g1 ./ (g1 + g2);
