function Y = uint8(X)
%UINT8 Converts symbolic matrix to unsigned 8-bit integers.
%   UINT8(S) converts a symbolic matrix S to a matrix of
%   unsigned 8-bit integers.
%
%   See also SYM, VPA, SINGLE, DOUBLE,
%   INT8, INT16, INT32, INT64, UINT16, UINT32, UINT64.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/16 22:23:20 $

Y = uint8(double(X));
