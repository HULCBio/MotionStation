function r = cubici1(f2,f1,c2,c1,dx)
%CUBICI1 Cubicly interpolates 2 points and gradients to estimate minimum.
%
%   This function uses cubic interpolation and the values of two 
%   points and their gradients in order to estimate the minimum of a 
%   a function along a line.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2004/02/07 19:12:56 $
%   Andy Grace 7-9-90.

if isinf(f2), f2 = 1/eps; end
z = 3*(f1-f2)/dx+c1+c2;
w = real(sqrt(z*z-c1*c2));
r = dx*((z+w-c1)/(c2-c1+2*w));
