function [latcells,loncells] = polysplit(lat,lon)

%POLYSPLIT extracts segments of NaN-delimited polygon vectors to cell arrays
%
% [latcells,loncells] = POLYSPLIT(lat,lon) returns the NaN-delimited segments
% of the vectors lat and lon as cell arrays. Each element of the cell array
% contains one segment.
%
% See also POLYJOIN, POLYBOOL, POLYCUT

%  Written by:  W. Stumpf
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:17:38 $


if nargin<2, error('Incorrect number of input arguments.'), end

if ~isnumeric(lat) | ~isnumeric(lon)
	error('Inputs must be numeric arrays.')
end

%  Input dimension tests

if any([min(size(lat))    min(size(lon))]    ~= 1) | ...
   any([ndims(lat) ndims(lon)] > 2)
    error('Latitude and longitude inputs must a vector')

elseif ~isequal(size(lat),size(lon))
    error('Inconsistent dimensions on lat and lon input')
    
end

%  Ensure at a terminating NaN in the vectors

if ~isnan( lat(length(lat)) );    lat = [lat; NaN];   end
if ~isnan( lon(length(lon)) );    lon = [lon; NaN];   end

%  Ensure vectors don't begin with NaNs

if isnan(lat(1)) | isnan(lon(1))
	lat = lat(2:length(lat));
	lon = lon(2:length(lon));
end

%  Find segment demarcations

indx=find(isnan(lat));
indx2=find(isnan(lon));

if ~isequal(indx,indx2)
   error('Lat and lon must have NaNs in same locations')
end


%  Extract each segment

for i=1:length(indx)

	% Pull segment out of main vectors

	if i>1
		latcells{i}=lat(indx(i-1)+1:indx(i)-1);
		loncells{i}=lon(indx(i-1)+1:indx(i)-1);
	else
		latcells{i}=lat(1:indx(i)-1);
		loncells{i}=lon(1:indx(i)-1);
	end


end

