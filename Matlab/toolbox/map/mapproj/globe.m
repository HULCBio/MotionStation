function [out1,out2,out3] = globe(mstruct,in1,in2,in3,object,direction)

%GLOBE  Render Earth as a sphere in 3-D graphics.
%
%  In the three-dimensional sense, this "projection" is true in scale,
%  equal-area, conformal, minimum error, and equidistant everywhere.  When
%  displayed, however, this "projection" looks like an orthographic
%  azimuthal projection, provided that the MATLAB axes projection property
%  is set to orthographic.
%
%  This is the only three-dimensional representation provided for display.
%  Unless some other display purpose requires three dimensions, the
%  orthographic projection's display is equivalent.
%
%  For the GLOBE digital elevation map data external interface, see
%  GLOBEDEM.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.10.4.2 $  $Date: 2003/12/13 02:55:31 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.galtitude = 0;
	  out1 = mstruct;
      return
end

%  Extract the necessary projection data and convert to radians

units  = mstruct.angleunits;
geoid  = mstruct.geoid;
epsilon = epsm('radians');

switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');
     long = angledim(in2,units,'radians');

	 alt  = in3;
	 if isempty(alt);    alt = zeros(size(lat));  end

     num = 1-geoid(2)^2;
     den = 1 - (geoid(2)*cos(lat)).^2;
	 rho = geoid(1) .* sqrt(num ./ den);

     alt = alt + rho;

%  Back off of the +/- 180 degree points.  This allows
%  the differentiation of longitudes at the dateline in
%  the inverse calculation.  For example, if not performed, -180 degree
%  points may become 180 degrees in the inverse calculation.

     indx = find( abs(pi - abs(long)) <= epsilon);
     if ~isempty(indx)
	      long(indx) = long(indx) - sign(long(indx))*epsilon;
     end

%  Back off of the +/- 90 degree points.  This allows
%  the differentiation of longitudes at the poles of the transformed
%  coordinate system.

     indx = find(abs(pi/2 - abs(lat)) <= epsilon);
     if ~isempty(indx)
	    lat(indx) = (pi/2 - epsilon) * sign(lat(indx));
     end

%  Transform to cartesian coordinates

     [out1,out2,out3] = sph2cart(long,lat,alt);

case 'inverse'

     x = in1;   y = in2;  z = in3;

     [long,lat,height] = cart2sph(in1,in2,in3);

     num = 1-geoid(2)^2;
     den = 1 - (geoid(2)*cos(lat)).^2;
	 rho = geoid(1) .* sqrt(num ./ den);

	 out1 = angledim(lat, 'radians', units);
     out2 = angledim(long,'radians', units);
     out3 = height - rho;


otherwise
     error('Unrecognized direction string')
end

%  Some operations on NaNs produce NaN + NaNi.  However operations
%  outside the map may product complex results and we don't want
%  to destroy this indicator.

indx = find(isnan(out1) | isnan(out2));
out1(indx) = NaN;   out2(indx) = NaN;

