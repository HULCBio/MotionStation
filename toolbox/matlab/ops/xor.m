function [varargout] = xor(varargin)
%XOR Logical EXCLUSIVE OR.
%   XOR(S,T) is the logical symmetric difference of elements S and T.
%   The result is one where either S or T, but not both, is nonzero.
%   The result is zero where S and T are both zero or nonzero.  S and T
%   must have the same dimensions (or one can be a scalar).
%
%   See also OR, RELOP.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.13.4.3 $  $Date: 2004/04/16 22:08:13 $


if nargout == 0
  builtin('xor', varargin{:});
else
  [varargout{1:nargout}] = builtin('xor', varargin{:});
end
