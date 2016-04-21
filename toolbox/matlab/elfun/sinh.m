function [varargout] = sinh(varargin)
%SINH   Hyperbolic sine.
%   SINH(X) is the hyperbolic sine of the elements of X.
%
%   See also ASINH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.3 $  $Date: 2004/04/16 22:06:21 $
%   Built-in function.

if nargout == 0
  builtin('sinh', varargin{:});
else
  [varargout{1:nargout}] = builtin('sinh', varargin{:});
end
