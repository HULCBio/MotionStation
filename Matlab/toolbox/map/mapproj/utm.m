function [out1,out2,savepts] = utm(mstruct,in1,in2,object,direction,savepts)

%UTM  Universal Transverse Mercator Cylindrical Projection
%
%  This is a conformal projection with parameters chosen to minimize 
%  distortion over a defined set of small areas.  It is not equal area, 
%  equidistant, or perspective.  Scale is true along two straight lines on 
%  the map approximately 180 kilometers east and west of the central 
%  meridian, and is constant along other straight lines equidistant from the 
%  central meridian.  Scale is less than true between, and greater than true 
%  outside the lines of true scale.
%  
%  The UTM system divides the world between 80 degrees S and 84 degrees N 
%  into a set of quadrangles called zones.  Zones generally cover 6 degrees 
%  of longitude and 8 degrees of latitude.  Each zone has a set of defined 
%  projection parameters, including central meridian, false eastings and 
%  northings and the reference ellipsoid.  The projection equations are the 
%  Gauss-Krueger versions of the transverse Mercator.  The projected 
%  coordinates form a grid system, in which a location is specified by the 
%  zone, easting and northing.
%  
%  The UTM system was introduced in the 1940's by the U.S. Army.  It is 
%  widely used in topographic and military mapping.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.6.4.1 $  $Date: 2003/08/01 18:24:38 $
%  Written by:  A. Kim


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -80  84],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.falseeasting = 5e5;
	  mstruct.scalefactor  = 0.9996;

	  if isempty(mstruct.zone)  % set zone to default and empty out zone affected properties
		  mstruct.zone = '31N';			%% This is the zone that has its 
	  									%% lower-left corner at (0 lat, 0 long)
		  mstruct.geoid = [];
		  mstruct.maplatlimit = [];
		  mstruct.maplonlimit = [];
		  mstruct.flatlimit = [];
		  mstruct.flonlimit = [];
		  mstruct.origin = [];
		  mstruct.mlinelocation = [];
		  mstruct.plinelocation = [];
		  mstruct.mlabellocation = [];
		  mstruct.plabellocation = [];
		  mstruct.mlabelparallel = [];
		  mstruct.plabelmeridian = [];
		  mstruct.falsenorthing  = [];
	  end

	  out1 = mstruct;     return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

%  Extract the necessary projection data and convert to radians

