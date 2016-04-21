function handles = geoshow(varargin)
%GEOSHOW Display map latitude and longitude data. 
%
%   GEOSHOW(S) displays the graphic features stored in the geographic data
%   structure S.  If Lat and Lon fields are present, then their coordinate
%   values are projected to map coordinates if the axes has a projection.
%   Otherwise, Lon will be plotted as LAT and Lat as LON.  If S includes X
%   and Y fields, then they are used directly to plot features in map
%   coordinates.
%
%   GEOSHOW(LAT,LON) or 
%   GEOSHOW(LAT,LON, ..., 'DisplayType', DISPLAYTYPE, ...)
%   displays the equal length coordinate vectors, LAT and LON.  LAT and LON
%   may contain embedded NaNs, delimiting coordinates of lines or polygons.
%   In this case, DISPLAYTYPE can be 'point', 'line', or 'polygon' and
%   defaults to 'line'.
%
%   GEOSHOW(LAT,LON,Z, ..., 'DisplayType', DISPLAYTYPE, ...) where LAT and
%   LON are M-by-N coordinate arrays, Z is an M-by-N array of class double,
%   and DISPLAYTYPE is 'texturemap' or 'contour', displays a geolocated
%   data grid.  Z may contain NaN values.  
%
%   GEOSHOW(LAT,LON,I)  
%   GEOSHOW(LAT,LON,BW) 
%   GEOSHOW(LAT,LON,X,CMAP) 
%   GEOSHOW(LAT,LON,RGB)
%   where I is an intensity image, BW is a logical image, X is an indexed
%   image with colormap CMAP, or RGB is a truecolor image, displays a
%   geolocated image. The image is rendered as a texturemap on a
%   zero-elevation surface.  If specified, 'DisplayType' must be set to
%   'image'.  Examples of geolocated images include a color composite from
%   a satellite swath or an image originally referenced to a different
%   coordinate system. 
%
%   GEOSHOW(Z,R, ..., 'DisplayType', DISPLAYTYPE,...) where Z is class
%   double and DISPLAYTYPE is 'contour', or 'texturemap', displays a
%   regular M-by-N data grid.  R is a referencing matrix or referencing
%   vector.
%
%   GEOSHOW(I,R) 
%   GEOSHOW(BW,R) 
%   GEOSHOW(RGB,R) 
%   GEOSHOW(A,CMAP,R) 
%   displays an image georeferenced to latitude/longitude.  It is rendered
%   as an image object if the display geometry permits; otherwise, the
%   image is rendered as a texturemap on a zero-elevation surface. If
%   specified, 'DisplayType' must be set to 'image'. 
% 
%   GEOSHOW(FILENAME) displays data from FILENAME, according to the type of
%   file format. The DisplayType parameter is automatically set, according
%   to the following table:
%
%       Format                           DisplayType
%       ------                           -----------
%       shapefile                       'point', 'line', or 'polygon'
%       GeoTIFF                         'image'
%       TIFF/JPEG/PNG with a world file 'image'
%       ARC ASCII GRID                  'surface' (may be overridden)
%       SDTS raster                     'surface' (may be overridden)
%
%   GEOSHOW(AX, ...) sets the axes parent to AX. This is equivalent to 
%   GEOSHOW(..., 'Parent', ax, ...)
%
%   H = GEOSHOW(...) returns a handle to a MATLAB graphics object, an array
%   of object handles, or in the case of vector data, a map graphics
%   object.
%
%   GEOSHOW(..., PARAM1, VAL1, PARAM2, VAL2, ...) specifies parameter/value
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
%                  grid           'texturemap', or 'contour' 
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
%                                   'MarkerFaceColor','MarkerSize', and
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
%                  structure. See example 3 below.
%
%                  To change the default symbolization rule for a
%                  property/value pair in the symbol spec, prepend the word
%                  'Default' to the graphics property name (listed in the
%                  above table). See example 2 below.
%
%   Example 1 
%   ---------
%   % Display world coastlines, without a projection.
%
%   load coast
%   figure
%   geoshow(lat,long);
%
%   % Add the international boundaries as black lines
%   boundaries = updategeostruct(worldlo('POline'));
%   symbols = makesymbolspec('Line',{'Default','Color','black'});
%   hold on
%   geoshow(gca,boundaries(1),'SymbolSpec',symbols);
%
%
%   Example 2 
%   ---------
%   % Override the SymbolSpec default rule.
%
%   % Create a SymbolSpec to display Alaska and Hawaii as red polygons.
%   symbols = makesymbolspec('Polygon', ...
%                            {'tag','Alaska','FaceColor','red'}, ...
%                            {'tag','Hawaii','FaceColor','red'});
%
%   % Display all the other states in blue.
%   figure;worldmap('na');
%   geoshow(usahi('statepatch'),'SymbolSpec',symbols, ...
%                               'DefaultFaceColor','blue', ...
%                               'DefaultEdgeColor','black');
%   axis off
%   
%
%   Example 3 
%   ---------
%   % Display the Korean data grid, with the worldhi boundaries.
%
%   % Display the Korean data grid as a texture map. 
%   load korea
%   figure;axesm mercator
%   geoshow(gca,map,refvec,'DisplayType','texturemap');
%   colormap(demcmap(map))
%
%   % Set the display to the bounding box of the data grid.
%   [latlim,lonlim] = limitm(map,refvec);
%   [x,y]=mfwdtran(latlim,lonlim);
%   set(gca,'Xlim',[min(x(:)), max(x(:))]);
%   set(gca,'Ylim',[min(y(:)), max(y(:))]);
%
%   % Get the region's worldhi data.
%   [korea_lat, korea_lon]= extractm(worldhi(latlim, lonlim));
% 
%   % Display the worldhi boundaries.
%   hold on
%   geoshow(korea_lat, korea_lon);
%
%   % Mask the ocean.
%   geoshow(worldlo('oceanmask'),'EdgeColor','none','FaceColor','c');
%
%
%   Example 4 
%   ---------
%   % Display the EGM96 geoid heights.
%
%   % Display the geoid as a texture map. 
%   load geoid
%   figure
%   axesm eckert4; framem; gridm;
%   h=geoshow(geoid, geoidrefvec, 'DisplayType','texturemap');
%   axis off
%
%   % Set the Z data to the geoid height values, rather than a
%   % surface with zero elevation.
%   set(h,'ZData',geoid);
%   light; material(0.6*[ 1 1 1]);
%
%   set(gca,'dataaspectratio',[ 1 1 200]);
%   hcb = colorbar('horiz');
%   set(get(hcb,'Xlabel'),'String','EGM96 geoid heights in m.')
%
%   % Mask out all the land.
%   load coast
%   geoshow(lat,long,'DisplayType','Polygon','FaceColor','black');  
%   zdatam(handlem('patch'),max(geoid(:)));
%
%
%   Example 5
%   ---------
%   % Display the moon albedo image unprojected 
%   % and in an orthographic projection.
%   
%   load moonalb
%   
%   % Unprojected. 
%   figure
%   geoshow(moonalb,moonalbrefvec) 
%   
%   % Orthographic projection.
%   figure
%   axesm ortho 
%   geoshow(moonalb, moonalbrefvec)
%   axis off
%                 
%   See also MAKESYMBOLSPEC, MAPSHOW, MAPVIEW, UPDATEGEOSTRUCT.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/03/24 20:41:06 $

%-------------------------------------------------------------------------

% Check the number of inputs
checknargin(1,inf,nargin,mfilename);

% Parse the inputs from the command line.
[ax, mapdata, layerName] = parseMapInputs(mfilename, varargin{:}, ...
                                          'CoordinateType','geographic');

% Render the graphics structure onto the axes.
h = renderMapData(ax, mapdata);

% Return the HG handles if requested.
if nargout == 1
  handles = h;
end
