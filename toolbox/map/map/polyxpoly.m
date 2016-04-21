function [xi,yi,ii,ri] = polyxpoly(varargin)

%POLYXPOLY  Line or polygon intersection points.
%
%   [XI,YI] = POLYXPOLY(X1,Y1,X2,Y2) returns the intersection points of
%   two sets of lines and/or polygons.
%
%   [XI,YI] = POLYXPOLY(...,'unique') returns only unique intersections.
%
%   [XI,YI,II] = POLYXPOLY(...) also returns a two-column index of line
%   segment numbers corresponding to the intersection points.
%
% See also NAVFIX, CROSSFIX, SCXSC, GCXGC, GCXSC, RHXRH

%  Written by:  A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.6.4.1 $    $Date: 2003/08/01 18:17:39 $

% set input variables
if nargin==4 | nargin==5
	x1 = varargin{1}(:);  y1 = varargin{2}(:);
	x2 = varargin{3}(:);  y2 = varargin{4}(:);
else
	error('Incorrect number of arguments')
end
if nargin==5,
	strcode = varargin{nargin};
else
	strcode = 'all';
end

% check for valid strcode
validtypes = {'all';'unique';'filter'};
if isempty(strmatch(strcode,validtypes))
	error('Valid options are ''all'',''unique'' or ''filter''')
end

% check x and y vectors
msg = inputcheck('xyvector',x1,y1); if ~isempty(msg); error(msg); end
msg = inputcheck('xyvector',x2,y2); if ~isempty(msg); error(msg); end


% determine if both are polygons
if (x1(1)==x1(end) & y1(1)==y1(end)) & (x2(1)==x2(end) & y2(1)==y2(end))
	datatype = 'polygon';
else
	datatype = 'line';
end

% compute all intersection points
[xi,yi,ii] = intptsall(x1,y1,x2,y2);
ri = [];
if isempty([xi yi ii]),  return;  end

% format intersection points according to type and strcode
if ~isempty(strmatch(strcode,'filter'))
	if strcmp(datatype,'line')
		error('Line data cannot be filtered for polygon boolean operations')
	end
	[xi,yi,ii,ri] = filterintpts(x1,y1,x2,y2,xi,yi,ii);
elseif ~isempty(strmatch(strcode,'unique'))
	[a,i,j] = uniqueerr(flipud([xi yi]),'rows',eps*1e4);
	i = length(xi)-flipud(sort(i))+1;
	xi = xi(i);  yi = yi(i);  ii = ii(i,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xi,yi,ii] = intptsall(x1,y1,x2,y2)
%INTPTSALL  Unfiltered line or polygon intersection points.
%   [XI,YI,II] = INTPTSALL(X1,Y1,X2,Y2) returns the unfiltered intersection 
%   points of two sets of lines or polygons, along with a two-column index
%   of line segment numbers corresponding to the intersection points.
%   Note: intersection points are ordered from lowest to hightest line 
%   segment numbers.

%  Written by:  A. Kim


err = eps*1e5;

% form line segment matrices
xs1 = [x1 [x1(2:end); x1(1)]];
ys1 = [y1 [y1(2:end); y1(1)]];
xs2 = [x2 [x2(2:end); x2(1)]];
ys2 = [y2 [y2(2:end); y2(1)]];

% remove last segment (for self-enclosed polygons, this is a non-segment;
% for lines, there are n-1 line segments)
xs1 = xs1(1:end-1,:);  ys1 = ys1(1:end-1,:);
xs2 = xs2(1:end-1,:);  ys2 = ys2(1:end-1,:);