units     = mstruct.angleunits;
zone      = mstruct.zone;
geoid     = mstruct.geoid;
aspect    = mstruct.aspect;
origin    = angledim(mstruct.origin,units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');
falsenorthing = mstruct.falsenorthing;
falseeasting = mstruct.falseeasting;


switch direction

case 'forward'

     lat  = angledim(in1,units,'radians');   %  Convert to radians
     long = angledim(in2,units,'radians');
	 
% 	 [lat,long] = rotatem(lat,long,origin,direction);	% Rotate to new origin
 	 long = long - origin(2);   %  Rotate to new longitude origin
	 [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
     [lat,long,trimmed] = trimdata(lat,trimlat,long,trimlon,object);

%  Construct the structure of altered points

     savepts.trimmed = trimmed;
     savepts.clipped = clipped;

%  Perform the projection calculations, adding false easting and northing

	[x,y] = utmcalc(long,lat,'forward',geoid);

	x = x + falseeasting;
	y = y + falsenorthing;

%  Set the output variables

     switch  aspect
	    case 'normal',         out1 = x;      out2 = y;
	    case 'transverse',	   error('Tranverse option not allowed')
        otherwise,             error('Unrecognized aspect string')
     end


case 'inverse'

     switch  aspect
	    case 'normal',         x = in1;    y = in2;
	    case 'transverse',	   error('Tranverse option not allowed')
        otherwise,             error('Unrecognized aspect string')
     end

% subtract appropriate false northings and eastings

	x = x - falseeasting;
	y = y - falsenorthing;
	
%  Perform the projection calculations
%  Results rounded to nearest 1e-7 degrees (~1 cm accuracy)

	 [dlam,phi] = utmcalc(x,y,'inverse',geoid);

	 lat = phi;   % lat = deg2rad(roundn(rad2deg(phi),-7));
 	 long = dlam; % long = deg2rad(roundn(rad2deg(dlam),-7));

%  Undo trims and clips

     [lat,long] = undotrim(lat,long,savepts.trimmed,object);
     [lat,long] = undoclip(lat,long,savepts.clipped,object);

%  Rotate to Greenwhich and transform to desired units

	 long = long + origin(2);
% 	 [lat,long] = rotatem(lat,long,origin,direction);

     out1 = angledim(lat, 'radians', units);   %  Transform units
     out2 = angledim(long,'radians', units);

otherwise
     error('Unrecognized direction string')
end


%  Some operations on NaNs produce NaN + NaNi.  However operations
%  outside the map may product complex results and we don't want
%  to destroy this indicator.

indx = find(isnan(out1) | isnan(out2));
out1(indx) = NaN;   out2(indx) = NaN;


%*****************************************************************************
%*****************************************************************************
%*****************************************************************************

function [out1,out2] = utmcalc(in1,in2,direction,geoid)

% Usage (radian angular units):
%
%	[x,y] = utm1(dlam,phi,'forward',geoid)
%	[dlam,phi] = utm1(x,y,'inverse',geoid)

%% ----------------------------------------------------------------------
%% unknown form of Transverse Mercator - Gauss-Kruger? (from Snyder's book)
%% ----------------------------------------------------------------------

% constants and parameters

k0 = .9996;							% scale on central meridian for UTM
a = geoid(1);						% semimajor axis in meters
e = geoid(2);						% eccentricity
e2 = e^2; e4 = e^4; e6 = e^6;		% eccentricity powers
ep2 = e2/(1-e2);					% second eccentricity parameter

% forward or inverse utm projection transform

switch direction

	case 'forward',   % forward transform
	
		dlam = in1;
		phi = in2;
	
		N = a./sqrt(1 - e2*(sin(phi)).^2);
		T = (tan(phi)).^2;
		C = ep2*(cos(phi)).^2;
		A = dlam.*cos(phi);
		
		Z1 = 1 - e2/4 - 3*e4/64 - 5*e6/256;
		Z2 = 3*e2/8 + 3*e4/32 + 45*e6/1024;
		Z3 = 15*e4/256 + 45*e6/1024;
		Z4 = 35*e6/3072;
		
		M = a*( Z1*phi - Z2*sin(2*phi) + Z3*sin(4*phi) - Z4*sin(6*phi) );

		Za = 1 - T + C;
		Zb = 5 - 18*T + T.^2 + 72*C - 58*ep2;
		Zc = 5 - T + 9*C + 4*C.^2;
		Zd = 61 - 58*T + T.^2 +600*C - 330*ep2;
		
		x = k0*N .* ( A + Za.*A.^3/6 + Zb.*A.^5/120 );
		y = k0 * ( M + N.*tan(phi).*( A.^2/2 + Zc.*A.^4/24 + Zd.*A.^6/720 ) );

		out1 = x;
		out2 = y;
		
	case 'inverse',   % inverse transform

		x = in1;
		y = in2;

		e1 = (1-sqrt(1-e2))/(1+sqrt(1-e2));
		M = y/k0;
		mu = M / ( a*(1 - e2/4 - 3*e4/64 - 5*e6/256) );
		
		Z1 = 3*e1/2 - 27*e1^3/32;
		Z2 = 21*e1^2/16 - 55*e1^4/32;
		Z3 = 151*e1^3/96;
		Z4 = 1097*e1^4/512;
		
		phi1 = mu + Z1*sin(2*mu) + Z2*sin(4*mu) + Z3*sin(6*mu) + Z4*sin(8*mu);

		C1 = ep2*(cos(phi1)).^2;
		T1 = (tan(phi1)).^2;
		N1 = a ./ sqrt( 1 - e2*(sin(phi1)).^2 );
  		R1 = a*(1-e2) ./ ( 1 - e2*(sin(phi1)).^2 ).^(3/2);
		D = x ./ (N1*k0);

		Za = 5 + 3*T1 + 10*C1 - 4*C1.^2 - 9*ep2;
		Zb = 61 + 90*T1 + 298*C1 + 45*T1.^2 - 252*ep2 - 3*C1.^2;
		Zc = 1 + 2*T1 + C1;
		Zd = 5 - 2*C1 + 28*T1 - 3*C1.^2 + 8*ep2 + 24*T1.^2;
		phi = phi1 - (N1.*tan(phi1)./R1).*(D.^2/2 - Za.*D.^4/24 + Zb.*D.^6/720);
		dlam = (D - Zc.*D.^3./6 + Zd.*D.^5/120) ./ cos(phi1);

		out1 = dlam;
		out2 = phi;
		
	otherwise,

		error('Unrecognized direction string')
		
end
