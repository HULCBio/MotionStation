function figHandle = mapview(varargin)
%MAPVIEW Interactive map viewer.
%
%   Use the Map Viewer to work with vector, image, and raster data grids in
%   a map coordinate system: load data, pan and zoom on the map, control
%   the map scale of your screen display, control the order, visibility,
%   and symbolization of map layers, annotate your map, and click to learn
%   more about individual vector features.  MAPVIEW complements MAPSHOW and
%   GEOSHOW, which are for constructing maps in ordinary figure windows in
%   a less interactive, script-oriented way. 
%
%   MAPVIEW (with no arguments) starts a new Map Viewer in an empty state.
%
%   Importing Data
%   --------------
%   The Map Viewer opens with no data loaded and an empty map display
%   window.  The first step is to import a data set. Use the options in
%   File menu to select data from a file or from the MATLAB workspace:
%
%     Import From File         Use the file browsing dialog to open a
%                              file in one the following formats:
%                              Shapefile, GeoTIFF, SDTS DEM, Arc ASCII
%                              Grid, TIFF, JPEG, or PNG with world file.
%                              This option imports the data into to the
%                              viewer but does not add it to to your
%                              workspace.
%
%     Import From Workspace    Select referencing matrix and data
%     -> Raster Data -> Image  representing the image from the list of
%                              workspace variables. If the image type is
%                              truecolor (RGB), specify which band
%                              represents the Red, Green and Blue
%                              intensities.
%                    
%     Import From Workspace    Select X and Y geolocation arrays and the 
%     -> Raster Data -> Grid   grid data from the list of workspace 
%                              variables.
%
%     Import From Workspace    Select X and Y coordinate vectors from the
%     -> Vector Data           list of workspace variables and select the
%     -> Map Coordinates       type of geometry.  The X and Y variables can
%                              specify multiple line segments or multiple
%                              polygons by inserting NaNs at matching
%                              locations in the coordinate vectors.
%
%     Import From Workspace    Select an geographic data structure array
%     -> Vector Data           from the list of workspace variables.
%     -> Geographic Data
%        Structure
%
%   Once you import your first data set, the Map Viewer automatically sets
%   the limits of its map display window to the spatial extent of the
%   imported data.
%
%   Working in Map Coordinates
%   --------------------------
%   As you move any of the Map Viewer cursors across the map display area,
%   the coordinate readout in the lower left corners shows you the cursor
%   position in map X and Y coordinates.
%
%   The Map Viewer requires that all currently-viewed data sets possess the
%   same coordinate system and length units.  This is likely to be the case
%   for data sets that originated from a common source.  If it is not the
%   case, you will need to adjust coordinates before importing data into
%   the Map Viewer.
%
%   If some or all of your data is in geographic coordinates, use PROJFWD
%   or MFWDTRAN to project latitudes and longitudes to your desired map
%   coordinate system before you import it.  When starting from a different
%   projection, you must first un-project to latitude and longitude using
%   PROJINV or MINVTRAN, then re-project with PROJFWD or MFWDTRAN.  You may
%   also need to adjust the horizontal datum of your data (using, for
%   example, the free GEOTRANS application from the Geospatial Sciences
%   Division of the U.S. National Imagery and Mapping Agency (NIMA),
%   www.nima.mil). If you simply need a change of units, multiply by the
%   appropriate conversion factor obtained from UNITSRATIO.
%
%   MAPVIEW can also display data in unprojected geographic coordinates, if
%   you consistently substitute longitude for map X and latitude for map Y.
%   Geographic coordinates must be consistently expressed in either degrees
%   or radians (not both at once).  When using geographic coordinates, do
%   not specify the viewer's map units (see below); you can only use the
%   Map Viewer's map scale display when working in linear units of length.
%
%   Setting Map Units and Scale
%   ---------------------------
%   If you tell the Map Viewer which length unit you are using, it can
%   calculate an approximate map scale for your on-screen display.  Set the
%   map units with either the drop-down menu at the bottom of the display
%   or the Set Map Units item in the Tools menu.
%
%   The scale computed by the Map Viewer is displayed in the window just
%   above the map units drop-down.  To change your display scale, while
%   keeping the center of the map display fixed, simply edit this text box.
%   Make sure to format your text in the standard way (1:N, where N is a
%   positive number such that a distance on the ground is N times the same
%   distance on your screen, e.g., 1:24000).
%
%   The scale is approximate because it depends on MATLAB's estimate of the
%   size of your screen pixels.  It is also approximate if your projection
%   introduces significant distortion.  If your data fall in a fairly small
%   area and you use a conformal projection (e.g., UTM with all data in a
%   single zone), the scale will be very consistent across your entire map.
%
%   Navigating Your Map
%   -------------------
%   By default, the Map Viewer sets the limits of your map window to match
%   the extent of the first data set that you load.  You'll probably want
%   to adjust this to see some areas in greater detail 
%
%   The Map Viewer provides several tools to control the limits of your map
%   window and the map scale of the data display.  Some are familiar from
%   standard MATLAB figure windows.
%
%      Zoom in                 Drag a box to zoom in on a specific area or
%                              click on a point to zoom in with that point
%                              centered in the map display.
%
%      Zoom out                Click on a point to zoom out with that point
%                              centered in the map display.
%
%      Pan tool                Click, hold, and drag to reposition the
%                              selected point in the display window, while
%                              holding the map scale fixed.  Release when
%                              satisified with new display limits.
%
%      Fit to window           Set the map display to enclose all
%                              currently-loaded data layers.  This is
%                              equivalant to selecting Fit to Window in the
%                              View menu.
%
%      Back to previous view   Click this button once to return the map
%                              scale and display center to their values
%                              prior to the most recent zoom, pan, or scale
%                              change.  Click repeatedly to undo earlier
%                              changes.  This is equivalent to selecting
%                              Previous View in the view menu.
%
%   Another way to zoom in or out, while keeping the center of the view
%   fixed at the same map coordinates, is to directly edit the map scale
%   box at the bottom of the screen.
%
%   Managing Map Layers
%   -------------------
%   Each time you import a set of vectors, an image, or a data grid into
%   the Map Viewer, the new data is stored in a new map layer.  The layers
%   form an ordered stack.   Each layer is listed as an item in the Layers
%   menu, with its position in the menu indicating its position in the
%   stack.
%
%   When you import a new layer, the Map Viewer automatically places it at
%   the top of the layer stack. To reposition a layer in the stack, select
%   it in the Layers menu, slide right, and select "To Top", "To Bottom",
%   "Move Up",or  "Move Down" from the pop-up submenu.
%
%   The vector features or raster in a given layer obscures coincident
%   elements of any underlying layers. To control layers that are obscuring
%   one another, you can also toggle layer visibility on and off.  Use item
%   "Visible" in the slide-right menu.  Or simply remove a layer from the
%   Map Viewer via the "Remove" item in the slide-right menu.
%
%   Remember that even if a layer's visibility is 'on', the layer will not
%   appear if its contents are located completely outside the current
%   display limits or are obscured by another layer.
%
%   Symbolizing Vector Features
%   ---------------------------
%   When point, line, and polygon layers are loaded, the Map Viewer
%   initializes their graphics properties as follows:
%
%     point              LineStyle = 'none'
%     (line objects)     Marker = 'x'
%                        MarkerEdgeColor = <randomly generated value>
%                        MarkerFaceColor = 'none'
%
%     line               Color = <randomly generated value>
%     (line objects)     LineStyle = '-'
%	                     Marker = 'none'
%
%     polygon            EdgeColor = [0 0 0]
%     (patch objects)    FaceColor = <randomly generated value>
%
%   To override symbolism defaults for a vector layer, use MAKESYMBOLSPEC
%   to create a symbol specification or "symbolspec" in the workspace.  A
%   symbolspec contains a set of rules for  setting vector graphics
%   properties based on the values of feature attributes.  For instance, if
%   you have a line layer representing roads of various classes (e.g.,
%   major highway, secondary road, etc.), you can create a symbolspec to
%   use a different color and/or line width and/or line style for each road
%   class.  See the MAKESYMBOLSPEC help for examples and to learn how to
%   construct a symbolspec.  If you regularly work with data sets sharing a
%   common set of feature attributes, you might wish to save one or more
%   symbolspecs in a MAT-file (or save calls to MAKESYMBOLSPEC in an
%   m-file).
%
%   Once you have a symbolspec in your workspace, select your vector layer
%   in the Layers menu, then slide right and click on Set Symbol Spec,
%   which opens a dialog box.  Use the dialog box to select the symbolspec
%   from your workspace.
%
%   Getting Information About Vector Features
%   -----------------------------------------
%   The datatip tool and the info tool provide different ways to check the
%   attributes of vector features that you select graphically.  Before
%   using either tool you must designate one of your vector layers as
%   "active."  (The default active layer is the first one that you
%   imported.)  Either use the Active Layer drop-down menu at the bottom of
%   your screen or select the layer in the Layers menu, slide right, and
%   select "Active."  Having a designated active layer ensures that when
%   you click on a feature you don't inadvertently select an overlapping
%   feature from a different layer.
%
%   Datatip tool    The Datatip Tool displays a feature attribute in a text
%                   label each time you click on a vector feature.  By
%                   default the attribute is the first one in the layer's
%                   attribute list.  To change which attribute is used,
%                   select the layer in the Layers menu, slide right, and
%                   click on Set Layer Attribute.  In the dialog that
%                   follows, select a different attibute, or "INDEX."  If
%                   you choose index, the Map Viewer displays the one-based
%                   index value corresponding to a given feature---based on
%                   its position in the input file or workspace array.  To
%                   remove a text label, right-click on it and choose
%                   "Delete datatip" from the context menu.  Or choose
%                   "Delete all datatips" from the context menu or the
%                   Tools menu.
%
%   Info tool       The Info Tool opens a separate text window each time
%                   you click on a vector feature.  The window displays all
%                   the attribute names and values for that feature, in
%                   contrast to the Datatip Tool which displays only the
%                   value of a single attibute.  If you need to compare two
%                   or more features, simply click on each one and view the
%                   info windows together.  Use its close button to close
%                   an info window when you're done with it, or choose
%                   "Close All Info Windows" from the tools menu.
%
%   Annotating Your Map
%   -------------------
%   Use the text, line, or arrow annotation tools to mark and highlight
%   points on interest on your map, or select the corresponding items in
%   the Insert menu.  Note that to insert a second object of the same type,
%   you must re-select the appropriate tool.  In addition, the Insert menu
%   allows you to insert axis labels and a title.  Use the "Select
%   annotations" tool and Edit menu to modify or remove your annotations.
%   The Map Viewer manages annotations separately from data layers;
%   annotations always stay on top.  Note that annotations cannot be saved,
%   although they appear on a map exported to an image format, as described
%   below.
%
%   Creating and Using Additional Views
%   -----------------------------------
%   Use File->New View to create an additional Map Viewer window linked to
%   an existing window.  Consider using an additional window when you want
%   to see your map at different scales at the same time (e.g., a detailed
%   view plus an overview), or when you want to simultaneously see
%   different areas of the map at large scale.  You can create as many
%   additional windows as you need, and close them when you wish. Your
%   MAPVIEW session will end when you close the last window.
%
%   Options for creating a new viewer window include: Duplicate Current
%   View, Full Extent, Full Extent of Active Layer, and Selected Area.
%   Click and drag with the "Select area" tool to define a selected area.
%
%   A new viewer window will differ from existing windows mainly in terms
%   of the visible map extent and scale.  (It will also omit annotations
%   and any labels you added with the datatip tool.)  You'll see the same
%   layers in the same order with the same settings (including active
%   layer).  Updates to layers (insertion/removal, order, visibility, label
%   attribute, and symbolization) in one viewer window propagate
%   automatically to all the windows with which it is linked.  Updates to
%   annotations and datatip labels do not propagate.
%
%   If you need two different layer configurations in different windows,
%   launch a second MAPVIEW from the command line instead of creating an
%   additional window.  Its views will not be linked to previous ones.
%
%   Exporting Your Map
%   ------------------
%   The Map Viewer allows you to export all or part of your map to a for
%   use in a publication or on a web page.  Use File->Save As Raster Map to
%   export an image of either the current display extent or an area
%   outlined with the "Select area" tool.  Select a format, PNG, TIFF,
%   JPEG, from the dropdown menu in the export dialog.  For maps including
%   vector layers, PNG (Portable Network Graphics) is often the best
%   choice.  It provides excellent quality, good compression, and is well
%   supported by modern web browsers.
%
%   See also ARCGRIDREAD, GEOSHOW, GEOTIFFREAD, MAKESYMBOLSPEC, MAPSHOW,
%            SDTSDEMREAD, SHAPEREAD, UPDATEGEOSTRUCT, WORLDFILEREAD.

%   Copyright 1996-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/04/01 16:12:09 $

checknargin(0,0,nargin,'mapview');

h = MapViewer.MapView(varargin{:});

if nargout>0
  % If there is no figure, return empty.  They user may have hit Cancel in
  % the import file dialog.
  if isempty(h.Figure)
    figHandle = [];
  else
    figHandle = h;
  end
end
