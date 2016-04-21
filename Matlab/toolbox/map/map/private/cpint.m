function [xpi,ypi] = cpint(xp1,yp1,xp2,yp2)
%CPINT  Complex polygon intersection.
%   [XPI,YPI] = CPINT(XP1,YP1,XP2,YP2) performs the polygon
%   intersection operation for complex polygons.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:23 $

% initialize output variables
count = 1;  % output polygon counter
xpi = {};  ypi = {};

% loop for polygon 1 elements
for n1=1:length(xp1)

% extract polygon 1 data element and separate into contour and hole data
	[xc1,yc1,xh1,yh1,nanindx1] = extractpoly(xp1(n1),yp1(n1));

% loop for polygon 2 elements
	for n2=1:length(xp2)

% extract polygon 2 data element and separate into contour and hole data
		[xc2,yc2,xh2,yh2,nanindx2] = extractpoly(xp2(n2),yp2(n2));

% compute intersection of contours
		[xci,yci] = spint(xc1,yc1,xc2,yc2);

% combine holes from polygon 1 and 2 into cell array
		if length(nanindx1)>1
			for n=1:length(nanindx1)-1
				indx = nanindx1(n)+1:nanindx1(n+1)-1;
				x1{n,1} = xh1(indx);  y1{n,1} = yh1(indx);
			end
		else
			x1 = {};  y1 = {};
		end
		if length(nanindx2)>1
			for n=1:length(nanindx2)-1
				indx = nanindx2(n)+1:nanindx2(n+1)-1;
				x2{n,1} = xh2(indx);  y2{n,1} = yh2(indx);
			end
		else
			x2 = {};  y2 = {};
		end
		if ~isempty(x1) & ~isempty(x2)
			[xh,yh] = spuni1(x1,y1,x2,y2);
		else
			xh = [x1; x2];  yh = [y1; y2];
		end

% loop for each intersection contour
		for nc=1:length(xci)

% subtract out holes from intersection contour
			if isempty(xh)
				xps = xci(nc);  yps = yci(nc);
			else
				[xps,yps] = spsub1(xci(nc),yci(nc),xh,yh);
			end

% form output polygon
			nn = length(xps);
			if nn>0
				xpi(count:count+nn-1,1) = xps;
				ypi(count:count+nn-1,1) = yps;
				count = count + nn;
			end

		end  % xci loop

	end  % xp2 loop

end  % xp1 loop
