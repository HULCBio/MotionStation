function [out1,out2,savepts] = murdoch3(mstruct,in1,in2,object,direction,savepts)

%MURDOCH3  Murdoch III Minimum Error Conic Projection
%
%  This is an equidistant projection which is minimum-error.  Scale is true
%  along any meridian and is constant along any parallel.  Scale is also true
%  along two standard parallels, which must calculated from the input
%  limiting parallels.  The total area of the mapped area is correct, but it
%  is not equal area everywhere.
%
%  This was first described by Patrick Murdoch in 1758, with errors only
%  corrected by Everett in 1904.
%
%  This projection is available for the spherical geoid only.  Longitude data
%  greater than 135 degrees east or west of the central meridian is trimmed.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
      mstruct.mapparallels = angledim([15 75],'degrees',mstruct.angleunits); % 1/6th and 5/6th of the northern hemisphere
      mstruct.nparallels   = 2;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-135 135],'degrees',mstruct.angleunits);
	  out1 = mstruct;          return
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
geoid   = mstruct.geoid;
aspect  = mstruct.aspect;
origin  = angledim(mstruct.origin,units,'radians');
parallels = angledim(mstruct.mapparallels,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
epsilon   = epsm('radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Adjust for equal parallels, or parallels at each pole

if length(parallels) == 1;            parallels = [parallels parallels];  end
if any( abs([diff(parallels) sum(parallels)]) <= epsilon )
     parallels(1) = parallels(1) + epsilon;
end
if abs(abs(diff(parallels)) - pi) <= epsilon
     parallels = [min(parallels)+epsilon max(epsilon)];
end

%  Compute the projection parameters

parallels = sort(parallels);   %  Parallels of form:  [South  North]
add = sum(parallels)/2;
sub = -diff(parallels)/2;      %  Want:  South - North parallel

m = tan(add) * (sub*cot(sub));
n = sin(sub)/sub * sin(add)/(m+add);

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

     lat = pi/2 - lat;       %  Compute co-lats

	 r = m + lat;            theta = n * long;
	 x =  geoid(1) * r .* sin(theta);
	 y = -geoid(1) * r .* cos(theta);

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

     long  = atan2(x,-y) / n;
     lat   = pi/2 - sqrt(x.^2 + y.^2)/geoid(1) + m;

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


