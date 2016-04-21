function [varargout] = reallog(varargin)
%REALLOG Real logarithm.
%   REALLOG(X) is the natural logarithm of the elements of X.
%   An error is produced if X is not positive.
%
%   See also LOG, LOG2, LOG10, EXP, LOGM, REALPOW, REALSQRT.
%

% $Revision: 1.3.4.2 $  $Date: 2004/04/16 22:06:12 $
% Copyright 1984-2003 The MathWorks, Inc.

if nargout == 0
  builtin('reallog', varargin{:});
else
  [varargout{1:nargout}] = builtin('reallog', varargin{:});
end
