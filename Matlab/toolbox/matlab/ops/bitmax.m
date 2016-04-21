function c = bitmax
%BITMAX Maximum double precision floating point integer.
%   BITMAX returns the maximum unsigned double precision floating point
%   integer. It is the value when all bits in the mantissa are set, 2^53-1.
%
%   Instead of integer valued double precision variables, use unsigned
%   integers for bit manipulations and replace BITMAX with INTMAX.
%
%   Example:
%      Display in different formats the largest floating point integer
%      and the largest 32 bit unsigned integer.
%
%      >> format long e
%      >> bitmax
%      ans =
%          9.007199254740991e+015
%      >> intmax('uint32')
%      ans =
%        4294967295
%      >> format hex
%      >> bitmax
%      ans =
%         433fffffffffffff
%      >> intmax('uint32')
%      ans =
%         ffffffff
%
%      Note: the last 13 hex digits of BITMAX are "f", corresponding to 52
%      1's (all 1's) in the mantissa of the binary representation. The
%      first 3 hex digits correspond to the sign bit 0 and the 11 bit
%      biased exponent 10000110011 in binary (1075 in decimal), and the
%      actual exponent is (1075-1023)=52. Thus the binary value of BITMAX
%      is 1.111...111x2^52 with 52 trailing 1's, or 2^53-1.
%
%   See also INTMAX, BITAND, BITOR, BITXOR, BITCMP, BITSHIFT, BITSET, BITGET.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2004/03/02 21:47:36 $

c = 9007199254740991; % 53 bits
