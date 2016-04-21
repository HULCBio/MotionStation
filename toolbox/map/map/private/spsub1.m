function [xp,yp] = spsub1(xc1,yc1,xc2,yc2)
%SPINT  Simple polygon subtraction for one-to-many polygons.
%   [XPS,YPS] = SPSUB(XP1,YP1,XP2,YP2) performs the polygon
%   subtraction operation for simple one-to-many polygons.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $ $Date: 2003/08/01 18:19:43 $

% initial subtraction (skip holes and splits)
isplit = [];  ihole = [];
for n=1:length(xc2)
	[xs,ys] = spsub(xc1{1},yc1{1},xc2{n},yc2{n});
	if length(xs)>1
		isplit = [isplit; n];
	elseif length(xs)==1
		if ~isempty(find(isnan(xs{1})))
			ihole = [ihole; n];
		else
			xc1 = xs;  yc1 = ys;
		end
	elseif length(xs)==0
		xp = {};  yp = {};
		return
	end
end

% subtraction for split contours
xc = xc1;  yc = yc1;
if ~isempty(isplit)
	for n=1:length(isplit)
		for m=1:length(xc)
			[xs,ys] = spsub(xc{m},yc{m},xc2{isplit(n)},yc2{isplit(n)});
			if length(xs)>1
				xc = [xc(1:m-1); xs; xc(m+1:length(xc))];
				yc = [yc(1:m-1); ys; yc(m+1:length(yc))];
			end
		end
	end
end

% subtraction for holes
xp = xc;  yp = yc;
if ~isempty(ihole)
	for n=1:length(ihole)
		for m=1:length(xp)
			[xc,yc] = extractpoly(xp(m),yp(m));
			[xs,ys] = spsub(xc,yc,xc2{ihole(n)},yc2{ihole(n)});
			if ~isempty(find(isnan(xs{1})))
				xp{m,1} = [xp{m,1}; nan; xc2{ihole(n)}];
				yp{m,1} = [yp{m,1}; nan; yc2{ihole(n)}];
			end
		end
	end
end
			
