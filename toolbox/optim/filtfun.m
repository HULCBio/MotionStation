function [f,g]=filtfun(xfree,x,xmask,n,h,maxbin);
%FILTFUN Returns frequency response and roots for DFILDEMO.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2004/02/07 19:13:04 $

x(xmask)  = xfree;
h2=abs(freqz(x(1:n), x(n+1:2*n), 128));
f= h2 - h;     
% Make sure its stable
g=[abs(roots(x(n+1:2*n)))-1];
