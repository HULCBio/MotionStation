function [w,ierr] = besselj(nu,z,scale)
%BESSELJ Bessel function of the first kind.
%   J = BESSELJ(NU,Z) is the Bessel function of the first kind, J_nu(Z).
%   The order NU need not be an integer, but must be real.
%   The argument Z can be complex.  The result is real where Z is positive.
%
%   If NU and Z are arrays of the same size, the result is also that size.
%   If either input is a scalar, it is expanded to the other input's size.
%   If one input is a row vector and the other is a column vector, the
%   result is a two-dimensional table of function values.
%
%   J = BESSELJ(NU,Z,1) scales J_nu(z) by exp(-abs(imag(z)))
%
%   [J,IERR] = BESSELJ(NU,Z) also returns an array of error flags.
%       ierr = 1   Illegal arguments.
%       ierr = 2   Overflow.  Return Inf.
%       ierr = 3   Some loss of accuracy in argument reduction.
%       ierr = 4   Complete loss of accuracy, z or nu too large.
%       ierr = 5   No convergence.  Return NaN.
%
%   Examples:
%
%       besselj(3:9,(0:.2:10)') generates the entire table on page 398
%       of Abramowitz and Stegun, Handbook of Mathematical Functions.
%
%       MEMBRANE uses BESSELJ to generate the fractional order Bessel
%       functions used by the MathWorks Logo, the L-shaped membrane.
%
%   This M-file uses a MEX interface to a Fortran library by D. E. Amos.
%
%   See also BESSELY, BESSELI, BESSELK, BESSELH.

%   Reference:
%   D. E. Amos, "A subroutine package for Bessel functions of a complex
%   argument and nonnegative order", Sandia National Laboratory Report,
%   SAND85-1018, May, 1985.
%
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.17.4.1 $  $Date: 2003/05/01 20:43:26 $

if nargin == 2, scale = 0; end
[msg,nu,z,siz] = besschk(nu,z); error(msg);
[w,ierr] = besselmx(real('J'),nu,z,scale);
if ~isempty(w) && all(all(imag(w) == 0)), w = real(w); end
w = reshape(w,siz);
