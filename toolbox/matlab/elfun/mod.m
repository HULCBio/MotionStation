function [varargout] = mod(varargin)
%MOD    Modulus after division.
%   MOD(x,y) is x - n.*y where n = floor(x./y) if y ~= 0.  If y is not an
%   integer and the quotient x./y is within roundoff error of an integer,
%   then n is that integer.  By convention, MOD(x,0) is x.  The input
%   x and y must be real arrays of the same size, or real scalars.
%
%   The statement "x and y are congruent mod m" means mod(x,m) == mod(y,m).
%
%   MOD(x,y) has the same sign as y while REM(x,y) has the same sign as x.
%   MOD(x,y) and REM(x,y) are equal if x and y have the same sign, but
%   differ by y if x and y have different signs.
%
%   See also REM.
 
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $  $Date: 2004/04/16 22:06:08 $
%   Built-in function.
if nargout == 0
  builtin('mod', varargin{:});
else
  [varargout{1:nargout}] = builtin('mod', varargin{:});
end
