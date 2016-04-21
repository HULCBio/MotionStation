function [xpu,ypu] = cpuni(xp1,yp1,xp2,yp2)
%CPUNI  Complex polygon union.
%   [XPU,YPU] = CPUNI(XP1,YP1,XP2,YP2) performs the polygon
%   union operation for complex polygons.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:25 $

% determine which polygons intersect
iip = [];
for n1=1:length(xp1)
	[xc1,yc1] = extractpoly(xp1(n1),yp1(n1));
	for n2=1:length(xp2)
		[xc2,yc2] = extractpoly(xp2(n2),yp2(n2));
		[xpi,ypi] = spint(xc1,yc1,xc2,yc2);
		if ~isempty(xpi)
			iip = [iip; n1 n2];
		end
	end
end

% determine which polygons have no intersections
if isempty(iip)
	xpu = [xp1; xp2];
	ypu = [yp1; yp2];
	return
else
	i1no = setdiff(1:length(xp1),unique(iip(:,1)));
	i2no = setdiff(1:length(xp2),unique(iip(:,2)));
end

% determine resultant polygon islands
num1 = iip(1,1);  count = 1;  ii = [];  % initialize
while ~isempty(iip)
	indx1 = find(ismember(iip(:,1),num1));
	if isempty(indx1)
		if ~isempty(iip)
			num1 = iip(1,1);
			iicell{count,1} = ii;
			count = count + 1;  ii = [];
		end
	else
		ii = [ii; iip(indx1,:)];
		num2 = iip(indx1,2);
		iip(indx1,:) = [];
		indx2 = find(ismember(iip(:,2),num2));
		if isempty(indx2)
			if ~isempty(iip)
				num1 = iip(1,1);
				iicell{count,1} = ii;
				count = count + 1;  ii = [];
			end
		else
			ii = [ii; iip(indx2,:)];
			num1 = iip(indx2,1);
			iip(indx2,:) = [];
		end
	end
	if isempty(iip),  iicell{count,1} = ii;  end
end

% for each polygon island, find union
for n=1:length(iicell)
	ii = iicell{n};
	i1 = ii(1,1);  i2 = [];
	x1 = xp1(i1);  y1 = yp1(i1);
	for m=1:length(ii(:,1))
		if isempty(find(ismember(i1,ii(m,1))))
			x2 = xp1(ii(m,1));  y2 = yp1(ii(m,1));
			[x1,y1] = cpuni1(x1,y1,x2,y2);
			i1 = [i1; ii(m,1)];
		end
		if isempty(find(ismember(i2,ii(m,2))))
			x2 = xp2(ii(m,2));  y2 = yp2(ii(m,2));
			[x1,y1] = cpuni1(x1,y1,x2,y2);
			i2 = [i2; ii(m,2)];
		end
	end
	xpu(n,1) = x1;  ypu(n,1) = y1;
end

% add polygons with no intersections
if ~isempty(i1no)
	nn = length(xpu) + 1;
	xpu(nn:nn+length(i1no)-1,1) = xp1(i1no);
	ypu(nn:nn+length(i1no)-1,1) = yp1(i1no);
end
if ~isempty(i2no)
	nn = length(xpu) + 1;
	xpu(nn:nn+length(i2no)-1,1) = xp2(i2no);
	ypu(nn:nn+length(i2no)-1,1) = yp2(i2no);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xpu,ypu] = cpuni1(xp1,yp1,xp2,yp2)
%CPUNI1  Complex polygon union for one-to-one polygons.
%   [XPI,YPI] = CPUNI1(XP1,YP1,XP2,YP2) performs the polygon
%   union operation for complex one-to-one polygons.

%  Written by:  A. Kim


% extract polygon 1 data element and separate into contour and hole data
[xc1,yc1,xh1,yh1,nanindx1] = extractpoly(xp1,yp1);

% extract polygon 2 data element and separate into contour and hole data
[xc2,yc2,xh2,yh2,nanindx2] = extractpoly(xp2,yp2);

% compute union of contours
[xcu,ycu] = spuni(xc1,yc1,xc2,yc2);

% initialize for holes
xh = [];  yh = [];

% compute holes - polygon 1 holes minus contour 2
for nh1=1:length(nanindx1)-1
	indx = nanindx1(nh1)+1:nanindx1(nh1+1)-1;
	[xhs1,yhs1] = spsub(xh1(indx),yh1(indx),xc2,yc2);
	for n=1:length(xhs1)
		xh = [xh; nan; xhs1{n}];
		yh = [yh; nan; yhs1{n}];
	end
end

% compute holes - polygon 2 holes minus contour 1
for nh2=1:length(nanindx2)-1
	indx = nanindx2(nh2)+1:nanindx2(nh2+1)-1;
	[xhs2,yhs2] = spsub(xh2(indx),yh2(indx),xc1,yc1);
	for n=1:length(xhs2)
		xh = [xh; nan; xhs2{n}];
		yh = [yh; nan; yhs2{n}];
	end
end

% compute holes from polygon holes intersection
for nh1=1:length(nanindx1)-1
	for nh2=1:length(nanindx2)-1
		indx1 = nanindx1(nh1)+1:nanindx1(nh1+1)-1;
		indx2 = nanindx2(nh2)+1:nanindx2(nh2+1)-1;
		[xhi,yhi] = spint(xh1(indx1),yh1(indx1),xh2(indx2),yh2(indx2));
		for n=1:length(xhi)
			xh = [xh; nan; xhi{n}];
			yh = [yh; nan; yhi{n}];
		end
	end
end

% combine contour and holes
xpu = {[xcu{1}; xh]};
ypu = {[ycu{1}; yh]};
