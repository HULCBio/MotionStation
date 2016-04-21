function [varargout] = exp(varargin)
%EXP    Exponential.
%   EXP(X) is the exponential of the elements of X, e to the X.
%   For complex Z=X+i*Y, EXP(Z) = EXP(X)*(COS(Y)+i*SIN(Y)).
%
%   See also EXPM1, LOG, LOG10, EXPM, EXPINT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2004/04/16 22:06:01 $
%   Built-in function.

if nargout == 0
  builtin('exp', varargin{:});
else
  [varargout{1:nargout}] = builtin('exp', varargin{:});
end
