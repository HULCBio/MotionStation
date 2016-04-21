function [varargout] = plus(varargin)
%+   Plus.
%   X + Y adds matrices X and Y.  X and Y must have the same
%   dimensions unless one is a scalar (a 1-by-1 matrix).
%   A scalar can be added to anything.  
%
%   C = PLUS(A,B) is called for the syntax 'A + B' when A or B is an
%   object.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:08:00 $

if nargout == 0
  builtin('plus', varargin{:});
else
  [varargout{1:nargout}] = builtin('plus', varargin{:});
end
