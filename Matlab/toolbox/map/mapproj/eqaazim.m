function [out1,out2,savepts] = eqaazim(mstruct,in1,in2,object,direction,savepts)

%EQAAZIM  Lambert Equal Area Azimuthal Projection
%
%  This non-perspective projection is equal area.  Only the center
%  point is free of distortion, but distortion is moderate within
%  90 degrees of this point.  Scale is true only at the center point,
%  increasing tangentially and decreasing radially with distance from
%  the center point.  This projection is neither conformal nor
%  equidistant.
%
%  This projection was presented by Johann Heinrich Lambert in 1772.
%  It is also know as the Zenithal Equal Area and the Zenithal
%  Equivalent projections, and the Lorgna projection in its polar aspect.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.trimlat = angledim([-inf 160],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.fixedorient  = [];
	  out1 = mstruct;     return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
a       = mstruct.geoid(1);
e       = mstruct.geoid(2);
radius  = rsphere('authalic',mstruct.geoid);
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Eliminate singularities in transformations at ± 90 origin.

epsilon = epsm('radians');
if abs(abs(origin(1)) - pi/2) <= epsilon
      origin(1) = sign(origin(1))*(pi/2 - epsilon);
end

%  Compute projection parameters

if e == 0;     qp = 2;
    else;      qp = 1 - (1-e^2)/(2*e) * log((1-e)/(1+e));
end
m1 = cos(origin(1))/sqrt(1-(e*sin(origin(1)))^2);

%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2aut(origin(1),mstruct.geoid,'radians');
trimlat   = geod2aut(trimlat  ,mstruct.geoid,'radians');

%  Another Projection parameter (which needs the authalic origin)

D = a * m1 / (radius * cos(origin(1)));


switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');
     lat  = geod2aut(lat,mstruct.geoid,'radians');
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

%  Calculate distances on the rotated sphere

     [lat,long] = rotatem(lat,long,origin,direction);

	 zeromat = zeros(size(lat));
     rng = distance('gc',zeromat,zeromat,lat,long,'radians');

%  Trim data exceeding a specified range from the origin

     [rng,junk,trimmed] = trimdata(rng,[-inf max(trimlat)],...
	                               zeromat,[-inf inf],object);
     if size(trimmed,2) == 3
	     indx = trimmed(:,1);
         trimmed(:,[2:3]) = [lat(indx) long(indx)];
         lat(indx) = NaN;    long(indx) = NaN;
	 elseif size(trimmed,2) == 4
	     indx = trimmed(:,1) + (trimmed(:,2) - 1) * size(lat,1);
         trimmed(:,[3:4]) = [lat(indx) long(indx)];
         lat(indx) = NaN;    long(indx) = NaN;
	 end

%  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = [];

%  Projection Transformation

     B = radius * sqrt(2 ./ (1 + cos(lat) .* cos(long)));
	 x = B *D .* cos(lat) .* sin(long);
	 y = (B/D) .* sin(lat);

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

     rho = sqrt((x/D).^2 + (D*y).^2);

     indx = find(rho ~= 0);

     lat = x;    long = y;   %  Note where x,y = 0, so does lat,long

	 if ~isempty(indx)
          ce  = 2*asin(rho(indx)/(2*radius));
	      lat(indx)  = asin(D*y(indx).*sin(ce)./rho(indx));
	      long(indx) = atan2(x(indx).*sin(ce), D*rho(indx).*cos(ce));
      end

%  Undo trims

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);
     lat        = aut2geod(lat,mstruct.geoid,'radians');

     out1 = angledim(lat, 'radians', units);
     out2 = angledim(long,'radians', units);

otherwise
     error('Unrecognized direction string')
end

%  Some operations on NaNs produce NaN + NaNi.  However operations
%  outside the map may product complex results and we don't want
%  to destroy this indicator.

indx = find(isnan(out1) | isnan(out2));
out1(indx) = NaN;   out2(indx) = NaN;


