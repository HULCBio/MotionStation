function [lat,lon] = interpm(lat,lon,maxdiff,method,units)

%INTERPM  Interpolates vector data to a specified data separation
%
%  [lat,lon] = INTERPM(lat,long,maxdiff) linearly interpolates between
%  vector data coordinate points where necessary to return data with no
%  two connected points separated by an angular distance greater than
%  maxdiff. Maxdiff must be in the same units as the input lat and lon
%  data.
%
%  [lat,lon] = INTERPM(lat,long,maxdiff,'method') interpolates between
%  vector data coordinate points using a specified interpolation method.
%  Valid interpolation methods strings are 'gc' for great circle, 'rh'
%  for rhumb lines, and 'lin' for linear interpolation. With no units
%  specified, lat,long and maxdiff are assumed to be in units of degrees.
%
%  [lat,lon] = INTERPM(lat,long,maxdiff,'method','units') interpolates
%  between vector data coordinate points using a specified interpolation
%  method. Inputs and outputs are in the specified units.
%
%  See also INTRPLAT, INTRPLON, RESIZEM

%  Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:42 $

if nargin == 5
	if ~isstr(method); error('Method must be a string'); end
	if ~isstr(units);  error('Units must be a string'); end
elseif nargin == 4
	if ~isstr(method); error('Method must be a string'); end
	units = 'deg';
elseif nargin == 3;
	method = 'lin';
	units = 'deg';
else
	error('Incorrect number of arguments');
end

%  Dimensional tests

if ~isequal(size(lat),size(lon))
    error('Inconsistent lat and lon dimensions')
elseif max(size(maxdiff)) ~= 1
    error('Scalar maximum angular difference required')
elseif any([~isreal(lat) ~isreal(lon) ~isreal(maxdiff)])
    warning('Imaginary parts of complex arguments ignored')
	lat = real(lat);   lon = real(lon);   maxdiff = real(maxdiff);
end

%  Test the track string

if isempty(method)
    method = 'lin';       %  Default is linear interpolation
else
    validstr = strvcat('gc','rh','lin');
	indx     = strmatch(lower(method),validstr);
	if length(indx) ~= 1;       error('Unrecognized track string')
          else;                 method = deblank(validstr(indx,:));
    end
end

%  Ensure column vectors

lat = lat(:);   lon = lon(:);

%  Compute the maximum angular distance between each latitude
%  and longitude pair of points.

dist  = max( [abs(diff(lat))'; abs(diff(lon))'] )';

%  Find angular differences which exceed the maximum allowed

indx  = find( dist > maxdiff);

if ~isempty(indx)
     steps = ceil(dist(indx)/maxdiff);      %  No points added each location
     totalpts = sum(steps)-length(steps);   %  Total points to be added
     lastpt  = length(lat);                 %  Current last point in data set
	 lat(length(lat)+totalpts) = 0;         %  Pre-allocate output memory
	 lon(length(lon)+totalpts) = 0;
end

%  Fill in points where the maximum angular difference is
%  exceeded.  Linearly interpolate points between the identified
%  two end points.

for i=length(indx):-1:1

%  Set the index in the original vectors and compute the
%  interpolation steps.

    loc = indx(i);
	factors = (1:steps(i)-1)' ; %  -1 eliminates double hit at end of
	                            %  interpolation insert
	switch method
	case {'gc','rh'}

%   Interpolate along great circles or rhumb lines. If the data is crude
%   enough to require interpolation, it's sufficient to interpolate on
%   a sphere.

		[latinsert,loninsert] = track(method,...
					[lat(loc) lat(loc+1)],...
					[lon(loc) lon(loc+1)],...
					[1 0],units,steps(i)+1);

%   strip trailing NaNs inserted by track

		latinsert = latinsert(find(~isnan(latinsert)));
		loninsert = loninsert(find(~isnan(loninsert)));

%   remove starting and ending points to avoid duplication when inserted

		latinsert = latinsert(2:length(latinsert)-1);
		loninsert = loninsert(2:length(loninsert)-1);

	otherwise

% interpolate in a platte carree space

		latinsert = ((lat(loc+1)-lat(loc))/steps(i))*factors + lat(loc);
		loninsert = ((lon(loc+1)-lon(loc))/steps(i))*factors + lon(loc);

	end

%  Fill in the interpolated data

	lat=[lat(1:loc); latinsert; lat(loc+1:lastpt)];
	lon=[lon(1:loc); loninsert; lon(loc+1:lastpt)];

%  Update the last point of the data set.  Note that since
%  the output memory is pre-allocated, the current last point
%  of the data set is not equal to the length of the data vector

    lastpt = lastpt + length(latinsert);
end

