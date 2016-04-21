function [xps,yps] = cpsub(xp1,yp1,xp2,yp2)
%CPSUB  Complex polygon intersection.
%   [XPS,YPS] = CPSUB(XP1,YP1,XP2,YP2) performs the polygon
%   subtraction operation for complex polygons.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:24 $

% initialize output variables
xps = {};  yps = {};

% loop for polygon 1 elements
for n1=1:length(xp1)

% extract polygon 1 data element and separate into contour and hole data
	[xc1,yc1,xh1,yh1,nanindx1] = extractpoly(xp1(n1),yp1(n1));

% convert holes from polygon 1 to cell array
	xho1 = {};  yho1 = {};
	for n=1:length(nanindx1)-1
		indx = nanindx1(n)+1:nanindx1(n+1)-1;
		xho1{n,1} = xh1(indx);  yho1{n,1} = yh1(indx);
	end

% initialize polygon
	xpm = xp1(n1);  ypm = yp1(n1);

	for n2=1:length(xp2)

% extract polygon 2 data element and separate into contour and hole data
		[xc2,yc2,xh2,yh2,nanindx2] = extractpoly(xp2(n2),yp2(n2));

% part 1: subtract polygon 2 contour from polygon 1 contour and subtract
% out holes from polygon 1
		xpa = {};  ypa = {};
		for m=1:length(xpm)

% extract polygon m data element and separate into contour and hole data
			[xcm,ycm,xhm,yhm,nanindxm] = extractpoly(xpm(m),ypm(m));

% convert holes from polygon m to cell array
			xh = {};  yh = {};
			for n=1:length(nanindxm)-1
				indx = nanindxm(n)+1:nanindxm(n+1)-1;
				xh{n,1} = xhm(indx);  yh{n,1} = yhm(indx);
			end

% compute subtraction of contours
			[xcs,ycs] = spsub(xcm,ycm,xc2,yc2);

% compute subtraction of hole from m
			for k=1:length(xcs)
				[xck,yck,xhk,yhk,nanindxk] = extractpoly(xcs(k),ycs(k));
				if ~isempty(nanindxk)  % combine holes
					for n=1:length(nanindxk)-1
						indx = nanindxk(n)+1:nanindxk(n+1)-1;
						xhn{n,1} = xhk(indx);  yhn{n,1} = yhk(indx);
					end
					[xh,yh] = spuni1(xh,yh,xhn,yhn);
				end
				[xk,yk] = spsub1({xck},{yck},xh,yh);
				xpa = [xpa; xk];  ypa = [ypa; yk];
			end
		
		end    % xpm loop

% part 2: find intersection of polygon 2 holes and polygon 1 contour and
% subtract out holes from polygon 1
		xpb = {};  ypb = {};
		for n=1:length(nanindx2)-1

			indx = nanindx2(n)+1:nanindx2(n+1)-1;

% compute intersection of polygon 2 hole and polygon 1 contour
			[xci,yci] = spint(xc1,yc1,xh2(indx),yh2(indx));

% subtract out holes from polygon 1
			for k=1:length(xci)
				[xk,yk] = spsub1(xci(k),yci(k),xho1,yho1);
				xpb = [xpb; xk];  ypb = [ypb; yk];
			end

		end

% figure; hold on; plotpoly(xpm,ypm,'b*-'); plotpoly(xp2{n2},yp2{n2},'ro--')
% patchpoly(xpa,ypa,'g'); patchpoly(xpb,ypb,'c');
% keyboard

% reset polygon m
		xpm = [xpa; xpb];  ypm = [ypa; ypb];

	end    % xp2 loop


% set output
	xps = [xps; xpm];  yps = [yps; ypm];

end    % xp1 loop
