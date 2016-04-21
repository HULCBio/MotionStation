function newlong=intrplon(lat,long,newlat,method,units);

%INTRPLON  Computes an interpolated longitude for a given latitude
%
%  long = INTRPLON(lat0,lon0,lat) linearly interpolates the input
%  data to determine the longitude value corresponding to lat.  The
%  input lat0 vector must be monotonic.
%
%  lat = INTRPLON(lat0,lon0,lat,'method') uses the method string to
%  determine the interpolation calculation.  Valid 'method' strings
%  are 'linear' for linear interpolation between coordinates;
%  'rh' for interpolation along a rhumb line between coordinates;
%  'gc' for interpolation along a great circle between coordinates;
%  'spline' for cubic spline interpolation between coordinates; and
%  'cubic' for cubic interpolation between coordinates.  If omitted,
%  'linear' is assumed.
%
%  lat = INTRPLON(lat0,lon0,lat,'method','units') uses the input 'units'
%  to specify the angle units for the input and output data.  If omitted,
%  'degrees' are assumed.
%
%  See also INTRPLAT

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:44 $

if nargin < 3
    error('Incorrect number of arguments')

elseif nargin == 3
	method = [];    units  = [];

elseif nargin == 4
    units = [];

end

%  Empty argument tests

if isempty(method);  method = 'linear';   end
if isempty(units);   units  = 'degrees';  end


%  Input dimension tests

if ~isequal(size(lat),size(long))
	 error('Inconsistent dimensions for latitude and longitude inputs.')

elseif any([min(size(lat))    min(size(long))] ~= 1) | ...
       any([ndims(lat) ndims(long)] > 2)
         error('Latitude and longitude inputs must a vector')

elseif max(size(lat)) == 1
	error('Longitude and latitude inputs must be at least length two')
end


sgn=1;   					% Latitude in increasing order
if any(diff(lat)<=0)
	sgn=-1; 				% Latitude in decreasing order
	if any(diff(lat)>=0)
		error('LATITUDE must be monotonic')
	end
end


%  Ensure column vectors

long=long(:);           lat=lat(:);
newlat=newlat(:);       points=length(newlat);

if max(newlat)>max(lat) | min(newlat)<min(lat)
	error('Requested point outside provided LATITUDE range.')
end

%  Preallocate space for output

newlong=zeros(size(newlat));

%  Convert inputs to radians

long   = angledim(long,units,'radians');
newlat = angledim(newlat,units,'radians');
lat    = angledim(lat,units,'radians');

%  Interpolate the data

if strcmp(method,'rh')     % Rhumb line interpolation

% Identify the indices of the bracketing latitude values for all requested points
	for i=1:points
		bound1(i)=sgn*(max(sgn*find(lat<=newlat(i))));
		bound2(i)=sgn*(min(sgn*find(lat>=newlat(i))));
	end

	bound1=bound1(:);
	bound2=bound2(:);

	% Identify those requested points which are exactly identified in latitude vector
	indx=find([bound1-bound2]==0);  % indx == exactly identified
	indx1=1:prod(size(bound1));
	indx1(indx)=[];					% indx1== ~indx
	bound11=bound1(indx1);			% bound'x'1 => do interpolation
	bound21=bound2(indx1);
	bound12=bound1(indx);			% bound'x'2 => return exact point
	bound22=bound2(indx);

	lat=pi/2-lat;					% make lats co-latitudes for calculations
	newlat=pi/2-newlat;

	if ~isempty(bound11)  % perform rhumb-line interpolation where necessary (heading uses lat, not colat)
		az = azimuth('rh',pi/2-lat(bound11),long(bound11),...
		             pi/2-lat(bound21),long(bound21),'radians');
		newlong(indx1) = long(bound11) + tan(az).*...
		                  (log(tan(lat(bound11)/2))-log(tan(newlat(indx1)/2)));
	end

	newlong(indx)=long(bound12);  % return exact longs for exact points


elseif strcmp(method,'gc')     % Great circle interpolation

% Identify the indices of the bracketing latitude values for all requested points
	for i=1:points
		bound1(i)=sgn*(max(sgn*find(lat<=newlat(i))));
		bound2(i)=sgn*(min(sgn*find(lat>=newlat(i))));
	end

	bound1=bound1(:);
	bound2=bound2(:);

	% Identify those requested points which are exactly identified in latitude vector
	indx=find([bound1-bound2]==0);  % indx == exactly identified
	indx1=1:prod(size(bound1));
	indx1(indx)=[];					% indx1== ~indx
	bound11=bound1(indx1);			% bound'x'1 => do interpolation
	bound21=bound2(indx1);
	bound12=bound1(indx);			% bound'x'2 => return exact point
	bound22=bound2(indx);

	lat=pi/2-lat;					% make lats co-latitudes for calculations
	newlat=pi/2-newlat;

	if ~isempty(bound11) % perform great circle interpolation where necessary (bearing uses lat, not colat)
		az=azimuth('gc',pi/2-lat(bound11),long(bound11),...
		            pi/2-lat(bound21),long(bound21),'radians');

		temp1=cos(newlat(indx1)).*sin(lat(bound11)).*cos(az);
		temp2=cos(lat(bound11)).*sqrt(sin(newlat(indx1)).^2 - ...
		                             (sin(lat(bound11)).*sin(az)).^2);
		temp3=1-(sin(lat(bound11)).*sin(az)).^2;

		sinrng=(temp1-temp2)./temp3;

		newlong(indx1)=long(bound11)+asin(sin(az).*sinrng./sin(newlat(indx1)));
	end

	newlong(indx)=long(bound12);  % return exact longs for exact points

else

	newlong=interp1(lat,long,newlat,method);

end

%  Convert output to desired units and make columnar

newlong=angledim(newlong(:),'radians',units);
