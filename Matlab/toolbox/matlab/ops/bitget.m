function [varargout] = bitget(varargin)
%BITGET Get bit.
%   C = BITGET(A,BIT) returns the value of the bit at position BIT in A. A
%   must be an unsigned integer and BIT must be a number between 1 and the
%   number of bits in the unsigned integer class of A e.g., 32 for UINT32s.
%
%   Example:
%      Prove that INTMAX sets all the bits to 1:
%
%      a = intmax('uint8')
%      if all(bitget(a,1:8)), disp('All the bits have value 1.'), end
%
%   See also BITSET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.3 $  $Date: 2004/04/16 22:07:41 $

if nargout == 0
  builtin('bitget', varargin{:});
else
  [varargout{1:nargout}] = builtin('bitget', varargin{:});
end
