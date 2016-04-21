function [newlat,newlong]=gcxsc(gclat,gclong,gcaz,sclat,sclong,scrange,units)

%GCXSC  Computes the intersection points between a great and a small circle
%
%  [lat,lon] = GCXSC(gclat,gclong,gcaz,sclat,sclong,scrange) finds the
%  intersection points, if any, between a great circle given in great
%  circle notation (lat,long,azimuth, lat/long on the circle) and a
%  small circle given in small circle notation (lat,long,range,
%  lat/long the center of the circle). GCXSC returns NaNs if the
%  circles do not intersect or are identical.  The great circle(s)
%  must be input first.  Only spherical geoids are supported.
%
%  [lat,lon] = GCXSC(gclat,gclong,gcaz,sclat,sclong,scrange,'units')
%  uses the input string units to define the angle units for the
%  inputs and outputs.
%
%  mat = GCXSC(...) returns a single output, where mat = [lat lon].
%
%  See also SCXSC, CROSSFIX, GCXGC, RHXRH

%  Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:19 $


if nargin < 6
    error('Incorrect number of arguments')
elseif nargin == 6
    units = 'degrees';
end

%  Input dimension tests

if any([ndims(gclat) ndims(gclong) ndims(gcaz)  ...
        ndims(sclat) ndims(sclong) ndims(scrange)] > 2)
     error('Input matrices can not contain pages')

elseif ~isequal(size(gclat),size(gclong),size(gcaz),...
                size(sclat),size(sclong),size(scrange))
	     error('Inconsistent dimensions on inputs')
end

%  Convert input angle to radians

gclat   = angledim(gclat,units,'radians');
sclat   = angledim(sclat,units,'radians');
gclong  = angledim(gclong,units,'radians');
sclong  = angledim(sclong,units,'radians');
gcaz    = angledim(gcaz,units,'radians');
scrange = angledim(scrange,units,'radians');

%  Convert great circle definition to a center and radius format

[gclat,gclong,gcrange]=gc2sc(gclat,gclong,gcaz,'radians');

%  Compute the intersection points

[newlat,newlong]=scxsc(gclat,gclong,gcrange,sclat,sclong,scrange,'radians');

%  Transform the output to the proper units

newlat  = angledim(newlat,'radians',units);
newlong = angledim(newlong,'radians',units);

%  Set the output argument if necessary

if nargout < 2;  newlat = [newlat newlong];  end
