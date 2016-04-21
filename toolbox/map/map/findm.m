function [latout,lonout,valout] = findm(latin,lonin,map)

%FINDM  Lat/lon values of non-zero map entries
%
%  [lat,lon] = FINDM(map,maplegend) computes the latitude and
%  longitude values of non-zero regular matrix map entries.
%
%  [lat,lon,val] = FINDM(map,maplegend) also returns the
%  value at the non-zero regular matrix map entries.
%
%  [...] = FINDM(lat,lon,map) finds the non-zero entries
%  of the general matrix map.  The input lat and lon are
%  vectors corresponding to the rows and columns respectively
%  of the map.
%
%  mat = FINDM(...) returns a single output, where mat = [lat lon].
%
%  See also FIND

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:13 $


if nargin <= 1
    error('Incorrect number of arguments')

elseif nargin == 2

	map = latin;    maplegend = lonin;

	if ndims(map) ~= 2;error('Map input must be a matrix');end

	[r,c] = size(map);
    rows = 1:r;    cols = 1:c;

%  Get the limits of the map

    [latlim,lonlim] = limitm(map,maplegend);

%  Compute the latitude and longitude of the row/col data
%  Assume that each point is in the center of the specified
%  cell (hence the use of delta/2 below).

    delta = 1/maplegend(1);
    latin = min(latlim) + (rows-1)*delta + delta/2;
    lonin = min(lonlim) + (cols-1)*delta + delta/2;

end

%  Input dimension tests

if any([min(size(latin))    min(size(lonin))]    ~= 1) | ...
   any([ndims(latin) ndims(lonin)] > 2)
    error('Latitude and longitude inputs must a vector')

elseif ndims(map) ~= 2;
	error('Map input must be a matrix')

elseif length(latin) ~= size(map,1)
    error('Latitude vector must equal number of map rows')

elseif length(lonin) ~= size(map,2)
    error('Longitude vector must equal number of map columns')

elseif any([~isreal(latin) ~isreal(lonin)])
    warning('Imaginary parts of complex LAT and/or LON arguments ignored')
	latin = real(latin);    lonin = real(lonin);
end


%  Ensure column vectors

if size(latin,1) == 1;  latin = latin';  end
if size(lonin,1) == 1;  lonin = lonin';  end

%  Compute the latitude and longitude of the non-zero elements

[r,c] = find(map);
lat = latin(r);
lon = lonin(c);


%  Set the output arguments if necessary

if nargout == 1
    latout = [lat lon];

elseif nargout == 2
    latout = lat;   lonout = lon;

elseif nargout == 3
    latout = lat;   lonout = lon;  valout = map(r+(c-1)*size(map,1));
end

