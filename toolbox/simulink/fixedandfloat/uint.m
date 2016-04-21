function DataType = uint( TotalBits );
%UINT Create structure describing Unsigned INTeger data type
%
%    This data type structure can be passed to the 
%    Fixed Point Blockset.
%
%    UINT( TotalBits )
%
%    For example, UINT(16) returns a MATLAB structure
%    that describes the data type of a 
%    16 bit Unsigned INTeger number.
%
%    Note: for integer types, the radix point is just
%    to the right of all bits.
%
%    See also SFIX, UFIX, SINT, SFRAC, UFRAC, FLOAT.
 
% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.7.2.3 $  
% $Date: 2004/04/15 00:35:46 $

DataType = struct('Class','INT','IsSigned',0,'MantBits',TotalBits);
