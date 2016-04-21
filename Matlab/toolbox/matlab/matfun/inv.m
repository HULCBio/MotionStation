function [varargout] = inv(varargin)
%INV    Matrix inverse.
%   INV(X) is the inverse of the square matrix X.
%   A warning message is printed if X is badly scaled or
%   nearly singular.
%
%   See also SLASH, PINV, COND, CONDEST, LSQNONNEG, LSCOV.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/16 22:07:23 $
%   Built-in function.

if nargout == 0
  builtin('inv', varargin{:});
else
  [varargout{1:nargout}] = builtin('inv', varargin{:});
end
