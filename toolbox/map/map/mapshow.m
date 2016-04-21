function handles = mapshow(varargin)
%MAPSHOW Display map data.
%
%   MAPSHOW(S) displays the graphic features stored in the geographic data
%   structure S.  If S includes X and Y fields, then they are used directly
%   to plot features in map coordinates. If Lat and Lon fields are present
%   instead, then their coordinate values are projected to map coordinates
%   if the axes has a projection. Otherwise, Lon will be plotted as X and
%   Lat as Y.
%
%   MAPSHOW(X,Y) or 
%   MAPSHOW(X,Y, ..., 'DisplayType', DISPLAYTYPE, ...)
%   displays the equal length coordinate vectors, X and Y.  X and Y may
%   contain embedded NaNs, delimiting coordinates of lines or polygons.
%   DISPLAYTYPE can be 'point', 'line', or 'polygon' and defaults to
%   'line'.
%
%   MAPSHOW(X,Y,Z, ..., 'DisplayType', DISPLAYTYPE, ...) where X and Y are
%   M-by-N coordinate arrays, Z is an M-by-N array of class double,  and
%   DISPLAYTYPE is 'surface', 'mesh', 'texturemap', or 'contour', displays
%   a geolocated data grid, Z. Z may contain NaN values.  
%
%   MAPSHOW(X,Y,I)  
%   MAPSHOW(X,Y,BW) 
%   MAPSHOW(X,Y,A,CMAP) 
%   MAPSHOW(X,Y,RGB)
%   where I is an intensity image, BW is a logical image, A is an indexed
%   image with colormap CMAP, or RGB is a truecolor image, displays a
%   geolocated image. The image is rendered as a texturemap on a
%   zero-elevation surface.  If specified, 'DisplayType' must be set to
%   'image'.  Examples of geolocated images include a color composite from
%   a satellite swath or an image originally referenced to a different
%   coordinate system.
%
%   MAPSHOW(Z,R, ..., 'DisplayType', DISPLAYTYPE,...) where Z is class
%   double and  DISPLAYTYPE is 'surface', 'mesh', 'texturemap', or
%   'contour', displays a regular M-by-N data grid.  R is a referencing
%   matrix or referencing vector.
%
%   MAPSHOW(I,R) 
%   MAPSHOW(BW,R) 
%   MAPSHOW(RGB,R) 
%   MAPSHOW(A,CMAP,R) 
%   displays a georeferenced image.  It is rendered as an image object if
%   the display geometry permits; otherwise, the image is rendered as a
%   texturemap on a zero-elevation surface. If specified, 'DisplayType'
%   must be set to 'image'.
%
%   MAPSHOW(FILENAME) displays data from FILENAME, according to the type of
%   file format. The DisplayType parameter is automatically set, according
%   to the following table:
%
%       Format                          DisplayType
%       ------                          -----------
%       shapefile                       'point', 'line', or 'polygon'
%       GeoTIFF                         'image'
%       TIFF/JPEG/PNG with a world file 'image'
%       ARC ASCII GRID                  'surface' (may be overridden)
%       SDTS raster                     'surface' (may be overridden)
%
%   MAPSHOW(AX, ...) sets the axes parent to AX. This is equivalent to 
%   MAPSHOW(..., 'Parent', ax, ...)
%
%   H = MAPSHOW(...) returns a handle to a MATLAB graphics object, an array
%   of object handles, or in the case of vector data, a map graphics
%   object.
%
%   MAPSHOW(..., PARAM1, VAL1, PARAM2, VAL2, ...) specifies parameter/value
%   pairs that modify the type of display or set MATLAB graphics properties.
%   Parameter names can be abbreviated and are case-insensitive.
%
%   Parameters include:
%
%   'DisplayType'  The DisplayType parameter specifies the type of graphic
%                  display for the data.  The value must be consistent with
%                  the type of data being displayed as shown in the
%                  following table:
%
%                  Data type      Value
%                  ---------      -----
%                  vector         'point', 'line', or 'polygon'
%
%                  image          'image'
%
%                  grid           'surface', 'mesh', 'texturemap', or
%                                 'contour'
%
%   Graphics       In addition to specifying a parent axes, the following
%   Properties     properties may be set for line, point, and polygon
%                  DisplayType:
%
%                  DisplayType      Property Name
%                  -----------      --------------
%                  'line'           'Color', 'LineStyle', 'LineWidth', and
%                                   'Visible'.
%
%                  'point'          'Marker', 'Color', 'MarkerEdgeColor',
%                                   'MarkerFaceColor', 'MarkerSize', and
%                                   'Visible'.
%
%                  'polygon'        'FaceColor', 'FaceAlpha', 'LineStyle',
%                                   'LineWidth', 'EdgeColor', 'EdgeAlpha',
%                                   and 'Visible'.
%
%                  Refer to the MATLAB Graphics documentation on line,
%                  patch, image, surface, and mesh for a complete
%                  description of these properties and their values.
%
%   'SymbolSpec'   The SymbolSpec parameter specifies the symbolization
%                  rules used for vector data through a structure returned
%                  by MAKESYMBOLSPEC. It is used only for vector data.
%
%   SymbolSpec     In  the case where both SymbolSpec and one or more
%   Override       graphics properties are specified, the graphics
%                  properties will override any settings in the symbol spec
%                  structure. See example 5 below.
%
%                  To change the default symbolization rule for a
%                  property/value pair in the symbol spec, prepend the word
%                  'Default' to the graphics property name (listed in the
%                  above table). See example 4 below.
%
%
%   Example 1 
%   ---------
%   % Display the roads geographic data structure.
%
%   roads = shaperead('concord_roads.shp');
%   figure
%   mapshow(roads);
%
%   
%   Example 2
%   ---------
%   % Display the roads shape and change the LineStyle.
%
%   figure
%   mapshow('concord_roads.shp','LineStyle',':');
%
%
%   Example 3 
%   ---------
%   % Display the roads shape, and render using a SymbolSpec.
%
%   roadspec = makesymbolspec('Line',...
%                             {'ADMIN_TYPE',0,'Color','c'}, ...
%                             {'ADMIN_TYPE',3,'Color','r'},...
%                             {'CLASS',6,'Visible','off'},...
%                             {'CLASS',[1 4],'LineWidth',2});
%   figure
%   mapshow('concord_roads.shp','SymbolSpec',roadspec);
%
%   
%   Example 4 
%   ---------
%   % Override default properties of the SymbolSpec.
%
%   roadspec = makesymbolspec('Line',...
%                             {'ADMIN_TYPE',0,'Color','c'}, ...
%                             {'ADMIN_TYPE',3,'Color','r'},...
%                             {'CLASS',6,'Visible','off'},...
%                             {'CLASS',[1 4],'LineWidth',2});
%   figure
%   mapshow('concord_roads.shp','SymbolSpec',roadspec,'DefaultColor','b', ...
%           'DefaultLineStyle','-.');
%
%
%   Example 5 
%   ---------
%   % Override a graphics property of the SymbolSpec.
%
%   roadspec = makesymbolspec('Line',...
%                             {'ADMIN_TYPE',0,'Color','c'}, ...
%                             {'ADMIN_TYPE',3,'Color','r'},...
%                             {'CLASS',6,'Visible','off'},...
%                             {'CLASS',[1 4],'LineWidth',2});
%   figure
%   mapshow('concord_roads.shp','SymbolSpec',roadspec,'Color','b');
%
%
%   Example 6 
%   ---------
%   % Display the ponds and roads shape in one figure.
%
%   figure
%   mapshow('concord_roads.shp');
%   mapshow(gca,'concord_hydro_line.shp','Color','b');
%   mapshow(gca,'concord_hydro_area.shp','FaceColor','b','EdgeColor','b');
%
%
%   Example 7 
%   ---------
%   % View the Mount Washington SDTS DEM terrain data.
%
%   % View the Mount Washington terrain data as a mesh.
%   figure
%   h = mapshow('9129CATD.ddf','DisplayType','mesh');
%   Z = get(h,'ZData');
%   colormap(demcmap(Z))
%
%   % View the Mount Washington terrain data as a surface.
%   figure
%   mapshow('9129CATD.ddf');
%   colormap(demcmap(Z))
%   view(3); % View  as a 3-d surface
%   axis normal;
%
%
%   Example 8 
%   ----------
%   % Display the grid and contour lines of Mount Washington 
%   % and Mount Dartmouth.
%
%   figure
%   [Z_W, R_W] = arcgridread('MtWashington-ft.grd');
%   [Z_D, R_D] = arcgridread('MountDartmouth-ft.grd');
%   mapshow(Z_W, R_W,'DisplayType','surface');
%   hold on
%   mapshow(gca,Z_W, R_W,'DisplayType','contour');
%   mapshow(gca,Z_D, R_D, 'DisplayType','surface');
%   mapshow(gca,Z_D, R_D,'DisplayType','contour');
%   % Set the contour lines to the max surface value
%   zdatam(handlem('line'),max([Z_D(:)' Z_W(:)']));
%   colormap(demcmap(Z_W))
%
%
%   Example 9 
%   ----------
%   % Display an image with a worldfile.
%
%   figure
%   mapshow('concord_ortho_e.tif');
%
%
%   See also ARCGRIDREAD, GEOTIFFREAD, MAKESYMBOLSPEC, MAPVIEW, 
%            SDTSDEMREAD, SHAPEREAD, UPDATEGEOSTRUCT. 

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:50:28 $

%-------------------------------------------------------------------------

% Check the number of inputs
checknargin(1,inf,nargin,mfilename);

% Parse the inputs from the command line.
[ax, mapdata, layerName] = parseMapInputs(mfilename, varargin{:});

% Render the graphics structure onto the axes.
h = renderMapData(ax, mapdata);

% Return the HG handles if requested.
if nargout == 1
  handles = h;
end

