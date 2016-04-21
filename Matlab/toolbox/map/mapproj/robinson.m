function [out1,out2,savepts] = robinson(mstruct,in1,in2,object,direction,savepts)

%ROBINSON  Robinson Pseudocylindrical Projection
%
%  For this projection, scale is true along the 38 deg parallels, and
%  is constant along any parallel, and between any pair of parallels
%  equidistant from the Equator.  It is not free of distortion at any
%  point, but distortion is very low within about 45 degrees of the
%  center and along the Equator.  This projection is not equal area,
%  conformal or equidistant;  however, it is considered to "look right"
%  for world maps, and hence is widely used by Rand McNally, the National
%  Geographic Society and others.  This feature is achieved through the
%  use of tabular coordinates rather than mathematical formulae for the
%  graticules.
%
%  This projection was presented by Arthur H. Robinson in 1963, and is
%  also called the Orthophanic projection, which means "right appearing."
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(38,'degrees',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units   = mstruct.angleunits;
geoid   = mstruct.geoid;
aspect  = mstruct.aspect;
origin  = angledim(mstruct.origin,units,'radians');
trimlat = angledim(mstruct.flatlimit,units,'radians');
trimlon = angledim(mstruct.flonlimit,units,'radians');
scalefactor = mstruct.scalefactor;
falseeasting = mstruct.falseeasting;
falsenorthing = mstruct.falsenorthing;


%  Robinson projection data
%  [Lat in deg,  Lat in rad,  X factor, Y factor]

r =[
         0         0    1.0000         0
    5.0000    0.0873    0.9986    0.0620
   10.0000    0.1745    0.9954    0.1240
   15.0000    0.2618    0.9900    0.1860
   20.0000    0.3491    0.9822    0.2480
   25.0000    0.4363    0.9730    0.3100
   30.0000    0.5236    0.9600    0.3720
   35.0000    0.6109    0.9427    0.4340
   40.0000    0.6981    0.9216    0.4958
   45.0000    0.7854    0.8962    0.5571
   50.0000    0.8727    0.8679    0.6176
   55.0000    0.9599    0.8350    0.6769
   60.0000    1.0472    0.7986    0.7346
   65.0000    1.1345    0.7597    0.7903
   70.0000    1.2217    0.7186    0.8435
   75.0000    1.3090    0.6732    0.8936
   80.0000    1.3963    0.6213    0.9394
   85.0000    1.4835    0.5722    0.9761
   90.0000    1.5708    0.5322    1.0000
];


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

%  Pick up NaN place holders.

	 x = long;  y = lat;

%  Projection transformation

     for i = 1:size(r,1)-1
		 xslope = (r(i,3) - r(i+1,3)) / (r(i,2) - r(i+1,2));
		 yslope = (r(i,4) - r(i+1,4)) / (r(i,2) - r(i+1,2));
	     indx = find(abs(lat) >= r(i,2) & abs(lat) <= r(i+1,2));

		 if ~isempty(indx)
              dellat = abs(lat(indx)) - r(i,2);

		      X = r(i,3) + xslope * dellat;
		      Y = (r(i,4) + yslope * dellat) .* sign(lat(indx));

		      x(indx) = 0.8487 * geoid(1) * X .* long(indx);
		      y(indx) = 1.3523 * geoid(1) * Y;
		 end
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

 %  Pick up NaN place holders.

	 long = x;  lat = y;

     for i = 1:size(r,1)-1
		 xslope   = (r(i,3) - r(i+1,3)) / (r(i,4) - r(i+1,4));
		 latslope = (r(i,2) - r(i+1,2)) / (r(i,4) - r(i+1,4));

         Y = y / (1.3523*geoid(1));
	     indx = find(abs(Y) >= r(i,4) & abs(Y) <= r(i+1,4));

		 if ~isempty(indx)
              dely = abs(Y(indx)) - r(i,4);
		      X = r(i,3) + xslope * dely;

		      lat(indx) = (r(i,2) + latslope * dely) .* sign(y(indx));
		      long(indx) = x(indx) ./ (0.8487 * geoid(1) * X);
		 end
     end

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwich and transform to desired units

     [lat,long] = rotatem(lat,long,origin,direction);

     out1 = angledim(lat, 'radians', units);
     out2 = angledim(long,'radians', units);

end

%  Some operations on NaNs produce NaN + NaNi.  However operations
%  outside the map may product complex results and we don't want
%  to destroy this indicator.

indx = find(isnan(out1) | isnan(out2));
out1(indx) = NaN;   out2(indx) = NaN;


