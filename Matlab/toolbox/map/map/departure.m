function dist=departure(long1,long2,lat,geoid,units)

%DEPARTURE  Departure of longitudes at specific latitudes
%
%  d = DEPARTURE(long1,long2,lat) computes the departure distance from
%  long1 to long2 at the input latitude lat.  Departure is the
%  distance along a specific parallel between two meridians.  The
%  output d is returned in degrees of arc length on a sphere.
%
%  d = DEPARTURE(long1,long2,lat,geoid) computes the departure
%  assuming that the input points lie on the ellipsoid defined by
%  the input geoid.  The geoid vector is of the form
%  [semimajor axes, eccentricity].
%
%  d = DEPARTURE(long1,long2,lat,'units') uses the input string 'units'
%  to define the angle units of the input and output data.  In this
%  form, the departure is returned as an arc length in the units
%  specified by 'units'.  If 'units' is omitted, 'degrees' are assumed.
%
%  d = DEPARTURE(long1,long2,lat,geoid,'units') is a valid calling
%  form.  In this case, the departure is computed in the same units as
%  the semimajor axes of the geoid vector.
%
%  See also DISTANCE

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:15:49 $

if nargin < 3
    error('Incorrect number of arguments')
elseif nargin == 3
    geoid = [];       units = [];
elseif nargin == 4
     if isstr(geoid)
	       units = geoid;     geoid = [];
	 else
	       units = [];
	 end
end

%  Empty argument tests
nogeoid=0;

if isempty(units);   units = 'degrees';   end
if isempty(geoid);   geoid = [1 0]; nogeoid=1;      end

%  Input dimension tests

if ~isequal(size(long1),size(long2))
    error('Inconsistent dimensions on longitude inputs')
end

if ~isequal(size(long1),size(lat))
    error('Inconsistent dimensions on latitude and longitude inputs')
end

%  Test the geoid parameter

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  Convert inputs to radians.  Ensure that longitudes are
%  in the range 0 to 2pi since they will be treated as distances.

lat = angledim(lat,units,'radians');
long1 = angledim(long1,units,'radians');
long1 = zero22pi(long1,'radians','exact');
long2 = angledim(long2,units,'radians');
long2 = zero22pi(long2,'radians','exact');

r=rcurve('parallel',geoid,lat,'radians');

deltalong=abs(long1-long2);

dist=r.*deltalong;


if nogeoid
	dist=angledim(dist,'radians',units);
end
