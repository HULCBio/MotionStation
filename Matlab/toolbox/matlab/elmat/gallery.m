function varargout = gallery(matname,varargin)
%GALLERY Higham test matrices.
%   [out1,out2,...] = GALLERY(matname, param1, param2, ...)
%   takes matname, a string that is the name of a matrix family, and
%   the family's input parameters. See the listing below for available
%   matrix families. Most of the functions take an input argument
%   that specifies the order of the matrix, and unless otherwise
%   stated, return a single output.
%   For additional information, type "help private/matname", where matname
%   is the name of the matrix family.
%
%   cauchy    Cauchy matrix.
%   chebspec  Chebyshev spectral differentiation matrix.
%   chebvand  Vandermonde-like matrix for the Chebyshev polynomials.
%   chow      Chow matrix -- a singular Toeplitz lower Hessenberg matrix.
%   circul    Circulant matrix.
%   clement   Clement matrix -- tridiagonal with zero diagonal entries.
%   compar    Comparison matrices.
%   condex    Counter-examples to matrix condition number estimators.
%   cycol     Matrix whose columns repeat cyclically.
%   dorr      Dorr matrix -- diagonally dominant, ill-conditioned, tridiagonal.
%             (One or three output arguments, sparse)
%   dramadah  Matrix of ones and zeroes whose inverse has large integer entries.
%   fiedler   Fiedler matrix -- symmetric.
%   forsythe  Forsythe matrix -- a perturbed Jordan block.
%   frank     Frank matrix -- ill-conditioned eigenvalues.
%   gearmat   Gear matrix.
%   grcar     Grcar matrix -- a Toeplitz matrix with sensitive eigenvalues.
%   hanowa    Matrix whose eigenvalues lie on a vertical line in the complex
%             plane.
%   house     Householder matrix. (Three output arguments)
%   invhess   Inverse of an upper Hessenberg matrix.
%   invol     Involutory matrix.
%   ipjfact   Hankel matrix with factorial elements. (Two output arguments)
%   jordbloc  Jordan block matrix.
%   kahan     Kahan matrix -- upper trapezoidal.
%   kms       Kac-Murdock-Szego Toeplitz matrix.
%   krylov    Krylov matrix.
%   lauchli   Lauchli matrix -- rectangular.
%   lehmer    Lehmer matrix -- symmetric positive definite.
%   leslie    Leslie matrix.
%   lesp      Tridiagonal matrix with real, sensitive eigenvalues.
%   lotkin    Lotkin matrix.
%   minij     Symmetric positive definite matrix MIN(i,j).
%   moler     Moler matrix -- symmetric positive definite.
%   neumann   Singular matrix from the discrete Neumann problem (sparse).
%   orthog    Orthogonal and nearly orthogonal matrices.
%   parter    Parter matrix -- a Toeplitz matrix with singular values near PI.
%   pei       Pei matrix.
%   poisson   Block tridiagonal matrix from Poisson's equation (sparse).
%   prolate   Prolate matrix -- symmetric, ill-conditioned Toeplitz matrix.
%   randcolu  Random matrix with normalized cols and specified singular values.
%   randcorr  Random correlation matrix with specified eigenvalues.
%   randhess  Random, orthogonal upper Hessenberg matrix.
%   randjorth Random J-orthogonal matrix.
%   rando     Random matrix with elements -1, 0 or 1.
%   randsvd   Random matrix with pre-assigned singular values and specified
%             bandwidth.
%   redheff   Matrix of 0s and 1s of Redheffer.
%   riemann   Matrix associated with the Riemann hypothesis.
%   ris       Ris matrix -- a symmetric Hankel matrix.
%   smoke     Smoke matrix -- complex, with a "smoke ring" pseudospectrum.
%   toeppd    Symmetric positive definite Toeplitz matrix.
%   toeppen   Pentadiagonal Toeplitz matrix (sparse).
%   tridiag   Tridiagonal matrix (sparse).
%   triw      Upper triangular matrix discussed by Wilkinson and others.
%   wathen    Wathen matrix -- a finite element matrix (sparse, random entries).
%   wilk      Various specific matrices devised/discussed by Wilkinson.
%             (Two output arguments)
%
%   GALLERY(3) is a badly conditioned 3-by-3 matrix.
%   GALLERY(5) is an interesting eigenvalue problem.  Try to find
%   its EXACT eigenvalues and eigenvectors.
%
%   See also MAGIC, HILB, INVHILB, HADAMARD, PASCAL, WILKINSON, ROSSER, VANDER.

%   References:
%   [1] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Second edition, Society for Industrial and Applied Mathematics,
%       Philadelphia, 2002; Chapter 28.
%   [2] J. R. Westlake, A Handbook of Numerical Matrix Inversion and
%       Solution of Linear Equations, John Wiley, New York, 1968.
%   [3] J. H. Wilkinson, The Algebraic Eigenvalue Problem,
%       Oxford University Press, 1965.
%
%   Nicholas J. Higham
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.20.4.2 $  $Date: 2004/04/16 22:04:58 $


switch matname
case 3
    varargout{1} = [ -149   -50  -154
                      537   180   546
                      -27    -9   -25 ];
case 5
    varargout{1} = [  -9     11    -21     63    -252
                      70    -69    141   -421    1684
                    -575    575  -1149   3451  -13801
                    3891  -3891   7782 -23345   93365
                    1024  -1024   2048  -6144   24572 ];
otherwise
    [varargout{1:max(nargout,1)}] = feval(matname,varargin{:});
end
