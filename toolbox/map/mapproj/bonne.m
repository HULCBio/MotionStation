function [out1,out2,savepts] = bonne(mstruct,in1,in2,object,direction,savepts)

%BONNE  Bonne Pseudoconic Projection
%
%  This is an equal area projection.  The curvature of the standard parallel
%  is identical to that on a cone tangent at that latitude.  The central
%  meridian and the central parallel are free of distortion.  This
%  projection is not conformal.
%
%  This projection dates in a rudimentary form back to Claudius Ptolemy
%  (about A.D. 100).  It was further developed by Bernardus Sylvanus in
%  1511.  It derives its name from its considerable use by Rigobert
%  Bonne, especially in 1752.  It has two interesting limiting forms.
%  If a pole is employed as the standard parallel, a Werner projection
%  results;  if the Equator is used, a Sinusoidal projection results.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 1;
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units  = mstruct.angleunits;
aspect = mstruct.aspect;
radius = rsphere('rectifying',mstruct.geoid);
parallels = angledim(mstruct.mapparallels,units,'radians');
origin    = angledim(mstruct.origin,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;

%  Compute projection parameters

rectifies  = geod2rec(parallels,mstruct.geoid,'radians');
a = mstruct.geoid(1);    e = mstruct.geoid(2);

den1 = (1 + e*sin(parallels(1))) * (1 - e*sin(parallels(1)));
m1   = cos(parallels(1)) / sqrt(den1);


%  Adjust the origin latitude to the auxiliary sphere

origin(1) = geod2rec(origin(1),mstruct.geoid,'radians');
trimlat   = geod2rec(trimlat  ,mstruct.geoid,'radians');


switch direction
case 'forward'

     lat  = angledim(in1,units,'radians');
     lat  = geod2rec(lat,mstruct.geoid,'radians');
     long = angledim(in2,units,'radians');

     [lat,long] = rotatem(lat,long,origin,direction);   %  Rotate to new origin
     [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
     latgeod = rec2geod(lat,mstruct.geoid,'radians');

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
	    latgeod(indx) = (pi/2 - epsilon) * sign(latgeod(indx));
     end

%  Perform the projection calculations

     m   = cos(latgeod) ./ sqrt(1 - (e*sin(latgeod)).^2);
     if parallels(1) ~= 0
	     rho = a*m1/(sin(parallels(1))) + radius*(rectifies(1) - lat);
 	     E   = a*m .* long ./ rho;

         x = rho .* sin(E);
         y = a*m1/sin(parallels(1)) - rho .* cos(E);
     else
         x = a * m .* long;
		 y = radius * lat;
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

%  Inverse projection

 	 if parallels(1) ~= 0
          factor1 = a*m1/sin(parallels(1));
	      factor2 = sign(parallels(1));
	      rho = factor2*sqrt(x.^2 + (factor1-y).^2);

	      lat  = (factor1 + radius*rectifies(1) - rho) / radius;
          latgeod = rec2geod(lat,mstruct.geoid,'radians');
          m    = cos(latgeod) ./ sqrt(1 - (e*sin(latgeod)).^2);
	      long = rho .* atan2(factor2*x, factor2*(factor1-y)) ./ (a*m);
     else
		  lat = y ./ radius;
          latgeod = rec2geod(lat,mstruct.geoid,'radians');
          m    = cos(latgeod) ./ sqrt(1 - (e*sin(latgeod)).^2);
          long = x ./ (a*m);
	 end

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);
     lat        = rec2geod(lat,mstruct.geoid,'radians');

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


