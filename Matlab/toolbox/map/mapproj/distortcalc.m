function [areascale,angdef,maxscale,minscale,merscale,parscale] = distortcalc(varargin)

% DISTORTCALC calculates distortion parameters for a map projection
%
%  areascale = DISTORTCALC(lat,long) computes the area distortion for the 
%  current map projection at the specified geographic location. An area 
%  scale of 1 indicates no scale distortion. Latitude and longitude may 
%  be scalars, vectors or matrices in the angle units of the defined map 
%  projection.  
%
%  areascale = DISTORTCALC(mstruct,lat,long) uses the projection defined in 
%  the map structure mstruct.
%
%  [areascale,angdef,maxscale,minscale,merscale,parscale] = DISTORTCALC(...)
%  computes the area scale, maximum angular deformation (in the angle units of
%  the defined projection), the particular maximum and minimum scale 
%  distortions in any direction, and the particular scale along the 
%  meridian and parallel. DISTORTCALC may also be called with fewer output 
%  arguments, in the order shown.
%
%  See also MDISTORT, TISSOT

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/12/13 02:55:29 $
%
%  Ref. Maling, Coordinate Systems and Map Projections, 2nd Edition, 


if nargin == 2 & ~isstruct(varargin{1})
	  mstruct = [];
      lat   = varargin{1};
	  lon   = varargin{2};
elseif nargin == 3 & isstruct(varargin{1})
	  mstruct = varargin{1};
      lat   = varargin{2};
	  lon   = varargin{3};
else
   error('Incorrect number of arguments')	  
end

%  Retrieve map structure

if isempty(mstruct)
   [mstruct,msg] = gcm;
   if ~isempty(msg);   error(msg);   end
end

units = mstruct.angleunits;

%  Direction and scale along the meridian by finite difference

[th,len] = vfwdtran(mstruct,lat,lon,0*ones(size(lat)));

%  Components in x and y directions

th = angledim(th,units,'radians');
dxdphi =  cos(th).*len; % phi = lat
dydphi =  sin(th).*len; % phi = lat

%  Direction and scale along the parallel by finite difference

ang = angledim(90,'degrees',units);
[th,len] = vfwdtran(mstruct,lat,lon,ang*ones(size(lat)));
th = angledim(th,units,'radians');

%  Convert lat and long to radians for trig functions

lat = angledim(lat,units,'radians');
lon = angledim(lon,units,'radians');

%  Components in x and y directions

dydlambda =  sin(th).*len.*cos(lat); % lambda = lon
dxdlambda =  cos(th).*len.*cos(lat); % lambda = lon

%  Gauss parameters

E = dxdphi.^2 + dydphi.^2;
F = dxdphi.*dxdlambda + dydphi.*dydlambda ;
G = dxdlambda.^2 + dydlambda.^2;

%  Particular scale along the meridian

h = sqrt(E);

%  Particular scale along the parallel.
%  Expect divide by zeros at the poles. Turn off warnings temporarily and
%  let the IEEE math do the right thing.

warnState = warning; warning off

k = sqrt(G)./cos(lat) ;

%  Parameters used in computing scales

cosThetaPrime = F./(h.*k.*cos(lat));
sinThetaPrime = sin(acos(cosThetaPrime));

warning(warnState);

aplusb  = sqrt(h.^2 + k.^2 + 2.*h.*k.*sinThetaPrime);
aminusb = sqrt(h.^2 + k.^2 - 2.*h.*k.*sinThetaPrime);

%  Maximum particular scale at a point

a = (aplusb + aminusb)./2;

%  Minimum particular scale at a point

b = aplusb-a;

%  Area scale

p = a.*b;

%  Angular deformation

sinomegaby2 = aminusb./aplusb;
omega = 2*asin(sinomegaby2);

%  Output arguments

if nargout >=1; areascale = p; end
if nargout >=2; angdef = angledim(omega,'radians',units); end
if nargout >=3; maxscale = a; end
if nargout >=4; minscale = b; end
if nargout >=5; merscale = h; end
if nargout ==6; parscale = k; end


