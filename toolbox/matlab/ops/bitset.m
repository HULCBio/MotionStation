function [varargout] = bitset(varargin)
%BITSET Set bit.
%   C = BITSET(A,BIT) sets bit position BIT in A to 1 (on). A must be an
%   unsigned integer and BIT must be a number between 1 and the length in
%   bits of the unsigned integer class of A, e.g., 32 for UINT32s.
%
%   C = BITSET(A,BIT,V) sets the bit at position BIT to the value V.
%   V must be either 0 or 1.
%
%   Example:
%      Repeatedly subtract powers of 2 from the largest UINT32 value:
%
%      a = intmax('uint32')
%      for i = 1:32, a = bitset(a,32-i+1,0), end
%
%   See also BITGET, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.18.4.2 $  $Date: 2004/03/02 21:47:38 $

if nargout == 0
  builtin('bitset', varargin{:});
else
  [varargout{1:nargout}] = builtin('bitset', varargin{:});
end
