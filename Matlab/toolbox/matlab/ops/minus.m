function [varargout] = minus(varargin)
%-   Minus.
%   X - Y subtracts matrix Y from X.  X and Y must have the same
%   dimensions unless one is a scalar.  A scalar can be subtracted
%   from anything.  
%
%   C = MINUS(A,B) is called for the syntax 'A - B' when A or B is an
%   object.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:07:52 $

if nargout == 0
  builtin('minus', varargin{:});
else
  [varargout{1:nargout}] = builtin('minus', varargin{:});
end
