function DataType = sfix( TotalBits );
%SFIX Create structure describing Signed FIXed point data type
%
%    This data type structure can be passed to the 
%    Fixed Point Blockset.
%
%    SFIX( TotalBits )
%
%    For example, SFIX(16) returns a MATLAB structure
%    that describes the data type of a 
%    16 bit Signed FIXed point number.
%
%    Note: A default radix point is not included in the data type
%    description.  The radix point would be given as separate
%    block parameter that describes the scaling.
%
%    See also UFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.7.2.3 $  
% $Date: 2004/04/15 00:34:56 $

DataType = struct('Class','FIX','IsSigned',1,'MantBits',TotalBits);
