function [out1,out2,savepts] = wagner4(mstruct,in1,in2,object,direction,savepts)

%WAGNER4  Wagner IV Pseudocylindrical Projection
%
%  This is an equal area projection.  Scale is true along the 42 deg,
%  59 min parallels, and is constant along any parallel and between
%  any pair of parallels equidistant from the Equator.  Distortion is
%  not as extreme near the outer meridians at high latitudes as for
%  pointed-polar pseudocylindrical projections, but there is considerable
%  distortion throughout polar regions.  It is free of distortion only
%  at the two points where the 42 deg, 59 min parallels intersect the
%  central meridian.  This projection is not conformal or equidistant.
%
%  This projection was presented by Karlheinz Wagner in 1932.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(4259,'dms',mstruct.angleunits);
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

     convergence = epsm('radians');     maxsteps = 100;
     steps = 1;                         thetanew = lat;
	 converged = 0;                     const = (4*pi + 3*sqrt(3))/6;

     while ~converged & steps <= maxsteps
          steps = steps + 1;
          thetaold = thetanew;
		  deltheta = -(thetaold + sin(thetaold) - const*sin(lat)) ./ ...
		              (1 + cos(thetaold));
          if max(abs(deltheta(:))) <= convergence;    converged = 1;
		      else;                  thetanew = thetaold + deltheta;
	      end
     end
     thetanew = thetanew / 2;

     x = 0.86310 * radius * long .* cos(thetanew);
     y = 1.56548 * radius * sin(thetanew);

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

     theta = asin(y ./ (1.56548*radius));
	 const = (4*pi + 3*sqrt(3))/6;

	 lat = asin((2*theta +sin(2*theta))/const);
	 long = x ./(0.86310*radius*cos(theta));

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


