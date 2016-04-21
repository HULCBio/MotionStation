function [latstd,lonstd] = stdm(lat,lon,geoid,units)

%STDM  Standard deviation for geographic data
%
%  [latstd,lonstd] = STDM(lat,lon) computes standard deviation for
%  geographic data.  This function assumes that the data is distributed
%  on a sphere.  In contrast, STD assumes that the data is distributed
%  on a cartesian plane.  Deviations are "sample" standard deviations,
%  normalized by (n-1), where n is the sample size. The square of the
%  sample standard deviation is an unbiased estimator of the variance.
%  When lat and lon are vectors, a single deviation location is returned.
%  When lat and long are matrices, latstd and lonstd are row vectors
%  providing the deviations for each column of lat and lon.  N-dimensional
%  arrays are not allowed.  Deviations are taken from the mean position
%  as returned by MEANM.  Deviations in longitude consider departure.
%  The deviations are degrees of distance.
%
%  [latstd,lonstd] = STDM(lat,lon,geoid) computes the standard deviation
%  on the ellipsoid defined by the input geoid. The geoid vector
%  is of the form [semimajor axes, eccentricity].  If omitted, the
%  unit sphere, geoid = [1 0], is assumed.  The output deviations are
%  returned in the same distance units as geoid(1).
%
%  [latstd,lonstd] = STDM(lat,lon,'units') use the input 'units'
%  to define the angle units of the inputs and outputs.  If
%  omitted, 'degrees' are assumed.
%
%  [latstd,lonstd] = STDM(lat,lon,geoid,'units') is a valid form.
%
%  mat = STDM(...) returns a single output, where mat = [latbar,lonbar].
%  This is particularly useful if the lat and lon inputs are vectors.
%
%  See also STD, MEANM, STDIST

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:20:25 $


if nargin < 2
    error('Incorrect number of arguments')
elseif nargin == 2
    geoid = [];       units = [];
elseif nargin == 3
     if isstr(geoid)
	       units = geoid;     geoid = [];
	 else
	       units = [];
	 end
end

%  Empty argument tests

nogeoid=0;

if isempty(units);   units = 'degrees';   end
if isempty(geoid);   geoid = [1 0]; nogeoid=1;       end

%  Input dimension tests

if ndims(lat)>2
	error('Latitude and longitude inputs limited to two dimensions.')
end

if ~isequal(size(lat),size(lon))
    error('Inconsistent dimensions on latitude and longitude inputs')
end

%  Test the geoid parameter

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  Convert inputs to radians.  Ensure that longitudes are
%  in the range 0 to 2pi since they will be treated as distances.

lat = angledim(lat,units,'radians');
lon = angledim(lon,units,'radians');
lon = zero22pi(lon,'radians','exact');

%  Calculate the appropriate geographic means

[latbar,lonbar]=meanm(lat,lon,geoid,'radians');

[m,n]=size(lat);
if m==1
	if n==1
		latstd=0;
		lonstd=0;
	else
		lat=lat(:);  lon=lon(:);
		latstd=norm(lat-latbar)*geoid(1)/(n-1);
		lonstd=norm(departure(lon,lonbar*ones(n,1),lat,geoid,'radians'))/(n-1);
	end

else  % it's a matrix, do column-wise

	latstd=zeros(1,n);
	lonstd=zeros(1,n);
	for i=1:n
		latstd(i)=norm(lat(:,i)-latbar(i))*geoid(1)/(m-1);
		lonstd(i)=norm(departure(lon(:,i),lonbar(i)*ones(m,1),lat(:,i),geoid,'radians'))/(m-1);
	end
end



%  Set the output arguments

if nogeoid
	latstd=angledim(latstd,'radians',units);
	lonstd=angledim(lonstd,'radians',units);
end

if nargout < 2
    latstd = [latstd lonstd];

end
