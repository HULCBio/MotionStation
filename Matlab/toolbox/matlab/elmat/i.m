function [varargout] = i(varargin)
%I  Imaginary unit.
%   As the basic imaginary unit SQRT(-1), i and j are used to enter
%   complex numbers.  For example, the expressions 3+2i, 3+2*i, 3+2j,
%   3+2*j and 3+2*sqrt(-1) all have the same value.
%
%   Since both i and j are functions, they can be overridden and used
%   as a variable.  This permits you to use i or j as an index in FOR
%   loops, etc.
%
%   See also J.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/16 22:05:00 $
%   Built-in function.

if nargout == 0
  builtin('i', varargin{:});
else
  [varargout{1:nargout}] = builtin('i', varargin{:});
end
