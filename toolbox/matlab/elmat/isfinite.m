function [varargout] = isfinite(varargin)
%ISFINITE True for finite elements.
%   ISFINITE(X) returns an array that contains 1's where
%   the elements of X are finite and 0's where they are not.
%   For example, ISFINITE([pi NaN Inf -Inf]) is [1 0 0 0].
%
%   For any X, exactly one of ISFINITE(X), ISINF(X), or ISNAN(X)
%   is 1 for each element.
%
%   See also ISNAN, ISINF.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/16 22:05:04 $
%   Built-in function.

if nargout == 0
  builtin('isfinite', varargin{:});
else
  [varargout{1:nargout}] = builtin('isfinite', varargin{:});
end
