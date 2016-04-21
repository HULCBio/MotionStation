function [s,f] = cubici3(f2,f1,c2,c1,dx)
%CUBICI3  Cubicly interpolates 2 points and gradients to find step and min.
%
%   This function uses cubic interpolation and the values of 
%   two points and their gradients in order to estimate the minimum s of a 
%   a function along a line and returns s and f=F(s);
%

%  The equation is F(s) = a/3*s^3 + b*s^2 + c1*s + f1
%      and F'(s) = a*s^2+2*b*s + c1
%  where we know that 
%          F(0) = f1
%          F'(0) = c1  
%          F(dx) = f2   implies: a/3*dx^3 + b*dx^2 + c1*dx + f1 = f2
%          F'(dx) = c2  implies: a*dx^2+2*b*dx + c1 = c2

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/02/01 21:43:27 $

if isinf(f2), 
    f2 = 1/eps; 
end
a = (6*(f1-f2)+3*(c1+c2)*dx)/dx^3;
b = (3*(f2-f1)-(2*c1+c2)*dx)/dx^2;
disc = b^2 - a*c1;
if a==0 & b==0 
    % F(s) is linear: F'(s) = c1, which is never zero;
    % minimum is s=Inf or -Inf (we return s always positive so s=Inf).
    s = inf; 
elseif a == 0 
    % F(s) is quadratic so we know minimum s
    s = -c1/(2*b);
elseif disc <= 0
    % If disc = 0 this is exact. 
    % If disc < 0 we ignore the complex component of the root.
    s = -b/a;  
else
    s = (-b+sqrt(disc))/a;
end
if s<0,  s = -s; end
if isinf(s)
    f = inf;
else
    % User Horner's rule
    f = ((a/3*s + b)*s + c1)*s + f1;
end

