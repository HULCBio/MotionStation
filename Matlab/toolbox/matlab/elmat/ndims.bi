function [varargout] = ndims(varargin)
%NDIMS   Number of dimensions.
%   N = NDIMS(X) returns the number of dimensions in the array X.
%   The number of dimensions in an array is always greater than
%   or equal to 2.  Trailing singleton dimensions are ignored.
%   Put simply, it is LENGTH(SIZE(X)).
%
%   For Java arrays and Java arrays of arrays, NDIMS always returns 2.
%
%   See also SIZE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:05:12 $
%   Built-in function.

if nargout == 0
  builtin('ndims', varargin{:});
else
  [varargout{1:nargout}] = builtin('ndims', varargin{:});
end
