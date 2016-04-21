function b = triu(a,varargin)
%TRIU Extract upper triangular part of GF array.
%   TRIU(X) is the upper triangular part of X.
%   TRIU(X,K) is the elements on and above the K-th diagonal of
%   X.  K = 0 is the main diagonal, K > 0 is above the main
%   diagonal and K < 0 is below the main diagonal.
%
%   See also TRIL, DIAG.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:14:53 $ 


    b = a;
    b.x = triu(a.x,varargin{:});
