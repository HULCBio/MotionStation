function r = poissrnd(lambda,varargin)
%POISSRND Random arras from the Poisson distribution.
%   R = POISSRND(LAMBDA) returns an array of random numbers chosen from the
%   Poisson distribution with parameter LAMBDA.  The size of R is the size
%   of LAMBDA.
%
%   R = POISSRND(LAMBDA,M,N,...) or R = POISSRND(LAMBDA,[M,N,...]) returns
%   an M-by-N-by-... array.
%
%   See also POISSCDF, POISSINV, POISSPDF, POISSSTAT, RANDOM.

%   POISSRND uses a waiting time method for small values of LAMBDA,
%   and Ahrens' and Dieter's method for larger values of LAMBDA.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation,
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.12.4.4 $  $Date: 2004/01/24 09:34:54 $

if nargin < 1
    error('stats:poissrnd:TooFewInputs','Requires at least one input argument.');
end

[err, sizeOut, numelOut] = statsizechk(1,lambda,varargin{:});
if err > 0
    error('stats:poissrnd:InputSizeMismatch','Size information is inconsistent.');
end

lambda(lambda < 0) = NaN;
if isscalar(lambda)
    lambda = repmat(lambda, numelOut, 1);
else
    lambda = lambda(:);
end

%Initialize r to zero.
if isa(lambda,'single')
   r = zeros(sizeOut,'single');
else
   r = zeros(sizeOut);
end

r(isinf(lambda)) = Inf;

% For large lambda, use the method of Ahrens and Dieter as
% described in Knuth, Volume 2, 1998 edition.
k = find(15 <= lambda & lambda < Inf);
if ~isempty(k)
   alpha = 7/8;
   lk = lambda(k);
   m = floor(alpha * lk);

   % Generate m waiting times, all at once
   x = randg(m);
   t = (x <= lk);

   % If we did not overshoot, then the number of additional times
   % has a Poisson distribution with a smaller mean.
   r(k(t)) = m(t) + poissrnd(lk(t)-x(t));

   % If we did overshoot, then the times up to m-1 are uniformly
   % distributed on the interval to x, so the count of times less
   % than lambda has a binomial distribution.
   r(k(~t)) = binornd(m(~t)-1, lk(~t)./x(~t));
end

% For small lambda, generate and count waiting times.
j = find(lambda < 15);
p = zeros(numel(j),1);
while ~isempty(j)
    p = p - log(rand(numel(j),1));
    t = (p < lambda(j));
    j = j(t);
    p = p(t);
    r(j) = r(j) + 1;
end

% Return NaN if LAMBDA is negative.
r(isnan(lambda)) = NaN;
