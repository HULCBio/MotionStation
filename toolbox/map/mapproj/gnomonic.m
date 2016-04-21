function [out1,out2,savepts] = gnomonic(mstruct,in1,in2,object,direction,savepts)

%GNOMONIC  Gnomonic Azimuthal Projection
%
%  This is a perspective projection from the center of the globe on
%  a plane tangent at the center point, which is a pole in the common
%  polar aspect, but can be any point.  Less than one hemisphere
%  can be shown with this projection, regardless of its center
%  point.  The significant property of this projection is that all
%  great circles are straight lines.  This is useful in navigation,
%  as a great circle is the shortest path between two points on
%  the globe.  Only the center point enjoys true scale and zero
%  distortion.  This projection is neither conformal nor equal
%  area.
%
%  This projection may have been first developed by Thales around
%  580 B.C.  Its name is derived from the gnomon, the face of a
%  sundial, since the meridians radiate like hour markings.  This
%  projection is also known as a Gnomic or Central Projection.
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.trimlat = angledim([-inf  65],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.fixedorient  = [];
	  out1 = mstruct;     return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
geoid   = mstruct.geoid;
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;


switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');   %  Convert to radians
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

%  Calculate the azimuths and distances on the rotated sphere

     [lat,long] = rotatem(lat,long,origin,direction);

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

	 x = geoid(1) * tan(rng) .* sin(az);
	 y = geoid(1) * tan(rng) .* cos(az);

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

% Inverse projection: Compute range and azimuth

     rng = atan(sqrt(x.^2 + y.^2) / geoid(1));
     az  = atan2(x,y);

%  Reckon back to lat, long points

     zeromat = zeros(size(rng));
     [lat,long] = reckon(zeromat,zeromat,rng,az,'radians');

%  Undo trims

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);

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


