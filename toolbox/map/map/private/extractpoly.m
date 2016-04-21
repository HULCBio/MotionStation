function [xc,yc,xh,yh,nanindx] = extractpoly(xp,yp)
%EXTRACTPOLY  Extract contour and holes from polygon element.
%   [XC,YC,XH,YH,NANINDX] = EXTRACTPOLY(XP,YP) extracts the contour and
%   holes data from a polygon element.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:28 $

% convert data to matrix
if iscell(xp)
	xp = xp{1};  yp = yp{1};
end

% append a nan at the end
x = [xp; nan];  y = [yp; nan];
indx = find(isnan(x));

% contour
indxc = 1:indx(1)-1;
xc = x(indxc);  yc = y(indxc);

% holes
xh = [];  yh = [];  nanindx = [];
if length(indx)>1
	indxh = indx(1):indx(end);
	xh = x(indxh);  yh = y(indxh);
	nanindx = find(isnan(xh));
end
