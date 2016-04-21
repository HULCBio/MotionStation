function [varargout] = bitor(varargin)
%BITOR  Bit-wise OR.
%   C = BITOR(A,B) returns the bit-wise OR of the two arguments A and B.
%   Both A and B must be unsigned integers.
%
%   Example:
%      Create a truth table:
%      A = uint8([0 1; 0 1])
%      B = uint8([0 0; 1 1])
%      TT = bitor(A,B)
%
%   See also BITAND, BITXOR, BITSHIFT, BITCMP, BITSET, BITGET, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.2 $  $Date: 2004/03/02 21:47:37 $

if nargout == 0
  builtin('bitor', varargin{:});
else
  [varargout{1:nargout}] = builtin('bitor', varargin{:});
end
