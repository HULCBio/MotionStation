function [out1,out2,savepts] = eqacylin(mstruct,in1,in2,object,direction,savepts)

%EQACYLIN  Equal Area Cylindrical Projection
%
%  This is an orthographic projection onto a cylinder secant at the
%  standard parallels.  It is equal area, but distortion of shape
%  increases with distance from the standard parallels.  Scale is true
%  along the standard parallels and constant between two parallels
%  equidistant from the Equator.  This projection is not equidistant.
%
%  This projection was proposed by Johann Heinrich Lambert (1772), a
%  prolific cartographer who proposed seven different important
%  projections.  The form of the projection tangent at the Equator
%  is often called the Lambert Equal Area Cylindrical projection.  That
%  and other special forms of this projection are included separately
%  in the toolbox, including the Gall Orthographic, the Behrmann
%  Cylindrical, the Balthasart Cylindrical, and the Trystan
%  Edwards Cylindrical projections.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(0,'degrees',mstruct.angleunits);
      mstruct.nparallels   = 1;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

units  = mstruct.angleunits;
aspect = mstruct.aspect;
parallels = angledim(mstruct.mapparallels,units,'radians');
origin    = angledim(mstruct.origin,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Compute projection parameters

a = mstruct.geoid(1);     e = mstruct.geoid(2);
if e == 0;     qp = 2;
    else;      qp = 1 - (1-e^2)/(2*e) * log((1-e)/(1+e));
end

den1 = (1 + e*sin(parallels(1))) * (1 - e*sin(parallels(1)));
m1   = cos(parallels(1)) / sqrt(den1);

%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2aut(origin(1),mstruct.geoid,'radians');
trimlat   = geod2aut(trimlat,  mstruct.geoid,'radians');
parallels = geod2aut(parallels,mstruct.geoid,'radians');

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

     x = a * m1 * long;
     y = a * qp * sin(lat) / (2*m1);

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

     lat  = asin(2*m1*y / (a*qp));
	 long = x / (a*m1);

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


