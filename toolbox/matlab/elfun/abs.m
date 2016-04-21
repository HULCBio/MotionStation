function [varargout] = abs(varargin)
%ABS    Absolute value.
%   ABS(X) is the absolute value of the elements of X. When
%   X is complex, ABS(X) is the complex modulus (magnitude) of
%   the elements of X.
%
%   See also SIGN, ANGLE, UNWRAP.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/16 22:05:39 $
%   Built-in function.

if nargout == 0
  builtin('abs', varargin{:});
else
  [varargout{1:nargout}] = builtin('abs', varargin{:});
end
