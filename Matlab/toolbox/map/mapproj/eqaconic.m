function [out1,out2,savepts] = eqaconic(mstruct,in1,in2,object,direction,savepts)

%EQACONIC  Albers Equal Area Conic Projection
%
%  This is an equal area projection.  Scale is true along the one or
%  two selected standard parallels.  Scale is constant along any parallel;
%  the scale factor of a meridian at any given point is the reciprocal of
%  that along the parallel to preserve equal area.  This projection is
%  free of distortion along the standard parallels.  Distortion is
%  constant along any other parallel.  This projection is neither
%  conformal nor equidistant.
%
%  This projection was presented by Heinrich Christian Albers in 1805 and
%  it is also known as a Conical Orthomorphic projection.  The cone of
%  projection has interesting limiting forms.  If a pole is selected as
%  a single standard parallel, the cone is a plane, and a Lambert Equal
%  Area Conic projection is the result.  If the Equator is chosen as a
%  single parallel, the cone becomes a cylinder and a Lambert Cylindrical
%  Equal Area Projection is the result.  Finally, if two parallels
%  equidistant from the Equator are chosen as the standard parallels, a
%  Behrmann or other cylindrical equal area projection is the result.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.12.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
      if length(mstruct.mapparallels) ~= 2
		mstruct.mapparallels = angledim([15 75],'degrees',mstruct.angleunits); % 1/6th and 5/6th of the northern hemisphere
      end
      mstruct.nparallels   = 2;
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-135 135],'degrees',mstruct.angleunits);
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units  = mstruct.angleunits;
aspect = mstruct.aspect;
radius = rsphere('authalic',mstruct.geoid);
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

authalics  = geod2aut(parallels,mstruct.geoid,'radians');

e = mstruct.geoid(2);
if e == 0;     qp = 2;
    else;      qp = 1 - (1-e^2)/(2*e) * log((1-e)/(1+e));
end

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
    n    = (m1^2 - m2^2) / (qp * (sin(authalics(2))-sin(authalics(1))) );
end

C    = m1^2 + qp*n*sin(authalics(1));
rho0 = radius * sqrt(C)/n;


%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2aut(origin(1),mstruct.geoid,'radians');
trimlat   = geod2aut(trimlat  ,mstruct.geoid,'radians');
%parallels done above

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

     theta = n*long;
	 rho   = radius * sqrt(2*C/qp - 2*n*sin(lat)) / n;
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

     rho = sqrt( x.^2 + (rho0-y).^2);
	 theta = atan2(sign(n)*x, sign(n)*(rho0-y));

	 lat  = asin( (2*C/qp - (n*rho/radius).^2) / (2*n));
	 long = theta/n;

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


