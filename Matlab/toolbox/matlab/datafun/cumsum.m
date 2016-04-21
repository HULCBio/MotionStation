function [varargout] = cumsum(varargin)
%CUMSUM Cumulative sum of elements.
%   For vectors, CUMSUM(X) is a vector containing the cumulative sum of
%   the elements of X. For matrices, CUMSUM(X) is a matrix the same size
%   as X containing the cumulative sums over each column.  For N-D
%   arrays, CUMSUM(X) operates along the first non-singleton dimension.
%
%   CUMSUM(X,DIM) works along the dimension DIM.
%
%   Example: If X = [0 1 2
%                    3 4 5]
%
%   then cumsum(X,1) is [0 1 2  and cumsum(X,2) is [0 1  3
%                        3 5 7]                     3 7 12]
%
%   See also CUMPROD, SUM, PROD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.2 $  $Date: 2004/04/16 22:04:41 $

%   Built-in function.

if nargout == 0
  builtin('cumsum', varargin{:});
else
  [varargout{1:nargout}] = builtin('cumsum', varargin{:});
end
