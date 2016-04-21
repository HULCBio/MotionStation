function xstart = startx(u,l);
%STARTX	Box-centered point
%
% xstart = STARTX(u,l) returns centered point.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:43:40 $

n = length(u);
onen = ones(n,1);
arg = (u > 1e12);
u(arg) = inf*onen(arg);
xstart = zeros(n,1);
arg1 = (u<inf)&(l==-inf); arg2 = (u== inf)&(l > -inf);
arg3 = (u<inf)&(l>-inf);  arg4 = (u==inf)&(l==-inf);
%
w = max(abs(u),ones(n,1));
xstart(arg1) = u(arg1) - .5*w(arg1);
%
ww = max(abs(l),ones(n,1));
xstart(arg2) = l(arg2) + .5*ww(arg2);
%
xstart(arg3)=(u(arg3)+l(arg3))/2;
xstart(arg4)=ones(length(arg4(arg4>0)),1);



