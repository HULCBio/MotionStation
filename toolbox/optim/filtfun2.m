function [f,g]=filtfun2(xfree,x,xmask,n,h,dcgain,maxbin);
%FILTFUN2 Return frequency response norm and roots for DFILDEMO.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/02/07 19:13:05 $

x(xmask)  = xfree;
h2=abs(freqz(x(1:n), x(n+1:2*n), 128));
f= h2 - h;     
f = f'*f;
% Make sure its stable
g=[abs(roots(x(n+1:2*n)))-1];
