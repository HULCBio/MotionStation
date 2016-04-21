function [map,maplegend] = country2mtx(varargin)
%COUNTRY2MTX Create a matrix map for a country in the worldlo database.
% 
%   [map,maplegend] = COUNTRY2MTX('countryname',scale) constructs a regular
%   matrix map of a country in the worldlo POpatch database.  The scale 
%   factor represents the number of matrix entries per degree of latitude
%   and  longitude (eg: 10 entries per degree, 100 entries per degree).
%   The scale  input must be scalar.  The returned matrix has values of 0
%   in the  interior of the country, 1 on the border and 2 in the exterior.
%  
%   [map,maplegend] = COUNTRY2MTX('countryname',scale,latlim,lonlim) uses
%   the  two element vector latitude and longitude limits to define the
%   extent of  the map.  If omitted, the limits are computed automatically.
%   COUNTRY2MTX may not fill properly if the vector data extends beyond a 
%   pole.
% 
%   [map,maplegend] = COUNTRY2MTX('countryname',map1,maplegend1) uses the  
%   limits of the provided map.
%    
%   See also VEC2MTX, LTLN2VAL, IMBEDM, ENCODEM, INTERPM

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by: W. Stumpf
%   $Revision: 1.5.4.1 $    $Date: 2003/08/01 18:18:11 $

% Check inputs
checknargin(2,4,nargin,mfilename);
countryname = varargin{1};
checkinput(countryname,'char',{},mfilename,'COUNTRYNAME',1);

[lat,lon] = extractm(worldlo('POpatch'),countryname);

if ~isempty(strmatch('ant',lower(countryname))) 
    % antarctica
    lon = zero22pi(lon);
end

[map,maplegend] = vec2mtx(lat,lon,varargin{2:end},'filled');



