function [out1,out2,savepts] = mollweid(mstruct,in1,in2,object,direction,savepts)

%MOLLWEID  Mollweide Pseudocylindrical Projection
%
%  This is an equal area projection.  Scale is true along the 40 deg
%  44 min parallels, and is constant along any parallel and between
%  any pair of parallels equidistant from the Equator.  It is free
%  of distortion only at the two points where the 40 deg, 44 min
%  parallels intersect the central meridian.  This projection is
%  not conformal or equidistant.
%
%  This projection was presented by Carl B. Mollweide in 1805.  Its
%  other names include the Homolographic, the Homalographic, the
%  Babinet, and the Elliptical projections.  It is occasionally
%  used for thematic world maps, and it is combined with the
%  Sinusoidal to produce the Goode Homolosine projection.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.11.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(4044,'dms',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

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

%  Back off of the +/- 90 degree points.  This allows
%  the differentiation of longitudes at the poles of the transformed
%  coordinate system.

     epsilon = epsm('radians');
     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
     end

%  Projection transformation
%  Convergence is selected to ensure successful testing of forward
%  and inverse points (the hard point set) using TMAPCALC

     convergence = 1E-10;            maxsteps = 100;
     steps = 1;                     thetanew = lat;
	 converged = 0;

     while ~converged & steps <= maxsteps
          steps = steps + 1;
          thetaold = thetanew;
		  deltheta = -(thetaold + sin(thetaold) -pi*sin(lat)) ./ ...
		              (1 + cos(thetaold));
          if max(abs(deltheta(:))) <= convergence;    converged = 1;
		      else;                  thetanew = thetaold + deltheta;
	      end
     end
     thetanew = thetanew / 2;

     x = sqrt(8) * radius * long .* cos(thetanew) / pi;
     y = sqrt(2) * radius * sin(thetanew);

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

%  Inverse projection

	 theta = asin(y / (sqrt(2)*radius));

	 lat = asin((2*theta +sin(2*theta))/pi);
	 long = pi*x ./(sqrt(8)*radius*cos(theta));

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


