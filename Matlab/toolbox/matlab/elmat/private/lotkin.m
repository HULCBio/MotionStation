function A = lotkin(n)
%LOTKIN Lotkin matrix.
%   A = GALLERY('LOTKIN',N) is the Hilbert matrix with its first row
%   altered to all ones.  A is unsymmetric, ill-conditioned, and has
%   many negative eigenvalues of small magnitude. Its inverse has
%   integer entries and is known explicitly.

%   Reference:
%   M. Lotkin, A set of test matrices, M.T.A.C., 9 (1955), pp. 153-161.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:42:56 $

A = hilb(n);
A(1,:) = ones(1,n);
