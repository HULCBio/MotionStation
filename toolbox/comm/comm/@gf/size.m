function [m,n] = size(x,varargin)
%SIZE  Size of GF array.
%   D = SIZE(X), for M-by-N matrix X, returns the two-element
%   row vector D = [M, N] containing the number of rows and columns
%   in the matrix.  
%
%   [M,N] = SIZE(X) returns the number of rows and columns in
%   separate output variables. 
%
%   M = SIZE(X,DIM) returns the length of the dimension specified
%   by the scalar DIM.  For example, SIZE(X,1) returns the number
%   of rows.
%
%   See also LENGTH.

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/27 00:14:36 $ 


if nargout==2
  [m,n] = size(x.x,varargin{:});
else
  m = size(x.x,varargin{:});
end

