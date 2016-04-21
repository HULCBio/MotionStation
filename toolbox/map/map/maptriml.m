function [lat,lon] = maptriml(lat0,lon0,latlim,lonlim)

%MAPTRIML  Trim a line map to a specified region.
%
%  [lat,lon] = MAPTRIML(lat0,lon0,latlim,lonlim) trims a line map
%  to a region specified by latlim and lonlim.  Latlim and lonlim
%  are two element vectors, defining the latitude and longitude limits
%  respectively.  The inputs lat0 and lon0 must be vectors.
%
%  See also MAPTRIMS, MAPTRIMP

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.2 $    $Date: 2004/02/01 21:57:31 $


if nargin < 4;   error('Incorrect number of arguments');   end

%  Test the inputs

if  ~isequal(sort(size(latlim)),sort(size(lonlim)),[1 2])
    error('Lat and lon limit inputs must be 2 element vectors')
end

%  Test for real inputs

if any([~isreal(lat0) ~isreal(lon0) ~isreal(latlim) ~isreal(lonlim)])
    warning('Imaginary parts of complex arguments ignored')
	lat0 = real(lat0);       lon0 = real(lon0);
	latlim = real(latlim);   lonlim = real(lonlim);
end

%  Test for consistent sized inputs

if ~isequal(size(lat0),size(lon0))
     error('Inconsistent dimensions on input data')
end

%  Ensure column vectors on input

lat0 = lat0(:);  lon0 = lon0(:);

%  Get the corners of the submap region

up    = max(latlim);   low  = min(latlim);
left  = lonlim(1);     right = lonlim(2);

%  Determine the points which lie outside the region of interest

indx = find(lat0 < low | lat0 > up | ...
            lon0 < left | lon0 > right);

%  Extract the found points by first replacing the points outside the map
%  with NaNs.  Then eliminate multiple NaNs in the vector.  This is
%  necessary incase a line segement exits and enters the trim box, so
%  as to NaN clip the exit/enter point.

if ~isempty(indx)
	 lat = lat0;             lon = lon0;
	 lat(indx) = NaN;        lon(indx) = NaN;

    nanloc = isnan(lat);	[r,c] = size(nanloc);
    nanloc = find(nanloc(1:r-1,:) & nanloc(2:r,:));
    lat(nanloc) = [];  lon(nanloc) = [];

else
    lat = lat0;       lon = lon0;
end
