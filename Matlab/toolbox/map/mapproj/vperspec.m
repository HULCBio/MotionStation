function [out1,out2,savepts] = vperspec(mstruct,in1,in2,object,direction,savepts)

%VPERSPEC  Vertical Perspective Azimuthal Projection
%
%  This is a perspective projection on a plane tangent at the center point 
%  from a finite distance.  Scale is true only at the center point, and is 
%  constant in the circumferencial direction along any circle having the 
%  center point as its center.  Distortion increases rapidly away from the 
%  center point, the only place which is distortion free.  This projection is 
%  neither conformal nor equal area.
%  
%  This projection providing views of the globe resembling those seen from a 
%  spacecraft in orbit.  The standard parallel can be interpreted physically as 
%  the altitude of the observer above the surface in the same distance units 
%  as the geoid.  The orthographic projection is a limiting form with the 
%  observer at an infinite distance.
%  
%  This projection is available for the spherical geoid only.

% Sometimes need a framem reset?

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.1 $
%  Written by:  W. Stumpf


if nargin == 1                  %  Set the default structure entries

      mstruct.mapparallels = [6]; % radii 
      mstruct.nparallels   = 1;
	  mstruct.trimlat = angledim([-inf  89],'degrees',mstruct.angleunits);
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


% reset the frame limits (See also similar code in framem)

P = mstruct.mapparallels/geoid(1) + 1;

trimlat = [-inf  min( [ acos(1/P)-5*epsm('radians')  max(trimlat)  1.5533] ) ]; % 1.5533 rad = 89 degrees
mstruct.flatlimit = angledim(...
					trimlat,...
					'radians',mstruct.angleunits);

switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');   %  Convert to radians
     long = angledim(in2,units,'radians');
	 
	 olat = lat;olong = long;

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

	 maxrng = max(rng(:));
     [rng,az,trimmed] = trimdata(rng,[-inf  max(trimlat)],...
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


% adjust angular distance from the center

	kp = (P-1)./(P-cos(rng));
	 
% Compute angles of points away from the center of the projection
% as view from point a normalized distance P from the center of 
% the sphere.
	 
%  Perform the projection calculations


	 x = geoid(1) * kp .* sin(rng) .* sin(az);
	 y = geoid(1) * kp .* sin(rng) .* cos(az);

%  Apply scale factor, false easting, northing

	x = x*scalefactor+falseeasting;
	y = y*scalefactor+falsenorthing;

%  Set the output variables

     out1 = x;   out2 = y;

case 'inverse'

     x = in1;   y = in2;

%  Apply scale factor, false easting, northing

	x = (x-falseeasting )/(scalefactor);
	y = (y-falsenorthing)/(scalefactor);

%  Inverse projection

	rho = sqrt(x.^2 + y.^2);
	indx = find(rho==0);
	rho(indx) = NaN;
	
	c = asin((P-sqrt(1-rho.^2*(P+1)/((geoid(1))^2*(P-1)))) ./ ...
	 			(geoid(1)*(P-1)./rho + rho/(geoid(1)*(P-1))) );
	c(indx) = 0;
	
	kp = (P-1)./(P-cos(c));
	
	x = x./kp;
	y = y./kp;

%  Compute range and azimuth

     rng = asin(sqrt(x.^2 + y.^2) / geoid(1));
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


