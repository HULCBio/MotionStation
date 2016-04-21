function [out1,out2,savepts] = mercator(mstruct,in1,in2,object,direction,savepts)

%MERCATOR  Mercator Cylindrical Projection
%
%  This is a projection with parallel spacing calculated to maintain
%  conformality.  It is not equal area, equidistant, or perspective.
%  Scale is true along the standard parallels and constant between
%  two parallels equidistant from the Equator.  It is also constant
%  in all directions near any given point.  Scale becomes infinite
%  at the poles.  The appearance of the Mercator projection is
%  unaffected by the selection of the standard parallels;  they
%  serve only to define the latitude of true scale.
%
%  The Mercator, which may be the most famous of all projections, has
%  the special feature that all rhumb lines, or loxodromes (lines that
%  make equal angles with all meridians, i.e. lines of constant heading)
%  are straight lines.  This makes it an excellent projection for
%  navigational purposes.
%
%  The transverse and oblique aspects of the projection are often
%  used for topographic mapping and atlas maps.  Its normal aspect
%  is often used for maps of the entire world, for which it is
%  really quite inappropriate.
%
%  The Mercator projection is named for Geradus Mercator, who presented
%  it "for navigation" in 1569.  It is now known to have been used for
%  the Tunhuang star chart as early as 940 by Ch'ien Lo-Chih.  It was
%  first used in Europe by Erhard Etzlaub in 1511.  It is also, but
%  rarely, called the Wright projection, after Edward Wright, who
%  developed the mathematics behind the projection in 1599.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -86  86],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = 0;
      mstruct.nparallels   = 1;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;     return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units     = mstruct.angleunits;
geoid     = mstruct.geoid;
aspect    = mstruct.aspect;
parallels = angledim(mstruct.mapparallels,units,'radians');
origin    = angledim(mstruct.origin,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;



%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2cnf(origin(1),mstruct.geoid,'radians');
trimlat   = geod2cnf(trimlat  ,mstruct.geoid,'radians');
parallels = geod2cnf(parallels,mstruct.geoid,'radians');


switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');   %  Convert to radians
     lat  = geod2cnf(lat,mstruct.geoid,'radians');
     long = angledim(in2,units,'radians');

     [lat,long] = rotatem(lat,long,origin,direction);   %  Rotate to new origin
     [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
     [lat,long,trimmed] = trimdata(lat,trimlat,long,trimlon,object);

%  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = clipped;

%  Perform the projection calculations

	  x = geoid(1) * long * cos(parallels(1));
	  y = geoid(1) * log(tan(pi/4+lat/2)) * cos(parallels(1));

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

	 long = x / (geoid(1) * cos(parallels(1)) );
     lat  = pi/2 - 2*atan(exp(-y/  (geoid(1) * cos(parallels(1)) )  ));

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

     [lat,long] = rotatem(lat,long,origin,direction);  %  Rotate back to Greenwich
     lat        = cnf2geod(lat,mstruct.geoid,'radians');

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


