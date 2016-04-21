function [dataArgs, displayType, info] = readMapData(mapfilename, filename)
%READMAPDATA Read map data from a file.
%
%   [DATAARGS, DISPLAYTYPE, INFO] = READMAPDATA(MAPFILENAME, FILENAME)
%   reads the  filename, FILENAME, and returns the map data in the cell
%   array DATAARGS, the type of map data in DISPLAYTPE, and the information
%   structure in INFO. 
%
%   FILENAME must the name of a file in GeoTIFF, ESRI Shape, Arc ASCII
%   Grid, or SDTS DEM format.
%
%   DATAARGS is a cell array containing the data from the file.  DATAARGS
%   must conform to the output of PARSEMAPINPUTS.
%
%   DISPLAYTYPE is a string with name  'mesh', 'surface', 'contour', 
%   'point', 'line', 'polygon', or 'image', 
%  
%   See also BUILDMAPDATA, MAPSHOW, MAPVIEW, PARSEMAPINPUTS.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:41 $

%-------------------------------------------------------------------------

[path,name,extension] = fileparts(filename);
ext = lower(extension);
switch ext

 case {'.tif','.tiff','.jpg','.jpeg','.png'}
 
    displayType = 'image';
    switch (ext)
     case {'.jpg','.jpeg','.png'}
       [I, cmap, R, info] = readImageAndWorldFile(filename);

     case {'.tif','.tiff'}
       [value, info] = isGeoTIFF(filename);
       if value
         [I, cmap, R, bbox] = geotiffread(filename);
         if isempty(R)
           eid = sprintf('%s:%s:emptyRefMatrix', getcomp, mfilename);
           msg = sprintf('%s\n%s%s', ...
               'The reference matrix is not defined by the GeoTiff file.',...
               'Consider using MAKEREFMAT or a worldfile ', ...
               'to define the referencing matrix.');
           error(eid, '%s',msg)
         end
       else
         [I, cmap, R, info] = readImageAndWorldFile(filename);
       end
    end
    dataArgs = {I,cmap,R};
    if isempty(cmap)
      dataArgs(2) = [];
    end

 case {'.shp','.shx','.dbf'}
    dataArgs = {shaperead(filename)};
    displayType = lower(dataArgs{1}(1).Geometry);
    info = shapeinfo(filename);

 case {'.grd','.ddf'}
    if strcmp('.grd',ext)
      [Z,R]= arcgridread(filename);
      info = struct([]);
    else
      [Z,R]= sdtsdemread(filename);
      info = sdtsinfo(filename);
    end
    dataArgs = {Z,R};
    displayType = 'surface';
    
 otherwise
    eid = sprintf('%s:%s:unsupportedFileFormat', getcomp, mfilename);
    msg = sprintf('%s%s%s%s%s%s%s%s\n%s', ...
                  'Function ',upper(mapfilename), ' cannot read ', ... 
                  'the file, ''',filename,''', with format ''',ext, ...
                  '''.','The format is not supported.');
    error(eid, '%s',msg)
end

%--------------------------------------------------------------------
function [I, cmap, R, info] = readImageAndWorldFile(filename)
worldfilename = getworldfilename(filename);

if ~exist(worldfilename,'file')
  [path,name,ext] = fileparts(filename);
  [tmppath,tmpname,tmpext] = fileparts(worldfilename);
  eid = sprintf('%s:%s:needsWorldFile', getcomp, mfilename);
  msg = sprintf('%s%s%s%s%s', ...
                  'A worldfile, with a ''',tmpext, ...
                  ''' extension, must accompany the ''', ext, ''' file.');
  error(eid, '%s',msg)
end

[I,cmap] = imread(filename);
info = imfinfo(filename);
R = worldfileread(getworldfilename(filename));

%--------------------------------------------------------------------
function [value, info] = isGeoTIFF(filename)
value = true;
info = [];
try
  info = geotiffinfo(filename);
catch
  value = false;
end

