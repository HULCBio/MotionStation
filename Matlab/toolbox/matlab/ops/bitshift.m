function [varargout] = bitshift(varargin)
%BITSHIFT Bit-wise shift.
%   C = BITSHIFT(A,K) returns the value of A shifted by K bits. A must be an
%   unsigned integer. Shifting by K is the same as multiplication by 2^K. 
%   Negative values of K are allowed and this corresponds to shifting to 
%   the right, or dividing by 2^ABS(K) and truncating to an integer. 
%   If the shift causes C to overflow the number of bits in the 
%   unsigned integer class of A, then the overflowing bits are dropped.
%
%   C = BITSHIFT(A,K,N) will cause bits overflowing N bits to be dropped. 
%   N must be less than or equal to the length in 
%   bits of the unsigned integer class of A, e.g., N<=32 for UINT32.
%
%   Instead of using BITSHIFT(A,K,8) or another power of 2 for N, consider
%   using BITSHIFT(UINT8(A),K) or the appropriate unsigned integer class
%   for A.
%
%   Example:
%      Repeatedly shift the bits of an unsigned 16 bit value to the left
%      until all the nonzero bits overflow. Track the progress in binary.
%
%      a = intmax('uint16');
%      disp(sprintf('Initial uint16 value %5d is %16s in binary', ...
%         a,dec2bin(a)))
%      for i = 1:16
%         a = bitshift(a,1);
%         disp(sprintf('Shifted uint16 value %5d is %16s in binary',...
%            a,dec2bin(a)))
%      end
%
%   See also BITAND, BITOR, BITXOR, BITCMP, BITSET, BITGET, BITMAX, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.15.4.3 $  $Date: 2004/03/24 03:05:39 $

if nargout == 0
  builtin('bitshift', varargin{:});
else
  [varargout{1:nargout}] = builtin('bitshift', varargin{:});
end
