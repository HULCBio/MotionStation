function [varargout] = asin(varargin)
%ASIN   Inverse sine.
%   ASIN(X) is the arcsine of the elements of X. Complex
%   results are obtained if ABS(x) > 1.0 for some element.
%
%   See also SIN, ASIND.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.3 $  $Date: 2004/04/16 22:05:48 $
%   Built-in function.

if nargout == 0
  builtin('asin', varargin{:});
else
  [varargout{1:nargout}] = builtin('asin', varargin{:});
end
