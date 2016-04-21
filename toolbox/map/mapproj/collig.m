function [out1,out2,savepts] = collig(mstruct,in1,in2,object,direction,savepts)

%COLLIG  Collignon Pseudocylindrical Projection
%
%  This is a novelty projection showing a straight-line, equal area
%  graticule.  Scale is true along the 15 deg, 15 min N parallel, 
%  is constant along any parallel, and is different for any pair
%  of parallels.  Distortion is severe in many regions, and is only
%  absent at 15 deg, 15 min N on the central meridian.  This projection
%  is not conformal or equidistant.
%
%  This projection was presented by Edouard Collignon in 1865.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(1551,'dms',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end


units  = mstruct.angleunits;
aspect = mstruct.aspect;
radius = rsphere('authalic',mstruct.geoid);
origin  = angledim(mstruct.origin,units,'radians');
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

	 x = 2* radius * long .* sqrt(1 - sin(lat)) / sqrt(pi);
	 y = sqrt(pi) * radius * (1 - sqrt(1 - sin(lat)));

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

     lat = asin(1 - (1 - y /(radius*sqrt(pi))).^2);
	 long = sqrt(pi) * x ./ (2*radius*sqrt(1 - sin(lat)));

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


