function [out1,out2,savepts] = tranmerc(mstruct,in1,in2,object,direction,savepts)

%TRANMERC  Transverse Mercator Projection
%
%  This conformal projection is the transverse form of the Mercator
%  projection and is also known as the Gauss-Krueger pojection.  It is not
%  equal area, equidistant, or perspective.
%
%  The scale is constant along the central meridian, and increases to the
%  east and west. The scale at the entral meridian can be set true to
%  scale, or reduced slightly to render the mean scale of the overall map
%  more nearly correct.
%
%  The uniformity of scale along its centeral meridian makes Transverse
%  Mercator an excellent choice for mapping areas that are elongated
%  north-to-south.  Its best known application is the definition of
%  Universal Transverse Mercator (UTM) coordinates.  Each UTM zone spans
%  only 6 degrees of longitude, but the northern half extends from the
%  equator all the way to 84 degrees north and the southern half extends
%  from 80 degrees south to the equator. Other map grids based on
%  Transverse Mercator include many of the state plane zones in the U.S.,
%  and the U.K. National Grid.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2003/08/01 18:24:35 $

if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = [];
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  mstruct.scalefactor  = 1;
      mstruct.aspect = 'normal';
      out1 = mstruct;
      return;
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

if ~strmatch(mstruct.aspect,'normal')
    warning('Aspect setting ''%s'' ignored by Transverse Mercator projection.',...
            mstruct.aspect);
end

%  Extract the necessary projection data and convert to radians
units     = mstruct.angleunits;
origin    = angledim(mstruct.origin,   units,'radians');
trimlat   = angledim(mstruct.flatlimit,units,'radians');
trimlon   = angledim(mstruct.flonlimit,units,'radians');

switch direction
    case 'forward'
        lat  = angledim(in1,units,'radians');   %  Convert to radians
        long = angledim(in2,units,'radians');
		 
        long = long - origin(2);   %  Rotate to new longitude origin
        [lat,long,clipped] = clipdata(lat,long,object);    %  Clip at the date line
        [lat,long,trimmed] = trimdata(lat,trimlat,long,trimlon,object);
	
        %  Construct the structure of altered points
        savepts.trimmed = trimmed;
        savepts.clipped = clipped;
	
        %  Perform the projection calculations
        [x,y] = transmercfwd(lat, long,...
                       mstruct.geoid, mstruct.scalefactor, origin(1), 0,...
                       mstruct.falseeasting, mstruct.falsenorthing);
	
        %  Set the output variables
        out1 = x;
        out2 = y;
	
    case 'inverse'
        x = in1;
        y = in2;

        % Perform inverse projection
        [lat,long] = transmercinv(x, y,...
                            mstruct.geoid, mstruct.scalefactor, origin(1), 0,...
                            mstruct.falseeasting, mstruct.falsenorthing);
	
        %  Undo trims and clips
        [lat,long] = undotrim(lat,long,savepts.trimmed,object);
        [lat,long] = undoclip(lat,long,savepts.clipped,object);
	
        %  Rotate to Greenwhich and transform to desired units
        long = long + origin(2);
        out1 = angledim(lat, 'radians', units);
        out2 = angledim(long,'radians', units);
       
    otherwise
        error('Unrecognized direction string')
end

%  Some operations on NaNs produce NaN + NaNi.  However operations
%  outside the map may product complex results and we don't want
%  to destroy this indicator.

indx = find(isnan(out1) | isnan(out2));
out1(indx) = NaN;
out2(indx) = NaN;
		
%----------------------------------------------------------------------
% Transverse Mercator formulas from the publication:
%   A guide to coordinate systems in Great Britain, Ordnance Survey.
%----------------------------------------------------------------------

function [x,y] = transmercfwd(phi, lambda,...
                              ellipsoid, scalefactor, phi0, lambda0, x0, y0)

F0 = scalefactor;
a = ellipsoid(1);
e2 = (ellipsoid(2))^2;

sinphi = sin(phi);
cosphi = cos(phi);
sinphi2 = sinphi.^2;
cosphi2 = cosphi.^2;

dlam2 = (lambda - lambda0).^ 2;

