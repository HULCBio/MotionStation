function  b = all(a,varargin)
%ALL  True if all elements of a GF vector are nonzero.
%   For GF vectors, ALL(V) returns 1 if none of the elements of the
%   vector are zero. Otherwise it returns 0. For matrices,
%   ALL(X) operates on the columns of X, returning a row vector
%   of 1's and 0's. 
%
%   ALL(X,DIM) works down the dimension DIM.  For example, ALL(X,1)
%   works down the first dimension (the rows) of X.
%
%   See also ANY.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:14:56 $ 

    b = all(a.x,varargin{:});

