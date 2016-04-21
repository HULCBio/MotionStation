function [xpx,ypx] = cpxor(xp1,yp1,xp2,yp2)
%CPXOR  Complex polygon xor.
%   [XPX,YPX] = CPXOR(XP1,YP1,XP2,YP2) performs the polygon
%   xor operation for complex polygons.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:19:26 $

[xpu,ypu] = cpuni(xp1,yp1,xp2,yp2);
[xpi,ypi] = cpint(xp1,yp1,xp2,yp2);

[xpx,ypx] = cpsub(xpu,ypu,xpi,ypi);
