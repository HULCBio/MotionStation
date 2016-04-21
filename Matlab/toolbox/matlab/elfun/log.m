function [varargout] = log(varargin)
%LOG    Natural logarithm.
%   LOG(X) is the natural logarithm of the elements of X.
%   Complex results are produced if X is not positive.
%
%   See also LOG1P, LOG2, LOG10, EXP, LOGM.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:06:06 $
%   Built-in function.

if nargout == 0
  builtin('log', varargin{:});
else
  [varargout{1:nargout}] = builtin('log', varargin{:});
end
