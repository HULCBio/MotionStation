function Y = uint32(X)
%UINT32 Converts symbolic matrix to unsigned 32-bit integers.
%   UINT32(S) converts a symbolic matrix S to a matrix of
%   unsigned 32-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT8, INT16, INT32, INT64, UINT8, UINT16, UINT64.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:23:18 $

Y = uint32(double(X));
