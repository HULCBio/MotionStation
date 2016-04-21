function [varargout] = all(varargin)
%ALL    True if all elements of a vector are nonzero.
%   For vectors, ALL(V) returns 1 if none of the elements of the
%   vector are zero. Otherwise it returns 0. For matrices,
%   ALL(X) operates on the columns of X, returning a row vector
%   of 1's and 0's. For N-D arrays, ALL(X) operates on the first
%   non-singleton dimension.
%
%   ALL(X,DIM) works down the dimension DIM.  For example, ALL(X,1)
%   works down the first dimension (the rows) of X.
%
%   See also ANY.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/16 22:07:38 $
%   Built-in function.

if nargout == 0
  builtin('all', varargin{:});
else
  [varargout{1:nargout}] = builtin('all', varargin{:});
end
