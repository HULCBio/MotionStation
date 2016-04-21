function [out1,out2,savepts] = loximuth(mstruct,in1,in2,object,direction,savepts)

%LOXIMUTH  Loximuthal Pseudocylindrical Projection
%
%  This projection has the special property that from the central point
%  (the intersection of the central latitude with the central meridian, or
%  map origin), rhumb lines (or loxodromes) are shown as straight, true
%  to scale, and correct in azimuth from the center.  This differs from
%  the Mercator projection, in that rhumb lines are here shown in true
%  scale, and that unlike the Mercator projection, this projection does
%  not maintain true azimuth for all points along rhumb lines.  Scale is
%  true along the central meridian, and is constant along any parallel, but
%  not, generally, between parallels.  It is free of distortion only at
%  the central point, and can be severely distorted in places.  However,
%  this projection is designed for its special property, in which
%  distortion is not a concern.
%
%  This projection was presented by Karl Siemon in 1935, and independently
%  by Waldo R. Tobler in 1966.  The Bordone Oval projection of 1520 was
%  very similar to the Equator-centered Loximuthal.
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = 0;
      mstruct.nparallels   = 1;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end


units  = mstruct.angleunits;
aspect = mstruct.aspect;
geoid   = mstruct.geoid;
parallels = angledim(mstruct.mapparallels,units,'radians');
origin    = angledim(mstruct.origin,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
epsilon   = epsm('radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Eliminate singularity with a parallel at -90 degrees

if (parallels(1) + pi/2) <= epsilon;   parallels(1) = -pi/2+epsilon;   end


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

%  Back off the lat == parallel(1) points.  This allows the straightforward
%  application of the transformation equations below.

     indx = find(abs(parallels(1) - lat) <= epsilon);
     if ~isempty(indx);   lat(indx) = parallels(1)+epsilon;   end

%  Projection transformation

     factor1 = log(tan(pi/4 + lat/2) / tan(pi/4 + parallels(1)/2));
	 x = geoid(1) * long .* (lat - parallels(1)) ./ factor1;
	 y = geoid(1) * (lat - parallels(1));

%  Apply scale factor, false easting, northing

	x = x*scalefactor+falseeasting;
	y = y*scalefactor+falsenorthing;

%  Set the output variables

     switch  aspect
	    case 'normal',         out1 = x;      out2 = y;
	    case 'transverse',	   out1 = y;      out2 = -x;
        otherwise,             error('Unrecognized aspect string')
     end


case 'inverse'

     switch  aspect
	    case 'normal',         x = in1;    y = in2;
	    case 'transverse',	   x = -in2;   y = in1;
        otherwise,             error('Unrecognized aspect string')
     end

%  Apply scale factor, false easting, northing

	x = (x-falseeasting)/scalefactor;
	y = (y-falsenorthing)/scalefactor;

% Inverse projection

     lat = y/geoid(1) + parallels(1);
     indx = find(abs(parallels(1) - lat) <= epsilon);
     if ~isempty(indx);   lat(indx) = parallels(1)+epsilon;   end

     factor1 = log(tan(pi/4 + lat/2) / tan(pi/4 + parallels(1)/2));
     factor2 = lat - parallels(1);
	 long = x .* factor1 ./ (geoid(1) * factor2);

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);

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


