function isp = isprime(X)
%ISPRIME True for prime numbers.
%   ISPRIME(X) is 1 for the elements of X that are prime, 0 otherwise.
%
%   See also FACTOR, PRIMES.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2003/05/01 20:43:48 $

if isempty(X), isp = false(size(X)); return, end
if any(X(:) < 0) || any(floor(X(:)) ~= X(:))
  error('MATLAB:isprime:InputNotPosInt',...
        'All entries of X must be positive integers.'); 
end

isp = false(size(X));
n = max(X(:));
if n > 2^32
    error('MATLAB:isprime:InputOutOfRange',...
          'The maximum value of X allowed is 2^32.');
end

p = primes(ceil(sqrt(n)));
for k = 1:numel(isp)
   isp(k) = all(rem(X(k), p(p<X(k))));
end

% p(p<1) would give an empty matrix and all([]) returns true.
% we need to correct isp for this case.
isp(X==1 | X==0)=0;
