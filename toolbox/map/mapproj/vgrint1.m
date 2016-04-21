function [out1,out2,savepts] = vgrint1(mstruct,in1,in2,object,direction,savepts)

%VGRINT1  Van Der Grinten I Polyconic Projection
%
%  In this projection, the world is enclosed in a circle.  Scale is
%  true along the Equator and increases rapidly away from the Equator.
%  Area distortion is extreme near the poles.  This projection is
%  neither conformal nor equal area.
%
%  This projection was presented by Alphons J. van der Grinten 1898.
%  He obtained a U.S. patent for it in 1904.  It is also known simply
%  as the Van der Grinten projection (without a "I").

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.2 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([-90   90],'degrees',mstruct.angleunits);
	  mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  out1 = mstruct;     return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
aspect  = mstruct.aspect;
geoid   = mstruct.geoid;
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
epsilon = 10*epsm('radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;


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

%  Back off of the +/- 90 degree points.  This allows
%  the differentiation of longitudes at the poles of the transformed
%  coordinate system.

     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
     end

%  Pick up NaN place holders

      x = long;   y = lat;

%  Compute the projection parameter theta

     theta = asin(2*abs(lat)/pi);

%  Process 0 latitude and longitude separately

     indx1 = find(abs(long) <= epsilon);
     indx2 = find(abs(lat) <= epsilon);
     indx3 = find(abs(lat) > epsilon & abs(long) > epsilon);

%  Points at zero longitude

     if ~isempty(indx1)
          x(indx1) = 0;                   y(indx1) = tan(theta(indx1)/2);
     end

%  Points at zero latitude

     if ~isempty(indx2)
          x(indx2) = abs(long(indx2))/pi;    y(indx2) = 0;
     end

%  Points at non-zero longitude and non-zero latitude

	 if ~isempty(indx3)
          theta0 = theta(indx3);   long0 = long(indx3);
		  A = abs( pi./long0 - long0/pi) / 2;
		  G = cos(theta0) ./ (sin(theta0) + cos(theta0) - 1);
		  P = G .* (2./sin(theta0) - 1);
		  Q = A.^2 + G;

          fact1 = A .* (G - P.^2);
          fact2 = P.^2 + A.^2;
          fact3 = fact1 + sqrt( fact1.^2  - fact2.*(G.^2 - P.^2));
		  fact4 = P.*Q - A.*sqrt((A.^2 + 1).*fact2 - Q.^2);

		  x(indx3) = fact3 ./ fact2;
		  y(indx3) = fact4 ./ fact2;
     end

% Final calcs

     x = geoid(1) * pi * sign(long) .* x;
     y = geoid(1) * pi * sign(lat)  .* y;

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
%  Normalize by the radius

     x = x / (pi*geoid(1));
     y = y / (pi*geoid(1));

%  Pick up NaN place holders and points at (0,0)

	 long = x;         lat = y;

%  Process points not at (0,0)

     indx1 = find(x ~= 0 | y ~= 0);
     indx2 = find(x ~= 0);

%  Inverse transformation

     if ~isempty(indx1)

	      fact1 = x(indx1).^2 + y(indx1).^2;
		  c1 = -abs(y(indx1)) .* (1 + fact1);
	      c2 = c1 - 2* y(indx1).^2 + x(indx1).^2;
	      c3 = -2*c1 + 1 + 2* y(indx1).^2 + fact1.^2;

	      d = y(indx1).^2 ./ c3 + (2*c2.^3./c3.^3 - 9*c1.*c2./c3.^2)/27;
	      a1 = (c1 - c2.^2./(3*c3))./c3;
	      m1 = 2*sqrt(-a1/3);
          cos_theta1_times3 = 3*d ./ (a1.*m1);
          % Correct for possible roundoff/noise
          cos_theta1_times3(cos_theta1_times3 < -1) = -1;
          cos_theta1_times3(cos_theta1_times3 >  1) =  1;
	      theta1 = acos(cos_theta1_times3)/3;
          lat(indx1) = pi * sign(y(indx1)) .* ...
		                      (-m1.*cos(theta1+pi/3)-c2./(3*c3));

%  Points at non-zero longitude

          if ~isempty(indx2)
		       c1 = x(indx2).^2 + y(indx2).^2;
		       c2 = x(indx2).^2 - y(indx2).^2;
		       c3 = (c1 - 1 + sqrt(1 + 2*c2 + c1.^2));
               long(indx2) = pi * c3 ./ (2*x(indx2));
	      end
     end

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


