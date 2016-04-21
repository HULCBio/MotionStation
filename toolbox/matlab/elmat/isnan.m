function [varargout] = isnan(varargin)
%ISNAN  True for Not-a-Number.
%   ISNAN(X) returns an array that contains 1's where
%   the elements of X are NaN's and 0's where they are not.
%   For example, ISNAN([pi NaN Inf -Inf]) is [0 1 0 0].
%
%   See also ISFINITE, ISINF.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/16 22:05:06 $
%   Built-in function.

if nargout == 0
  builtin('isnan', varargin{:});
else
  [varargout{1:nargout}] = builtin('isnan', varargin{:});
end
