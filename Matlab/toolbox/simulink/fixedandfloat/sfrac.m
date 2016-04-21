function DataType = sfrac( TotalBits, GuardBits );
%SFRAC Create structure describing Signed FRACtional data type
%
%    This data type structure can be passed to the 
%    Fixed Point Blockset.
%
%    SFRAC( TotalBits )
%
%      For example, SFRAC(5) returns a MATLAB structure
%      that describes the data type of a 
%      5 bit Signed FRACtional number.
%      Note: the DEFAULT radix point is assumed to lie immediately
%      to the right of the sign bit.  In this example,
%      the range is -1 to 1-2^(1-5) = 0.9375
%
%    SFRAC( TotalBits, GuardBits )
%
%      For example, SFRAC(8,4) returns a MATLAB structure
%      that describes the data type of a 
%      8 bit Signed FRACtional number with 4 guard bits.
%      Note: in addition to the sign, 4 guard bits lie to the left
%      of the DEFAULT radix point.  In this example,
%      the range is -1*2^(4) = -16 to (1-2^(1-8))*2^(4) = 15.875
%
%    See also SFIX, UFIX, SINT, UINT, UFRAC, FLOAT.
 
% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.8.2.3 $  
% $Date: 2004/04/15 00:35:06 $

if nargin < 2
  GuardBits = 0;
end
  
DataType = struct('Class','FRAC','IsSigned',1,'MantBits',TotalBits,'GuardBits',GuardBits);
