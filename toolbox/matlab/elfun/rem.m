function [varargout] = rem(varargin)
%REM    Remainder after division.
%   REM(x,y) is x - n.*y where n = fix(x./y) if y ~= 0.  If y is not an
%   integer and the quotient x./y is within roundoff error of an integer,
%   then n is that integer.  By convention, REM(x,0) is NaN.  The input
%   x and y must be real arrays of the same size, or real scalars.
%
%   REM(x,y) has the same sign as x while MOD(x,y) has the same sign as y.
%   REM(x,y) and MOD(x,y) are equal if x and y have the same sign, but
%   differ by y if x and y have different signs.
%
%   See also MOD.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.13.4.2 $  $Date: 2004/04/16 22:06:15 $
%   Built-in function.

if nargout == 0
  builtin('rem', varargin{:});
else
  [varargout{1:nargout}] = builtin('rem', varargin{:});
end
