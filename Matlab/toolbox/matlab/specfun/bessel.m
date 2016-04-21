function [w,ierr] = bessel(nu,z)
%BESSEL Bessel functions of various kinds.
%   Bessel functions are solutions to Bessel's differential
%   equation of order NU:
%            2                    2    2
%           x * y'' +  x * y' + (x - nu ) * y = 0
%
%   There are several functions available to produce solutions to
%   Bessel's equations.  These are:
%
%       BESSELJ(NU,Z)    Bessel function of the first kind
%       BESSELY(NU,Z)    Bessel function of the second kind
%       BESSELI(NU,Z)    Modified Bessel function of the first kind
%       BESSELK(NU,Z)    Modified Bessel function of the second kind
%       BESSELH(NU,K,Z)  Hankel function
%       AIRY(K,Z)        Airy function
%
%   See the help for each function for more details.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12 $  $Date: 2002/04/15 03:56:07 $

[w,ierr] = besselj(nu,z);

