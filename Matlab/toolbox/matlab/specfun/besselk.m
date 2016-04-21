function [w,ierr] = besselk(nu,z,scale)
%BESSELK Modified Bessel function of the second kind.
%   K = BESSELK(NU,Z) is the modified Bessel function of the second kind,
%   K_nu(Z).  The order NU need not be an integer, but must be real.
%   The argument Z can be complex.  The result is real where Z is positive.
%
%   If NU and Z are arrays of the same size, the result is also that size.
%   If either input is a scalar, it is expanded to the other input's size.
%   If one input is a row vector and the other is a column vector, the
%   result is a two-dimensional table of function values.
%
%   K = BESSELK(NU,Z,1) scales K_nu(z) by exp(z)
%
%   [K,IERR] = BESSELK(NU,Z) also returns an array of error flags.
%       ierr = 1   Illegal arguments.
%       ierr = 2   Overflow.  Return Inf.
%       ierr = 3   Some loss of accuracy in argument reduction.
%       ierr = 4   Complete loss of accuracy, z or nu too large.
%       ierr = 5   No convergence.  Return NaN.
%
%   Examples:
%
%       besselk(3:9,(0:.2:10)',1) generates part of the table on page 424
%       of Abramowitz and Stegun, Handbook of Mathematical Functions.
%
%   This M-file uses a MEX interface to a Fortran library by D. E. Amos.
%
%   See also BESSELJ, BESSELY, BESSELI, BESSELH.

%   Reference:
%   D. E. Amos, "A subroutine package for Bessel functions of a complex
%   argument and nonnegative order", Sandia National Laboratory Report,
%   SAND85-1018, May, 1985.
%
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.17.4.1 $  $Date: 2003/05/01 20:43:27 $

if nargin == 2, scale = 0; end
[msg,nu,z,siz] = besschk(nu,z); error(msg);
[w,ierr] = besselmx(real('K'),nu,z,scale);
if ~isempty(w) && all(all(imag(w) == 0)), w = real(w); end
w = reshape(w,siz);
