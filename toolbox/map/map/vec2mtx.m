function [map,maplegend] = vec2mtx(varargin)

%VEC2MTX regular matrix map from vector data
% 
%  [map,maplegend] = VEC2MTX(lat,lon,scale) creates a regular matrix map from 
%  vector data.  The returned map has values of one corresponding to the 
%  vector data, and zeros otherwise.  Lat and lon are vectors of equal length 
%  containing geographic locations in units of degrees.  The scale factor 
%  represents the number of matrix entries per single unit of latitude and 
%  longitude (eg: 10 entries per degree, 100 entries per degree).  The scale 
%  input must be scalar.
% 
%  [map,maplegend] = VEC2MTX(lat,lon,scale,latlim,lonlim) uses the two 
%  element vector latitude and longitude limits to define the extent of the 
%  map.  If omitted, the limits are computed automatically.
% 
%  [map,maplegend] = VEC2MTX(lat,lon,map1,maplegend1) uses the provided map 
%  and maplegend to define the extent of the map.  If omitted, the limits 
%  are computed automatically.
% 
%  [...] = VEC2MTX(...,'filled') also fills the area outside the border. The 
%  interior then has values of 0, the border 1 and the exterior 2. Lat and 
%  lon should contain data that closes on itself. VEC2MTX may not fill 
%  properly if the vector data extends beyond a pole.
%  
%  See also COUNTRY2MTX, LTLN2VAL, IMBEDM, ENCODEM, INTERPM

%
%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%   $Revision: 1.7.4.1 $    $Date: 2003/08/01 18:20:36 $


autolim = 0;
inputmap = 0;

% [map,maplegend] = VEC2MTX(lat,lon,scale)
% [map,maplegend] = VEC2MTX(lat,lon,scale,'filled')
if nargin == 3 | (...
					nargin == 4 & ...
					isstr(varargin{end}) & ...
					strcmp('filled',varargin{end}) ...
					)
	lat = varargin{1};
	lon = varargin{2};
	scale = varargin{3};
	lon = smoothlong(lon);
	[latlim,lonlim] = limitmV(lat,lon); % limits of vector data
	autolim = 1;
	
% [map,maplegend] = VEC2MTX(lat,lon,map1,maplegend1)
% [map,maplegend] = VEC2MTX(lat,lon,map1,maplegend1,'filled')
elseif nargin == 4  | (...
					nargin == 5 & ...
					isstr(varargin{end}) & ...
					strcmp('filled',varargin{end}) ...
					)

	lat = varargin{1};
	lon = varargin{2}; 
	map = varargin{3};
	maplegend = varargin{4};
	[latlim,lonlim] = limitm(map,maplegend); % limits of matrix data
	scale = maplegend(1);
	inputmap = 1;
	sz = size(map);

% [map,maplegend] = VEC2MTX(lat,lon,scale,latlim,lonlim)	
% [map,maplegend] = VEC2MTX(lat,lon,scale,latlim,lonlim,'filled')	
elseif nargin == 5 | (...
					nargin == 6 & ...
					isstr(varargin{end}) & ...
					strcmp('filled',varargin{end}) ...
					)
	lat = varargin{1};
	lon = varargin{2}; 
	scale = varargin{3};
	latlim = varargin{4};
	lonlim = varargin{5};

else
	error('Incorrect number of input arguments')
end
	
% ensure vector data is over the matrix

if any(lon < lonlim(1))
   lon = eastof(lon,lonlim(1));
end

% Mash in the sides to the geographic limits. 

[lat,lon] = maptrimp(lat,lon,latlim,lonlim);
if length(lat) == 1;
	error('Data completely outside geographic limits')
end

% interpolate for conversion to matrix

[lat,lon] = interpm(lat,lon,(0.9/scale));

% Increase limits by two cells, so vector data will never 
% touch the edge. This will be used to flood fill in from 
% the sides.

latlim(1) = latlim(1)-2*1/scale; 
latlim(2) = latlim(2)+2*1/scale;

lonlim(1) = lonlim(1)-2*1/scale;
lonlim(2) = lonlim(2)+2*1/scale;

% convert to matrix. Suppress warnings about points outside of map
 
[map,maplegend] =  zerom(latlim,lonlim,scale);

warnstate = warning; warning off
map = imbedm(lat,lon,1,map,maplegend);    %  Make matrix map
warning(warnstate)

% Optional fill. Fill in from the corners

[r,c] = size(map);
if isstr(varargin{end}) & strcmp('filled',varargin{end})
	map = encodem(map,[1 1 2],1) ;% floodfill region outside face
	map = encodem(map,[1 c 2],1) ;% floodfill region outside face
	map = encodem(map,[r 1 2],1) ;% floodfill region outside face
	map = encodem(map,[r c 2],1) ;% floodfill region outside face
end

% remove border to stay within requested limits

if ~autolim
	map = map(1+2:end-2,1+2:end-2);
	maplegend = maplegend + [ 0 -2*1/scale 2*1/scale];
	if inputmap & ~isequal(sz,size(map))
		map = map(1:sz(1),1:sz(2));
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latlim,lonlim] = limitmV(lat,long)

% lat = npi2pi(lat);
% long = npi2pi(long);

indx = find(~isnan(lat) & ~isnan(long)) ;

latlim = [min(lat(indx)) max(lat(indx)) ];
lonlim = [min(long(indx)) max(long(indx)) ];

 

