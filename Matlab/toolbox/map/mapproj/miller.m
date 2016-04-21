function [out1,out2,savepts] = miller(mstruct,in1,in2,object,direction,savepts)

%MILLER  Miller Cylindrical Projection
%
%  This is a projection with parallel spacing calculated to maintain
%  a look similar to the Mercator projection while reducing the distortion
%  near the poles, thus allowing the poles to be displayed.  It is not
%  equal area, equidistant, conformal or perspective.  Scale is true
%  along the Equator and constant between two parallels equidistant
%  from the Equator.  There is no distortion near the Equator, and it
%  increases moderately away from the Equator, but becomes severe at
%  the poles.
%
%  The Miller Cylindrical projection is derived from the Mercator
%  projection;  parallels are spaced from the Equator by calculating
%  the distance on the Mercator for a parallel at 80% of the true
%  latitude and dividing the result by 0.8.  The result is that the
%  two projections are almost identical near the Equator.
%
%  This projection was presented by Osborn Maitland Miller of the
%  American Geographical Society in 1942.  It is often used in place
%  of the Mercator projection for atlas maps of the world, for which
%  it is somewhat more appropriate.
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
geoid   = mstruct.geoid;
aspect  = mstruct.aspect;
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;


switch direction
case 'forward'

     lat       = angledim(in1,units,'radians');
     long      = angledim(in2,units,'radians');

     [lat,long] = rotatem(lat,long,origin,direction);   %  Rotate to new origin
     [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
     [lat,long,trimmed] = trimdata(lat,trimlat,long,trimlon,object);

%  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = clipped;

%  Projection transformation

	 x = geoid(1) * long;
     y = geoid(1) * asinh(tan(0.8*lat)) / 0.8;

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

     lat  = atan(sinh(0.8*y/geoid(1))) / 0.8;
	 long = x / geoid(1);

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


