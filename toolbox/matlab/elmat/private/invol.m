function A = invol(n)
%INVOL  Involutory matrix.
%   A = GALLERY('INVOL',N) is an N-by-N involutory (A*A = EYE(N)) 
%   and ill-conditioned matrix. It is a diagonally scaled version 
%   of HILB(N).
%
%   Note: B = (EYE(N)-A)/2 and B = (EYE(N)+A)/2 are 
%   idempotent (B*B = B).

%   Reference:
%   [1] A.S. Householder and J.A. Carpenter, The singular values
%       of involutory and of idempotent matrices, 
%       Numer. Math. 5 (1963), pp. 234-237.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:42:32 $

A = hilb(n);

d = -n;
A(:, 1) = d*A(:, 1);

for i = 1:n-1
    d = -(n+i)*(n-i)*d/(i*i);
    A(i+1, :) = d*A(i+1, :);
end
