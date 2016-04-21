function [varargout] = rdivide(varargin)
%./  Right array divide.
%   A./B denotes element-by-element division.  A and B
%   must have the same dimensions unless one is a scalar.
%   A scalar can be divided with anything.
%
%   C = RDIVIDE(A,B) is called for the syntax 'A ./ B' when A or B is an
%   object.
%
%   See also LDIVIDE, MLDIVIDE, MRDIVIDE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:08:03 $

if nargout == 0
  builtin('rdivide', varargin{:});
else
  [varargout{1:nargout}] = builtin('rdivide', varargin{:});
end
