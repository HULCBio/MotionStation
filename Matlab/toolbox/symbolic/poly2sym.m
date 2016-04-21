function p = poly2sym(c,x)
%POLY2SYM Polynomial coefficient vector to symbolic polynomial.
%   POLY2SYM(C) is a symbolic polynomial in 'x' with coefficients
%   from the vector C.
%   POLY2SYM(C,'V') and POLY2SYM(C,SYM('V') both use the symbolic
%   variable specified by the second argument.
% 
%   Example:
%       poly2sym([1 0 -2 -5])
%   is
%       x^3-2*x-5
%
%       poly2sym([1 0 -2 -5],'t')
%   and
%       t = sym('t')
%       poly2sym([1 0 -2 -5],t)
%   both return
%       t^3-2*t-5
%
%   See also SYM2POLY, POLYVAL.

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/15 03:13:21 $

if nargin < 2, x = 'x'; end
p = poly2sym(sym(c),sym(x));
