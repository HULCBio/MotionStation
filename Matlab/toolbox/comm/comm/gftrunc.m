function c = gftrunc(a)
%GFTRUNC Minimize the length of a polynomial representation.
%   C = GFTRUNC(A) removes the zero coefficients from the highest order
%   terms of a GF(P) polynomial A. If the coefficient of the highest order
%   term is a nonzero number, the output of this function equals the input.
%   The resulting GF(P) polynomial C is the same as A with a shortened
%   form.
%
%   A is a row vector that specifies the polynomial coefficients in
%   order of ascending powers.
%
%   See also GFADD, GFSUB, GFCONV, GFDECONV, GFTUPLE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/03/27 00:08:23 $
