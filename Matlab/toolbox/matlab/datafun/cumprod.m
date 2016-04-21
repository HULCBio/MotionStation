function [varargout] = cumprod(varargin)
%CUMPROD Cumulative product of elements.
%   For vectors, CUMPROD(X) is a vector containing the cumulative product
%   of the elements of X.  For matrices, CUMPROD(X) is a matrix the same
%   size as X containing the cumulative products over each column.  For
%   N-D arrays, CUMPROD(X) operates along the first non-singleton
%   dimension.
%
%   CUMPROD(X,DIM) works along the dimension DIM.
%
%   Example: If X = [0 1 2
%                    3 4 5]
%
%   then cumprod(X,1) is [0 1  2  and cumprod(X,2) is [0  0  0
%                         0 4 10]                      3 12 60]
%
%   See also CUMSUM, SUM, PROD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.2 $  $Date: 2004/04/16 22:04:40 $

%   Built-in function.

if nargout == 0
  builtin('cumprod', varargin{:});
else
  [varargout{1:nargout}] = builtin('cumprod', varargin{:});
end
