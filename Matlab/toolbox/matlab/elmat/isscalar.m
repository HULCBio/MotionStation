function [varargout] = isscalar(varargin)
%ISSCALAR True if array is a scalar.
%   ISSCALAR(S) returns logical true (1) if S is a 1 x 1 matrix
%   and logical false (0) otherwise.
%
%   See also ISVECTOR, ISNUMERIC, ISLOGICAL, ISCHAR, ISEMPTY.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/16 22:05:07 $

if nargout == 0
  builtin('isscalar', varargin{:});
else
  [varargout{1:nargout}] = builtin('isscalar', varargin{:});
end
