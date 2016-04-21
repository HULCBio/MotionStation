function A = gearmat(n, i, j)
%GEARMAT Gear matrix.
%   A = GALLERY('GEARMAT',N,I,J) is the N-by-N matrix with ones on
%   the sub- and super-diagonals, SIGN(I) in the (1,ABS(I)) position,
%   SIGN(J) in the (N,N+1-ABS(J)) position, and zeros everywhere else.
%   Defaults: I = N, J = -N.
%
%   Properties:
%   All eigenvalues are of the form 2*COS(a) and the eigenvectors
%     are of the form [SIN(w+a), SIN(w+2a), ..., SIN(w+Na)].
%     (The values of a and w are given in the reference below.)
%   A can have double and triple eigenvalues and can be defective.
%   GALLERY('GEARMAT',N) is singular.

%   Reference:
%   [1] C. W. Gear, A simple set of test matrices for eigenvalue programs,
%       Math.  Comp., 23 (1969), pp. 119-125.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2003/05/19 11:16:06 $

if nargin < 3, j = -n; end
if nargin < 2, i = n; end

if ~(i~=0 && abs(i)<=n && j~=0 && abs(j)<=n)
     error('MATLAB:gearmat:InvalidIandJ', 'Invalid I and J parameters.')
end

A = diag(ones(n-1,1),-1) + diag(ones(n-1,1),1);
A(1, abs(i)) = sign(i);
A(n, n+1-abs(j)) = sign(j);
