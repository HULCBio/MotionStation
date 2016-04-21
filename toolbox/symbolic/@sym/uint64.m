function Y = uint64(X)
%UINT64 Converts symbolic matrix to unsigned 64-bit integers.
%   UINT64(S) converts a symbolic matrix S to a matrix of
%   unsigned 64-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT8, INT16, INT32, INT64, UINT8, UINT16, UINT32.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:23:19 $

Y = uint64(double(X));
