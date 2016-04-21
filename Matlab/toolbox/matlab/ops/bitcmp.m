function [varargout] = bitcmp(varargin)
%BITCMP Complement bits.
%   C = BITCMP(A) returns the bit-wise complement of A. A must be an unsigned
%   integer.
%
%   C = BITCMP(A,N) returns the bit-wise complement of A as an N-bit
%   unsigned integer. A may not have any bits sets higher than N, i.e. may
%   not have value greater than 2^N-1. The largest value of N is the number of
%   bits in the unsigned integer class of A, e.g., the largest value for
%   UINT32s is N=32.
%
%   Example:
%      a = uint16(intmax('uint8'))
%      bitcmp(a,8)
%
%   See also BITAND, BITOR, BITXOR, BITSHIFT, BITSET, BITGET, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.15.4.3 $  $Date: 2004/03/24 03:05:38 $

if nargout == 0
  builtin('bitcmp', varargin{:});
else
  [varargout{1:nargout}] = builtin('bitcmp', varargin{:});
end
