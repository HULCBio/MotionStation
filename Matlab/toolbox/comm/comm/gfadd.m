function c = gfadd(a, b, p, len)
%GFADD Add polynomials over a Galois field.
%   C = GFADD(A, B) adds two GF(2) polynomials A and B.  If A and B are
%   vectors of the same orientation but different lengths, then the shorter
%   vector is zero-padded.  If A and B are matrices they must be of the same
%   size.
%
%   C = GFADD(A, B, P) adds two GF(P) polynomials A and B, where P is
%   a prime number scalar.  Each entry of A and B represents an element of
%   GF(P).  The entries of A and B are integers between 0 and P-1.
%
%   C = GFADD(A, B, P, LEN) adds two GF(P) polynomials A and B and returns
%   a truncated or extended representation of the answer.  If the row vector
%   corresponding to the answer has fewer than LEN entries, then extra zeros
%   are added at the end; if it has more than LEN entries, then entries from
%   the end are removed.  If LEN is negative, then all high-order zeros are
%   removed.
%
%   C = GFADD(A, B, FIELD) adds elements of A and B in GF(P^M) where P is a
%   prime number and M is a positive integer. Each entry of A and B represents
%   an element of GF(P^M) in exponential format.  The entries of A and B are
%   integers between -Inf and P^M-2.  FIELD is a matrix listing all the
%   elements in GF(P^M), arranged relative to the same primitive element.
%   FIELD can be generated using, FIELD = GFTUPLE([-1:P^M-2]', M, P);
%
%   See also GFSUB, GFCONV, GFMUL, GFDECONV, GFDIV, GFTUPLE, GFPLUS.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.15 $   $Date: 2002/03/27 00:07:14 $