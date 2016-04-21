function [varargout] = real(varargin)
%REAL   Complex real part.
%   REAL(X) is the real part of X.
%   See I or J to enter complex numbers.
%
%   See also ISREAL, IMAG, CONJ, ANGLE, ABS.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/04/16 22:06:11 $
%   Built-in function.

if nargout == 0
  builtin('real', varargin{:});
else
  [varargout{1:nargout}] = builtin('real', varargin{:});
end
