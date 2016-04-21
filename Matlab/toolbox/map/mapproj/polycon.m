function [out1,out2,savepts] = polycon(mstruct,in1,in2,object,direction,savepts)

%POLYCON  Polyconic Projection
%
%  For this projection, each parallel has a curvature identical to
%  its curvature on a cone tangent at that latitude.  Since each
%  parallel would have its own cone, this is a "polyconic" projection.
%  Scale is true along the central meridian and along each parallel.
%  This projection is free of distortion only along the central meridian;
%  distortion can be severe at extreme longitudes.  This projection is
%  neither conformal nor equal area.
%
%  This projection was apparently originated about 1820 by Ferdinand
%  Rudolph Hassler.  It is also known as the American Polyconic and
%  the Ordinary Polyconic projections.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.11.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([-90  90],'degrees',mstruct.angleunits);
	  mstruct.trimlon = angledim([-75  75],'degrees',mstruct.angleunits);

%  Longitude limits are set well within the [-90 90] algorithm limit
%  because the algorithm sometimes does not converge when approaching
%  this boundary.

	  out1 = mstruct;
      return

elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
aspect  = mstruct.aspect;
geoid   = mstruct.geoid;
radius  = rsphere('rectifying',mstruct.geoid);
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
epsilon = 5*epsm('radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2rec(origin(1),mstruct.geoid,'radians');
trimlat   = geod2rec(trimlat  ,mstruct.geoid,'radians');

switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');
     lat  = geod2rec(lat,mstruct.geoid,'radians');
     long = angledim(in2,units,'radians');

%  Back off of the +/- 180 degree points.  The inverse
%  algorithm has trouble distinguishing points at -180 degrees
%  when they are near the pole.

     indx = find( abs(pi - abs(long)) <= epsilon);
     if ~isempty(indx)
	      long(indx) = long(indx) - sign(long(indx))*epsilon;
     end

%  Continue with the transformation

     [lat,long] = rotatem(lat,long,origin,direction);   %  Rotate to new origin
     [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
     [lat,long,trimmed] = trimdata(lat,trimlat,long,trimlon,object);
     latgeod = rec2geod(lat,mstruct.geoid,'radians');

     %  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = clipped;

%  Back off of the +/- 90 degree points.  This allows
%  the differentiation of longitudes at the poles of the transformed
%  coordinate system.

     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
	    latgeod(indx) = (pi/2 - epsilon) * sign(latgeod(indx));
     end

%  Pick up NaN place holders

      x = long;   y = lat;

%  Eliminate singularities in transformations at 0 latitude.

     indx1 = find(latgeod == 0);
     indx2 = find(latgeod ~= 0);

%  Points at zero latitude

     if ~isempty(indx1)
          x(indx1) = geoid(1) * long(indx1);
		  y(indx1) = 0;
     end

%  Points at non-zero latitude

	 if ~isempty(indx2)
          N = geoid(1) ./ sqrt(1 - (geoid(2)*sin(latgeod(indx2))).^2);
	      E = long(indx2) .* sin(latgeod(indx2));
          x(indx2) = N .* cot(latgeod(indx2)) .* sin(E);
          y(indx2) = radius*lat(indx2) + ...
		             N .* cot(latgeod(indx2)) .* (1-cos(E));
     end

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
%  Eliminate singularities in transformations at 0 latitude.

     indx = find(y == 0);
	 if ~isempty(indx);   y(indx) = epsilon;   end


     A = y / geoid(1);                  B = (x / geoid(1)).^2 + A.^2;
     convergence = 1E-10;             maxsteps = 100;
     steps = 1;                       latnew = A;
     converged = 0;                   e = geoid(2);

     while ~converged & steps <= maxsteps
         steps = steps + 1;
		 latold = latnew;

         C = sqrt(1 - (e*sin(latold)).^2) .* tan(latold);
         Ma = (1 - e^2/4 - 3*e^4/64 - 5*e^6/256) * latold - ...
		      (3*e^2/8 + 3*e^4/32 + 45*e^6/1024) * sin(2*latold) + ...
			  (15*e^4/256 + 45*e^6/1024) * sin(4*latold) - ...
			  (35*e^6/3072) * sin(6*latold);
		 M = Ma * geoid(1);

         Mp = (1 - e^2/4 - 3*e^4/64 - 5*e^6/256) - ...
		      2 * (3*e^2/8 + 3*e^4/32 + 45*e^6/1024) * cos(2*latold) + ...
			  4 * (15*e^4/256 + 45*e^6/1024) * cos(4*latold) - ...
			  6 * (35*e^6/3072) * cos(6*latold);


         num = A.*(C.*Ma + 1) - Ma - 0.5*(Ma.^2 + B).*C;
		 fact1 = (e^2)*sin(2*latold) .* (Ma.^2 + B - 2*A.*Ma) ./ (4*C);
		 fact2 = (A-Ma) .* (C.*Mp - 2./sin(2*latold)) - Mp;
		 dellat = num ./ (fact1 + fact2);

         if max(abs(dellat(:))) <= convergence;     converged = 1;
		      else;                      latnew = latold - dellat;
	     end
     end

     long = asin(x.*C/geoid(1)) ./ sin(latnew);

     latnew(indx) = 0;       %  Correct for y = 0 points
     lat  = geod2rec(latnew,mstruct.geoid,'radians');

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);
     lat        = rec2geod(lat,mstruct.geoid,'radians');

%  Transform to desired units

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


