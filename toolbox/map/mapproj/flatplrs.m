function [out1,out2,savepts] = flatplrs(mstruct,in1,in2,object,direction,savepts)

%FLATPLRS  McBryde-Thomas Flat-Polar Sinusoidal Pseudocylindrical Projection
%
%  This is an equal area projection.  Scale is true along the 55 deg,
%  51 min parallels, and is constant along any parallel and between any
%  pair of parallels equidistant from the Equator.  Distortion is severe
%  near the outer meridians at high latitudes, but less so than on the
%  pointed-polar projections.  It is free of distortion only at the two
%  points where the central meridian intersects the 55 deg, 51 min
%  parallels.  This projection is not conformal or equidistant.
%
%  This projection was presented by F. Webster McBryde and Paul D. Thomas
%  in 1949.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(5551,'dms',mstruct.angleunits);
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
%  Convergence is selected to ensure successful testing of forward
%  and inverse points (the hard point set) using TMAPCALC

     convergence = 1E-10;     maxsteps = 100;
     steps = 1;               thetanew = lat;
	 converged = 0;

     while ~converged & steps <= maxsteps
          steps = steps + 1;
          thetaold = thetanew;
		  deltheta = -(thetaold/2 + sin(thetaold) - (1+pi/4)*sin(lat)) ./ ...
		              (1/2 + cos(thetaold));
          if max(abs(deltheta(:))) <= convergence;    converged = 1;
		      else;                  thetanew = thetaold + deltheta;
	      end
     end

     x = sqrt(6/(4+pi)) * radius * long .* (0.5+cos(thetanew)) / 1.5;
     y = sqrt(6/(4+pi)) * radius * thetanew;

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

     theta = y ./ (sqrt(6/(4+pi))*radius);
	 lat = asin((theta/2 +sin(theta))/(1+pi/4) );
	 long = 1.5*x ./(sqrt(6/(4+pi)) * radius * (0.5+cos(theta)));

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


