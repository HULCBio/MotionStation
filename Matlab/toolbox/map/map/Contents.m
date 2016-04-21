% Mapping Toolbox
% Version 2.0.2 (R14) 05-May-2004
%
% GEOSPATIAL DATA IMPORT AND ACCESS.
%
% Standard File Formats.
%
%   arcgridread    - Read a gridded data set in Arc ASCII Grid Format.
%   geotiffinfo    - Information about a GeoTIFF file.
%   geotiffread    - Read a georeferenced image from GeoTIFF file.
%   getworldfilename - Derive a worldfile name from an image file name.
%   sdtsdemread    - Read data from an SDTS raster/DEM data set.
%   sdtsinfo       - Information about an SDTS data set.
%   shapeinfo      - Information about a shapefile.
%   shaperead      - Read vector feature coordinates and attributes from a shapefile.
%   worldfileread  - Read a worldfile and return a referencing matrix.
%   worldfilewrite - Construct a worldfile from a referencing matrix.
%
% Gridded Terrain and Bathymetry Products.
%
%   dted         - Read U.S. Dept. of Defense Digital Terrain Elevation Data (DTED).
%   dteds        - Return DTED data file names covering a latitude-longitude box.
%   etopo5       - Read 5-minute gridded terrain/bathymetry from global ETOPO5 data set.
%   globedem     - Read Global Land One-km Base Elevation (GLOBE) elevation data.
%   globedems    - Return GLOBE data file names covering a latitude-longitude box.
%   gtopo30      - Read 30-arc-second global digital elevation model (GTOPO30).
%   gtopo30s     - Return GTOPO30 data file names covering a latitude-longitude box.
%   satbath      - Read 2-minute global terrain/bathymetry from Smith and Sandwell.
%   tbase        - Read 5-minute global terrain elevations from TerrainBase.
%   usgs24kdem   - Read a USGS 7.5-minute (30-meter) Digital Elevation Model.
%   usgsdem      - Read a USGS 1-degree (3-arc-second) Digital Elevation Model.
%   usgsdems     - Return USGS 1-Degree DEM file names covering a latitude-longitude box.
%
% Vector Map Products.
%
%   dcwdata      - Read selected data from the Digital Chart of the World.
%   dcwgaz       - Search for entries in a Digital Chart of the World gazette file.
%   dcwrdx       - Read the Digital Chart of the World index file.
%   dcwread      - Read a Digital Chart of the World file.
%   dcwrhead     - Read Digital Chart of the World file headers.
%   fipsname     - Read the name file used to index the TIGER thinned boundary files.
%   gshhs        - Read Global Self-consistent Hierarchical High-resolution Shoreline.
%   tgrline      - Read TIGER/Line data.
%   tigermif     - Read a TIGER MIF thinned boundary file.
%   tigerp       - Read TIGER p and pa thinned boundary files.
%   vmap0data    - Read selected data from the Vector Map Level 0 CD-ROMs.
%   vmap0rdx     - Read the Vector Map Level 0 index file.
%   vmap0read    - Read a Vector Map Level 0 file.
%   vmap0rhead   - Read Vector Map Level 0 file headers.
%
% Miscellaneous Data Sets.
%
%   avhrrgoode   - Read AVHRR data product stored in Goode projection.
%   avhrrlambert - Read AVHRR data product stored in Lambert projection.
%   egm96geoid   - Read 15-minute gridded geoid heights from EGM96 global geoid model.
%   readfk5      - Read the Fifth Fundamental Catalog of stars and its extension.
%
% Graphical User Interfaces.
%   demdataui   - Interactively select elevation data from external sources.
%   vmap0ui     - Extract selected data from Vector Map Level 0 CD-ROMs.
%
% File Reading Utilities.
%   grepfields   - Identify matching records in fixed record length files.
%   readfields   - Read fields or records from a fixed format file.
%   readmtx      - Read a matrix stored in a file.
%   spcread      - Read columns of data from an ascii text file.
%
% Ellipsoids, Radii, Areas, and Volumes.
%   almanac     - Parameters for Earth and other objects in the Solar System.
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
%   moonalb     - Clementine global albedo map of the Moon.
%   moontopo    - Clementine LIDAR topography for the Moon.
%   oceanlo     - Ocean mask patches.
%   stars       - Celestial coordinates and magnitudes of 4500+ stars.
%   usahi       - High-resolution United States vector data.
%   usalo       - United States vector data.
%   usamtx      - Data grid at 5 cells/degree for states in the USA.
%   worldhi     - High-resolution world vector data.
%   worldlo     - World vector data.
%   worldmtx    - Data grid at one cell/degree for countries of the world.
%   worldmtxmed - Data grid at 4 cells/degree for countries of the world.
%
%
% VECTOR MAP DATA AND GEOGRAPHIC DATA STRUCTURES.
%
% Geographic Data Structures.
%   extractfield - Extract the field values from a structure.
%   extractm     - Extract coordinates from a v1 geographic data structure.
%   updategeostruct - Update a geographic data structure. 
%
% Data Manipulation.
%   bufferm     - Compute buffer zones for vector data.
%   flatearthpoly - Insert points along the dateline to the pole.
%   interpm     - Interpolate vector data to a specified data separation.
%   intrplat    - Interpolate a latitude for a given longitude.
%   intrplon    - Interpolate a longitude for a given latitude.
%   nanclip     - Clip vector data with NaNs at specified pen-down locations.
%   polybool    - Perform boolean operations on polygons.
%   polycut     - Compute branch cuts for holes in polygons.
%   polyjoin    - Convert polygon segments from cell array to vector format.
%   polymerge   - Merge line segments with matching endpoints.
%   polysplit   - Extract segments of NaN-delimited polygon vectors to cell arrays.
%   polyxpoly   - Compute line or polygon intersection points.
%   reducem     - Reduce the density of points in vector data.
%
%
% GEOREFERENCED IMAGES AND DATA GRIDS.
%
% Spatial Referencing.
%   latlon2pix  - Convert latitude-longitude coordinates to pixel coordinates.
%   limitm      - Calculate latitude/longitude bounds for a regular data grid.
%   makerefmat  - Construct an affine spatial-referencing matrix.
%   map2pix     - Convert map coordinates to pixel coordinates.
%   mapbbox     - Compute bounding box of a georeferenced image or data grid.
%   mapoutline  - Compute outline of a georeferenced image or data grid.
%   meshgrat    - Construct a graticule for a surface map object.
%   pix2latlon  - Convert pixel coordinates to latitude-longitude coordinates.
%   pix2map     - Convert pixel coordinates to map coordinates.
%   pixcenters  - Compute pixel centers for georeferenced image or data grid.
%   refmat2vec  - Convert a referencing matrix to a referencing vector.
%   refvec2mat  - Convert a referencing vector to a referencing matrix.
%   setltln     - Convert data grid rows and columns to latitude-longitude.
%   setpostn    - Convert latitude-longitude to data grid rows and columns.
%
% Visibility in Terrain.
%   viewshed    - Areas visible from a point on a digital elevation model.
%   los2        - Line of sight visibility between two points in terrain.
%
% Other Analysis/Access.
%   areamat     - Surface area covered by non-zero values in regular data grid.
%   findm       - Return latitude/longitude of non-zero data grid elements.
%   gradientm   - Calculate gradient, slope and aspect of data grid.
%   ltln2val    - Extract data grid values for specified locations.
%   mapprofile  - Interpolate between waypoints on a regular data grid.
%
% Construction and Modification.
%   changem     - Substitute values in a data array.
%   encodem     - Fill in regular data grid from seed values and locations.
%   geoloc2grid - Convert a geolocated data array to a regular data grid.
%   imbedm      - Encode data points into a regular data grid.
%   neworig     - Rotate a regular data grid on the sphere.
%   resizem     - Resize a regular data grid.
%   sizem       - Row and column dimensions needed for a regular data grid.
%   vec2mtx     - Convert latitude-longitude vectors to a regular data grid.
%
% Initialization.
%   nanm        - Construct a regular data grid of all NaNs.
%   onem        - Construct a regular data grid of all ones.
%   spzerom     - Construct a sparse regular data grid of all zeros.
%   zerom       - Construct a regular data grid of all zeros.
%
%
% MAP PROJECTIONS AND COORDINATES.
%
% Available Map Projections (in addition to PROJ.4 library). 
%   maps        - List available map projections and verify names.
%   maplist     - List map projections available in the Mapping Toolbox.
%   projlist    - List map projections supported by PROJFWD and PROJINV.
%
% Map Projection Transformations.
%   mfwdtran    - Process forward transformation.
%   minvtran    - Process inverse transformation.
%   projfwd     - Forward map projection using the PROJ.4 library.
%   projinv     - Inverse map projection using the PROJ.4 library.
%
% Angles, Scales and Distortions.
%   vfwdtran    - Transform azimuth to direction angle on map plane.
%   vinvtran    - Transform direction angle from map plane to azimuth.
%   distortcalc - Calculate distortion parameters for a map projection.
%
% Visualizing Map Distortions.
%   mdistort    - Display contours of constant map distortion.
%   tissot      - Project Tissot indicatrices on a map.
%
% Cylindrical Projections.
%   balthsrt    - Balthasart Projection.
%   behrmann    - Behrmann Projection.
%   bsam        - Bolshoi Sovietskii Atlas Mira Projection.
%   braun       - Braun Perspective Projection.
%   cassini     - Cassini Projection.
%   ccylin      - Central Cylindrical Projection.
%   eqacylin    - Equal Area Projection.
%   eqdcylin    - Equidistant Projection.
%   giso        - Gall Isographic Projection.
%   gortho      - Gall Orthographic Projection.
%   gstereo     - Gall Stereographic Projection.
%   lambcyln    - Lambert Projection.
%   mercator    - Mercator Projection.
%   miller      - Miller Projection.
%   pcarree     - Plate Carree Projection.
%   tranmerc    - Transverse Mercator Projection.
%   trystan     - Trystan Edwards Projection.
%   wetch       - Wetch Projection.
%
% Pseudocylindrical Projections.
%   apianus     - Apianus II Projection.
%   collig      - Collignon Projection.
%   craster     - Craster Parabolic Projection.
%   eckert1     - Eckert I Projection.
%   eckert2     - Eckert II  Projection.
%   eckert3     - Eckert III Projection.
%   eckert4     - Eckert IV Projection.
%   eckert5     - Eckert V Projection.
%   eckert6     - Eckert VI Projection.
%   flatplrp    - Flat-Polar Parabolic Projection.
%   flatplrq    - Flat-Polar Quartic Projection.
%   flatplrs    - Flat-Polar Sinusoidal Projection.
%   fournier    - Fournier Projection.
%   goode       - Goode Homolosine Projection.
%   hatano      - Hatano Assymmetrical Equal Area Projection.
%   kavrsky5    - Kavraisky V Projection.
%   kavrsky6    - Kavraisky VI Projection.
%   loximuth    - Loximuthal Projection.
%   modsine     - Modified Sinusoidal Projection.
%   mollweid    - Mollweide Projection.
%   putnins5    - Putnins P5 Projection.
%   quartic     - Quartic Authalic Projection.
%   robinson    - Robinson Projection.
%   sinusoid    - Sinusoidal Projection.
%   wagner4     - Wagner IV Projection.
%   winkel      - Winkel I Projection.
%
% Conic Projections.
%   eqaconic    - Albers Equal Area Conic Projection.
%   eqdconic    - Equidistant Conic Projection.
%   lambert     - Lambert Conformal Conic Projection.
%   murdoch1    - Murdoch I Conic Projection.
%   murdoch3    - Murdoch III Minimum Error Conic Projection.
%
% Polyconic and Pseudoconic Projections.
%   bonne       - Bonne Projection.
%   polycon     - Polyconic Projection.
%   vgrint1     - Van Der Grinten I Projection.
%   werner      - Werner Projection.
%
% Azimuthal, Pseudoazimuthal and Modified Azimuthal Projections.
%   aitoff      - Aitoff Projection
%   breusing    - Breusing Harmonic Mean Projection.
%   bries       - Briesemeister's Projection
%   eqaazim     - Lambert Equal Area Azimuthal Projection.
%   eqdazim     - Equidistant Azimuthal Projection.
%   gnomonic    - Gnomonic Azimuthal Projection.
%   hammer      - Hammer Projection
%   ortho       - Orthographic Azimuthal Projection.
%   stereo      - Stereographic Azimuthal Projection.
%   vperspec    - Vertical Perspective Azimuthal Projection
%   wiechel     - Weichel Equal Area Projection.
%
% UTM and UPS Systems.
%   ups         - Universal Polar Stereographic (UPS) Projection
%   utm         - Universal Transverse Mercator (UTM) Projection.
%   utmgeoid    - Select ellipsoid for a given UTM zone.
%   utmzone     - Select a UTM zone.
%
% Three Dimensional Globe Display.
%   globe       - Render Earth as a sphere in 3-D graphics.
%
% Longitude Wrapping.
%   eastof       - Wrap longitudes to values east of a meridian.
%   npi2pi       - Wrap latitudes to the [-180 180] degree interval.
%   smoothlong   - Remove discontinuities in longitude data.
%   westof       - Wrap longitudes to values west of a meridian.
%   zero22pi     - Wrap longitudes to the [0 360) degree interval.
%
% Rotating Coordinates on the Sphere.
%   newpole     - Compute origin vector to rotate a point to the pole.
%   org2pol     - Compute location of the north pole in a rotated map.
%   putpole     - Compute origin vector to rotate north pole to a specific point.
%
% Trimming and Clipping.
%   clipdata    - Clip map data at the -pi to pi border of a display.
%   trimdata    - Trim map data exceeding projection limits.
%   undoclip    - Remove object clips introduced by CLIPDATA.
%   undotrim    - Remove object trims introduced by TRIMDATA.
%
%
% MAP DISPLAY AND INTERACTION.
%
% Map Creation and High-Level Display.
%   axesm       - Create a new map axes/define a map projection.
%   displaym    - Project features from a v1 geographic data structure.
%   geoshow     - Display map latitude and longitude data.
%   grid2image  - Display a regular data grid as an image.
%   mapshow     - Display map data.
%   mapview     - Interactive map viewer.
%
% Vector Symbolization.
%   makesymbolspec  - Construct a vector symbolization specification. 
%
% Automated Base Map Creation.
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
% Interactive Track and Circle Definition.
%   scircleg    - Display a small circle defined via mouse input.
%   sectorg     - Display a small circle sector defined via mouse input.
%   trackg      - Display a great circle or rhumb line by mouse input.
%
% Graphical User Interfaces.
%   axesmui     - Interactively define map axes properties.
%   clrmenu     - Add a colormap menu to a figure window.
%   cmapui      - Create custom colormap.
%   colorm      - Create index map colormaps.
%   colorui     - Interactively define an RGB color.
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
%
% Map Object and Projection Properties.
%   cart2grn    - Transform from projected coordinates to Greenwich frame.
%   defaultm    - Initialize or reset projection properties to default values.
%   gcm         - Get current map projection structure.
%   geotiff2mstruct - Convert GeoTIFF info to a map projection structure.
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
%
% GEOGRAPHIC CALCULATIONS.
%
% Geometry of Sphere and Ellipsoid.
%   antipode    - Point on the opposite side of the globe.
%   areaint     - Surface area of a polygon on a sphere or ellipsoid.
%   areaquad    - Surface area of a latitude-longitude quadrangle.
%   azimuth     - Azimuth between points on a sphere/ellipsoid.
%   departure   - Compute departure of longitudes at specific latitudes.
%   distance    - Distance between points on a sphere/ellipsoid.
%   elevation   - Elevation angle between points on a sphere/ellipsoid.
%   ellipse1    - Construct ellipse from center, semimajor axes, eccentricity and azimuth.
%   gc2sc       - Compute center and radius of a great circle.
%   gcxgc       - Compute intersection points between great circles.
%   gcxsc       - Compute intersection points between great and small circles.
%   reckon      - Point at specified azimuth, range on a sphere/ellipsoid.
%   rhxrh       - Compute intersection points between rhumb lines.
%   scircle1    - Construct small circle from center, range and azimuth.
%   scircle2    - Construct small circle from center and perimeter.
%   scxsc       - Compute intersection points between small circles.
%   track1      - Construct track lines from starting point, azimuth and range.
%   track2      - Construct track lines from starting and ending points.
%
% Ellipsoids and Latitudes.
%   axes2ecc    - Compute eccentricity from semimajor and semiminor axes.
%   convertlat  - Convert between geodetic and auxiliary latitudes.
%   ecc2flat    - Compute flattening of an ellipse from eccentricity.
%   ecc2n       - Compute parameter n of an ellipse from eccentricity.
%   flat2ecc    - Compute eccentricity of an ellipse from flattening.
%   majaxis     - Compute semimajor axis from semiminor axis and eccentricity.
%   minaxis     - Compute semiminor axis from semimajor axis and eccentricity.
%   n2ecc       - Compute eccentricity of an ellipse from parameter n.
%   rcurve      - Compute radii of curvature for an ellipsoid.
%   rsphere     - Compute radii for auxiliary spheres.
%
% Intersections in the Cartesian Plane.
%   circcirc    - Intersections of circles in a Cartesian plane.
%   linecirc    - Intersections of circles and lines in a Cartesian plane.
%
% Geographic Statistics.
%   combntns    - Compute all combinations of a given set of values.
%   eqa2grn     - Convert equal area coordinates to Greenwich coordinates.
%   filterm     - Filter data points geographically.
%   grn2eqa     - Convert Greenwich coordinates to equal area coordinates.
%   hista       - Histogram for geographic points with equal-area bins.
%   histr       - Histogram for geographic points with equirectangular bins.
%   meanm       - Compute mean for geographic point locations.
%   stdist      - Compute standard distance for geographic point locations.
%   stdm        - Compute standard deviation for geographic point locations.
%
% Navigation.
%   crossfix    - Compute cross fix positions for bearings and ranges.
%   dreckon     - Compute dead reckoning positions for a track.
%   driftcorr   - Compute heading to correct for wind or current drift.
%   driftvel	- Compute drift speed and direction.
%   gcwaypts    - Compute equally spaced waypoints along a great circle.
%   legs        - Compute courses and distances between waypoints along a track.
%   navfix      - Perform mercator-based navigational fixing.
%   timezone    - Compute time zone description from longitude.
%   track       - Connect navigational waypoints with track segments.
%
%
% UTILITIES.
%
% Image Conversion.
%   ind2rgb8    - Convert an indexed image to a uint8 RGB image.
%
% Map Trimming.
%   maptriml    - Trim a line map to a specified region.
%   maptrimp    - Trim a patch map to a specified region.
%   maptrims    - Trim a regular data grid to a specified region.
%
% Data Precision.
%   epsm        - Return accuracy in angle units of certain map computations.
%   roundn      - Round to specified power of 10.
%
% Conversion Factors for Angles and Distances.
%   unitsratio   - Unit conversion factors.
%
% Angle Conversions.
%   angl2str     - Format an angle string.
%   angledim     - Convert angles from one unit or format to another.
%   deg2dm       - Convert angles from degrees to deg:min vector format.
%   deg2dms      - Convert angles from degrees to deg:min:sec vector format.
%   deg2rad      - Convert angles from degrees to radians.
%   dms2deg      - Convert angles from deg:min:sec to degrees.
%   dms2dm       - Convert angles from deg:min:sec to deg:min vector format.
%   dms2mat      - Convert a dms vector format to a [deg min sec] matrix.
%   dms2rad      - Convert angles from deg:min:sec to radians.
%   mat2dms      - Convert a [deg min sec] matrix to vector format.
%   rad2deg      - Convert angles from radians to degrees.
%   rad2dm       - Convert angles from radians to deg:min vector format.
%   rad2dms      - Convert angles from radians to deg:min:sec vector format.
%   str2angle    - Convert formatted DMS angle strings to numbers.
%
% Distance Conversions.
%   dist2str     - Format a distance string.
%   distdim      - Convert distances from one unit or format to another.
%   deg2km       - Convert distances from degrees to kilometers.
%   deg2nm       - Convert distances from degrees to nautical miles.
%   deg2sm       - Convert distances from degrees to statute miles.
%   km2deg       - Convert distances from kilometers to degrees.
%   km2nm        - Convert distances from kilometers to nautical miles.
%   km2rad       - Convert distances from kilometers to radians.
%   km2sm        - Convert distances from kilometers to statute miles.
%   nm2deg       - Convert distances from nautical miles to degrees.
%   nm2km        - Convert distances from nautical miles to kilometers.
%   nm2rad       - Convert distances from nautical miles to radians.
%   nm2sm        - Convert distances from nautical miles to statute miles.
%   rad2km       - Convert distances from radians to kilometers.
%   rad2nm       - Convert distances from radians to nautical miles.
%   rad2sm       - Convert distances from radians to statute miles.
%   sm2deg       - Convert distances from statute miles to degrees.
%   sm2km        - Convert distances from statute miles to kilometers.
%   sm2nm        - Convert distances from statute miles to nautical miles.
%   sm2rad       - Convert distances from statute miles to radians.
%
% Time Conversions.
%   hms2hm       - Convert time from hrs:min:sec to hr:min vector format.
%   hms2hr       - Convert time from hrs:min:sec to hours.
%   hms2mat      - Convert a hms vector format to a [hrs min sec] matrix.
%   hms2sec      - Convert time from hrs:min:sec to seconds.
%   hr2hm        - Convert time from hours to hrs:min format.
%   hr2hms       - Convert time from hours to hrs:min:sec vector format.
%   hr2sec       - Convert time from hours to seconds.
%   mat2hms      - Convert a [hrs min sec] matrix to vector format.
%   sec2hm       - Convert time from seconds to hrs:min vector format.
%   sec2hms      - Convert time from seconds to hrs:min:sec vector format.
%   sec2hr       - Convert time from seconds to hours.
%   time2str     - Format a time string.
%   timedim      - Convert times from one unit or format to another.

