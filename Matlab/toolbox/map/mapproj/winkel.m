function [out1,out2,savepts] = winkel(mstruct,in1,in2,object,direction,savepts)

%WINKEL  Winkel I Pseudocylindrical Projection
%
%  This projection is an arithmetical average of the x and y coordinates
%  of the Sinusoidal and Equidistant Cylindrical projections.  Scale is
%  true along the standard parallels, and is constant along any parallel
%  and between any pair of parallels equidistant from the Equator.
%  There is no point free of distortion.  This projection is not equal
%  area, conformal, or equidistant.
%
%  This projection was developed by Oswald Winkel in 1914.  Its
%  limiting form is the Eckert V when a standard parallel of 0 degrees
%  is chosen.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(5028,'dms',mstruct.angleunits);
      mstruct.nparallels   = 1;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
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


if parallels(1) == 0;     factor1 = sqrt(2+pi);
     else;                factor1 = 2;
end

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

%  Projection transformation

	 x = geoid(1) * long .* (cos(parallels(1)) + cos(lat)) / factor1;
	 y = 2 * geoid(1) * lat / factor1;

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

     lat = factor1 * y / (2*geoid(1));
	 long = factor1 * x ./ (geoid(1)*(cos(parallels(1)) + cos(lat)) );

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


