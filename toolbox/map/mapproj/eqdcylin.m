function [out1,out2,savepts] = eqdcylin(mstruct,in1,in2,object,direction,savepts)

%EQDCYLIN  Equidistant Cylindrical Projection
%
%  This is a projection onto a cylinder secant at the standard parallels.
%  Distortion of both shape and area increase with distance from the
%  standard parallels.  Scale is true along all meridians (i.e. it is
%  equidistant) and the standard parallels, and is constant along
%  any parallel and along the parallel of opposite sign.
%
%  This projection was first used by Marinus of Tyre, about A.D. 100.
%  Special forms of this projection are the Plate Carree, with a standard
%  parallel at 0 deg, and the Gall Isographic, with standard parallels
%  at 45 deg N and S.  Other names for this projection include
%  Equirectangular, Rectangular, Projection of Marinus, La Carte
%  Parallelogrammatique, and Die Rechteckige Plattkarte.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(30,'degrees',mstruct.angleunits);
      mstruct.nparallels   = 1;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units     = mstruct.angleunits;
geoid     = mstruct.geoid;
radius    = rsphere('rectifying',mstruct.geoid(1));
aspect    = mstruct.aspect;
parallels = angledim(mstruct.mapparallels,units,'radians');
origin    = angledim(mstruct.origin,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;


%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2rec(origin(1),mstruct.geoid,'radians');
trimlat   = geod2rec(trimlat  ,mstruct.geoid,'radians');
parallels = geod2rec(parallels,mstruct.geoid,'radians');


switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');
     lat  = geod2rec(lat,mstruct.geoid,'radians');
     long = angledim(in2,units,'radians');


     [lat,long] = rotatem(lat,long,origin,direction);   %  Rotate to new origin
     [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
     [lat,long,trimmed] = trimdata(lat,trimlat,long,trimlon,object);

%  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = clipped;

%  Perform the projection calculations

     x = radius * long * cos(parallels(1));
     y = radius * lat;

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

     lat  = y / radius;
	 long = x / (radius*cos(parallels(1)));

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);
     lat        = rec2geod(lat,mstruct.geoid,'radians');

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


