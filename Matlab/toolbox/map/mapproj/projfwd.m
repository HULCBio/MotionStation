function [x, y] = projfwd(proj, lat, lon)
%PROJFWD Forward map projection using the PROJ.4 library.
%
%   [X, Y] = PROJFWD(PROJ, LAT, LON) returns the X and Y map coordinates
%   from the forward projection.  PROJ is a structure defining the map
%   projection.  PROJ may be a map projection MSTRUCT or a GeoTIFF INFO
%   structure.  LAT and LON are arrays of latitude and longitude
%   coordinates. For a complete list of GeoTIFF info and map projection
%   structures that may be used with PROJFWD, see PROJLIST.
%
%   Example 1
%   ---------
%   % Project the latitude and longitude bounding box corners
%   % of 'boston.tif'.
%
%   % Obtain the info structure.
%   info = geotiffinfo('boston.tif');
%
%   % Project the corner latitude and longitude coordinates
%   [x, y] = projfwd(info, ...
%                    info.CornerCoords.LAT, ...
%                    info.CornerCoords.LON);
%
%   % Display the image and corners.
%   figure
%   mapshow('boston.tif')
%   mapshow(gca,[x; x(1)],[y; y(1)],'Color','cyan')
%
%
%   Example 2
%   ---------
%   % Overlay 'boston.tif' on top of 'boston_ovr.jpg'. 
%
%   % Obtain the info structure.
%   info = geotiffinfo('boston.tif');
%
%   % Read the boston_ovr.jpg image and worldfile.
%   [I,cmap] = imread('boston_ovr.jpg');
%   R = worldfileread(getworldfilename('boston_ovr.jpg'));
%
%   % Create a latitude and longitude grid.
%   [lon, lat] = pixcenters(R, size(I), 'makegrid');
%
%   % Project the grid to the same projection as 'boston.tif'.
%   [x, y] = projfwd(info, lat, lon);
%
%   % Overlay 'boston_ovr.jpg' and 'boston.tif'.
%   figure
%   mapshow(x,y,I,cmap);
%   hold on
%   mapshow('boston.tif');
%
%   See also GEOTIFFINFO, MFWDTRAN, MINVTRAN, PROJINV, PROJLIST.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/03/24 20:41:21 $

% Check the input arguments
checknargin(3,3,nargin,mfilename);
checkinput(lat, {'numeric'}, {'real'}, mfilename, 'LAT', 2);
checkinput(lon, {'numeric'}, {'real'}, mfilename, 'LON', 3);
if numel(lat) ~= numel(lon)
   eid = sprintf('%s:%s:invalidLength', getcomp, mfilename);
   msg = sprintf('The number of elements in LAT and LON must be equal.');
   error(eid, '%s',msg);
end

% Project the latitude and longitude points.
[x,y] = projaccess('fwd', proj, lon, lat);
