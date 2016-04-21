function [newlat,newlong]=rhxrh(lat1,long1,az1,lat2,long2,az2,units)

%RHXRH  Finds the intersection point between two rhumb lines
%
%  [lat,lon] = RHXRH(lat1,long1,az1,lat2,long2,az2) finds the
%  intersection point, if any, for every input pair of rhumb lines.
%  Inputs are in rhumb line notation, each line defined by the latitude
%  and longitude of a point on that line and the line's constant heading.
%  When two lines are identical (which is not generally obvious from the
%  input notation), or the lines do not intersect, NaN's are returned.
%  Since all rhumb lines with headings other than +/-90 degrees terminate
%  at both poles, the poles are not considered points of intersection.
%  Only spherical geoids are supported.
%
%  [lat,lon] = RHXRH(lat1,long1,az1,lat2,long2,az2,'units') uses the
%  input string units to define the angle units for the inputs and
%  outputs.
%
%  mat = RHXRH(...) returns a single output, where mat = [lat lon].
%
%  See also SCXSC, CROSSFIX, GCXSC, GCXGC, POLYXPOLY

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.11.4.1 $ $Date: 2003/08/01 18:20:02 $
%  Written by:  E. Brown, E. Byrns



if nargin < 6
    error('Incorrect number of arguments')
elseif nargin == 6
    units = 'degrees';
end

%  Input dimension tests

if any([ndims(lat1) ndims(long1) ndims(az1) ...
        ndims(lat2) ndims(long2) ndims(az2)] > 2)
     error('Input matrices can not contain pages')

elseif ~isequal(size(lat1),size(long1),size(az1),...
                size(lat2),size(long2),size(az2))
	     error('Inconsistent dimensions on inputs')
end

%  Convert input angle to radians

lat1  = angledim(lat1(:),units,'radians');
lat2  = angledim(lat2(:),units,'radians');
long1 = angledim(long1(:),units,'radians');
long2 = angledim(long2(:),units,'radians');
az1   = angledim(az1(:),units,'radians');
az2   = angledim(az2(:),units,'radians');

kindx = 1:length(lat1);


slope1=tan(pi/2-az1); slope1(abs(slope1) > 1E10) = inf;
slope2=tan(pi/2-az2); slope2(abs(slope2) > 1E10) = inf;
indx=find((abs(slope1-slope2)<epsm('radians'))|(isinf(slope1)&isinf(slope2)));

jndx1=find(isinf(slope1)&~isinf(slope2));
jndx2=find(isinf(slope2)&~isinf(slope1));

if ~isempty(indx)
	warning('Non intersecting or identical rhumb lines.')
    kindx(indx) = [];
end


%  Convert to mercator coordinates

[x1,y1]=merccalc(lat1,long1,'forward','radians');
[x2,y2]=merccalc(lat2,long2,'forward','radians');

%  Compute the intersections

xhat = zeros(size(lat1));    %  Initialize in case of no intersections
xhat(kindx)=((y2(kindx)-y1(kindx))-((slope2(kindx).*x2(kindx))- ...
              slope1(kindx).*x1(kindx)))./(slope1(kindx)-slope2(kindx));
yhat=slope1.*(xhat-x1)+y1;

% Account for cases where one slope was infinite

% first slope infinite:

if ~isempty(jndx1)
    xhat(jndx1)=x1(jndx1);
    yhat(jndx1)=slope2(jndx1).*(xhat(jndx1)-x2(jndx1))+y2(jndx1);
end

% or second slope infinite:

if ~isempty(jndx2)
    xhat(jndx2)=x2(jndx2);
    yhat(jndx2)=slope1(jndx2).*(xhat(jndx2)-x1(jndx2))+y1(jndx2);
end

%  Transform back to Greenwich coordinates

[newlat,newlong]=merccalc(xhat,yhat,'inverse','radians');

%  Place NaNs where the rhumb lines do not intersect
if ~isempty(indx)
	newlat(indx)  = NaN;
	newlong(indx) = NaN;
end

%  Transform the output to the proper units

newlat  = angledim(newlat,'radians',units);
newlong = npi2pi(newlong,'radians','exact');
newlong = angledim(newlong,'radians',units);

%  Set the output argument if necessary

if nargout < 2;  newlat = [newlat newlong];  end

