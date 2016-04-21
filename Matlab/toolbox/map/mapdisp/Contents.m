% Mapping Toolbox Map Definition and Display.
%
% Map Creation and High Level Display.
%   axesm       - Create a new map axes/define a map projection.
%   displaym    - Project features from v1 geographic data structures.
%   grid2image  - Display a regular data grid as an image.
%
% Automated Map Creation.
%   usamap      - Map the United States of America using atlas data.
%   worldmap    - Map a country, region or the world using atlas data.
%
% Displaying Lines and Contours.
%   contourm    - Project a contour plot of map data.
%   contour3m   - Project a contour plot of map data in 3-D space.
%   contourfm   - Project a filled contour plot of map data. 
%   linem       - Create and project a line.
%   plotm       - Project lines and points.
%   plot3m      - Project lines and points in 3-D space.
%
% Displaying Patch Data.
%   fillm       - Project filled 2-D map polygons.
%   fill3m      - Project filled 3-D map polygons in 3-D space.
%   patchesm    - Project patches as individual objects.
%   patchm      - Project patch objects.
%
% Displaying Data Grids.
%   meshm       - Warp a regular data grid a projected graticule mesh.
%   pcolorm     - Project a regular data grid in the z = 0 plane.
%   surfacem    - Warp geolocated data to a projected graticule mesh.
%   surfm       - Project a geolocated data grid on a map axes.
%
% Displaying Light Objects and Lighted Surfaces.
%   lightm      - Project a light source onto the current map.
%   meshlsrm    - Project 3-D lighted shaded relief for regular data grid.
%   surflm      - Project a geolocated data grid with lighting.
%   surflsrm    - Project 3-D lighted shaded relief for geolocated data.
%   shaderel    - Construct cdata and colormap for colored shaded relief.
%
% Dislaying Thematic Maps.
%   cometm      - Project a 2-D comet plot.
%   comet3m     - Project a 3-D comet plot.
%   quiverm     - Project a 2-D quiver plot.
%   quiver3m    - Project a 3-D quiver plot.
%   scatterm    - Project point markers with variable color and area.
%   stem3m      - Project a stem map.
%   symbolm     - Project point markers with variable size.
%
% Interactive Track and Circle Definition.
%   scircleg    - Display a small circle defined via mouse input.
%   sectorg     - Display a small circle sector defined via mouse input.
%   trackg      - Display a great circle or rhumb line by mouse input.
%
% Visualizing Map Distortions.
%   mdistort    - Display contours of constant map distortion.
%   tissot      - Project Tissot indicatrices on a map.
%
% Annotating Map Displays.
%   clabelm     - Add contour labels to a map contour plot.
%   clegendm    - Add a legend labels to a map contour plot.
%   degchar     - Return the LaTeX degree symbol character.
%   framem      - Toggle and control the display of the map frame.
%   gridm       - Toggle and control the display of the map grid.
%   lcolorbar   - Append a colorbar with text labels.
%   mlabel      - Toggle and control the display of meridian labels.
%   mlabelzero22pi - Convert meridian labels to the range [0,360] degrees.
%   northarrow  - Add graphic element pointing to the geographic North Pole.
%   plabel      - Toggle and control the display of parallel labels.
%   rotatetext  - Rotate text to the projected graticule.
%   scaleruler  - Add graphic scale.
%   textm       - Project text annotation on a map.
%
% Colormaps for Map Displays.
%   contourcmap - Create a contour colormap for a projected data grid.
%   demcmap     - Create a colormap appropriate to terrain elevation data.
%   polcmap     - Create a colormap appropriate to a political map.
%
% Interactive Map Positions.
%   gcpmap      - Get current mouse point from the map.
%   gtextm      - Place text on a 2-D map using a mouse.
%   inputm      - Return latitudes and longitudes of mouse click positions.
%
% Map Object and Projection Properties.
%   cart2grn    - Transform from projected coordinates to Greenwich frame.
%   gcm         - Get current map projection structure.
%   getm        - Get map object properties.
%   handlem     - Get handle of displayed map objects.
%   ismap       - True if axes have a map projection defined.
%   ismapped    - True if object is projected on a map axes.
%   makemapped  - Make an object a mapped object.
%   namem       - Determine the names for valid graphics objects.
%   project     - Project a displayed graphics object.
%   restack     - Restacks objects within the axes.
%   rotatem     - Transform map data to new origin and orientation.
%   setm        - Set and modify properties of a map.
%   tagm        - Assign a name to a graphics object using the tag property.
%   zdatam      - Adjust the z plane of displayed map objects.
%
% Controlling Map Appearance.
%   axesscale   - Resize axes for equivalent scale.
%   camposm     - Set axes camera position using geographic coordinates.
%   camtargm    - Set axes camera target using geographic coordinates.
%   camupm      - Set axes camera up vector using geographic coordinates.
%   daspectm    - Set the figure DataAspectRatio property for a map.
%   paperscale  - Set the figure paper size for a given map scale.
%   previewmap  - Preview map at printed size.
%   tightmap    - Remove white space around a map.
%
% Clearing Map Displays/Managing Visibility.
%   clma        - Clear current map axes.
%   clmo        - Clear specified graphic objects from map axes.
%   hidem       - Hide specified graphic objects on map axes.
%   showaxes    - Toggle display of map coordinate axes.
%   showm       - Show specified graphic objects.
%   trimcart    - Trim graphic objects to the map frame.
%
% Trimming and Clipping.
%   clipdata    - Clip map data at the -pi to pi border of a display.
%   trimdata    - Trim map data exceeding projection limits.
%   undoclip    - Remove object clips introduced by CLIPDATA.
%   undotrim    - Remove object trims introduced by TRIMDATA.
%
% Graphical User Interfaces.
%   axesmui     - Interactively define map axes properties.
%   clrmenu     - Add a colormap menu to a figure window.
%   cmapui      - Create custom colormap.
%   colorm      - Create index map colormaps.
%   colorui     - Interactively define an RGB color.
%   demdataui   - Interactively select elevation data from external sources.
%   getseeds    - Get seed locations and values for encoding maps.
%   lightmui    - Control position of lights on a globe or 3D map.
%   maptrim     - Customize map data sets.
%   maptool     - Add menu activated tools to a map figure.
%   mlayers     - Manipulate map layers defined with structure data.
%   mobjects    - Manipulate object sets displayed on an axes.
%   originui    - Interactively modify map origin.
%   panzoom     - Pan and zoom on a 2D plot.
%   parallelui  - Interactively modify map parallels.
%   qrydata     - Create queries associated with map axes.
%   rootlayr    - Construct mlayer cell array input for user workspace.
%   scirclui    - Interactively add small circles to a map.
%   seedm       - Seed regular matrix maps.
%   trackui     - Interactively add great circles and rhumb lines to a map.
%   uimaptbx    - Process button down callbacks in Mapping Toolbox.
%   utmzoneui   - Choose or identify a UTM zone by clicking on a map.
%   vmap0ui     - Extract selected data from Vector Map Level 0 CD-ROMs.
%
% Atlas Data Functions
%   country2mtx - Create a raster map grid of a country from worldlo data.
%   usahi       - Return high-resolution vector data for the United States.
%   usalo       - Return vector data for the United States.
%   worldhi     - Return high-resolution vector data for the world.
%   worldlo     - Return vector data for the world or oceans.
%
% Atlas Data MAT-files.
%   coast       - World coastline latitude and longitude arrays.
%   geoid       - Global geoid height grid in meters at one cell/degree.
%   oceanlo     - Ocean mask patches.
%   usahi       - High-resolution United States vector data.
%   usalo       - United States vector data.
%   usamtx      - Data grid at 5 cells/degree for states in the USA.
%   worldhi     - High-resolution world vector data.
%   worldlo     - World vector data.
%   worldmtx    - Data grid at one cell/degree for countries of the world.
%   worldmtxmed - Data grid at 4 cells/degree for countries of the world.
%
% See also MAP, MAPDEMOS, MAPFORMATS, MAPPROJ.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.20.4.2 $ $Date: 2003/12/13 02:52:43 $


% Undocumented functions.
%   loadcape    - Load Cape Code elevation image as regular data grid.
%   guifactm    - Compute scaling factors for cross platform GUIs.
%   leadblnk    - Delete leading characters common to all rows of a string matrix.
%   maphlp1     - Help Utility for Selected GUIs.
%   setfaces    - Construct the face matrix for a patch, given vertex data.
%   shiftspc    - Left or right justify a string matrix.
