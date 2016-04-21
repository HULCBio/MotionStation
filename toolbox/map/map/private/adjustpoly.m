function [x1,y1,x2,y2] = adjustpoly(x1,y1,x2,y2)
%ADJUSTPOLY  Adjusts polygon data.
%   [X1,Y1,X2,Y2] = ADJUSTPOLY(X1,Y1,X2,Y2) adjusts the polygon data so
%   that the first point of polygon 1 is not located on the border of
%   polygon 2.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $ $Date: 2003/08/01 18:19:19 $

err = eps*1e4;

% check individual points on polygon 1
p1in = inpolygonerr(x1(1:end-1),y1(1:end-1),x2,y2,err);

% if first point of polygon 1 is on the border, then shift data such that
% the first point is located inside or outside of polygon 2 (not border)
% if all points are located on border, then create an intermediate point
if p1in(1)==0.5
	indx = find(p1in~=0.5);
	if ~isempty(indx)
		x1 = [x1(indx(1):end); x1(2:indx(1))];
		y1 = [y1(indx(1):end); y1(2:indx(1))];
	else
		n = 1;
		xc = x1(1);  yc = y1(1);
		while inpolygonerr(xc,yc,x2,y2,err)==0.5
			xc = x1(n) + (x1(n+1)-x1(n))/2;
			yc = y1(n) + (y1(n+1)-y1(n))/2;
			n = n + 1;
		end
		x1 = [xc; x1(n:end-1); x1(1:n-1); xc];
		y1 = [yc; y1(n:end-1); y1(1:n-1); yc];
	end
end

% check individual points on polygon 2
p2in = inpolygonerr(x2(1:end-1),y2(1:end-1),x1,y1,err);

% if first point of polygon 2 is on the border, then shift data such that
% the first point is located inside or outside of polygon 1 (not border)
% if all points are located on border, then create an intermediate point
if p2in(1)==0.5
	indx = find(p2in~=0.5);
	if ~isempty(indx)
		x2 = [x2(indx(1):end); x2(2:indx(1))];
		y2 = [y2(indx(1):end); y2(2:indx(1))];
	else
		n = 1;
		xc = x2(1);  yc = y2(1);
		while inpolygonerr(xc,yc,x1,y1,err)==0.5
			xc = x2(n) + (x2(n+1)-x2(n))/2;
			yc = y2(n) + (y2(n+1)-y2(n))/2;
			n = n + 1;
		end
		x2 = [xc; x2(n:end-1); x2(1:n-1); xc];
		y2 = [yc; y2(n:end-1); y2(1:n-1); yc];
	end
end
