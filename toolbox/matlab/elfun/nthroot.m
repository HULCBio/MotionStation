function y = nthroot(x, n)
%NTHROOT Real n-th root of real numbers.
%
%   NTHROOT(X, N) returns the real Nth root of the elements of X.
%   Both X and N must be real, and if X is negative, N must be an odd integer.
%
%   See also POWER.

%   Thanks to Peter J. Acklam (http://home.online.no/~pjacklam)
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:06:09 $

if ~isreal(x) || ~isreal(n)
   error('MATLAB:nthroot:ComplexInput', 'Both X and N must be real.');
end

if any((x(:) < 0) & ((n(:) ~= fix(n(:)))) | rem(n,2)==0)
   error('MATLAB:nthroot:NegXNotOddIntegerN',...
         'If X is negative, N must be an odd integer.');
end

y = sign(x) .* abs(x).^(1/n);

% Correct numerical errors (since, e.g., 64^(1/3) is not exactly 4)
% by one iteration of Newton's method
m = (x~=0);
y(m) = y(m) - (y(m).^n - x) ./ (n * y(m).^(n-1));
