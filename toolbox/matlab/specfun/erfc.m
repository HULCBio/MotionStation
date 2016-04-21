function y = erfc(x)
%ERFC  Complementary error function.
%   Y = ERFC(X) is the complementary error function for each element
%   of X.  X must be real.  The complementary error function is
%   defined as:
%
%     erfc(x) = 2/sqrt(pi) * integral from x to inf of exp(-t^2) dt.
%             = 1 - erf(x).
%
%   See also ERF, ERFCX, ERFINV.

%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 7.1.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.12.4.2 $  $Date: 2003/07/31 05:26:30 $

% Derived from a FORTRAN program by W. J. Cody.

y = erfcore(x,1);
