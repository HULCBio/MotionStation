function [lat, lon] = projinv(proj, x, y)
%PROJINV Inverse map projection using the PROJ.4 library.
%
%   [LAT, LON] = PROJINV(PROJ, X, Y) returns the latitude and longitude
%   values from the inverse projection.  PROJ is a structure defining the
%   map projection.  PROJ may be a map projection MSTRUCT or a GeoTIFF INFO
%   structure.  X and Y are map coordinate arrays.  For a complete list of
%   GeoTIFF info and map projection structures that may be used with
%   PROJINV, see PROJLIST.
%
%   Example - Display 'boston.tif' in a Mercator projection.
%   -------
%   % Obtain the info structure and read the image.
%   info = geotiffinfo('boston.tif');
%   [I, cmap] = geotiffread('boston.tif');
%
%   % Create a grid for the image and convert it 
%   % to latitude and longitude.
%   [x, y] = pixcenters(info.RefMatrix, size(I),'makegrid');
%   [lat, lon] = projinv(info, x, y);
%
%   % Obtain Massachusett's stateline boundary,
%   % and create a Mercator projection with the 
%   % latitude and longitude limits of the state boundary.
%   figure;axesm('mercator')
%   [slat, slon] = extractm(usahi('stateline'),'Massachusetts');
%   setm(gca,'maplonlimit',[min(slon(:)) max(slon(:))], ...
%            'maplatlimit',[min(slat(:)) max(slat(:))])
%
%   % Display the stateline boundary and image.
%   geoshow(slat,slon,'color','black')
%   geoshow(lat,lon,ind2rgb8(I,cmap))
%   tightmap 
%
%   % Set the map boundary to the image's northern, western,
%   % and southern limits, and the eastern limit of the stateline
%   % within the image latitude boundaries.
%   ltvals = find((slat>=min(lat(:))) & (slat<=max(lat(:))));
%   setm(gca,'maplonlimit',[min(lon(:)) max(slon(ltvals))], ...
%            'maplatlimit',[min(lat(:)) max(lat(:))])
%   tightmap
%   
%   See also GEOTIFFINFO, MFWDTRAN, MINVTRAN, PROJFWD, PROJLIST.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/03/24 20:41:22 $

% Check the input arguments
checknargin(3,3,nargin,mfilename);
checkinput(x, {'numeric'}, {'real'}, mfilename, 'X', 2);
checkinput(y, {'numeric'}, {'real'}, mfilename, 'Y', 3);
if numel(x) ~= numel(y)
   eid = sprintf('%s:%s:invalidLength', getcomp, mfilename);
   msg = sprintf('The number of elements in X and Y must be equal.');
   error(eid, '%s',msg);
end

% Inverse transform the X and Y points.
[lat, lon] = projaccess('inv', proj, x, y);
