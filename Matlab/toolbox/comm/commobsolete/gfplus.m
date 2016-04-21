function k = gfplus(i,j,fvec,ivec)
%GFPLUS Add elements of a Galois field of characteristic two.
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use the + operator on Galois field arrays instead. For more 
%         information, enter the following in the MATLAB Command Window: 
%            help gf
%            help gf/plus

%GFPLUS Add elements of a Galois field of characteristic two.
%   C = GFPLUS(A, B, FVEC, IVEC) adds two elements A and B in GF(2^M).  A, B 
%   and C represent elements in GF(2^M) using exponential form.  That is, 
%   alpha^C = alpha^A + alpha^B, where alpha is a primitive element of
%   GF(2^M).  The entries in A and B must be integers between -Inf and 2^M-2.
%   All negative entries represent alpha^-Inf = 0.
%
%   A and B can be scalars, vectors or matrices.  If A and B are both 
%   nonscalars, then they must have the same size.  If either A or B is a
%   scalar while the other is a vector or matrix, the scalar input is
%   expanded.
%
%   FVEC and IVEC are vectors of length 2^M.  The entries in both are integers
%   between 0 and 2^M-1.  FVEC contains the same information as the FIELD
%   parameter as used by GFADD, except that FVEC has been condensed into a 
%   vector.  FVEC and IVEC can be computed by
%   FVEC = GFTUPLE([-1 : 2^M-2]',M) * 2.^[0 : M-1]';
%   IVEC(FVEC+1) = 0 : 2^M-1;
%
%   GFPLUS and GFADD both add elements of GF(2^M), but for many cases GFPLUS
%   is faster.
%    
%   See also GFADD, GFSUB.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $   $Date: 2003/12/01 18:58:12 $
