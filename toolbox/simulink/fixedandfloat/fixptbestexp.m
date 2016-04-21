function fixedExponent = fixptbestexp( RealWorldValue, TotalBits, IsSigned );
%FIXPTBESTEXP  Determine the exponent that gives the best precision
%            fixed point representation for a value.
% Usage:
%   fixedExponent = FIXPTBESTEXP( RealWorldValue, TotalBits, IsSigned )
% or
%   fixedExponent = FIXPTBESTEXP( RealWorldValue, FixPtDataType )
%
%  The best precision (power of 2) fixed point representation is based
%  on the formula
%     RealWorldValue = StoredInteger * 2^fixedExponent
%  where StoredInteger is an integer with a specified size and  
%  signed/unsigned status.
%
%  The negative of the fixed exponent specifies the number of bits to the
%  right of the binary point.
%
%  For example, 
%      fixptbestexp(4/3,16,1) 
%  or
%      fixptbestexp(4/3,sfix(16))
%  would return
%      -14
%  This says that if a signed sixteen bit number is used then the maximum 
%  precision representation of 
%      1.33333333333333 (base 10) 
%  is obtained by placing 14 bits to the right of the binary point.  The 
%  representation would be
%      01.01010101010101 (base 2)  =  21845 * 2^-14 
%                                  =  1.33331298828125 (base 10)
%  The precision of this representation would be specified in fixed point 
%  blocks by setting the scaling to 
%      2^-14
%  or
%      2^fixptbestexp(4/3,16,1)
%
%  See also SFIX, UFIX, FIXPTBESTPREC


% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 18:58:44 $

if nargin < 2
    error('Not enough input arguments.')
elseif nargin < 3
    fixedExponent = bestfixexp(RealWorldValue, TotalBits.MantBits, ...
                                               TotalBits.IsSigned);
else
    fixedExponent = bestfixexp(RealWorldValue, TotalBits, IsSigned);
end    
