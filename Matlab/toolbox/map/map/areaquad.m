function a=areaquad(lat1,lon1,lat2,lon2,in5,in6)

%AREAQUAD Area of a latitude-longitude quadrangle.
%
%   a = AREAQUAD(lat1,lon1,lat2,lon2) calculates the spherical surface
%   area of the quadrangle specified by the input vectors.  The points
%   specified by lat1/lon1 are assumed to be the corner of the quadrangle
%   opposite the points specified by lat2/lon2.  A spherical quadrangle
%   is defined by the intersection of a lune and a zone. The output, a,
%   is the surface area fraction of the unit sphere.
%
%   a = AREAQUAD(lat1,lon1,lat2,lon2,ELLIPSOID) uses the input ELLIPSOID to
%   describe the sphere or ellipsoid.  The output, a, is in square units
%   corresponding to the units of ELLIPSOID(1).
%
%   a = AREAQUAD(lat1,lon1,lat2,lon2,'units') uses the units defined by the
%   input string 'units'.  If omitted, default units of degrees
%   is assumed.
%
%   a = AREAQUAD(lat1,lon1,lat2,lon2,ELLIPSOID,'units') uses both the
%   inputs ELLIPSOID and 'units' in the calculation.
%
%  See also AREAINT, AREAMAT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.2 $  $Date: 2003/12/13 02:50:08 $

checknargin(4,6,nargin,mfilename);

if nargin==4
	units = [];
    ellipsoid = [];
elseif nargin==5
	if ischar(in5)
		units = in5;
        ellipsoid = [];
	else
		units = [];
        ellipsoid = in5;
	end
elseif nargin==6
	ellipsoid=in5;
    units=in6;
end

%  Empty argument tests

if isempty(units)
    units  = 'degrees';
end

absolute_units = 1;          %  Report answer in absolute units assuming
if isempty(ellipsoid)        %  a radius input has been supplied.  Otherwise,
     ellipsoid = [1 0];      %  report surface area answer as a fraction
	 absolute_units = 0;     %  of a sphere
end

%  Test the ellipsoid parameter
ellipsoid = checkellipsoid(ellipsoid,mfilename,'ELLIPSOID',5);

%  Input dimension tests
checkinput(lat1,{'double'},{'real'},mfilename,'LAT1',1);
checkinput(lon1,{'double'},{'real'},mfilename,'LON1',2);
checkinput(lat2,{'double'},{'real'},mfilename,'LAT2',3);
checkinput(lon2,{'double'},{'real'},mfilename,'LON2',4);

if ~isequal(size(lat1),size(lon1),size(lat2),size(lon2))
    eid = sprintf('%s:%s:latlonSizeMismatch',getcomp,mfilename);
    error(eid, '%s', 'Latitude and longitude inputs must all match in size.');
end

%  Convert angles to radians and transform to the authalic sphere

lat1=angledim(lat1,units,'radians');
lat2=angledim(lat2,units,'radians');
lon1=angledim(lon1,units,'radians');
lon2=angledim(lon2,units,'radians');

lat1 = geod2aut(lat1,ellipsoid,'radians');
lat2 = geod2aut(lat2,ellipsoid,'radians');
radius = rsphere('authalic',ellipsoid);

%  Compute the surface area as a fraction of a sphere

a = abs(lon1-lon2) .* abs(sin(lat1)-sin(lat2)) / (4*pi);

%  Convert to absolute terms if the default radius was not used

if absolute_units;
    a = a * 4*pi*radius^2;
end
