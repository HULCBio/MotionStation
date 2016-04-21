function Y = int32(X)
%INT32 Converts symbolic matrix to signed 32-bit integers.
%   INT32(S) converts a symbolic matrix S to a matrix of
%   signed 32-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT8, INT16, INT64, UINT8, UINT16, UINT32, UINT64.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:39 $

Y = int32(double(X));
