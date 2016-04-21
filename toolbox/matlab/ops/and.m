function [varargout] = and(varargin)
%&  Logical AND.
%   A & B is a matrix whose elements are 1's where both A and B
%   have non-zero elements, and 0's where either has a zero element.
%   A and B must have the same dimensions unless one is a scalar.
%
%   C = AND(A,B) is called for the syntax 'A & B' when A or B is an
%   object.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:07:39 $

if nargout == 0
  builtin('and', varargin{:});
else
  [varargout{1:nargout}] = builtin('and', varargin{:});
end
