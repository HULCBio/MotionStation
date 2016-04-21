function A = poisson(n)
%POISSON Block tridiagonal matrix from Poisson's equation (sparse).
%   GALLERY('POISSON',N) is the block tridiagonal (sparse) matrix
%   of order N^2 resulting from discretizing Poisson's equation with
%   the 5-point operator on an N-by-N mesh.

%   Reference:
%   [1] G. H. Golub and C. F. Van Loan, Matrix Computations, third edition,
%       Johns Hopkins University Press, Baltimore, Maryland, 1996,
%       Sec. 4.5.4.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:43:14 $

S = tridiag(n,-1,2,-1);
I = speye(n);
A = kron(I,S) + kron(S,I);
