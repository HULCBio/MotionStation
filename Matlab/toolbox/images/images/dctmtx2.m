function c = dctmtx2(n)
%DCTMTX2 Discrete cosine transform matrix.
%
%   Note: This function is obsolete and may be removed in future
%   versions. Use DCTMTX instead.
%
%   D = DCTMTX(N) returns the N-by-N unitary 2-D DCT transform
%   matrix.  D*A is the DCT of A and D'*A is the inverse DCT
%   of A (when A is N-by-N).
%
%   See also DCTMTX, DCT.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.18.4.1 $  $Date: 2003/01/26 05:54:52 $

%   References:
%   Jain, Fundamentals of Digital Image Processing, p. 150.
warning('Images:dctmtx2:obsoleteFunction',['This function is obsolete and may be removed ',...
  'in future versions. Use DCTMTX instead.']);

c = dctmtx(n);
