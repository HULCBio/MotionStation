function [varargout] = not(varargin)
%~   Logical NOT.
%   ~A is a matrix whose elements are 1's where A has zero
%   elements, and 0's where A has non-zero elements.
%
%   B = NOT(A) is called for the syntax '~A' when A is an object.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/16 22:07:58 $

if nargout == 0
  builtin('not', varargin{:});
else
  [varargout{1:nargout}] = builtin('not', varargin{:});
end
