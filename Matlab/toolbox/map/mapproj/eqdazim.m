function [out1,out2,savepts] = eqdazim(mstruct,in1,in2,object,direction,savepts)

%EQDAZIM  Equidistant Azimuthal Projection
%
%  This is an equidistant projection.  It is neither equal-area nor conformal.
%  In the polar aspect, scale is true along any meridian.  The projection is
%  distortion free only at the center point.  Distortion is moderate for the
%  inner hemisphere, but it becomes extreme in the outer hemisphere.
%
%  This projection may have been first used by the ancient Egyptians for star
%  charts.  Several cartographers used it during the sixteenth century,
%  including Guillaume Postel, who used it in 1581.  Other names for this
%  projections include Postel and Zenithal Equidistant.
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:21:54 $

if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([-inf  160],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  out1 = mstruct;
      return
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
geoid   = mstruct.geoid;
geoid   = [geoid(1)  0];    %  Need elliptical reckoning to complete inverse
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  This projection is highly sensitive around poles and the date
%  line.  The azimuth calculation in the inverse direction will
%  transform -180 deg longitude into 180 deg longitude if an
%  insufficient epsilon is supplied.  Trial and error yielded
%  an epsilon of 0.01 degrees to back-off from the date line and
%  the poles.

epsilon = deg2rad(0.01);


switch direction
case 'forward'

     lat       = angledim(in1,units,'radians');
     long      = angledim(in2,units,'radians');

%  Back off edge points.  This must be done before the
%  azimuth and distance calculations, since azimuth is
%  sensitive to points near the poles and dateline.

%  Back off of the +/- 180 degree points.  This allows
%  the differentiation of longitudes at the dateline in
%  the inverse calculation.  For example, if not performed, -180 degree
%  points may become 180 degrees in the inverse calculation.

     indx = find( abs(pi - abs(long)) <= epsilon);
     if ~isempty(indx)
	      long(indx) = long(indx) - sign(long(indx))*epsilon;
     end

%  Back off of the +/- 90 degree points.  This allows
%  the differentiation of longitudes at the poles of the transformed
%  coordinate system.

     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
     end

%  Calculate the azimuths and distances on the rotated sphere

	 lat0 = origin(1);   lat0 = lat0(ones(size(lat)));
	 lon0 = origin(2);   lon0 = lon0(ones(size(lat)));

     rng = distance('gc',lat0,lon0,lat,long,geoid,'radians');

     if abs(pi/2 - abs(origin(1))) <= epsilon
          az = -sign(origin(1))*(long + pi - origin(2));
	 else
	      az  = azimuth('gc',lat0,lon0,lat,long,geoid,'radians');
	      az  = az + origin(3);    %  Adjust the azimuths for the orientation
	 end

%  Trim data exceeding a specified range from the origin

	 [rng,az,trimmed] = trimdata(rng,[-inf max(trimlat*geoid(1))],...
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

	 x = rng .* sin(az);     y = rng .* cos(az);

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

% Inverse projection: Compute the range and azimuth and reckon the points

     if abs(pi/2 - abs(origin(1))) <= epsilon
	      lat0 = origin(1);   lat0 = lat0(ones(size(x)));
          lon0 = -sign(origin(1))*atan2(x,y) - pi + origin(2);

		  az = pi;   az = az(ones(size(x)));
		  rng  = sqrt( x.^2 + y.^2);

 	 else
          rng = sqrt( x.^2 + y.^2);
	      az  = atan2(x,y) - origin(3);

	      lat0 = origin(1);   lat0 = lat0(ones(size(x)));
	      lon0 = origin(2);   lon0 = lon0(ones(size(x)));
	 end

	 [lat,long] = reckon('gc',lat0,lon0,rng,az,geoid,'radians');

%  Undo trims.  This is done before the reseting of edge points
%  because the backing-off of edge points is done before
%  the trim operation in the forward direction.

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);

%  Reset the +/- 180 degree points.  Account for round-off
%  by expanding epsilon to 1.02*epsilon

     indx = find( abs(pi - abs(long)) <= 1.02*epsilon);
     if ~isempty(indx)
	      long(indx) = sign(long(indx))*pi;
     end

%  Reset the +/- 90 degree points.

     indx = find(abs(pi/2 - abs(lat)) <= 1.02*epsilon);
     if ~isempty(indx)
	    lat(indx) = sign(lat(indx))*pi/2;
     end

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




