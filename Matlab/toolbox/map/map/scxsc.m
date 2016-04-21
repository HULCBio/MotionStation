function [newlat,newlong]=scxsc(lat1,long1,range1,lat2,long2,range2,units)

%SCXSC  Calculates intersection points for pairs of small circles
%
%  [lat,lon] = SCXSC(lat1,long1,range1,lat2,long2,range2) finds the two
%  intersection points for every input pair of small circles.  SCXSC returns
%  NaNs where no intersection exists, or when both circles are identical.
%  Assumes spherical geoid and ranges in same angular unit.  Note that a
%  great circle is a small circle with radius of 90 degrees.  Only
%  spherical geoids are supported.
%
%  [lat,lon] = SCXSC(lat1,long1,range1,lat2,long2,range2,'units') uses the
%  input string units to define the angle units for the inputs and
%  outputs.
%
%  mat = SCXSC(...) returns a single output, where mat = [lat lon].
%
%  See also GCXGC, CROSSFIX, GCXSC, RHXRH, POLYXPOLY

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:20:07 $

if nargin < 6
    error('Incorrect number of arguments')
elseif nargin == 6
    units = 'degrees';
end

%  Input dimension tests

if any([ndims(lat1) ndims(long1) ndims(range1) ...
        ndims(lat2) ndims(long2) ndims(range2)] > 2)
     error('Input matrices can not contain pages')

elseif ~isequal(size(lat1),size(long1),size(range1),...
                size(lat2),size(long2),size(range2))
	     error('Inconsistent dimensions on inputs')
end

%  Convert input angle to radians and make all column vectors

lat1   = angledim(lat1(:),units,'radians');
lat2   = angledim(lat2(:),units,'radians');
long1  = angledim(long1(:),units,'radians');
long2  = angledim(long2(:),units,'radians');
range1 = angledim(range1(:),units,'radians');
range2 = angledim(range2(:),units,'radians');

jndx1=find(range1>pi/2);
jndx2=find(range2>pi/2);

[lat1(jndx1),long1(jndx1)]=antipode(lat1(jndx1),long1(jndx1),'radians');
[lat2(jndx2),long2(jndx2)]=antipode(lat2(jndx2),long2(jndx2),'radians');

range1(jndx1)=pi-range1(jndx1);
range2(jndx2)=pi-range2(jndx2);

epsilon = epsm('radians');

range3=distance('gc',lat1,long1,lat2,long2,'radians');
indx1=find(range3-range1-range2>epsilon); % Case where circle too far apart to intersect
indx2=find(range2-range1-range3>epsilon); % Case where one circle completely inside the other
indx3=find(range1-range3-range2>epsilon); % Case where one circle completely inside the other
indx=[indx1(:);indx2(:);indx3(:)];
if ~isempty(indx);   warning('Failure to intersect.');   end



% Case where circles identical
indx4=find(((abs(lat1-lat2)<epsilon)&(abs(long1-long2)<epsilon)&(abs(range1-range2)<epsilon))|...  % same range and center, or...
			(((abs(range1-range2)<epsilon)&(abs(range1-pi/2)<epsilon))&... 				% great circles with centers which are
			((((abs(lat1+lat2)<epsilon)&(abs(npi2pi(long1,'radians')-npi2pi(long2+pi,'radians'))<epsilon)))|... 	% antipodes or..
			((abs(abs(lat1)-pi/2)<epsilon) & (abs(abs(lat2)-pi/2)<epsilon)))));		% the longitudinally ambiguous antipodes, the poles

if ~isempty(indx4);   warning('Non-unique intersection.');  end
indx=[indx;indx4(:)];

%Case where great circles identically the equator (center points longitude ambiguity because at poles)

az1 = azimuth('gc',lat1,long1,lat2,long2,'radians');
az2 = azimuth('gc',lat2,long2,lat1,long1,'radians');

temp1=cos(range3)-cos(range1).*cos(range2);
temp2=sin(range2).*sin(range1);

apex=acos(temp1./temp2);

projaz1 = zeros(size(apex));    projaz2 = zeros(size(apex));
kndx1=1:length(apex);        %  Index only valid intersections to
kndx1(indx)=[];              %  avoid a divide by zero below

projaz1(kndx1)=asin(sin(apex(kndx1)).*sin(range2(kndx1))./sin(range3(kndx1)));
projaz2(kndx1)=asin(sin(apex(kndx1)).*sin(range1(kndx1))./sin(range3(kndx1)));


[newlat1,newlong1]=reckon('gc',lat1,long1,range1,(az1-projaz1),'radians');
[newlat2,newlong2]=reckon('gc',lat1,long1,range1,(az1+projaz1),'radians');

d = distance('gc',newlat1(kndx1),newlong1(kndx1),lat2(kndx1),long2(kndx1),'radians');
kndx=find(abs(d-range2(kndx1))>epsilon);
kndx=kndx(:);

if ~isempty(kndx)
	[newlat1(kndx),newlong1(kndx)]=reckon('gc',lat2(kndx),long2(kndx),range2(kndx),(az2(kndx)-projaz2(kndx)),'radians');
	[newlat2(kndx),newlong2(kndx)]=reckon('gc',lat2(kndx),long2(kndx),range2(kndx),(az2(kndx)+projaz2(kndx)),'radians');
end


newlat1(indx)  = NaN;      newlat2(indx)  = NaN;
newlong1(indx) = NaN;      newlong2(indx) = NaN;

newlat=[newlat1(:) newlat2(:)];
newlong=[newlong1(:) newlong2(:)];

%  Convert the outputs to the desired units

newlat  = angledim(newlat,'radians',units);
newlong = npi2pi(newlong,'radians','exact');
newlong = angledim(newlong,'radians',units);

%  Set the output argument if necessary

if nargout < 2;  newlat = [newlat newlong];  end
