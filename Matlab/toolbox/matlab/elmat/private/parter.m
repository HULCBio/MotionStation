function A = parter(n)
%PARTER Parter matrix (Toeplitz with singular values near pi).
%     C = GALLERY('PARTER',N) returns the matrix C such that
%     C(i,j) = 1/(i-j+0.5).
%     C is a Cauchy matrix and a Toeplitz matrix.
%     Most of the singular values of C are very close to pi.

%   References:
%   [1] The MathWorks Newsletter, Volume 1, Issue 1, March 1986, page 2.
%   [2] S.V. Parter, On the distribution of the singular values of 
%   Toeplitz matrices, Linear Algebra and Appl., 80(1986), pp. 115-130.
%   [3] E.E. Tyrtyshnikov, Cauchy-Toeplitz matrices and some applications,
%   Linear Algebra and Appl., 149 (1991), pp. 1-18.
%
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/15 03:43:08 $

A = cauchy( (1:n)+0.5, -(1:n) );