nu = a * F0 ./ sqrt(1 - e2 * sinphi2);
nuOVERrho = (1 - e2 * sinphi2)/(1 - e2);
eta2 = nuOVERrho - 1;

yc = ycentral(phi, ellipsoid, scalefactor, phi0, y0);

x = x0 + nu .* cosphi .*  (lambda - lambda0) .* (1 ...
    + dlam2 .* (((nuOVERrho) .* cosphi2 - sinphi2)/6 ...
    + dlam2 .* (((5 + 14 * eta2) .* cosphi2.^2 ...
                     - (18 + 58 * eta2) .* cosphi2 .* sinphi2 + sinphi2.^2))/120));

y = yc + nu .* sinphi .* cosphi .* dlam2 .* (1/2 ...
    + dlam2 .* (((5 + 9 * eta2) .* cosphi2 - sinphi2)/24 ...
    + dlam2 .* (61 * cosphi2.^2 ...
                     - 58 * cosphi2 .* sinphi2 + sinphi.^2)/720));

%-----------------------------------------------------------------------

function [phi,lambda] = transmercinv(x, y,...
                                     ellipsoid, scalefactor, phi0, lambda0, x0, y0)

F0 = scalefactor;
a = ellipsoid(1);
e2 = (ellipsoid(2))^2;

phiP = phicentral(y, ellipsoid, scalefactor, phi0, y0);

sinphiP2 = sin(phiP).^2;
nu = a * F0 ./ sqrt(1 - e2 * sinphiP2);
nuOVERrho = (1 - e2 * sinphiP2)/(1 - e2);
eta2 = nuOVERrho - 1;

tanphiP  = tan(phiP);
tanphiP2 = tanphiP.^2;
dx2OVERnu2 = ((x - x0)./nu).^2;

phi = phiP + tanphiP .* nuOVERrho .* dx2OVERnu2 .* (-1/2 ...
      + dx2OVERnu2 .* ((5 + eta2 + tanphiP2 .* (3 - 9 * eta2))/24 ...
      + dx2OVERnu2 .* -(61 + tanphiP2 .* (90 + 45 * tanphiP2))/720));

lambda = lambda0 + sec(phiP) .* ((x - x0)./nu) .* (1 ...
         + dx2OVERnu2 .* (-(nuOVERrho + 2 * tanphiP2)/6 ...
         + dx2OVERnu2 .* ((5 + tanphiP2 .* (28 + 24 * tanphiP2))/120 ...
         + dx2OVERnu2 .* -(61 + tanphiP2 .* (662 + tanphiP2 .* (1320 + 720 * tanphiP2)))/5040)));

%-----------------------------------------------------------------------

function yc = ycentral(phi, ellipsoid, scalefactor, phi0, y0)
% Calculate the northing of the point (phi,lambda0), which lies on the
% central meridian.

F0 = scalefactor;
b = minaxis(ellipsoid);
n = ecc2n(ellipsoid);

dphi = phi - phi0;
pphi = phi + phi0;

yc = y0 + b * F0 ...
          * ( ((4 + n.*(4 + 5*n.*(1 + n)))/4) .* dphi ...
             - (n .* (24 + n.*(24 + n*21))/8) .* sin(dphi)   .* cos(pphi) ...
                   + (15 * n.^2 .* (1 + n)/8) .* sin(2*dphi) .* cos(2*pphi) ...
                           - ((35 * n.^3)/24) .* sin(3*dphi) .* cos(3*pphi));

%-----------------------------------------------------------------------

function phiP = phicentral(y, ellipsoid, scalefactor, phi0, y0);
% Fixed point iteration for the latitude of the point (y,x0), which
% lies on the central meridian.

F0 = scalefactor;
a = ellipsoid(1);

tol = 1e-12 * a;

phiP = (y - y0)/(a * F0) + phi0;
yc = ycentral(phiP, ellipsoid, F0, phi0, y0);
nIterations = 0;
while any(abs(y - yc) > tol) && nIterations < 10
    phiP = (y - yc)/(a * F0) + phiP;
    yc = ycentral(phiP, ellipsoid, scalefactor, phi0, y0);
    nIterations = nIterations + 1;
end
