function primpoly
%PRIMPOLY Find primitive polynomials for a Galois field.
%   PR = PRIMPOLY(M) computes the default degree-M primitive polynomial for GF(2^M). 
%
%   PR = PRIMPOLY(M, OPT) computes primitive polynomial(s) for GF(2^M).
%   OPT = 'min'  find one primitive polynomial of minimum weight.
%   OPT = 'max'  find one primitive polynomial of maximum weight.
%   OPT = 'all'  find all primitive polynomials. 
%   OPT = L      find all primitive polynomials of weight L.
%   
%   PR = PRIMPOLY(M, OPT, 'nodisplay') or PR = PRIMPOLY(M, 'nodisplay') disables 
%   the default display.
%
%   Each element of PR represents the polynomial by its decimal equivalent.
%   If OPT = 'all' or L, and more than one primitive polynomial satisfies the
%   constraints, then each element of PR represents a different polynomial.  If no
%   primitive polynomial satisfies the constraints, then PR is empty.
%   Example:
%     PR = primpoly(3)
% 
%     Primitive polynomial(s) = 
%
%     D^3+D^1+1
%
%     PR =
%
%     11
%
%     PR = primpoly(4,'nodisplay')
%
%     PR =
%
%     19
%
%   See also ISPRIMITIVE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $   $  $
