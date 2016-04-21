%SYMLINDEMO Demonstrate Symbolic Linear Algebra.

%  Copyright 1993-2002 The MathWorks, Inc. 
%  $Revision: 1.8 $  $Date: 2002/04/15 03:14:02 $

if any(get(0,'children') == 3), close(3), end
echo on
clc

% Demonstrate Symbolic Linear Algebra.

% Generate a possibly familiar test matrix, the 5-by-5 Hilbert matrix.

H = sym(hilb(5))

pause % Strike any key to continue.

% The determinant is very small.

d = det(H)

pause % Strike any key to continue.

% The elements of the inverse are integers.

X = inv(H)

pause % Strike any key to continue.

% Verify that the inverse is correct.

I = X*H

pause % Strike any key to continue.

% Find the characteristic polynomial.

p = poly(H)

pause % Strike any key to continue.

% Try to factor the characteristic polynomial.

factor(p)

% The result indicates that the characteristic polynomial
% cannot be factored over the rational numbers.

pause % Strike any key to continue.

% Compute 50 digit numerical approximations to the eigenvalues.

digits(50)
e = eig(vpa(H))

pause % Strike any key to continue.
clc

% Create a generalized Hilbert matrix involving a free variable, t.

t = sym('t');
[I,J] = meshgrid(1:5);
H = 1./(I+J-t)

pause % Strike any key to continue.

% Substituting t = 1 retrieves the original Hilbert matrix.

subs(H,t,1)

pause % Strike any key to continue.

% The reciprocal of the determinant is a polynomial in t.

d = 1/det(H)

pause % Strike any key to continue.

d = expand(d)

pause % Strike any key to continue.

pretty(d)

pause % Strike any key to continue.

% The elements of the inverse are also polynomials in t.

X = inv(H)

pause % Strike any key to continue.

% Substituting t = 1 generates the Hilbert inverse.

subs(X,t,1)

pause % Strike any key to continue.
clc

% Investigate a different example.

A = sym(gallery(5))

% This matrix is "nilpotent".  It's fifth power is the zero matrix.

A^5

pause % Strike any key to continue.
clc

% Because this matrix is nilpotent, its characteristic polynomial is very simple.

p = poly(A,'lambda')

pause % Strike any key to continue.

% You should now be able to compute the matrix eigenvalues in your head.
% They are the zeros of the equation lambda^5 = 0.

pause % Strike any key to continue.

% Symbolic computation can find the eigenvalues exactly.

lambda = eig(A)

pause % Strike any key to continue.
clc

% Numeric computation involves roundoff error and finds the zeros of an equation
% that is something like
%     lambda^5 = eps*norm(A)
% So the computed eigenvalues are roughly
%     lambda = (eps*norm(A))^(1/5)
% Here are the eigenvalues, computed by the Symbolic Toolbox using 16 digit
% floating point arithmetic.  It is not obvious that they should all be zero.

digits(16)
lambda = eig(vpa(A))

pause % Strike any key to continue.
clc

% This matrix is also "defective".  It is not similar to a diagonal matrix.
% Its Jordan Canonical Form is not diagonal.

J = jordan(A)

pause % Strike any key to continue.
clc

% The matrix exponential, expm(t*A), is usually expressed in terms of scalar exponentials
% involving the eigenvalues, exp(lambda(i)*t).  But for this matrix, the elements of
% expm(t*A) are all polynomials in t.

t = sym('t');
E = expm(t*A)

pause % Strike any key to continue.
clc

% By the way, the function "exp" computes element-by-element exponentials.

X = exp(t*A)

pause % Strike any key to terminate.
echo off
