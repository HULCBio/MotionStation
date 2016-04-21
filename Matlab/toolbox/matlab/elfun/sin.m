function [varargout] = sin(varargin)
%SIN    Sine.
%   SIN(X) is the sine of the elements of X.
%
%   See also ASIN, SIND.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.3 $  $Date: 2004/04/16 22:06:20 $
%   Built-in function.

if nargout == 0
  builtin('sin', varargin{:});
else
  [varargout{1:nargout}] = builtin('sin', varargin{:});
end
