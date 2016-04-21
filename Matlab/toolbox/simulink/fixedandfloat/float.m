function DataType = float( TotalBits, ExpBits );
%FLOAT Create structure describing a floating point data type
%
%    This data type structure can be passed to the 
%    Fixed Point Blockset.
%
%    FLOAT( 'single' )
%
%      Returns a MATLAB structure that describes the data type of
%      an IEEE Single (32 total bits, 8 exponent bits).
%
%    FLOAT( 'double' )
%
%      Returns a MATLAB structure that describes the data type of
%      an IEEE Double (64 total bits, 11 exponent bits).
%
%    FLOAT( TotalBits, ExpBits )
%
%      Returns a MATLAB structure that describes a floating point 
%      data type.  The data type is assumed to mimic the IEEE style.
%      For example, numbers are normalized with a hidden leading one
%      for all exponents except the smallest possible exponent.  However,
%      the largest possible exponent might not be treated as a flag for
%      INFs and NANs.
%
%   Note: Unlike fixed point numbers, floating point numbers ignore any
%      specified scaling: radix point, slope, or bias.  The floating point
%      number and the real world number are the same.
%
%    See also SFIX, UFIX, SINT, UINT, UFRAC, FLOAT.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.10.2.3 $  
% $Date: 2004/04/15 00:34:50 $

  if ischar(TotalBits)
    if strcmp(upper(TotalBits), 'SINGLE')
      DataType = struct('Class','SINGLE');
    elseif strcmp(upper(TotalBits), 'DOUBLE')
      DataType = struct('Class','DOUBLE');
    else
      disp('The string being specified was neither ''single'' nor ''double'' ');
    end
  elseif (TotalBits == 64) & (ExpBits == 11)
    DataType = struct('Class','DOUBLE');
  elseif (TotalBits == 32) & (ExpBits == 8)
    DataType = struct('Class','SINGLE');
  else
    DataType = struct('Class','FLOAT','MantBits',(TotalBits-ExpBits-1),'ExpBits',ExpBits);
  end
    

