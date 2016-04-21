function x = sind(x)
%SIND   Sine of argument in degrees.
%   SIND(X) is the sine of the elements of X, expressed in degrees.
%   For integers n, sind(n*180) is exactly zero, whereas sin(n*pi)
%   reflects the accuracy of the floating point value of pi.
%
%   See also ASIND, SIN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:53 $

if ~isreal(x)
    error('MATLAB:sind:ComplexInput', 'Argument should be real.');
end

n = round(x/90);
x = x - n*90;
m = mod(n,4);
x(m==0) = sin(pi/180*x(m==0));
x(m==1) = cos(pi/180*x(m==1));
x(m==2) = -sin(pi/180*x(m==2)); 
x(m==3) = -cos(pi/180*x(m==3)); 
