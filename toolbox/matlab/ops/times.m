function [varargout] = times(varargin)
%.*  Array multiply.
%   X.*Y denotes element-by-element multiplication.  X and Y
%   must have the same dimensions unless one is a scalar.
%   A scalar can be multiplied into anything.
%
%   C = TIMES(A,B) is called for the syntax 'A .* B' when A or B is an
%   object.
%
%   See also MTIMES.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:08:07 $

if nargout == 0
  builtin('times', varargin{:});
else
  [varargout{1:nargout}] = builtin('times', varargin{:});
end
