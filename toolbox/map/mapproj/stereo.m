function [out1,out2,savepts] = stereo(mstruct,in1,in2,object,direction,savepts)

%STEREO  Stereographic Azimuthal Projection
%
%  This is a perspective projection on a plane tangent at the center
%  point from the point antipodal to the center point.  The center
%  point is a pole in the common polar aspect, but it can be any
%  point.  This projection has two significant properties.  It is
%  conformal, being free from angular distortion.  Additionally, all
%  great and small circles are either straight lines or circular
%  arcs on this projection.  Scale is true only at the center point,
%  and is constant along any circle having the center point as its
%  center.  This projection is not equal area.
%
%  The polar aspect of this projection appears to have been developed
%  by the Egyptians and Greeks by the second century B.C.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([-inf  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  out1 = mstruct;     return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
a       = mstruct.geoid(1);
e       = mstruct.geoid(2);
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Compute projection parameters

epsilon = epsm('radians');
latcnf = geod2cnf(origin(1),mstruct.geoid,'radians');
a = mstruct.geoid(1);    e = mstruct.geoid(2);

den1  = (1 - (e*sin(origin(1)))^2);
m1    = cos(origin(1)) / sqrt(den1);
if abs(pi/2 - abs(origin(1))) <= epsilon
    fact1 = 2*a/sqrt(den1);
else
    fact1 = 2*a*m1 / cos(latcnf);
end

%  Adjust the origin latitude to the auxiliary sphere

origin(1)  = latcnf;
trimlat = geod2cnf(trimlat,mstruct.geoid,'radians');


switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');   %  Convert to radians
     lat  = geod2cnf(lat,mstruct.geoid,'radians');
     long = angledim(in2,units,'radians');

%  Back off of the +/- 180 degree points.  This allows
%  the differentiation of longitudes at the dateline in
%  the inverse calculation.  For example, if not performed, -180 degree
%  points may become 180 degrees in the inverse calculation.

     epsilon = 5*epsm('radians');
     indx = find( abs(pi - abs(long)) <= epsilon);

     if ~isempty(indx)
	      long(indx) = long(indx) - sign(long(indx))*epsilon;
     end

%  Calculate the azimuths and distances on the rotated auxiliary sphere

     [lat,long] = rotatem(lat,long,origin,direction);   %  Rotate to new origin

	 zeromat = zeros(size(lat));
     az  = azimuth('gc',zeromat,zeromat,lat,long,'radians');
     rng = distance('gc',zeromat,zeromat,lat,long,'radians');

%  Trim data exceeding a specified range from the origin

     [rng,az,trimmed] = trimdata(rng,[-inf max(trimlat)],...
	                              az,[-inf inf],object);
     if size(trimmed,2) == 3
	     indx = trimmed(:,1);
         trimmed(:,[2:3]) = [lat(indx) long(indx)];
	 elseif size(trimmed,2) == 4
	     indx = trimmed(:,1) + (trimmed(:,2) - 1) * size(lat,1);
         trimmed(:,[3:4]) = [lat(indx) long(indx)];
	 end

%  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = [];

%  Perform the projection calculations

	 A = fact1 ./ ( 1 + cos(rng) );

	 x = A .* sin(rng) .* sin(az);
	 y = A .* sin(rng) .* cos(az);

%  Apply scale factor, false easting, northing

	x = x*scalefactor+falseeasting;
	y = y*scalefactor+falsenorthing;

%  Set the output variables

     out1 = x;   out2 = y;

case 'inverse'

     x = in1;   y = in2;

%  Apply scale factor, false easting, northing

	x = (x-falseeasting)/scalefactor;
	y = (y-falsenorthing)/scalefactor;

% Inverse projection

     rho = (x.^2 + y.^2) / fact1^2;

     indx1 = find(rho == 0);
     indx2 = find(rho ~= 0);

     lat = x;    long = y;

	 if ~isempty(indx1);   lat(indx1)  = 0;    long(indx1) = 0;   end

	 if ~isempty(indx2)
	     az = atan2(x(indx2),y(indx2));
		 rng = acos( (1-rho(indx2)) ./ (1+rho(indx2)));

	     zeromat = zeros(size(lat(indx2)));
         [lat(indx2),long(indx2)] = reckon(zeromat,zeromat,rng,az,'radians');
     end

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);
     lat        = cnf2geod(lat,mstruct.geoid,'radians');

     out1 = angledim(lat, 'radians', units);   %  Transform units
     out2 = angledim(long,'radians', units);

otherwise
     error('Unrecognized direction string')
end

%  Some operations on NaNs produce NaN + NaNi.  However operations
%  outside the map may product complex results and we don't want
%  to destroy this indicator.

indx = find(isnan(out1) | isnan(out2));
out1(indx) = NaN;   out2(indx) = NaN;


