function [varargout] = tan(varargin)
%TAN    Tangent.
%   TAN(X) is the tangent of the elements of X.
%
%   See also ATAN, TAND, ATAN2.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:06:23 $
%   Built-in function.

if nargout == 0
  builtin('tan', varargin{:});
else
  [varargout{1:nargout}] = builtin('tan', varargin{:});
end
