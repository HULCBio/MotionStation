function [out1,out2,savepts] = aitoff(mstruct,in1,in2,object,direction,savepts)

%AITOFF Aitoff Projection
%
% This is a modified azimuthal projection.  The world is displayed as an 
% ellipse, with curved parallels and meridians.  It is neither conformal nor 
% equal area.  The only point free of distortion is the center point.  
% Distortion of shape and area are moderate throughout.
% 
% This projection was created by David Aitoff in 1889.  It is a modification 
% of the azimuthal equidistant projection.  The Aitoff projection inspired 
% the similar Hammer projection, which is equal area.
% 
% This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf

if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(4044,'dms',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
aspect = mstruct.aspect;
geoid   = mstruct.geoid;
geoid   = [geoid(1)  0];    %  Need elliptical reckoning to complete inverse
radius  =  geoid(1);
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

epsilon = deg2rad(0.01);

switch direction
case 'forward'
     lat  = angledim(in1,units,'radians');
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

     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
     end 
 
%  Perform the projection calculations

	d = acos(cos(lat) .* cos(long/2));

	zeroindx = find(d==0);   % to avoid divide by zeros
	d(zeroindx) = pi/2;      % correct the x and y coordinates below
	
	c = sin(lat) ./ sin(d);
	

	 x = radius * 2 * d .* sqrt(1 - c .* c) .* sign(long);     
	 y = radius * d .* c;
	 
	 x(zeroindx) = 0;
	 y(zeroindx) = 0;
	 
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


%  Inverse projection: Compute the range and azimuth and 
%  reckon the points
	
	x = x/2;
	rng = sqrt( x.^2 + y.^2);
	az  = atan2(x,y);
	
	lat0 = 0;   lat0 = lat0(ones(size(x)));
	lon0 = 0;   lon0 = lon0(ones(size(x)));
	 [lat,long] = reckon('gc',lat0,lon0,rng,az,geoid,'radians');

	long = 2*long;
	
%  Reset the +/- 90 degree points.  Account for trig round-off
%  by expanding epsilon to 1.01*epsilon


     indx = find(abs(pi/2 - abs(lat)) <= 1.01*epsilon);
     if ~isempty(indx)
	    lat(indx) = pi/2 * sign(lat(indx));
     end

%  Undo clips and trims.  

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

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

