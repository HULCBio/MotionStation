function [varargout] = bitand(varargin)
%BITAND Bit-wise AND.
%   C = BITAND(A,B) returns the bit-wise AND of the two arguments A and B.
%   Both A and B must be unsigned integers.
%
%   Example:
%      Create a truth table:
%      A = uint8([0 1; 0 1])
%      B = uint8([0 0; 1 1])
%      TT = bitand(A,B)
%
%   See also BITOR, BITXOR, BITCMP, BITSHIFT, BITSET, BITGET, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.2 $  $Date: 2004/03/02 21:47:33 $

if nargout == 0
  builtin('bitand', varargin{:});
else
  [varargout{1:nargout}] = builtin('bitand', varargin{:});
end
