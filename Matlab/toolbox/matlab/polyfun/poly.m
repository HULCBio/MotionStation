function c = poly(x)
%POLY Convert roots to polynomial.
%   POLY(A), when A is an N by N matrix, is a row vector with
%   N+1 elements which are the coefficients of the
%   characteristic polynomial, DET(lambda*EYE(SIZE(A)) - A) .
%
%   POLY(V), when V is a vector, is a vector whose elements are
%   the coefficients of the polynomial whose roots are the
%   elements of V . For vectors, ROOTS and POLY are inverse
%   functions of each other, up to ordering, scaling, and
%   roundoff error.
%
%   ROOTS(POLY(1:20)) generates Wilkinson's famous example.
%
%   Class support for inputs A,V:
%      float: double, single
%
%   See also ROOTS, CONV, RESIDUE, POLYVAL.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.14.4.2 $  $Date: 2004/03/02 21:47:54 $

[m,n] = size(x);
if m == n
   % Characteristic polynomial (square x)
   e = eig(x);
elseif (m==1) || (n==1)
   e = x;
else
   error('MATLAB:poly:InputSize','Argument must be a vector or a square matrix.')
end

% Strip out infinities
e = e( isfinite(e) );

% Expand recursion formula
n = length(e);
c = [1 zeros(1,n,class(x))];
for j=1:n
    c(2:(j+1)) = c(2:(j+1)) - e(j).*c(1:j);
end

% The result should be real if the roots are complex conjugates.
if isequal(sort(e(imag(e)>0)),sort(conj(e(imag(e)<0))))
    c = real(c);
end
