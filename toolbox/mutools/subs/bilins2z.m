% function sysout=bilins2z(sys,h)
%
% Calculates the Cayley bilinear transformation of a system
%  z=(1+sh/2)/(1-sh/2), continuous to discrete.
%
% See Also: BILINZ2S, SAMHLD, CO2DI, and DI2CO

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sysout=bilins2z(sys,h)

[a,b,c,d]=unpck(sys);
[na,na] = size(a);
eah2=eye(na,na)-a*h/2;
ad=eah2\(eah2+a*h);
bd=sqrt(h)*(eah2\b);
cd=sqrt(h)*(c/eah2);
dd=d+(h/2)*(c/eah2)*b;
sysout=pck(ad,bd,cd,dd);
%
%