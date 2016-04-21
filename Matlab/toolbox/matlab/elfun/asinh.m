function [varargout] = asinh(varargin)
%ASINH  Inverse hyperbolic sine.
%   ASINH(X) is the inverse hyperbolic sine of the elements of X.
%
%   See also SINH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:05:49 $
%   Built-in function.

if nargout == 0
  builtin('asinh', varargin{:});
else
  [varargout{1:nargout}] = builtin('asinh', varargin{:});
end
