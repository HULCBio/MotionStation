function [out1,out2,savepts] = wiechel(mstruct,in1,in2,object,direction,savepts)

%WIECHEL  Wiechel Pseudoazimuthal Projection
%
%  This equal area projection is a novelty map, usually centered at
%  a pole, showing semicircular meridians in a pinwheel arrangement.
%  Scale is correct along the meridians.  This projection is not
%  conformal.
%
%  This projection was presented by H. Wiechel in 1879.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([-inf  65],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  out1 = mstruct;      return
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

%  Calculate the azimuths and distances on the rotated sphere

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

	 x = 2*geoid(1) * sin(rng/2) .* sin(az + rng/2);
	 y = 2*geoid(1) * sin(rng/2) .* cos(az + rng/2);

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

     rng = 2*asin(sqrt(x.^2 + y.^2) / (2*geoid(1)) );
     az  = atan2(x,y) - rng/2;

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


