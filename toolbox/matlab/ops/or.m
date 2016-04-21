function [varargout] = or(varargin)
%|   Logical OR.
%   A | B is a matrix whose elements are 1's where either A or B
%   has a non-zero element, and 0's where both have zero elements.
%   A and B must have the same dimensions unless one is a scalar.
%
%   C = OR(A,B) is called for the syntax 'A | B' when A or B is an
%   object.
%
%   See also XOR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:07:59 $

if nargout == 0
  builtin('or', varargin{:});
else
  [varargout{1:nargout}] = builtin('or', varargin{:});
end
