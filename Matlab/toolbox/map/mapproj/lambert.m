function [out1,out2,savepts] = lambert(mstruct,in1,in2,object,direction,savepts)

%LAMBERT  Lambert Conformal Conic Projection
%
%  For this projection, scale is true along the one or two selected
%  standard parallels.  Scale is constant along any parallel, and
%  is the same in every direction at any point.  This projection is
%  free of distortion along the standard parallels.  Distortion is
%  constant along any other parallel.  This projection is conformal
%  everywhere but the poles;  it is neither equal area  nor equidistant.
%
%  This projection was presented by Johann Heinrich Lambert in 1772,
%  and it is also known as the Conical Orthomorphic projection.  The
%  cone of projection has interesting limiting forms.  If a pole
%  is selected as a single stantard parallel, the cone is a plane
%  and a Stereographic Azimuthal projection results.  If the Equator
%  or two parallels equidistant from the Equator are chosen as the
%  standard parallels, the cone becomes a cylinder, and a Mercator
%  projection results.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
      if length(mstruct.mapparallels) ~= 2
		mstruct.mapparallels = angledim([15 75],'degrees',mstruct.angleunits); % 1/6th and 5/6th of the northern hemisphere
      end
	  mstruct.nparallels   = 2;
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);;
      mstruct.trimlon = angledim([-135 135],'degrees',mstruct.angleunits);
	  if isempty(mstruct.maplatlimit)
		  mstruct.maplatlimit = angledim([ 0  90],'degrees',mstruct.angleunits);
	  end
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end



%  Extract the necessary projection data and convert to radians

units  = mstruct.angleunits;
aspect = mstruct.aspect;
parallels = angledim(mstruct.mapparallels,units,'radians');
origin    = angledim(mstruct.origin,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Eliminate singularities in transformations at 0 and ± 90 parallel.

epsilon = epsm('radians');
indx1 = find(abs(parallels) <= epsilon);
indx2 = find(abs(abs(parallels) - pi/2) <= epsilon);

if ~isempty(indx1);  parallels(indx1) = epsilon;  end
if ~isempty(indx2)
      parallels(indx2) = sign(parallels(indx2))*(pi/2 - epsilon);
end

%  Compute projection parameters

conformals  = geod2cnf(parallels,mstruct.geoid,'radians');
a = mstruct.geoid(1);    e = mstruct.geoid(2);

den1 = (1 + e*sin(parallels(1))) * (1 - e*sin(parallels(1)));
m1   = cos(parallels(1)) / sqrt(den1);

if length(parallels) == 1 | abs(diff(parallels)) < epsilon
    n = sin(parallels(1));
else
    if diff(abs(parallels)) < epsilon
         parallels(2) = parallels(2) - sign(parallels(2))*epsilon;
    end
    den2 = (1 + e*sin(parallels(2))) * (1 - e*sin(parallels(2)));
    m2   = cos(parallels(2)) / sqrt(den2);
	fact1 = tan(conformals(1)/2 + pi/4);
	fact2 = tan(conformals(2)/2 + pi/4);
	n = log(m1/m2) / log(fact2/fact1);
end

F    = (m1/n) * (tan(conformals(1)/2 + pi/4))^n;
rho0 = a*F / (tan(pi/4))^n;

%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2cnf(origin(1),mstruct.geoid,'radians');
trimlat   = geod2cnf(trimlat  ,mstruct.geoid,'radians');
%parallels done above

switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');
     lat  = geod2cnf(lat,mstruct.geoid,'radians');
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

     theta = n*long;
	 rho   = a*F ./ (tan(lat/2 + pi/4)).^n;
     x     = rho .* sin(theta);
	 y     = rho0 - rho .* cos(theta);

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

     rho   = sign(n)*sqrt( x.^2 + (rho0-y).^2);
	 theta = atan2(sign(n)*x, sign(n)*(rho0-y));
     lat   = 2*atan((a*F./rho).^(1/n)) - pi/2;
     long  = theta/n;

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);
     lat        = cnf2geod(lat,mstruct.geoid,'radians');

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


