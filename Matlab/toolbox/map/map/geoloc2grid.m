function [Z, refvec] = geoloc2grid(lat, lon, A, cellsize)
%GEOLOC2GRID Convert a geolocated data array to a regular data grid.
%
%   [Z, REFVEC] = GEOLOC2GRID(LAT, LON, A, CELLSIZE) converts the
%   geolocated data array, A, given geolocation points in LAT and LON, to
%   produce a regular data grid, Z, and the corresponding referencing
%   vector REFVEC.  CELLSIZE is a scalar that specifies the width and
%   height of data cells in the regular data grid, using the same angular
%   units as LAT and LON.  Data cells in Z falling outside the area covered
%   by A are set to NaN.
%
%   Note
%   ----
%   GEOLOC2GRID provides an easy-to-use alternative to gridding geolocated 
%   data arrays with IMBEDM.  There is no need to pre-allocate the output
%   map, there are no data gaps in the output (even if CELLSIZE is chosen
%   to be very small), and the output map is smoother.
%
%   Example
%   -------
%   % Load the geolocated data array 'map1' and grid it to 1/2-degree cells.
%   load mapmtx
%   cellsize = 0.5;
%   [Z, refvec] = geoloc2grid(lt1, lg1, map1, cellsize);
%
%   % Create a figure
%   f = figure;
%   [cmap,clim] = demcmap(map1);
%   set(f,'Colormap',cmap,'Color','w')
%
%   % Define map limits
%   latlim = [-35 70];
%   lonlim = [0 100];
%
%   % Display 'map1' as a geolocated data array in subplot 1
%   subplot(1,2,1)
%   ax = axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim,...
%              'Grid','on','MeridianLabel','on','ParallelLabel','on');
%   set(ax,'Visible','off')
%   geoshow(lt1, lg1, map1, 'DisplayType', 'texturemap');
%
%   % Display 'Z' as a regular data grid in subplot 2
%   subplot(1,2,2)
%   ax = axesm('mercator','MapLatLimit',latlim,'MapLonLimit',lonlim,...
%              'Grid','on','MeridianLabel','on','ParallelLabel','on');
%   set(ax,'Visible','off')
%   geoshow(Z, refvec, 'DisplayType', 'texturemap');

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:50:17 $

% TO DO:
%   Generalize to the case where size(lat) and size(lon) ~= size(A).
%   See page 2-64 in the Mapping Toolbox User's Guide.

checklatlon(lat, lon, mfilename, 'LAT', 'LON', 1, 2);
checkinput(A,'numeric',{'real','2d','nonempty'}, mfilename,'A', 3);

if any(size(lat) ~= size(A)) 
    eid=sprintf('%s:%s:invalidLatLonSize', getcomp, mfilename);
    error(eid,'%s','LAT and LON must have the same size as A.')
end

if numel(cellsize) ~= 1
    eid = sprintf('%s:%s:cellsizeNotScalar',getcomp,mfilename);
    error(eid, '%s','CELLSIZE must be a scalar.');
end

if cellsize <= 0
    eid = sprintf('%s:%s:cellsizeNotPositive',getcomp,mfilename);
    error(eid, '%s','CELLSIZE must be positive.');
end

ab1 = abs(diff(lon,1,1));
ab2 = abs(diff(lon,1,2));
lonCheck1 = max(ab1(:));
lonCheck2 = max(ab2(:));
if isempty(lonCheck1) || isempty(lonCheck2) || ...
   (lonCheck1 > 10*cellsize) || (lonCheck2 > 10*cellsize)
    wid = sprintf('%s:%s:possibleLongitudeWrap', getcomp, mfilename);
    warning(wid,'Longitude values may wrap. Consider using ZERO22PI or NPI2PI.');
end

% Extend limits to even degrees in lat and lon
latlim = [floor(min(lat(:))),ceil(max(lat(:)))];
lonlim = [floor(min(lon(:))),ceil(max(lon(:)))];

halfcell = cellsize/2;
Z = griddata(lon, lat, A,...
           ((lonlim(1)+halfcell):cellsize:(lonlim(2)-halfcell)),...
           ((latlim(1)+halfcell):cellsize:(latlim(2)-halfcell))');
            
refvec = [1/cellsize, latlim(1) + cellsize*size(Z,1), lonlim(1)];

