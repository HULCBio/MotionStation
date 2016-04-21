function C = circul(v)
%CIRCUL Circulant matrix.
%   C = GALLERY('CIRCUL',V) is the circulant matrix whose first row is V.
%   A circulant matrix has the property that each row is obtained
%   from the previous one by cyclically permuting the entries one step
%   forward. It is a special Toeplitz matrix in which the diagonals
%   "wrap round". If V is a scalar, then C = GALLERY('CIRCUL',1:V).
%
%   The eigensystem of C (N-by-N) is known explicitly. If t is an Nth
%   root of unity, then the inner product of V with W = [1 t t^2 ... t^(N-1)]
%   is an eigenvalue of C, and W(N:-1:1) is an eigenvector of C.

%   Reference:
%   [1] P.J. Davis, Circulant Matrices, John Wiley, 1977.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 03:42:02 $

n = length(v);

if n == 1
   n = v;
   v = 1:n;
end

v = v(:).';   % Make sure v is a row vector.

C = toeplitz( [ v(1) v(n:-1:2) ], v );
