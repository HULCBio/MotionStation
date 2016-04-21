function [varargout] = bitxor(varargin)
%BITXOR Bit-wise XOR.
%   C = BITXOR(A,B) returns the bit-wise exclusive OR of the two arguments 
%   A and B. Both A and B must be unsigned integers.
%
%   Example:
%      Create a truth table:
%      A = uint8([0 1; 0 1])
%      B = uint8([0 0; 1 1])
%      TT = bitxor(A,B)
%
%   See also BITOR, BITAND, BITCMP, BITSHIFT, BITSET, BITGET, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.2 $  $Date: 2004/03/02 21:47:40 $

if nargout == 0
  builtin('bitxor', varargin{:});
else
  [varargout{1:nargout}] = builtin('bitxor', varargin{:});
end
