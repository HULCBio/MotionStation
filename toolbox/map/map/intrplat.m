function newlat=intrplat(long,lat,newlong,method,units);

%INTRPLAT  Computes an interpolated latitude for a given longitude
%
%  lat = INTRPLAT(lon0,lat0,long) linearly interpolates the input
%  data to determine the latitude value corresponding to long.  The
%  input lon0 vector must be monotonic.
%
%  lat = INTRPLAT(lon0,lat0,long,'method') uses the method string to
%  determine the interpolation calculation.  Valid 'method' strings
%  are 'linear' for linear interpolation between coordinates;
%  'rh' for interpolation along a rhumb line between coordinates;
%  'gc' for interpolation along a great circle between coordinates;
%  'spline' for cubic spline interpolation between coordinates; and
%  'cubic' for cubic interpolation between coordinates.  If omitted,
%  'linear' is assumed.
%
%  lat = INTRPLAT(lon0,lat0,long,'method','units') uses the input 'units'
%  to specify the angle units for the input and output data.  If omitted,
%  'degrees' are assumed.
%
%  See also INTRPLON

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:43 $

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

elseif any([min(size(lat))    min(size(long))]    ~= 1) | ...
       any([ndims(lat) ndims(long)] > 2)
         error('Latitude and longitude inputs must a vector')

elseif max(size(long)) == 1
	error('Longitude and latitude inputs must be at least length two')
end


sgn=1;   					% Longitude in increasing order
if any(diff(long)<=0)
	sgn=-1; 				% Longitude in decreasing order
	if any(diff(long)>=0)
		error('LONGITUDE must be monotonic')
	end
end


%  Ensure column vectors

long=long(:);           lat=lat(:);
newlong=newlong(:);     points=length(newlong);

if max(newlong)>max(long) |  min(newlong)<min(long)
	error('Requested point outside provided LONGITUDE range.')
end

%  Preallocate space for output

newlat=zeros(size(newlong));

%  Convert inputs to radians

long    = angledim(long,units,'radians');
newlong = angledim(newlong,units,'radians');
lat     = angledim(lat,units,'radians');

%  Interpolate the data

if strcmp(method,'rh')     % Rhumb line interpolation

% Identify the indices of the bracketing longitude values for all requested points
	for i=1:points
		bound1(i)=sgn*(max(sgn*find(long<=newlong(i))));
		bound2(i)=sgn*(min(sgn*find(long>=newlong(i))));
	end

	bound1=bound1(:);
	bound2=bound2(:);

	% Identify those requested points which are exactly identified in longitude vector
	indx=find([bound1-bound2]==0);  % indx == exactly identified
	indx1=1:prod(size(bound1));
	indx1(indx)=[];					% indx1== ~indx
	bound11=bound1(indx1);			% bound'x'1 => do interpolation
	bound21=bound2(indx1);
	bound12=bound1(indx);			% bound'x'2 => return exact point
	bound22=bound2(indx);

	lat=pi/2-lat;					% make lats co-latitudes for calculations

	if ~isempty(bound11)  % perform rhumb-line interpolation where necessary (heading uses lat, not colat)
		az=azimuth('rh',pi/2-lat(bound11),long(bound11),...
		                pi/2-lat(bound21),long(bound21),'radians');
		newlat(indx1)=pi/2-2*atan(tan(lat(bound11)/2).*...
		                          exp((long(bound11)-newlong(indx1))./tan(az)));
	end

	newlat(indx)=pi/2-lat(bound12);  % return exact lats for exact points (change back from colatitude)



elseif strcmp(method,'gc')     % Great circle interpolation

% Identify the indices of the bracketing longitude values for all requested points
	for i=1:points
		bound1(i)=sgn*(max(sgn*find(long<=newlong(i))));
		bound2(i)=sgn*(min(sgn*find(long>=newlong(i))));
	end

	bound1=bound1(:);
	bound2=bound2(:);

	% Identify those requested points which are exactly identified in longitude vector
	indx=find([bound1-bound2]==0);  % indx == exactly identified
	indx1=1:prod(size(bound1));
	indx1(indx)=[]; 				% indx1== ~indx
	bound11=bound1(indx1);			% bound'x'1 => do interpolation
	bound21=bound2(indx1);
	bound12=bound1(indx);			% bound'x'2 => return exact point
	bound22=bound2(indx);

	lat=pi/2-lat;					% make lats co-latitudes for calculations

	if ~isempty(bound11) % perform great circle interpolation where necessary
		az=azimuth('gc',pi/2-lat(bound11),long(bound11),...
		                pi/2-lat(bound21),long(bound21),'radians');
		dellong=newlong(indx1)-long(bound11);
		temp1=cos(lat(bound11)).*sin(az).*sin(dellong);
		temp2=cos(az).*cos(dellong);
		antiaz=acos(temp1-temp2);

		temp3=sin(lat(bound11)).*sin(dellong);
		temp4=sin(antiaz);

		rng=asin(temp3./temp4);

		[newlat(indx1),dummy]=reckon('gc',pi/2-lat(bound11),long(bound11),rng,az,'radians');
	end

	newlat(indx)=pi/2-lat(bound12);% return exact lats for exact points (change back from colatitude)

else

	newlat=interp1(long,lat,newlong,method);

end

%  Convert output to desired units and make columnar

newlat=angledim(newlat(:),'radians',units);
