function f = factor(n)
%FACTOR Prime factors.
%   FACTOR(N) returns a vector containing the prime factors of N.
%
%   This function uses the simple sieve approach. It may require large
%   memory allocation if the number given is too big. Technically
%   it is possible to improve this algorithm, allocating less
%   memory for most cases and resulting in a faster execution
%   time. However, it will still have problems in the worst
%   case, so we choose to impose an upper bound on the input number
%   and error out for n > 2^32. 
% 
%   See also PRIMES, ISPRIME.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2003/05/01 20:43:41 $

if numel(n)~=1, error('MATLAB:factor:NonScalarInput','N must be a scalar.'); end
if (n < 0) || (floor(n) ~= n)
  error('MATLAB:factor:InputNotPosInt', 'N must be a positive integer.'); 
end
if n > 2^32
    error('MATLAB:factor:InputOutOfRange','The maximum value of n allowed is 2^32.');
end

if n < 4
   f=n; 
   return
else
   f = [];
end

p = primes(sqrt(n));
while n>1,
  d = find(rem(n,p)==0);
  if isempty(d)
    f = [f n];
    break; 
  end
  p = p(d);
  f = [f p];
  n = n/prod(p);
end

f = sort(f);
