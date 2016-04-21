function Y = int16(X)
%INT16 Converts symbolic matrix to signed 16-bit integers.
%   INT16(S) converts a symbolic matrix S to a matrix of
%   signed 16-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT8, INT32, INT64, UINT8, UINT16, UINT32, UINT64.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:38 $

Y = int16(double(X));
