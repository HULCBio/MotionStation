function DataType = sint( TotalBits );
%SINT Create structure describing Signed INTeger data type
%
%    This data type structure can be passed to the 
%    Fixed Point Blockset.
%
%    SINT( TotalBits )
%
%    For example, SINT(16) returns a MATLAB structure
%    that describes the data type of a 
%    16 bit Signed INTeger number.
%
%    Note: for integer types, the radix point is just
%    to the right of all bits.
%
%    See also SFIX, UFIX, UINT, SFRAC, UFRAC, FLOAT.

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.7.2.3 $  
% $Date: 2004/04/15 00:35:07 $

DataType = struct('Class','INT','IsSigned',1,'MantBits',TotalBits);
