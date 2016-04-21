function [varargout] = cosh(varargin)
%COSH   Hyperbolic cosine.
%   COSH(X) is the hyperbolic cosine of the elements of X.
%
%   See also ACOSH.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.3 $  $Date: 2004/04/16 22:05:57 $
%   Built-in function.

if nargout == 0
  builtin('cosh', varargin{:});
else
  [varargout{1:nargout}] = builtin('cosh', varargin{:});
end
