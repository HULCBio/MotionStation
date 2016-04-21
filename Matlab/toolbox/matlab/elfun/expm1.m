function y = expm1(x)
%EXPM1  Compute exp(x)-1 accurately.
%    EXPM1(X) computes exp(x)-1, compensating for the roundoff in exp(x).
%    For small x, expm1(x) is approximately x, whereas exp(x)-1 can be zero.
%
%    (The matrix exponential demo function EXPM1 is now EXPMDEMO1.)
%
%    See also EXP, LOG1P, EXPMDEMO1.

%   Algorithm due to W. Kahan, unpublished course notes.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/11/18 03:10:43 $

y = x;
u = exp(x);
m = (u ~= 1);
y(m) = (u(m)-1).*x(m)./log(u(m));
y(u-1==-1) = -1;
