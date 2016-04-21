function [varargout] = length(varargin)
%LENGTH   Length of vector.
%   LENGTH(X) returns the length of vector X.  It is equivalent
%   to MAX(SIZE(X)) for non-empty arrays and 0 for empty ones.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/16 22:05:10 $
%   Built-in function.

if nargout == 0
  builtin('length', varargin{:});
else
  [varargout{1:nargout}] = builtin('length', varargin{:});
end
