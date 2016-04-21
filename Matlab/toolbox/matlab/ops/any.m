function [varargout] = any(varargin)
%ANY    True if any element of a vector is nonzero.
%   For vectors, ANY(V) returns 1 if any of the elements of the
%   vector are non-zero. Otherwise it returns 0. For matrices,
%   ANY(X) operates on the columns of X, returning a row vector
%   of 1's and 0's. For N-D arrays, ANY(X) operates on the first
%   non-singleton dimension.
%
%   ANY(X,DIM) works down the dimension DIM.  For example, ANY(X,1)
%   works down the first dimension (the rows) of X.
%
%   See also ALL.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/16 22:07:40 $
%   Built-in function.

if nargout == 0
  builtin('any', varargin{:});
else
  [varargout{1:nargout}] = builtin('any', varargin{:});
end
