function [varargout] = size(varargin)
%SIZE   Size of array.  
%   D = SIZE(X), for M-by-N matrix X, returns the two-element
%   row vector D = [M, N] containing the number of rows and columns
%   in the matrix.  For N-D arrays, SIZE(X) returns a 1-by-N
%   vector of dimension lengths.  Trailing singleton dimensions
%   are ignored.
%
%   [M,N] = SIZE(X) for matrix X, returns the number of rows and 
%   columns in X as separate output variables. 
%   
%   [M1,M2,M3,...,MN] = SIZE(X) returns the sizes of the first N 
%   dimensions of array X.  If the number of output arguments N does
%   not equal NDIMS(X), then for:
%
%   N > NDIMS(X), size returns ones in the "extra" variables,
%                 i.e., outputs NDIMS(X)+1 through N.
%   N < NDIMS(X), MN contains the product of the sizes of the 
%                 remaining dimensions, i.e., dimensions N+1 through
%                 NDIMS(X).
%
%   M = SIZE(X,DIM) returns the length of the dimension specified
%   by the scalar DIM.  For example, SIZE(X,1) returns the number
%   of rows.
%
%   When SIZE is applied to a Java array, the number of rows
%   returned is the length of the Java array and the number of columns
%   is always 1.  When SIZE is applied to a Java array of arrays, the
%   result describes only the top level array in the array of arrays.
%
%   See also LENGTH, NDIMS, NUMEL.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.13.4.3 $  $Date: 2004/04/16 22:06:29 $
%   Built-in function.

if nargout == 0
  builtin('size', varargin{:});
else
  [varargout{1:nargout}] = builtin('size', varargin{:});
end
