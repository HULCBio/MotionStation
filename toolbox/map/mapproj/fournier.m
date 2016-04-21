function [out1,out2,savepts] = fournier(mstruct,in1,in2,object,direction,savepts)

%FOURNIER  Fournier Pseudocylindrical Projection
%
%  This projection is equal-area.  Scale is constant along any parallel or
%  pair of parallels equidistant from the Equator.  This projection is neither
%  equidistant nor conformal.
%
%  This projection was first described in 1643 by Georges Fournier.  This is
%  actually his second projection, the Fournier II.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  out1 = mstruct;          return
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

%  This transformation is sensitive to points  at the poles, so the %
%  epsilon use to back off must be larger than epsm.  In addition,
%  for this projection, the inverse calculations must also
%  address the points backed off of the pole since the epsilon
%  is significant to the trig functions (but not necessarily to
%  the display of the projection).

epsilon = 500*epsm('radians');

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

     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
     end

%  Projection transformation

     x = radius * long .* cos(lat) / sqrt(pi);
	 y = sqrt(pi) * radius * sin(lat) / 2;

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

     lat  =  asin(2*y / (sqrt(pi)*radius));
	 long = sqrt(pi) * x ./ (radius * cos(lat) );

%  Reset the +/- 90 degree points.  Account for trig round-off
%  by expanding epsilon to 1.01*epsilon


     indx = find(abs(pi/2 - abs(lat)) <= 1.01*epsilon);
     if ~isempty(indx)
	    lat(indx) = pi/2 * sign(lat(indx));
     end

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


