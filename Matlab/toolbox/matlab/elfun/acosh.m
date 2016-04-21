function [varargout] = acosh(varargin)
%ACOSH  Inverse hyperbolic cosine.
%   ACOSH(X) is the inverse hyperbolic cosine of the elements of X.
%
%   See also COSH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:05:41 $
%   Built-in function.

if nargout == 0
  builtin('acosh', varargin{:});
else
  [varargout{1:nargout}] = builtin('acosh', varargin{:});
end
