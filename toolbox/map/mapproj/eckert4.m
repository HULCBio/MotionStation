function [out1,out2,savepts] = eckert4(mstruct,in1,in2,object,direction,savepts)

%ECKERT4  Eckert IV Pseudocylindrical Projection
%
%  This is an equal area projection.  Scale is true along the 40 deg,
%  30 min parallels, and is constant along any parallel and between
%  any pair of parallels equidistant from the Equator.  It is not free
%  of distortion at any point except at 40 deg, 30 min N and S along
%  the central meridian.  This projection is not conformal or equidistant.
%
%  This projection was presented by Max Eckert in 1906.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(4030,'dms',mstruct.angleunits);
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

     convergence = 1E-10;           maxsteps = 100;
     steps = 1;                     thetanew = lat/2;
	 converged = 0;

     while ~converged & steps <= maxsteps
          steps = steps + 1;
          thetaold = thetanew;
		  deltheta = -(thetaold + sin(thetaold).*cos(thetaold) + ...
		               2*sin(thetaold) - (2+pi/2)*sin(lat)) ./ ...
		              (2*cos(thetaold) .* (1 + cos(thetaold)));
          if max(abs(deltheta(:))) <= convergence
		        converged = 1;
		  else
		        thetanew = thetaold + deltheta;
	      end
     end

     x = 2 * radius * long .* (1 + cos(thetanew)) / sqrt(pi*(4+pi));
     y = 2 * sqrt(pi) * radius * sin(thetanew) / sqrt(4+pi);

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

     theta = asin(sqrt(4+pi)*y/(2*sqrt(pi)*radius));

	 lat = asin( (theta+sin(theta).*cos(theta)+2*sin(theta) )/(2 + pi/2) );
	 long = sqrt(pi*(4+pi))*x ./ (2*radius*(1+cos(theta)));

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