% tile matrices for vectorized intersection calculations
N1 = length(xs1(:,1));  N2 = length(xs2(:,1));
X1 = reshape(repmat(xs1,1,N2)',2,N1*N2)';
Y1 = reshape(repmat(ys1,1,N2)',2,N1*N2)';
X2 = repmat(xs2,N1,1);
Y2 = repmat(ys2,N1,1);

% compute slopes
w = warning;
warning off
m1 = (Y1(:,2) - Y1(:,1)) ./ (X1(:,2) - X1(:,1));
m2 = (Y2(:,2) - Y2(:,1)) ./ (X2(:,2) - X2(:,1));
% m1(find(m1==-inf)) = inf;  m2(find(m2==-inf)) = inf;
m1(find(abs(m1)>1/err)) = inf;  m2(find(abs(m2)>1/err)) = inf;
warning(w)

% compute y-intercepts (note: imaginary values for vertical lines)
b1 = zeros(size(m1));  b2 = zeros(size(m2));
i1 = find(m1==inf);  if ~isempty(i1),  b1(i1) = X1(i1)*i;  end
i2 = find(m2==inf);  if ~isempty(i2),  b2(i2) = X2(i2)*i;  end
i1 = find(m1~=inf);  if ~isempty(i1),  b1(i1) = Y1(i1) - m1(i1).*X1(i1);  end
i2 = find(m2~=inf);  if ~isempty(i2),  b2(i2) = Y2(i2) - m2(i2).*X2(i2);  end

% zero intersection coordinate arrays
sz = size(X1(:,1));  x0 = zeros(sz);  y0 = zeros(sz);

% parallel lines (do not intersect except for similar lines)
% for similar lines, take the low and high points
% idx = find(m1==m2);
idx = find( abs(m1-m2)<err | (isinf(m1)&isinf(m2)) );
if ~isempty(idx)
% non-similar lines
% 	sub = find(b1(idx)~=b2(idx));  j = idx(sub);
	sub = find(abs(b1(idx)-b2(idx))>err);  j = idx(sub);
	x0(j) = nan;  y0(j) = nan;
% similar lines (non-vertical)
% 	sub = find(b1(idx)==b2(idx) & m1(idx)~=inf);  j = idx(sub);
	sub = find(abs(b1(idx)-b2(idx))<err & m1(idx)~=inf);  j = idx(sub);
	Xlo = max([min(X1(j,:),[],2) min(X2(j,:),[],2)],[],2);
	Xhi = min([max(X1(j,:),[],2) max(X2(j,:),[],2)],[],2);
	if ~isempty(j)
		j0 = find(abs(Xlo-Xhi)<=err);
		j1 = find(abs(Xlo-Xhi)>err);
		x0(j(j0)) = Xlo(j0);
		y0(j(j0)) = Y1(j(j0)) + m1(j(j0)).*(Xlo(j0) - X1(j(j0)));
		x0(j(j1)) = Xlo(j1) + i*Xhi(j1);
		y0(j(j1)) = (Y1(j(j1)) + m1(j(j1)).*(Xlo(j1) - X1(j(j1)))) + ...
					 i*(Y1(j(j1)) + m1(j(j1)).*(Xhi(j1) - X1(j(j1))));
% 		if Xlo==Xhi
% 		if abs(Xlo-Xhi)<=eps
% 			x0(j) = Xlo;
% 			y0(j) = Y1(j) + m1(j).*(Xlo - X1(j));
% 		else
% 			x0(j) = Xlo + i*Xhi;
% 			y0(j) = (Y1(j) + m1(j).*(Xlo - X1(j))) + ...
% 					 i*(Y1(j) + m1(j).*(Xhi - X1(j)));
% 		end
	end
% similar lines (vertical)
% 	sub = find(b1(idx)==b2(idx) & m1(idx)==inf);  j = idx(sub);
	sub = find(abs(b1(idx)-b2(idx))<err & m1(idx)==inf);  j = idx(sub);
	Ylo = max([min(Y1(j,:),[],2) min(Y2(j,:),[],2)],[],2);
	Yhi = min([max(Y1(j,:),[],2) max(Y2(j,:),[],2)],[],2);
	if ~isempty(j)
		y0(j) = Ylo + i*Yhi;
		x0(j) = X1(j) + i*X1(j);
	end
end

% non-parallel lines
% idx = find(m1~=m2);
idx = find(abs(m1-m2)>err);
if ~isempty(idx)
% non-vertical/non-horizontal lines
% 	sub = find(m1(idx)~=inf & m2(idx)~=inf & m1(idx)~=0 & m2(idx)~=0);
	sub = find(m1(idx)~=inf & m2(idx)~=inf & ...
			   abs(m1(idx))>eps & abs(m2(idx))>eps);
	j = idx(sub);
	x0(j) = (Y1(j) - Y2(j) + m2(j).*X2(j) - m1(j).*X1(j)) ./ ...
			(m2(j) - m1(j));
	y0(j) = Y1(j) + m1(j).*(x0(j)-X1(j));
% first line vertical
	sub = find(m1(idx)==inf);  j = idx(sub);
	x0(j) = X1(j);
	y0(j) = Y2(j) + m2(j).*(x0(j)-X2(j));
% second line vertical
	sub = find(m2(idx)==inf);  j = idx(sub);
	x0(j) = X2(j);
	y0(j) = Y1(j) + m1(j).*(x0(j)-X1(j));
% first line horizontal, second line non-vertical
% 	sub = find(m1(idx)==0 & m2(idx)~=inf);  j = idx(sub);
	sub = find(abs(m1(idx))<=eps & m2(idx)~=inf);  j = idx(sub);
	y0(j) = Y1(j);
	x0(j) = (Y1(j) - Y2(j) + m2(j).*X2(j)) ./ m2(j);
% second line horizontal, first line non-vertical
% 	sub = find(m2(idx)==0 & m1(idx)~=inf);  j = idx(sub);
	sub = find(abs(m2(idx))<=eps & m1(idx)~=inf);  j = idx(sub);
	y0(j) = Y2(j);
	x0(j) = (Y1(j) - y0(j) - m1(j).*X1(j)) ./ -m1(j);
% connecting line segments (exact solution)
% 	sub1 = find(X1(idx,1)==X2(idx,1) & Y1(idx,1)==Y2(idx,1));
% 	sub2 = find(X1(idx,1)==X2(idx,2) & Y1(idx,1)==Y2(idx,2));
% 	sub3 = find(X1(idx,2)==X2(idx,1) & Y1(idx,2)==Y2(idx,1));
% 	sub4 = find(X1(idx,2)==X2(idx,2) & Y1(idx,2)==Y2(idx,2));
% 	j1 = idx(sort([sub1; sub2]));
% 	j2 = idx(sort([sub3; sub4]));
% 	x0(j1) = X1(j1,1);  y0(j1) = Y1(j1,1);
% 	x0(j2) = X1(j2,2);  y0(j2) = Y1(j2,2);
end

% throw away points that lie outside of line segments
dx1 = [min(X1,[],2)-x0, x0-max(X1,[],2)];
dy1 = [min(Y1,[],2)-y0, y0-max(Y1,[],2)];
dx2 = [min(X2,[],2)-x0, x0-max(X2,[],2)];
dy2 = [min(Y2,[],2)-y0, y0-max(Y2,[],2)];
% [irow,icol] = find([dx1 dy1 dx2 dy2]>1e-14);
[irow,icol] = find([dx1 dy1 dx2 dy2]>err);
idx = sort(unique(irow));
x0(idx) = nan;
y0(idx) = nan;

% retrieve only intersection points (no nans)
idx = find(~isnan(x0));
xi = x0(idx);  yi = y0(idx);

% determine indices of line segments that intersect
i1 = ceil(idx/N2);  i2 = rem(idx,N2);
if ~isempty(i2),  i2(find(i2==0)) = N2;  end
ii = [i1 i2];

% combine all intersection points
indx = union(find(imag(xi)),find(imag(yi)));
% indx = find(imag(xi));
for n=length(indx):-1:1
	j = indx(n);
	ii = [ii(1:j-1,:); ii(j,:); ii(j:end,:)];
	xi = [xi(1:j-1); imag(xi(j)); real(xi(j:end))];
	yi = [yi(1:j-1); imag(yi(j)); real(yi(j:end))];
end

% round intersection points
% xi = round(xi/1e-9)*1e-9;
% yi = round(yi/1e-9)*1e-9;

% check for identical intersection points (numerical error in epsilon)
[xt,ixt,jxt] = uniqueerr(xi,[],err);
[yt,iyt,jyt] = uniqueerr(yi,[],err);
xi = xt(jxt);  yi = yt(jyt);
[xi,yi] = ptserr(xi,yi,[x1;x2],[y1;y2],err);
% if ~isempty([xi yi])
% 	N = length(xi);
% 	xi1 = repmat(xi,N,1);  yi1 = repmat(yi,N,1);
% 	xi2 = repmat(xi',N,1);  yi2 = repmat(yi',N,1);
% 	xi2 = xi2(:);  yi2 = yi2(:);
% 	dxi = abs(xi1 - xi2);  dyi = abs(yi1 - yi2);
% 	indx = find((dxi>0 & dxi<eps) | dyi>0 & dyi<eps);
% 	itmp = rem(indx,N);
% 	if ~isempty(itmp),  itmp(find(itmp==0)) = N;  end
% 	ixyi = [ceil(indx/N) itmp];
% 	while ~isempty(ixyi)
% 		idx =  find(ismember([xi(ixyi(1,:)) yi(ixyi(1,:))],...
% 							 [x1 y1; x2 y2],'rows'));
% 		xi(ixyi(1,:)) = xi(ixyi(1,idx));
% 		yi(ixyi(1,:)) = yi(ixyi(1,idx));
% 		iz = find(ixyi(:,1)==ixyi(1,2) & ixyi(:,2)==ixyi(1,1));
% 		ixyi([1 iz],:) = [];
% 	end
% end

% figure; hold; plotpoly(x1,y1,'b*-'); plotpoly(x2,y2,'ro--')
% [xi yi ii]
% keyboard

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xi,yi,ii,ri] = filterintpts(x1,y1,x2,y2,xi,yi,ii)
%FILTERINTPTS  Filter polygon intersection points.
%   [XI,YI,II,RI] = FILTERINTPTS(X1,Y1,X2,Y2,XI,YI,II) filters the intersection 
%   points from INTPTSALL for the polygon boolean operations.

%  Written by:  A. Kim


err = eps*1e5;

% extract unique intersection points
[a,i,j] = uniqueerr(flipud([xi yi]),'rows',err);
i = length(xi)-flipud(sort(i))+1;
ixy0 = [ii(i,:) xi(i) yi(i)];

% sort all unique intersection points along polygon 1
i1 = sort(unique(ixy0(:,1)));
for n=1:length(i1)
	indx1 = find(ixy0(:,1)==i1(n));
	dist = sqrt((x1(i1(n))-ixy0(indx1,3)).^2 + ...
					(y1(i1(n))-ixy0(indx1,4)).^2);
	[dist,isort] = sort(dist);  indx2 = indx1(isort);
	ixy0(indx1,:) = ixy0(indx2,:);
end

% identify vertex intersection points
nvtx(:,1) = ismembererr(ixy0(:,3:4),[x1 y1],'rows',err);
nvtx(:,2) = ismembererr(ixy0(:,3:4),[x2 y2],'rows',err);
ivtx = find(nvtx(:,1) | nvtx(:,2));

% procedure for determining which vertex intersection points to add:
%	1.  for each vertex intersection point, determine whether the points 
%		before and after the intersection points on polygon 1 are inside
%		or outside polygon 2
%   2.  check conditions to add point

ri = [];  % initialize reverse intersection points index

if ~isempty(ivtx)

% polygon 1 point inside/outside of polygon 2
% for each vertex intersection point, check the last and next midpoints
% on polygon 1 to see if they are inside of polygon 2
	for n=1:length(ivtx)
% determine last point before current vertex intersection point
% (will either be the last point on polygon 1 or an intersection point)
		ilastpt1 = ixy0(ivtx(n),1);
		lastpt = [x1(ilastpt1) y1(ilastpt1)];	% on polygon 1
		if ivtx(n)>1
			if ixy0(ivtx(n)-1,1)==ilastpt1
				lastpt = ixy0(ivtx(n)-1,3:4);	% intersection point
			end
		end
% determine next point after current vertex intersection point
% (will either be the next point on polygon 1 or an intersection point)
		if nvtx(ivtx(n),1)
			inextpt1 = ixy0(ivtx(n),1) + 2;
		else
			inextpt1 = ixy0(ivtx(n),1) + 1;
		end
		nextpt = [x1(inextpt1) y1(inextpt1)];	% on polygon 1
		if ivtx(n)<length(ixy0(:,1))
			if ixy0(ivtx(n)+1,1)==inextpt1-1
				nextpt = ixy0(ivtx(n)+1,3:4);	% intersection point
			end
		end
% compute midpoints and determine whether inside or outside
		lastmidpt = lastpt + .5*(ixy0(ivtx(n),3:4) - lastpt);
		nextmidpt = nextpt + .5*(ixy0(ivtx(n),3:4) - nextpt);
% evaluate last and next points at 9 points: [nw,n,ne;w,c,e;sw,s,se]
		xa = lastmidpt(:,1);  ya = lastmidpt(:,2);
		xb = nextmidpt(:,1);  yb = nextmidpt(:,2);
		p1in(n,1) = inpolygonerr(xa,ya,x2,y2,err);
		p1in(n,2) = inpolygonerr(xb,yb,x2,y2,err);
% 		xca = lastmidpt(:,1);  yca = lastmidpt(:,2);
% 		xcb = nextmidpt(:,1);  ycb = nextmidpt(:,2);
% 		xa = zeros(3,3);  ya = zeros(3,3);
% 		xb = zeros(3,3);  yb = zeros(3,3);
% 		xa(:,1) = xca - xca*eps;  xa(:,2) = xca;  xa(:,3) = xca + xca*eps;
% 		ya(1,:) = yca + yca*eps;  ya(2,:) = yca;  ya(3,:) = yca - yca*eps;
% 		xb(:,1) = xcb - xcb*eps;  xb(:,2) = xcb;  xb(:,3) = xcb + xcb*eps;
% 		yb(1,:) = ycb + ycb*eps;  yb(2,:) = ycb;  yb(3,:) = ycb - ycb*eps;
% 		ina = inpolygon(xa,ya,x2,y2);
% 		inb = inpolygon(xb,yb,x2,y2);
% 		if all(ina(:))
% 			ina = 1;
% 		elseif ~any(ina(:))
% 			ina = 0;
% 		else
% 			ina = .5;
% 		end
% 		if all(inb(:))
% 			inb = 1;
% 		elseif ~any(inb(:))
% 			inb = 0;
% 		else
% 			inb = .5;
% 		end
% 		xa = lastmidpt(:,1);  ya = lastmidpt(:,2);
% 		xb = nextmidpt(:,1);  yb = nextmidpt(:,2);
% 		p1in(n,:) = [ina inb];
	end

% determine which simple (no borders) vertex intersection points to add
%	- check whether points before and after vertex are same or different
% add point for same
	iadd1 = find(ismember(p1in,[0 0; 1 1],'rows'));
% 	nbrdr1 = zeros(size(iadd1));

% determine which complex (borders) vertex intersection points to add:
% 	- check whether points before and after border are same or different
%	- check whether number of borders are odd or even
% add point: diff & odd, same & even
	iadd2 = [];
	indx = [find(p1in(:,2)==.5) find(p1in(:,1)==.5)];
	if ~isempty(indx)
		if length(indx(:,1))==1
			ichk = indx;
		elseif length(indx(:,1))>1
			itmp = find(diff(indx(:,1))>1);
			if isempty(itmp)
				ichk = [1 length(p1in(:,1))];
			else
				ichk = [1 indx(itmp(1),2)];
				for n=1:length(itmp)-1
					ichk = [ichk; indx(itmp(n)+1,1) indx(itmp(n+1),2)];
				end
				ichk = [ichk; indx(itmp(end)+1,1) indx(end)];
			end
		end
		binout = [p1in(ichk(:,1),1) p1in(ichk(:,2),2)];
		bnum = ichk(:,2) - ichk(:,1);
		ipts = find( (binout(:,1)==~binout(:,2) & mod(bnum,2)) | ...
					  (binout(:,1)==binout(:,2) & ~mod(bnum,2)) );
		if ~isempty(ipts)
			iadd2 = ichk(ipts,2);
		end
	end

% procedure for adding additional vertex intersection points:
%	1.  for each vertex intersection point to be added, determine ordering
%	2.  add points with correct ordering

% determine ordering for non-border vertex intersection points:
% for each non-border vertex intersection point to add, check the last and 
% next midpoints on polygon 2 to see if they are inside of polygon 1 to 
% determine ordering of intersection points
	rvsordr1 = [];
	if ~isempty(iadd1)
		for n=1:length(iadd1)
% specify current vertex point to add
			ivtxpt = ivtx(iadd1(n));
% determine last point before current vertex intersection point or border
% point (last point on polygon 2 or an intersection point)
			ilastpt2 = ixy0(ivtxpt,2);
			lastpt = [x2(ilastpt2) y2(ilastpt2)];	% on polygon 2
			if ivtxpt>1
				if ixy0(ivtxpt-1,2)==ilastpt2
					lastpt = ixy0(ivtxpt-1,3:4);	% intersection point
				end
			end
% determine next point after current vertex intersection point
% (will either be the next point on polygon 1 or an intersection point)
			if nvtx(ivtxpt,2)
				inextpt2 = ixy0(ivtxpt,2) + 2;
			else
				inextpt2 = ixy0(ivtxpt,2) + 1;
			end
			nextpt = [x2(inextpt2) y2(inextpt2)];	% on polygon 2
			if ivtxpt<length(ixy0(:,1))
				if ixy0(ivtxpt+1,2)==inextpt2-1
					nextpt = ixy0(ivtxpt+1,3:4);	% intersection point
				end
			end
% compute midpoints and determine whether inside or outside
			lastmidpt = lastpt + (ixy0(ivtxpt,3:4) - lastpt) / 2;
			nextmidpt = nextpt + (ixy0(ivtxpt,3:4) - nextpt) / 2;
			xa = lastmidpt(:,1);  ya = lastmidpt(:,2);
			xb = nextmidpt(:,1);  yb = nextmidpt(:,2);
% 			p2in(n,:) = inpolygon([xa xb],[ya yb],x1,y1);
			p2in(n,1) = inpolygonerr(xa,ya,x1,y1,err);
			p2in(n,2) = inpolygonerr(xb,yb,x1,y1,err);
		end
% if polygon 2 is counter-clockwise (intersection and union), reverse 
% order if similar in/out states; if polygon 2 is clockwise (subtraction),
% reverse oder if opposite in/out states
		if sparea(x2,y2)<0
			rvsordr1 = p1in(iadd1,1)==p2in(:,1);
		else
			rvsordr1 = p1in(iadd1,1)~=p2in(:,1);
		end
	end

% determine ordering for border vertex intersection points:
%	- if the point on polygon 2 before the current vertex intersection point 
%	  is on the border of polygon 1, then the two polygons follow the same 
% 	  direction along their common border
%	- if the point on polygon 2 before the current vertex intersection point  
%	  is not on the border of polygon 1, then the two polygons do not follow  
%	  the same direction along their common border
	rvsordr2 = [];
	if ~isempty(iadd2)
		for n=1:length(iadd2)
% specify current vertex point to add
			ivtxpt = ivtx(iadd2(n));
% point on polygon 2 before the current vertex intersection point
			ipt = ixy0(ivtxpt,1:2);
% reverse order border segments are in opposite direction
			dir1 = atan2(y1(ipt(1)+1)-y1(ipt(1)),x1(ipt(1)+1)-x1(ipt(1)));
			dir2 = atan2(y2(ipt(2)+1)-y2(ipt(2)),x2(ipt(2)+1)-x2(ipt(2)));
% 			if dir1~=dir2
			if abs(dir1-dir2)>err
				rvsordr2(n,1) = 1;
			else
				rvsordr2(n,1) = 0;
			end
		end
% 		rvsordr2 = inpolygon(x2(ipt),y2(ipt),x1,y1)~=.5;
	end

% add points using add points index and reverse order flag
	[iaddpts,isort] = sort(ivtx([iadd1; iadd2]));
	rvsordr = [rvsordr1; rvsordr2];
	rvsordr = rvsordr(isort);
	ixy = ixy0;
	for n=1:length(iaddpts)
		iins = find(ismembererr(ixy(:,3:4),ixy0(iaddpts(n),3:4),'rows',err));
		iadd = find(ismembererr([xi yi],ixy0(iaddpts(n),3:4),'rows',err));
		if rvsordr(n)
			if length(iadd(:)) > 1
				iadd = flipud(iadd(1:2));
			end
			ri = [ri; iins];  % store reverses
		else
			iadd = iadd(1:2);
		end
		addvtxpts = [ii(iadd,:) xi(iadd) yi(iadd)];
		ixy = [ixy(1:iins-1,:); addvtxpts; ixy(iins+1:end,:)];
	end

% all intersection points
	ixy0 = ixy;	

end

% set outputs
ii = ixy0(:,1:2);  xi = ixy0(:,3);  yi = ixy0(:,4);

% check for epsilon error
[xi,yi] = ptserr(xi,yi,[x1;x2],[y1;y2],err);



