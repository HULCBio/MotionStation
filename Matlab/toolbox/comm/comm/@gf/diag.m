function b = diag(a,varargin)
%DIAG Diagonal GF matrices and diagonals of a GF matrix.
%   DIAG(V,K) when V is a vector with N components is a square matrix
%   of order N+ABS(K) with the elements of V on the K-th diagonal. K = 0
%   is the main diagonal, K > 0 is above the main diagonal and K < 0
%   is below the main diagonal. 
%
%   DIAG(V) is the same as DIAG(V,0) and puts V on the main diagonal.
%
%   DIAG(X,K) when X is a matrix is a column vector formed from
%   the elements of the K-th diagonal of X.
%
%   DIAG(X) is the main diagonal of X. DIAG(DIAG(X)) is a diagonal matrix.
%
%   See also TRIU, TRIL.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:14:59 $ 

    b = a;
    b.x = diag(a.x,varargin{:});
