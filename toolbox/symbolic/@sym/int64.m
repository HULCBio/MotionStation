function Y = int64(X)
%INT64 Converts symbolic matrix to signed 64-bit integers.
%   INT64(S) converts a symbolic matrix S to a matrix of
%   signed 64-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT8, INT16, INT32, UINT8, UINT16, UINT32, UINT64.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:40 $

Y = int64(double(X));
