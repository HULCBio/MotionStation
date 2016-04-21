function [varargout] = conj(varargin)
%CONJ   Complex conjugate.
%   CONJ(X) is the complex conjugate of X.
%   For a complex X, CONJ(X) = REAL(X) - i*IMAG(X).
%
%   See also REAL, IMAG, I, J.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/16 22:05:55 $
%   Built-in function.

if nargout == 0
  builtin('conj', varargin{:});
else
  [varargout{1:nargout}] = builtin('conj', varargin{:});
end
