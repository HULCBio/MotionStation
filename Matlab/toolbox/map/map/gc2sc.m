function [newlat,newlong,range]=gc2sc(lat,long,az,units);

%GC2SC  Converts a great circle definition to a center and radius
%
%  [lat,lon,rng] = GC2SC(lat0,lon0,az) converts a great circle in
%  great circle notation (i.e., lat,long, azimuth, where lat/long is
%  on the circle) to small circle notation (i.e., lat,long,range,
%  where lat/long is the center of the circle and range is 90 degrees,
%  which is a definition of a great circle).  A great circle has two
%  possible centers (or zeniths), one is given.  Its antipode is the other.
%
%  [lat,lon,rng] = GC2SC(lat0,lon0,az,'units') uses the input 'units'
%  to define the angle units of the inputs and outputs.  If omitted,
%  then 'degrees' are assumed.
%
%  mat = GC2SC(...) returns a single output, where mat = [lat lon rng].
%
%  See also SCXSC, GCXGC, GCXSC

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $ $Date: 2003/08/01 18:16:16 $
%  Written by:  E. Brown, E. Byrns



if nargin < 3
    error('Incorrect number of arguments')
elseif nargin == 3
	units='degrees';
end

%  Convert input angles to radians

lat  = angledim(lat,units,'radians');
long = angledim(long,units,'radians');
az   = angledim(az,units,'radians');

% Zenith lies orthogonal to the path of the great circle, at 90 degrees distance

[newlat,newlong] = reckon('gc',lat,long,pi/2*ones(size(lat)),...
                          az+pi/2,'radians');
range = pi/2*ones(size(lat));

%  Convert output to proper units

newlat  = angledim(newlat,'radians',units);
newlong = npi2pi(newlong,'radians','exact');
newlong = angledim(newlong,'radians',units);
range   = angledim(range,'radians',units);

%  Set output arguments if necessary

if nargout < 3;  newlat = [newlat newlong range];  end
