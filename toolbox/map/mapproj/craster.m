function [out1,out2,savepts] = craster(mstruct,in1,in2,object,direction,savepts)

%CRASTER  Craster Parabolic Pseudocylindrical Projection
%
%  This is an equal area projection.  Scale is true along the 36 deg,
%  46 min parallels, and is constant along any parallel, and between
%  any pair of parallels equidistant from the equator.  Distortion
%  is severe near the outer meridians at high latitudes, but less
%  so than the Sinusoidal projection.  It is free of distortion only at
%  the two points where the central meridian intersects the 36 deg,
%  46 min parallels.  This projection is not conformal or equidistant.
%
%  This projection was developed by John Evelyn Edmund Craster in 1929;
%  it was further developed by Charles H. Deetz and O. S. Adams in 1934.
%  It was presented independently in 1934 by Putnins as his P4 projection.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(3646,'dms',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end


units  = mstruct.angleunits;
aspect = mstruct.aspect;
radius = rsphere('authalic',mstruct.geoid);
origin = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

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

%  Projection transformation

     x = sqrt(3) * radius * long .* (2*cos(2*lat/3) - 1) / sqrt(pi);
	 y = sqrt(3*pi) * radius * sin(lat/3);

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

     lat = 3 * asin(y / (sqrt(3*pi)*radius));
	 long = sqrt(pi) * x ./ (sqrt(3) * radius * (2*cos(2*lat/3) - 1) );

%  Undo trims and clips

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


