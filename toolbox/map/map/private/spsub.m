function [xps,yps] = spsub(x1,y1,x2,y2)
%SPSUB  Simple polygon subtraction.
%   [XPS,YPS] = (X1,Y1,X2,Y2) performs the simple polygon subtraction operation.
%   The resulting contours and hole are returned in cell arrays of x and y
%   coordinates.  Each contour is represented as a cell element.  Holes are
%   separated from the contour by NaNs.  Multiple output contours may be 
%   present with no holes, or one contour with one hole.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $ $Date: 2003/08/01 18:19:42 $

err = eps*1e5;

% clean input polygon data
[x1,y1] = cleandata(x1,y1);
[x2,y2] = cleandata(x2,y2);

% eliminate differences in numerical error
[x2,y2] = ptserr(x2,y2,x1,y1,err);

% polygon 1 must be counter-clockwise and polygon 2 must be clockwise
a1 = sparea(x1,y1);
if a1>0
	x1 = flipud(x1);
	y1 = flipud(y1);
	end
a2 = sparea(x2,y2);
if a2<0
	x2 = flipud(x2);
	y2 = flipud(y2);
end

% check to see if boolean operation can be performed logically
% if so, return outputs and exit
if isempty([x1 y1]) & isempty([x2 y2])
% an empty polygon
	xps = {};  yps = {};  return
elseif isempty([x1 y1]) & ~isempty([x2 y2])
% polygon 1 empty
	xps = {};  yps = {};  return
elseif ~isempty([x1 y1]) & isempty([x2 y2])
% polygon 2 empty
	xps = {x1};  yps = {y1};  return
end
[p1,p2] = polyinit(x1,y1,x2,y2);
if strcmp(p1,'in') & strcmp(p2,'in')
% if polygons are similar, subtraction yields nothing
	xps = {};  yps = {};  return
elseif strcmp(p1,'in') & strcmp(p2,'out')
% if polygon 1 is inside of polygon 2, contour is polygon 2, nothing left
	xps = {};  yps = {};  return
elseif strcmp(p1,'out') & strcmp(p2,'in')
% if polygon 2 is inside of polygon 1, contour is polygon 1, hole is polygon 2
	xps = {[x1; nan; x2]};  yps = {[y1; nan; y2]};  return
elseif strcmp(p1,'out') & strcmp(p2,'out')
% if both polygons are outside of each other, contour is polygon 1 (no subtr)
	xps = {x1};  yps = {y1};  return
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
count = 0;
i0 = (1:length(xi))';
xps = {};  yps = {};

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
		if (x1(ipt1)==x1(ipt2) & y1(ipt1)==y1(ipt2)) & (ipt2-ipt1)==1
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

% throw away non 2-d data (point and line)
% store valid data
	if length(x)>2
		count = count + 1;	% contour counter
		[x,y] = cleandata([x; x(1)],[y; y(1)]);
		xps{count,1} = x;
		yps{count,1} = y;
	end
	i0(z) = [];  % remove used intersection point

end
