function [xc,yc] = spuni1(xc1,yc1,xc2,yc2)
%SPUNI  Simple polygon union for m-to-n polygons.
%   [XP,YP] = SPUNI1(XC1,YC1,XC2,YC2) performs the polygon
%   union operation for simple m-to-n polygons.

%  Written by:  A. Kim
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.3.4.1 $ $Date: 2003/08/01 18:19:45 $

% determine which polygon contours intersect
iic = [];
for n1=1:length(xc1)
	for n2=1:length(xc2)
		[xpi,ypi] = spint(xc1{n1},yc1{n1},xc2{n2},yc2{n2});
		if ~isempty(xpi)
			iic = [iic; n1 n2];
		end
	end
end

% determine which polygons have no intersections
if ~isempty(iic)
	i1no = setdiff(1:length(xc1),unique(iic(:,1)));
	i2no = setdiff(1:length(xc2),unique(iic(:,2)));
else
	i1no = [];  i2no = [];
end

% determine resultant polygon islands
iicell = {};
if ~isempty(iic)
	num1 = iic(1,1);  count = 1;  ii = [];  % initialize
end
while ~isempty(iic)
	indx1 = find(ismember(iic(:,1),num1));
	if isempty(indx1)
		if ~isempty(iic)
			num1 = iic(1,1);
			iicell{count,1} = ii;
			count = count + 1;  ii = [];
		end
	else
		ii = [ii; iic(indx1,:)];
		num2 = iic(indx1,2);
		iic(indx1,:) = [];
		indx2 = find(ismember(iic(:,2),num2));
		if isempty(indx2)
			if ~isempty(iic)
				num1 = iic(1,1);
				iicell{count,1} = ii;
				count = count + 1;  ii = [];
			end
		else
			ii = [ii; iic(indx2,:)];
			num1 = iic(indx2,1);
			iic(indx2,:) = [];
		end
	end
	if isempty(iic),  iicell{count,1} = ii;  end
end

% for each polygon island, find union
xc = {};  yc = {};
for n=1:length(iicell)
	ii = iicell{n};
	i1 = ii(1,1);  i2 = [];
	x1 = xc1(i1);  y1 = yc1(i1);
	for m=1:length(ii(:,1))
		if isempty(find(ismember(i1,ii(m,1))))
			x2 = xc1{ii(m,1)};  y2 = yc1{ii(m,1)};
			[x1,y1] = spuni(x1{1},y1{1},x2,y2);
			i1 = [i1; ii(m,1)];
		end
		if isempty(find(ismember(i2,ii(m,2))))
			x2 = xc2{ii(m,2)};  y2 = yc2{ii(m,2)};
			[x1,y1] = spuni(x1{1},y1{1},x2,y2);
			i2 = [i2; ii(m,2)];
		end
	end
	xc(n,1) = x1;  yc(n,1) = y1;
end

% add polygons with no intersections
if ~isempty(i1no)
	nn = length(xc) + 1;
	xc(nn:nn+length(i1no)-1,1) = xc1(i1no);
	yc(nn:nn+length(i1no)-1,1) = yc1(i1no);
end
if ~isempty(i2no)
	nn = length(xc) + 1;
	xc(nn:nn+length(i2no)-1,1) = xc2(i2no);
	yc(nn:nn+length(i2no)-1,1) = yc2(i2no);
end
if isempty(i1no) & isempty(i2no)
	xc = [xc1; xc2];  yc = [yc1; yc2];
end
