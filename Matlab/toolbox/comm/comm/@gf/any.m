function  b = any(a,varargin)
%ANY  True if any element of a GF vector is nonzero.
%   For GF vectors, ANY(V) returns 1 if any of the elements of the
%   vector are nonzero. Otherwise it returns 0. For matrices,
%   ANY(X) operates on the columns of X, returning a row vector
%   of 1's and 0's. 
%
%   ANY(X,DIM) works down the dimension DIM.  For example, ANY(X,1)
%   works down the first dimension (the rows) of X.
%
%   See also ALL.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/27 00:15:05 $ 

    b = any(a.x,varargin{:});

