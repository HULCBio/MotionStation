function [x1,y1,i1,x2,y2,i2] = insertintpts(x1,y1,x2,y2,xi,yi,ii,ri)
%INSERTINTPTS  Inserts computed intersection points into polygon data.
%   [X1,Y1,X2,Y2] = INSERTINTPTS(X1,Y1,X2,Y2,XI,YI,II,RI) inserts the computed 
%   intersection points of two polygons into the original polygon data.

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:32 $


err = eps*1e4;

% eliminate differences in numerical error
[x1,y1] = ptserr(x1,y1,xi,yi,err);
[x2,y2] = ptserr(x2,y2,xi,yi,err);

% insert intersection points into polygon 1
vtxpts = intersect([x1 y1],[xi yi],'rows');
i0 = flipud(ii(:,1));  xi0 = flipud(xi);  yi0 = flipud(yi);
while ~isempty(i0)
	lineseg = i0(1);  indx = find(i0==lineseg);
	if length(indx)>1
		dist = sqrt((x1(lineseg)-xi0(indx)).^2 + ...
					(y1(lineseg)-yi0(indx)).^2);
		[dist,isort] = sort(dist);  indx = indx(isort);
	end
	x1 = [x1(1:lineseg); xi0(indx); x1(lineseg+1:end)];
	y1 = [y1(1:lineseg); yi0(indx); y1(lineseg+1:end)];
	z = find(i0==lineseg);  i0(z) = [];  xi0(z) = [];  yi0(z) = [];
end
iz = [];
for n=1:length(vtxpts(:,1))
	vtx = vtxpts(n,:);  indx = find(x1==vtx(1) & y1==vtx(2));
	iz = [iz; indx(find(diff(indx)~=1)); indx(end)];
end
x1(iz) = [];  y1(iz) = [];

% insert intersection points into polygon 2
vtxpts = intersect([x2 y2],[xi yi],'rows');
[i0,isort] = sort(ii(:,2));
i0 = flipud(i0);  xi0 = flipud(xi(isort));  yi0 = flipud(yi(isort));
while ~isempty(i0)
	lineseg = i0(1);  indx = find(i0==lineseg);
	if length(indx)>1
		dist = sqrt((x2(lineseg)-xi0(indx)).^2 + ...
					(y2(lineseg)-yi0(indx)).^2);
		[dist,isort] = sort(dist);  indx = indx(isort);
	end
	x2 = [x2(1:lineseg); xi0(indx); x2(lineseg+1:end)];
	y2 = [y2(1:lineseg); yi0(indx); y2(lineseg+1:end)];
	z = find(i0==lineseg);  i0(z) = [];  xi0(z) = [];  yi0(z) = [];
end
iz = [];
for n=1:length(vtxpts(:,1))
	vtx = vtxpts(n,:);  indx = find(x2==vtx(1) & y2==vtx(2));
	iz = [iz; indx(find(diff(indx)~=1)); indx(end)];
end
x2(iz) = [];  y2(iz) = [];

% identify intersection points on polygon 1
i1 = zeros(size(x1));
indx1 = find(ismembererr([x1 y1],[xi yi],'rows',err));
i1(indx1) = (1:length(xi))';
xi = x1(indx1);  yi = y1(indx1);

% identify intersection points on polygon 2
i2 = zeros(size(x2));
count = 1;  xi0 = xi;  yi0 = yi; ii0 = ii;
while ~isempty([xi0 yi0])
   indx = find(ismembererr([x2 y2],[xi0(1) yi0(1)],'rows',err));
   if isempty(ri)
      i2(indx) = [count:count+length(indx)-1]';
   else
      if isempty(find(ismembererr([x2(indx) y2(indx)],[xi(ri) yi(ri)],...
		  						  'rows',err)))
         i2(indx) = [count:count+length(indx)-1]';
      else
         i2(indx) = [count+length(indx)-1:-1:count]';
      end
   end
%	if isempty(find(ismember([x2(indx) y2(indx)],[xi(ri) yi(ri)],'rows')))
%		i2(indx) = [count:count+length(indx)-1]';
%	else
%		i2(indx) = [count+length(indx)-1:-1:count]';
%	end
	count = count + length(indx);
	iz = find(xi0==xi0(1) & yi0==yi0(1));
	xi0(iz) = [];  yi0(iz) = []; ii0(iz,:) = [];
end

% enclose polygons
if x1(1)~=x1(end) & y1(1)~=y1(end)
	x1 = [x1; x1(1)];  y1 = [y1; y1(1)];  i1 = [i1; i1(1)];
end
if x2(1)~=x2(end) & y2(1)~=y2(end)
	x2 = [x2; x2(1)];  y2 = [y2; y2(1)];  i2 = [i2; i2(1)];
end
