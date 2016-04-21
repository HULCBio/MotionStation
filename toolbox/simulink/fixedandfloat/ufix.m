function DataType = ufix( TotalBits );
%UFIX Create structure describing Unsigned FIXed point data type
%
%    This data type structure can be passed to the 
%    Fixed Point Blockset.
%
%    UFIX( TotalBits )
%
%    For example, UFIX(16) returns a MATLAB structure
%    that describes the data type of a 
%    16 bit Unsigned FIXed point number.
%
%    Note: A default radix point is not included in the data type
%    description.  The radix point would be given as separate
%    block parameter that describes the scaling.
%
%    See also SFIX, SINT, UINT, SFRAC, UFRAC, FLOAT.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.7.2.3 $  
% $Date: 2004/04/15 00:35:44 $

DataType = struct('Class','FIX','IsSigned',0,'MantBits',TotalBits);

