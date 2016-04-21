function Y = uint16(X)
%UINT16 Converts symbolic matrix to unsigned 16-bit integers.
%   UINT16(S) converts a symbolic matrix S to a matrix of
%   unsigned 16-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT8, INT16, INT32, INT64, UINT8, UINT32, UINT64.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:23:17 $

Y = uint16(double(X));
