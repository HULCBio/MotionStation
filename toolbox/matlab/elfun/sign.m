function [varargout] = sign(varargin)
%SIGN   Signum function.
%   For each element of X, SIGN(X) returns 1 if the element
%   is greater than zero, 0 if it equals zero and -1 if it is
%   less than zero.  For the nonzero elements of complex X,
%   SIGN(X) = X ./ ABS(X).
%
%   See also ABS.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:06:19 $
%   Built-in function.

if nargout == 0
  builtin('sign', varargin{:});
else
  [varargout{1:nargout}] = builtin('sign', varargin{:});
end
