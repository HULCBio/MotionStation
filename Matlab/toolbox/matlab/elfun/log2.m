function [varargout] = log2(varargin)
%LOG2   Base 2 logarithm and dissect floating point number.
%   Y = LOG2(X) is the base 2 logarithm of the elements of X.
%
%   [F,E] = LOG2(X) for each element of the real array X, returns an
%   array F of real numbers, usually in the range 0.5 <= abs(F) < 1,
%   and an array E of integers, so that X = F .* 2.^E.  Any zeros in X
%   produce F = 0 and E = 0.  This corresponds to the ANSI C function
%   frexp() and the IEEE floating point standard function logb().
%
%   See also LOG, LOG10, POW2, NEXTPOW2, REALMAX, REALMIN.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/16 22:06:07 $
%   Built-in function.

if nargout == 0
  builtin('log2', varargin{:});
else
  [varargout{1:nargout}] = builtin('log2', varargin{:});
end
