function f = filtobj(xfree,x,xmask,n,h,maxbin);
%FILTOBJ Returns frequency response for DFILDEMO.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/02/07 19:13:06 $

x(xmask)  = xfree;
h2=abs(freqz(x(1:n), x(n+1:2*n), 128));
f= h2 - h;     

