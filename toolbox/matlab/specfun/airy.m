function [w,ierr] = airy(k,z)
%AIRY   Airy functions.
%   W = AIRY(Z) is the Airy function, Ai(z), of the elements of Z.
%   W = AIRY(0,Z) is the same as AIRY(Z).
%   W = AIRY(1,Z) is the derivative, Ai'(z).
%   W = AIRY(2,Z) is the Airy function of the second kind, Bi(z).
%   W = AIRY(3,Z) is the derivative, Bi'(z).
%   If the argument Z is an array, the result is the same size.
%
%   [W,IERR] = AIRY(K,Z) also returns an array of error flags.
%       ierr = 1   Illegal arguments.
%       ierr = 2   Overflow.  Return Inf.
%       ierr = 3   Some loss of accuracy in argument reduction.
%       ierr = 4   Complete loss of accuracy, z too large.
%       ierr = 5   No convergence.  Return NaN.
%
%   The relationship between the Airy and modified Bessel functions is:
%
%       Ai(z) = 1/pi*sqrt(z/3)*K_1/3(zeta)
%       Bi(z) = sqrt(z/3)*(I_-1/3(zeta)+I_1/3(zeta))
%       where zeta = 2/3*z^(3/2)
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
%   $Revision: 1.12.4.1 $  $Date: 2003/05/01 20:43:23 $

if nargin <= 1
   z = k; k = 0;
end
if (k == 0) || (k == 1)
   [w,ierr] = besselmx(real('A'),k,z);
elseif (k == 2) || (k == 3)
   [w,ierr] = besselmx(real('B'),k-2,z);
else
   error('MATLAB:airy:InvalidArg1', 'The first argument must be 0, 1, 2 or 3')
end
