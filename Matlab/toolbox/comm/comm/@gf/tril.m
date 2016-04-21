function b = tril(a,varargin)
%TRIL Extract lower triangular part of GF array.
%   TRIL(X) is the lower triangular part of X.
%   TRIL(X,K) is the elements on and below the K-th diagonal
%   of X .  K = 0 is the main diagonal, K > 0 is above the
%   main diagonal and K < 0 is below the main diagonal.
%
%   See also TRIU, DIAG.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:14:39 $ 

    b = a;
    b.x = tril(a.x,varargin{:});
