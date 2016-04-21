function [varargout] = isinf(varargin)
%ISINF  True for infinite elements.
%   ISINF(X) returns an array that contains 1's where the
%   elements of X are +Inf or -Inf and 0's where they are not.
%   For example, ISINF([pi NaN Inf -Inf]) is [0 0 1 1].
%
%   See also ISFINITE, ISNAN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.10.4.2 $  $Date: 2004/04/16 22:05:05 $
%   Built-in function.

if nargout == 0
  builtin('isinf', varargin{:});
else
  [varargout{1:nargout}] = builtin('isinf', varargin{:});
end
