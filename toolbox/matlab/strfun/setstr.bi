function [varargout] = setstr(varargin)
%SETSTR Convert numeric values into character string.
%   SETSTR has been renamed to CHAR.  SETSTR still works but may be
%   removed in the future.  Use CHAR instead.
%
%   See also CHAR, ISCHAR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/04/10 23:32:47 $
%   Built-in function.

if nargout == 0
  builtin('setstr', varargin{:});
else
  [varargout{1:nargout}] = builtin('setstr', varargin{:});
end
