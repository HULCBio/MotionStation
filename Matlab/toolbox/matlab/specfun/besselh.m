function [w,ierr] = besselh(nu,k,z,scale)
%BESSELH Bessel function of the third kind (Hankel function).
%   H = BESSELH(NU,K,Z), for K = 1 or 2, computes the Hankel function
%   H1_nu(Z) or H2_nu(Z) for each element of the complex array Z.
%
%   H = BESSELH(NU,Z) uses K = 1.
%   H = BESSELH(NU,1,Z,1) scales H1_nu(z) by exp(-i*z)))
%   H = BESSELH(NU,2,Z,1) scales H2_nu(z) by exp(+i*z)))
%
%   If NU and Z are arrays of the same size, the result is also that size.
%   If either input is a scalar, it is expanded to the other input's size.
%   If one input is a row vector and the other is a column vector, the
%   result is a two-dimensional table of function values.
%
%   [H,IERR] = BESSELH(NU,K,Z) also returns an array of error flags.
%       ierr = 1   Illegal arguments.
%       ierr = 2   Overflow.  Return Inf.
%       ierr = 3   Some loss of accuracy in argument reduction.
%       ierr = 4   Complete loss of accuracy, z or nu too large.
%       ierr = 5   No convergence.  Return NaN.
%
%   The relationship between the Hankel and Bessel functions is:
%
%       besselh(nu,1,z) = besselj(nu,z) + i*bessely(nu,z)
%       besselh(nu,2,z) = besselj(nu,z) - i*bessely(nu,z)
%
%   Example:
%       This example generates the contour plot of the modulus and
%       phase of the Hankel Function H1_0(z) shown on page 359 of
%       Abramowitz and Stegun, "Handbook of Mathematical Functions."
%
%       [X,Y] = meshgrid(-4:0.025:2,-1.5:0.025:1.5);
%       H = besselh(0,1,X+i*Y);
%       contour(X,Y,abs(H),0:0.2:3.2), hold on
%       contour(X,Y,(180/pi)*angle(H),-180:10:180); hold off
%
%   This M-file uses a MEX interface to a Fortran library by D. E. Amos.
%
%   See also BESSELJ, BESSELY, BESSELI, BESSELK.

%   Reference:
%   D. E. Amos, "A subroutine package for Bessel functions of a complex
%   argument and nonnegative order", Sandia National Laboratory Report,
%   SAND85-1018, May, 1985.
%
%   D. E. Amos, "A portable package for Bessel functions of a complex
%   argument and nonnegative order", Trans.  Math. Software, 1986.
%
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.19.4.1 $  $Date: 2003/05/01 20:43:24 $

if nargin == 2, z = k; k = 1; end
if nargin <= 3, scale = 0; end
[msg,nu,z,siz] = besschk(nu,z); error(msg);
[w,ierr] = besselmx(real('H')*k,nu,z,scale);
if ~isempty(w) && all(all(imag(w) == 0)), w = real(w); end
w = reshape(w,siz);
