function [xpu,ypu] = spuni(x1,y1,x2,y2)
%SPUNI  Simple polygon union.
%   [XPU,YPU] = SPUNI(X1,Y1,X2,Y2) performs the simple polygon union operation.
%   The resulting contour and holes are returned in cell arrays of x and y
%   coordinates.  Each contour is represented as a cell element.  Holes are
%   separated from the contour by NaNs.  Multiple holes may be present, but
%   with only one main contour.  If the polygons do not intersect, then both
%   polygons are returned.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $ $Date: 2003/08/01 18:19:44 $


err = eps*1e5;

% clean input polygon data
[x1,y1] = cleandata(x1,y1);
[x2,y2] = cleandata(x2,y2);

% eliminate differences in numerical error
[x2,y2] = ptserr(x2,y2,x1,y1,err);

% polygon 1 and 2 must be in counter-clockwise directions
a1 = sparea(x1,y1);
if a1>0
	x1 = flipud(x1);
	y1 = flipud(y1);
	end
a2 = sparea(x2,y2);
if a2>0
	x2 = flipud(x2);
	y2 = flipud(y2);
end

% check to see if boolean operation can be performed logically
% if so, return outputs and exit
if isempty([x1 y1]) & isempty([x2 y2])
% empty polygons
	xpu = {};  ypu = {};  return
elseif isempty([x1 y1]) & ~isempty([x2 y2])
% polygon 1 empty
	xpu = {x2};  ypu = {y2};  return
elseif ~isempty([x1 y1]) & isempty([x2 y2])
% polygon 2 empty
	xpu = {x1};  ypu = {y1};  return
end
[p1,p2] = polyinit(x1,y1,x2,y2);
if strcmp(p1,'in') & strcmp(p2,'in')
% if polygons are similar, union is either polygon
	xpu = {x1};  ypu = {y1};  return
elseif strcmp(p1,'in') & strcmp(p2,'out')
% if polygon 1 is inside of polygon 2, union is polygon 2
	xpu = {x2};  ypu = {y2};  return
elseif strcmp(p1,'out') & strcmp(p2,'in')
% if polygon 2 is inside of polygon 1, union is polygon 1
	xpu = {x1};  ypu = {y1};  return
elseif strcmp(p1,'out') & strcmp(p2,'out')
% if both polygons are outside of each other, union is both
	xpu = {x1; x2};  ypu = {y1; y2};  return
end

% ensure that first point of polygon 1 is located either inside or outside
% of polygon 2 and not on its border
[x1,y1,x2,y2] = adjustpoly(x1,y1,x2,y2);

% calculate intersection points
[xi,yi,ii,ri] = polyxpoly(x1,y1,x2,y2,'filter');

% determine if first point of polygon 1 is located inside of polygon 2
if inpolygon(x1(1),y1(1),x2,y2)
	p1in = 1;
else
	p1in = 0;
end

% insert intersection points into polygon data
[x1,y1,i1,x2,y2,i2] = insertintpts(x1,y1,x2,y2,xi,yi,ii,ri);

% stack coordinates and indices for continuity
i1 = [i1; i1(2:end)];  x1 = [x1; x1(2:end)];  y1 = [y1; y1(2:end)];
i2 = [i2; i2(2:end)];  x2 = [x2; x2(2:end)];  y2 = [y2; y2(2:end)];

% initialize parameters
count = 0;	% count holes
i0 = (1:length(xi))';
xc = {};  yc = {};
xh = {};  yh = {};

% multiple polygons - continue until all intersection points are used
while ~isempty(i0)

% if first point of polygon 1 is inside of polygon 2, must start with an 
% even-numbered intersection point
% if first point of polygon 1 is outside of polygon 2, must start with an 
% odd-numbered intersection point
	if (p1in & mod(i0(1),2)) | (~p1in & ~mod(i0(1),2))
		i0 = [i0(2:end); i0(1)];
	end

% initialize parameters
	startpt = i0(1);  endpt = 0;  tmppt = startpt;
	x = [];  y = [];  z = [];

% begin with first intersection point
% check to see if orginal starting point is reached
	while endpt~=startpt

% traverse polygon 2 until intersection point is reached
		itmp = find(i2==tmppt);			ipt1 = itmp(1);
		itmp = find(i2(ipt1+1:end));	ipt2 = ipt1+itmp(1);
		z = [z; find(i0==tmppt)];
		if (x2(ipt1)==x2(ipt2) & y2(ipt1)==y2(ipt2)) & (ipt2-ipt1)==1
			indx2 = [];
		else
			indx2 = ipt1:ipt2-1;
		end
		tmppt = i2(ipt2);

% traverse polygon 1 until intersection point is reached
		itmp = find(i1==tmppt);			ipt1 = itmp(1);
		itmp = find(i1(ipt1+1:end));	ipt2 = ipt1+itmp(1);
		z = [z; find(i0==tmppt)];
		if x1(ipt1)==x1(ipt2) & y1(ipt1)==y1(ipt2) & (ipt2-ipt1)==1
			indx1 = [];
		else
			indx1 = ipt1:ipt2-1;
		end
		tmppt = i1(ipt2);

% record path traversed thus far
		x = [x; x2(indx2); x1(indx1)];
		y = [y; y2(indx2); y1(indx1)];

% end of first intersection pair - record end point
		endpt = tmppt;

	end

% throw away non 2-d data (point and line), store valid data
	if length(x)>2
		[x,y] = cleandata([x; x(1)],[y; y(1)]);
% if polygon direction is counter-clockwise, it is a contour;
% if polygon direction is clockwise, it is a hole
		area = sparea(x,y);
		if area<=0
			xc = {x};
			yc = {y};
		else
			count = count + 1;	% hole counter
			xh{count,1} = x;
			yh{count,1} = y;
		end
	end
	i0(z) = [];  % remove used intersection point

end

% form output polygon
xpu = xc{1};  ypu = yc{1};
for n=1:length(xh)
	xpu = [xpu; nan; xh{n}];
	ypu = [ypu; nan; yh{n}];
end
xpu = {xpu};  ypu = {ypu};
