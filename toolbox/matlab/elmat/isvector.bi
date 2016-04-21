function [varargout] = isvector(varargin)
%ISVECTOR True if array is a vector.
%   ISVECTOR(V) returns logical true (1) if V is a 1 x n or n x 1 vector,
%   where n >= 0, and logical false (0) otherwise.
%
%   See also ISSCALAR, ISNUMERIC, ISLOGICAL, ISCHAR, ISEMPTY.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/16 22:05:08 $

if nargout == 0
  builtin('isvector', varargin{:});
else
  [varargout{1:nargout}] = builtin('isvector', varargin{:});
end
