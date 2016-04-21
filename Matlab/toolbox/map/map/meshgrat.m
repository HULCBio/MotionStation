function [lat,lon] = meshgrat(map,maplegend,npts,units)

%MESHGRAT  Construct a graticule for a surface map object
%
%  [lat,lon] = MESHGRAT(map,maplegend) constructs a graticule for
%  a regular surface map object.  A map graticule is the actual points
%  projected, and then the matrix map is warped to the graticule grid.
%  A finer graticule (larger matrices) produces a higher fidelity map.
%  In this form, the default graticule size is equal to the size of
%  the map.
%
%  [lat,lon] = MESHGRAT(map,maplegend,npts) produces a graticule of
%  size npts.  The npts is a two element vector of the form
%  npts = [# lat grid points, # lon grid points].  If npts = [],
%  then the graticule returned is the Mapping Toolbox default
%  graticule size 50 by 100. If omitted, a graticule of the same 
%  size as map is returned.
%
%  [lat,lon] = MESHGRAT(lat0,lon0) takes the vectors lat0 and lon0
%  and returns graticule matrices.  In this form, MESHGRAT is similar
%  to MESHGRID.
%
%  [lat,lon] = MESHGRAT(lat0,lon0,'units') uses the input 'units' to
%  specify the angle units of the input vectors and output matrices.
%  If omitted, 'degrees' are assumed.
%
%  [lat,lon] = MESHGRAT(latlim,lonlim,npts) returns a graticule
%  mesh dimensioned npts.  The input vectors are two element vectors 
%  specifying the graticule latitude and longitude limits in 
%  degrees. The npts is a two element vector where
%  npts = [# lat grid points, # lon grid points].  If npts = [],
%  then the graticule returned is the Mapping Toolbox default
%  graticule size 50 by 100.
%
%  [lat,lon] = MESHGRAT(latlim,lonlim,'units') and
%  [lat,lon] = MESHGRAT(latlim,lonlim,npts,'units') uses the input
%  'units' to specify the angle units of the input and output matrices.
%  If omitted, 'degrees' are assumed.
%
%  See also MESHM, SURFM, SURFACEM, MESHGRID

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:17:12 $

unitsflag = 0;  %  Used to control a warning in lat/lon usage

if nargin < 2
	  error('Incorrect number of arguments')

elseif nargin == 2          %  Two arguments defaults to size of map
      npts = size(map);
      units = [];
elseif nargin == 3 & isstr(npts)
      units = npts;   npts = [];
	  unitsflag = 1;    %  Skip warning
elseif nargin == 3 & ~isstr(npts)
      units = [];
end

%  Test of the input npts.  If npts is empty (three arguments supplied)
%  then use the Mapping Toolbox default graticule size.

if isempty(npts);  npts = [50 100];    end
if isempty(units); units = 'degrees';  end

% Epsilon used to eliminate edge colisions (eg 0 and 360 degrees).

epsilon = 1.0E-10;

%  Retrieve and set appropriate coordinate data

if min(size(map)) == 1 & min(size(maplegend)) == 1    % Lat/lon usage

     lat = map;       lon = maplegend;

	 lat = angledim(lat,units,'degrees');
	 lon = angledim(lon,units,'degrees');

	 if any([ndims(lat) ndims(lon)] > 2)
	      error('Input vectors can not contain pages')
	 elseif (length(lat) > 2 | length(lon) > 2) & ...
	        ((nargin == 3 & ~unitsflag) | nargin == 4)
	      warning('Parameter NPTS ignored with vector LAT and/or LONG arguments')
	 elseif ~isequal(sort(size(npts)),[1 2])
    		error('Parameter NPTS must be a 2 element vector.')
	 elseif any([~isreal(lat) ~isreal(lon)])
	      warning('Imaginary parts of complex LAT and/or LON arguments ignored')
		  lat = real(lat);    lon = real(lon);
	 end

     if isequal(sort(size(lat)),[1 2])
			lat = linspace(min(lat)+epsilon, max(lat)-epsilon, max(npts(1),length(lat)));
	  end
     if isequal(sort(size(lon)),[1 2])
			lon = linspace(min(lon)+epsilon, max(lon)-epsilon, max(npts(2),length(lon)));
	  end
	 [lon,lat] = meshgrid(lon,lat);

	 lat = angledim(lat,'degrees',units);
	 lon = angledim(lon,'degrees',units);

elseif min(size(map)) ~= 1 & min(size(maplegend)) == 1  %  Map/maplegend usage

     if ndims(map) > 2
         error('Input map can not have pages')
     elseif ~isequal(sort(size(npts)),[1 2])
    		error('Parameter NPTS must be a 2 element vector.')
     elseif ~isequal(sort(size(maplegend)),[1 3])
         error('Input maplegend must be a 3 element vector')
     end

     [lat, lon] = limitm(map,maplegend);
	 lat = linspace(min(lat)+epsilon, max(lat)-epsilon, npts(1));
     lon = linspace(min(lon)+epsilon, max(lon)-epsilon, npts(2));
	 [lon,lat] = meshgrid(lon,lat);
else
    error('Incorrect specification of MESHGRAT inputs.')
end


%  Adjust the output arguments if necessary

if nargout ~= 2;  lat = [lat lon];  end

