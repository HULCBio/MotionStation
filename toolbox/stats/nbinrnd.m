function rnd = nbinrnd(r,p,varargin)
%NBINRND Random arrays from the negative binomial distribution.
%   RND = NBINRND(R,P,M,N) returns an array of random numbers chosen from a
%   negative binomial distribution with parameters R and P.  The size of RND
%   is the common size of R and P if both are arrays.  If either parameter
%   is a scalar, the size of RND is the size of the other parameter.
%   
%   RND = NBINRND(R,P,M,N,...) or RND = NBINRND(R,P,[M,N,...]) returns an
%   M-by-N-by-... array. 
%
%   See also NBINCDF, NBININV, NBINPDF, NBINSTAT, RANDOM.

%   NBINRND uses either a sum of geometric random values, or a
%   Poisson/gamma mixture.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.4.3 $  $Date: 2004/01/24 09:34:39 $

if nargin < 2
    error('stats:nbinrnd:TooFewInputs','Requires at least two input arguments.'); 
end

[err, sizeOut] = statsizechk(2,r,p,varargin{:});
if err > 0
    error('stats:nbinrnd:InputSizeMismatch','Size information is inconsistent.');
end

if isscalar(r), r = repmat(r,sizeOut); end
if isscalar(p), p = repmat(p,sizeOut); end

rnd = zeros(sizeOut);

% Out of range or missing parameters return NaN.  Infinite values for
% R correspond to a Poisson, but its mean cannot be determined from the
% (R,P) parametrization.
nans = ~(0 < r & isfinite(r) & 0 < p & p <= 1);
rnd(nans) = NaN;

k = find(~nans);

% Generate Poisson random values mixed on gamma random values.
if any(round(r(k)) ~= r(k)  |  r(k) > 50)
    rnd(k) = poissrnd(randg(r(k)) .* (1-p(k))./p(k));
    
% Generate a sum of geometric random values.  This "discrete" generator
% is slow when R is large.
elseif any(k)
    plong = p(k); plong = plong(:)';
    rlong = r(k); rlong = rlong(:)';
    maxr = max(rlong);
    if maxr == 1
        rnd(k) = geornd(plong);
    else
        pbig = plong(ones(maxr,1),:);
        gr = geornd(pbig);

        count = length(plong);
        kk = (0:count-1);
        mask = zeros(maxr,count);
        mask(kk*maxr+rlong)=ones(count,1);
        mask = 1 - cumsum(mask) + mask; 
        rnd(k) = sum(gr .* mask);
    end
end