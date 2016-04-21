function x = cosd(x)
%COSD   Cosine of argument in degrees.
%   COSD(X) is the cosine of the elements of X, expressed in degrees.
%   For odd integers n, cosd(n*90) is exactly zero, whereas cos(n*pi/2)
%   reflects the accuracy of the floating point value for pi.
%
%   See also ACOSD, COS.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:49 $

if ~isreal(x)
    error('MATLAB:cosd:ComplexInput', 'Argument should be real.');
end

n = round(x/90);
x = x - n*90;
m = mod(n,4);
x(m==0) = cos(pi/180*x(m==0));
x(m==1) = -sin(pi/180*x(m==1));
x(m==2) = -cos(pi/180*x(m==2)); 
x(m==3) = sin(pi/180*x(m==3)); 
