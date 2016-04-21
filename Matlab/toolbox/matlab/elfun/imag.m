function [varargout] = imag(varargin)
%IMAG   Complex imaginary part.
%   IMAG(X) is the imaginary part of X.
%   See I or J to enter complex numbers.
%
%   See also REAL, ISREAL, CONJ, ANGLE, ABS.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/16 22:06:04 $
%   Built-in function.

if nargout == 0
  builtin('imag', varargin{:});
else
  [varargout{1:nargout}] = builtin('imag', varargin{:});
end