% Copyright 1996-2004 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.1.4.1 $Date: 2004/04/08 20:52:21 $

% Undocumented functions: MAP.
%   elpcalc     - Volume and surface area of an oblate spheroid.
%   eqacalc     - Transform data to/from an equal area space.
%   merccalc    - Transform data to/from a Mercator space.
%   sphcalc     - Compute volume and surface area for a sphere.
%   mapgate          - Gateway routine to call private functions.
%   unitstr          - Test for valid unit strings or abbreviations.
%   createShapeLayer - Used internally by MAPVIEW.
%   geoidtst         - Test for a valid geoid vector.
%   warnobsolete     - Issue a warning indicating the filename is obsolete.
%   ignoreComplex    - Convert complex input to real and issue warning.
%   num2ordinal      - Convert positive integer to ordinal string.

% Undocumented functions: MAPDISP.
%   loadcape    - Load Cape Code elevation image as regular data grid.
%   guifactm    - Compute scaling factors for cross platform GUIs.
%   leadblnk    - Delete leading characters common to all rows of a string matrix.
%   maphlp1     - Help Utility for Selected GUIs.
%   maphlp2     - Help Utility for Selected GUIs.
%   maphlp3     - Help Utility for Selected GUIs.
%   maphlp4     - Help Utility for Selected GUIs.
%   setfaces    - Construct the face matrix for a patch, given vertex data.
%   shiftspc    - Left or right justify a string matrix.
%   shiftwin    - Shift a figure window to reposition it on-screen.

% Undocumented functions: MAPFORMATS.
%   vmap0phead  - Parse the Digital Chart of the World header string.
