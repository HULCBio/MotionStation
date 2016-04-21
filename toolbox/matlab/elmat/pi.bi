function [varargout] = pi(varargin)
%PI     3.1415926535897....
%   PI = 4*atan(1) = imag(log(-1)) = 3.1415926535897....

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/16 22:05:16 $
%   Built-in function.

if nargout == 0
  builtin('pi', varargin{:});
else
  [varargout{1:nargout}] = builtin('pi', varargin{:});
end
