function [varargout] = sort(varargin)
%SORT   Sort in ascending or descending order.
%   For vectors, SORT(X) sorts the elements of X in ascending order.
%   For matrices, SORT(X) sorts each column of X in ascending order.
%   For N-D arrays, SORT(X) sorts the along the first non-singleton
%   dimension of X. When X is a cell array of strings, SORT(X) sorts
%   the strings in ASCII dictionary order.
%
%   Y = SORT(X,DIM,MODE)
%   has two optional parameters.  
%   DIM selects a dimension along which to sort.
%   MODE selects the direction of the sort
%      'ascend' results in ascending order
%      'descend' results in descending order
%   The result is in Y which has the same shape and type as X.
%
%   [Y,I] = SORT(X,DIM,MODE) also returns an index matrix I.
%   If X is a vector, then Y = X(I).  
%   If X is an m-by-n matrix and DIM=1, then
%       for j = 1:n, Y(:,j) = X(I(:,j),j); end
%
%   When X is complex, the elements are sorted by ABS(X).  Complex
%   matches are further sorted by ANGLE(X).
%
%   When more than one element has the same value, the order of the
%   elements are preserved in the sorted result and the indexes of
%   equal elements will be ascending in any index matrix.
%
%   Example: If X = [3 7 5
%                    0 4 2]
%
%   then sort(X,1) is [0 4 2  and sort(X,2) is [3 5 7
%                      3 7 5]                   0 2 4];
%
%   See also ISSORTED, SORTROWS, MIN, MAX, MEAN, MEDIAN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.16.4.3 $  $Date: 2004/04/16 22:04:51 $
%   Built-in function.

%   Cell array implementation in @cell/sort.m

if nargout == 0
  builtin('sort', varargin{:});
else
  [varargout{1:nargout}] = builtin('sort', varargin{:});
end
