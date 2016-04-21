function b = bitslice(a,lsb,msb)
%BITSLICE Compute a bitfield.
%   B = BITSLICE(A,LSB,MSB) "slices" bits out of the values of
%   the uint8 or uint16 input array A.  LSB is the least-significant 
%   bit of the desired bitfield; MSB is the most-significant bit.
%
%   Examples:
%      bitslice(uint8(255),5,8)
%      ans =
%          15
%      bitslice(uint8(128),7,8)
%      ans =
%           2

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:42 $
%#mex

error('MATLAB:bitslice:missingMEX', 'Missing MEX-file BITSLICE');
