function [varargout] = prod(varargin)
%PROD Product of elements.
%   For vectors, PROD(X) is the product of the elements of X. For
%   matrices, PROD(X) is a row vector with the product over each
%   column. For N-D arrays, PROD(X) operates on the first
%   non-singleton dimension.
%
%   PROD(X,DIM) works along the dimension DIM. 
%
%   Example: If X = [0 1 2
%                    3 4 5]
%
%   then prod(X,1) is [0 4 10] and prod(X,2) is [ 0
%                                                60]
%
%   See also SUM, CUMPROD, DIFF.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.14.4.2 $  $Date: 2004/04/16 22:04:50 $

%   Built-in function.

if nargout == 0
  builtin('prod', varargin{:});
else
  [varargout{1:nargout}] = builtin('prod', varargin{:});
end
