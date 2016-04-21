function p = factorial(n)
%FACTORIAL Factorial function.
%   FACTORIAL(N) for scalar N, is the product of all the integers from 1 to N,
%   i.e. prod(1:N). When N is an N-D matrix, FACTORIAL(N) is the factorial for
%   each element of N.  Since double precision numbers only have about
%   15 digits, the answer is only accurate for N <= 21. For larger N,
%   the answer will have the correct order of magnitude, and is accurate for 
%   the first 15 digits.
%
%   See also PROD.

% Copyright 1998-2004 The MathWorks, Inc.

N = n(:);
if any(fix(N) ~= N) || any(N < 0) || ~isa(N,'double') || ~isreal(N)
  error('MATLAB:factorial:NNegativeInt', ...
        'N must be a matrix of non-negative integers.')
end
n(N>170) = 171;
m = max([1;n(:)]);
N = [1 1 cumprod(2:m)];
p = N(n+1);
