function r = binornd(n,p,varargin)
% BINORND Random arrays from the binomial distribution.
%   R = BINORND(N,P,MM,NN) returns an array of random numbers chosen from a
%   binomial distribution with parameters N and P.  The size of R is the
%   common size of N and P if both are arrays.  If either parameter is a
%   scalar, the size of R is the size of the other parameter.
%   
%   R = BINORND(N,P,MM,NN,...) or R = BINORND(N,P,[MM,NN,...]) returns an
%   MM-by-NN-by-... array.
%
%   See also BINOCDF, BINOINV, BINOPDF, BINOSTAT, RANDOM.

%   BINORND generates values using the definition of the binomial
%   distribution, as a sum of Bernoulli random variables.  See Devroye,
%   Lemma 4.1 on page 428, method on page 524.

%   References:
%      [1]  Devroye, L. (1986) Non-Uniform Random Variate Generation, 
%           Springer-Verlag.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.11.4.5 $  $Date: 2004/03/02 21:49:04 $

if nargin < 2
    error('stats:binornd:TooFewInputs','Requires at least two input arguments.'); 
end

[err, sizeOut] = statsizechk(2,n,p,varargin{:});
ndimsOut = numel(sizeOut);
if err > 0
    error('stats:binornd:InputSizeMismatch','Size information is inconsistent.');
end

% Handle the scalar params case efficiently
if isscalar(n) && isscalar(p) % scalar params
    if (0 <= p && p <= 1) && (0 <= n && round(n) == n)
        r = sum(rand([sizeOut,double(n)]) < p, ndimsOut+1);
    else
        r = repmat(NaN, sizeOut);
    end

% Handle the scalar n case efficiently
elseif isscalar(n)
    if 0 <= n && round(n) == n
        r = sum(rand([sizeOut,n]) < repmat(p, [ones(1,ndimsOut),n]), ndimsOut+1);
        r(p < 0 | 1 < p) = NaN;
    else
        r = repmat(NaN, sizeOut);
    end

% Handle the non-scalar params case
else 
    if isscalar(p), p = repmat(p, sizeOut); end
    r = zeros(sizeOut);
    for i = 1:max(n(:))
        k = find(n >= i);
        r(k) = r(k) + (rand(size(k)) < p(k));
    end
    r(p < 0 | 1 < p | n < 0 | round(n) ~= n) = NaN;
end
