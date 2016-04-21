function x = tand(x)
%TAND   Tangent of argument in degrees.
%   TAND(X) is the tangent of the elements of X, expressed in degrees.
%   For odd integers n, tand(n*90) is infinite, whereas tan(n*pi/2) is large
%   but finite, reflecting the accuracy of the floating point value of pi.
%
%   See also ATAND, TAN.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/11/24 23:23:54 $

if ~isreal(x)
    error('MATLAB:tand:ComplexInput', 'Argument should be real.');
end

n = round(x/90);
x = x - n*90;
z = (x == 0);
m = mod(n,2);
x(m==0) = tan(pi/180*x(m==0));
x(m==1 & ~z) = -1./tan(pi/180*x(m==1 & ~z));
x(m==1 & z & n>=0) = Inf;
x(m==1 & z & n<0) = -Inf;
