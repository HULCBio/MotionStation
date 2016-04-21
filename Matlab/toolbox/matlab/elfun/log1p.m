function y = log1p(x)
%LOG1P  Compute log(1+x) accurately.
%   LOG1P(X) computes log(1+x), compensating for the roundoff in 1+x.
%   For small x, log1p(x) is approximately x, whereas log(1+x) can be zero.
%
%   See also LOG, EXPM1.

%   Algorithm due to W. Kahan, unpublished course notes.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/11/18 03:10:45 $

y = x;
u = 1+x;
m = (u ~= 1);
y(m) = log(u(m)).*x(m)./(u(m)-1);
