function Y = int8(X)
%INT8 Converts symbolic matrix to signed 8-bit integers.
%   INT8(S) converts a symbolic matrix S to a matrix of
%   signed 8-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT16, INT32, INT64, UINT8, UINT16, UINT32, UINT64.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:22:41 $

Y = int8(double(X));
