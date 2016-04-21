% function sysout=bilinz2s(sys,h)
%
% Calculates the Cayley bilinear transformation of a system
%  z=(1+sh/2)/(1-sh/2).  Discrete to continuous.
%
% See Also: SAMHLD, CO2DI, and DI2CO

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sysout=bilinz2s(sys,h)

[ad,bd,cd,dd]=unpck(sys);
[na,na] = size(ad);
ead=eye(na,na)+ad;
a=(2/h)*(ad-eye(na,na))/ead;
b=(2/sqrt(h))*(ead\bd);
c=(2/sqrt(h))*(cd/ead);
d=dd-cd*(ead\bd);
sysout=pck(a,b,c,d);
%
%