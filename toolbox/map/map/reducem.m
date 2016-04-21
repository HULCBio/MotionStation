function [latout,lonout,cerr,epstol] = reducem(latin,lonin,epstol)

%REDUCEM  Reduce the number of points in vector data
%
%  [latout,lonout] = REDUCEM(latin,lonin) reduces the number of points
%  in vector map data using the Douglas-Peucker line simplification
%  algorithm.  This method recursively subdivides a polygon until a
%  run of points can be replaced by a straight line segment, with no
%  point in that run deviating from the straight line by more than the
%  tolerance.  In this case the tolerance is computed automatically.
%
%  [latout,lonout] = REDUCEM(latin,lonin,tol) uses the provided
%  tolerance. The units of the tolerance are degrees of arc on the surface
%  of a sphere.
%
%  [latout,lonout,cerr] = REDUCEM(...)  also returns a measure of the
%  error introduced by the simplification.  Cerr is the difference in
%  the arc length of the original and reduced data, normalized by the
%  original length.
%
%  [latout,lonout,cerr,tol] = REDUCEM(...)  also returns the tolerance
%  used in the reduction. Useful when the tolerance is computed
%  automatically.
%
%  See also: INTERPM, RESIZEM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  A. Kim, W. Stumpf
%  $Revision: 1.12.4.1 $ $Date: 2003/08/01 18:19:58 $


% if no epstol given as input, set initial value
corig = arclength(latin,lonin);
if nargin==2
	dd = corig/length(latin);
	epstol = dd/250;
end

% add wrap-around nans if necessary
if all(isnan([latin(1) lonin(1)]))
	nanadd1 = 0;
else
	latin = [nan; latin];
	lonin = [nan; lonin];
	nanadd1 = 1;
end
ntot = length(latin);
if all(isnan([latin(ntot) lonin(ntot)]))
	nanadd2 = 0;
else
	latin = [latin; nan];
	lonin = [lonin; nan];
	nanadd2 = 1;
end

nanindx = find(isnan(latin));
npatches = length(nanindx) - 1;

latout = nan;
lonout = nan;

% loop through each patch

for n=1:npatches

% extract points for this patch
	lt = latin(nanindx(n)+1:nanindx(n+1)-1);
	ln = lonin(nanindx(n)+1:nanindx(n+1)-1);
	npts = length(lt);

% might have solitary points in data.

	if npts <= 1

		latout = [latout; lt; nan];
		lonout = [lonout; ln; nan];


% check to see if self enclosed polygon
% determine start and finish idices and implement D-P function

	elseif all([lt(1) ln(1)]==[lt(npts) ln(npts)])

% divide polygon in half
		i = 1;
		j = floor(length(lt)/2);

% line simplification for one half of patch
		[ln1,lt1] = dpalg(ln,lt,1,j,epstol);

% line simplification for second half of patch
		[ln2,lt2] = dpalg(ln,lt,j,npts,epstol);

% combine patch halves if necessary
		ntmp = length(lt2);
		if ~(length(lt1)==2 & length(lt2)==2)
			ltp = [lt1; lt2(2:ntmp)];
			lnp = [ln1; ln2(2:ntmp)];
			latout = [latout; ltp; nan];
			lonout = [lonout; lnp; nan];
		end

	else

		i = 1;
		j = npts;

% line simplification for entire line
		lttmp = [lt(i:j); lt(i)];
		lntmp = [ln(i:j); ln(i)];
		[ln1,lt1] = dpalg(lntmp,lttmp,1,length(lttmp)-1,epstol);
		latout = [latout; lt1; nan];
		lonout = [lonout; ln1; nan];

	end

end

% calculate error based on arclength
cnew = arclength(latout,lonout);
if corig == 0;
    cerr = 0;
else
	cerr = abs(cnew-corig)/corig;
end

% remove wrap-around nans if added above
nnew = length(latout);
if nanadd1 & nanadd2
	latout = latout(2:nnew-1);
	lonout = lonout(2:nnew-1);
elseif nanadd1 & ~nanadd2
	latout = latout(2:nnew);
	lonout = lonout(2:nnew);
elseif ~nanadd1 & nanadd2
	latout = latout(1:nnew-1);
	lonout = lonout(1:nnew-1);
end


%************************************************************************
%************************************************************************
%************************************************************************


function [xout,yout] = dpalg(xin,yin,i,j,epstol,xstore,ystore)

%DPALG  Douglas-Peucker line simplification algorithm
%
%	Purpose
%		Reduces a polygon by the Douglas-Peucker line simplification
%		algorithm.
%
%	Synopsis
%
%		[xout,yout] = dpalg(xin,yin,i,j,epstol)

%  Written by:  A. Kim

epstol2 = epstol^2;

if nargin==5

	xstore = xin(i);
	ystore = yin(i);

% check for identical adjacent points and reduce
	ntot = length(xin);		% size of original data
	dxin = diff(xin);
	dyin = diff(yin);
	indx1 = find(dxin==0 & dyin==0);
	if ~isempty(indx1)
		indx = find(dxin~=0 | dyin~=0);
		xin = [xin(indx); xin(ntot)];
		yin = [yin(indx); yin(ntot)];
	end

% shift i and j accordingly
	i = i - length(find(indx1<i));
	j = j - length(find(indx1<j));

end

% calculate maximum distance
if (j-i)>1
	A = [1 xin(i) yin(i); 1 xin(j) yin(j)];
	dij2 = (xin(i)-xin(j))^2 + (yin(i)-yin(j))^2;
	for k=i+1:j-1
		A(3,:) = [1 xin(k) yin(k)];
		d2(k,1) = det(A)^2/dij2;
	end
	indx = find(d2==max(d2));
	dist2 = d2(indx(1));
	f = indx(1);
else
	dist2 = epstol2;
end

% recursive algorithm
if dist2>epstol2
	if (j-i)==2
		xstore = [xstore; xin(j-1); xin(j)];
		ystore = [ystore; yin(j-1); yin(j)];
	else
		[xstore,ystore] = dpalg(xin,yin,i,f,epstol,xstore,ystore);
		[xstore,ystore] = dpalg(xin,yin,f,j,epstol,xstore,ystore);
	end
else
	xstore = [xstore; xin(j)];
	ystore = [ystore; yin(j)];
end

xout = xstore;
yout = ystore;


%************************************************************************
%************************************************************************
%************************************************************************
function c = arclength(lat,lon)
%ARCLENGTH  Calculates arc length of polygons (separated by nans).
%
%	Purpose
%		Calculates sum of polygon arc lengths.
%		Polygons are separated by nans.
%
%	Synopsis
%
%		c = arclength(lat,lon)
%

%  Written by:  A. Kim

ntot = length(lat);
rng = distance('rh',lat(1:ntot-1),lon(1:ntot-1),...
					lat(2:ntot),lon(2:ntot),almanac('earth','geoid'));
indx = find(~isnan(rng));
c = sum(rng(indx));

