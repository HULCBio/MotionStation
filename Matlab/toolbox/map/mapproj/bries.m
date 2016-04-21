function [out1,out2,savepts] = bries(mstruct,in1,in2,object,direction,savepts)

%BRIES  Briesemeister's Projection
%
% This equal-area projection groups the continents about the center of the   
% frame. The only point free of distortion is the center point.  Distortion 
% of shape and scale are moderate throughout.
% 
% This projection was presented by William Briesemeister in 1953.  It is 
% an oblique Hammer projection with an axis ratio of 1.75 to 1, instead of 
% 2 to 1.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf, E. Byrns, E. Brown
%   $Revision: 1.6.4.1 $    $Date: 2003/08/01 18:21:39 $

if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
      mstruct.origin = angledim([45 10 0],'degrees',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

% The forward and inverse formulas are not consistent for elliptical geoid.
% Until the difference can be resolved, HAMMER and BRIES will ignore the
% elliptical component of the geoid vector.

mstruct.geoid(2) = 0;

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
aspect = mstruct.aspect;
geoid   = mstruct.geoid;
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
%  the poles. (Carried over from the azimuthal projection)

epsilon = deg2rad(0.01);


%  Another Projection parameter (which needs the authalic origin)
a       = mstruct.geoid(1);
e       = mstruct.geoid(2);
radius  = rsphere('authalic',mstruct.geoid);
m1 = cos(origin(1))/sqrt(1-(e*sin(origin(1)))^2);
D = a * m1 / (radius * cos(origin(1)));

%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2aut(origin(1),mstruct.geoid,'radians');
trimlat   = geod2aut(trimlat  ,mstruct.geoid,'radians');

switch direction
case 'forward'
     lat  = angledim(in1,units,'radians');
     lat  = geod2aut(lat,mstruct.geoid,'radians');
     long = angledim(in2,units,'radians');

     [lat,long] = rotatem(lat,long,origin,direction);   %  Rotate to new origin
     [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
     [lat,long,trimmed] = trimdata(lat,trimlat,long,trimlon,object);

%  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = clipped;

%  Back off of the +/- 90 degree points.  This allows
%  the differentiation of longitudes at the poles of the transformed
%  coordinate system.

     epsilon = epsm('radians');
     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
     end 

%  Perform the projection calculations

	w = 0.5;
	d = 2./(1 + cos(lat) .* cos(w*long));
	d = reshape(d,size(lat));
	
	 x = radius * sqrt(1.75/2) * sqrt(d)/w .* cos(lat) .* sin(w*long);
	 y = radius * 1/sqrt(1.75/2) * sqrt(d) .* sin(lat);

%  Apply scale factor, false easting, northing

	x = x*scalefactor+falseeasting;
	y = y*scalefactor+falsenorthing;
	 
%  Set the output variables

     switch  aspect
	    case 'normal',         out1 = real(x);      out2 = real(y);
	    case 'transverse',	   out1 = real(y);      out2 = real(-x);
        otherwise,             error('Unrecognized aspect string')
     end

case 'inverse'


     switch  aspect
	    case 'normal',         x = in1;       y = in2;
	    case 'transverse',	   x = -in2;      y = in1;
        otherwise,             error('Unrecognized aspect string')
     end

%  Apply scale factor, false easting, northing

	x = (x-falseeasting )/(scalefactor);
	y = (y-falsenorthing)/(scalefactor);

%  Inverse projection

     x = x/2/sqrt(1.75/2);
	 y = y*sqrt(1.75/2);
	 
	  rho = sqrt((x/D).^2 + (D*y).^2);

     indx = find(rho ~= 0);

     lat = x;    long = y;   %  Note where x,y = 0, so does lat,long

	 if ~isempty(indx)
          ce  = 2*asin(rho(indx)/(2*radius));
	      lat(indx)  = asin(D*y(indx).*sin(ce)./rho(indx));
	      long(indx) = atan2(x(indx).*sin(ce), D*rho(indx).*cos(ce));
     end
	 long = 2*long;

%  Reset the +/- 90 degree points.

     indx = find(abs(pi/2 - abs(lat)) <= 1.02*epsilon);
     if ~isempty(indx)
	    lat(indx) = sign(lat(indx))*pi/2;
     end
 
%  Undo trims

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

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



 

