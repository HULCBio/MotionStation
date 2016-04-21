function [c,ceq]=filtcon(xfree,x,xmask,n,h,maxbin);
%FILTCON Returns roots for DFILDEMO.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:03 $

x(xmask)  = xfree;
% Make sure its stable
c=[abs(roots(x(n+1:2*n)))-1];
ceq = [];