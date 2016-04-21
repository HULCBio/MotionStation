function [varargout] = realsqrt(varargin)
%REALSQRT Real square root.
%   REALSQRT(X) is the square root of the elements of X.  An
%   error is produced if X is not positive.
%
%   See also SQRT, SQRTM, REALLOG, REALPOW.

% $Revision: 1.3.4.2 $  $Date: 2004/04/16 22:06:14 $
% Copyright 1984-2003 The MathWorks, Inc.

if nargout == 0
  builtin('realsqrt', varargin{:});
else
  [varargout{1:nargout}] = builtin('realsqrt', varargin{:});
end
