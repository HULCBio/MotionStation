% Mapping Toolbox
% Version 2.0 (R13SP1+) 08-January-2004
%
% High Level Map Display.
%   geoshow     - Display map latitude and longitude data. 
%   mapshow     - Display map data.
%   mapview     - Interactive map viewer.
%
% Geographic Data Structures.
%   extractfield - Extract the field values from a structure.
%   extractm     - Extract coordinates from a v1 geographic data structure.
%   makesymbolspec  - Construct a vector symbolization specification. 
%   updategeostruct - Update a geographic data structure. 
%
% Georeferenced Images and Data Grids.
%   areamat     - Surface area covered by non-zero values in regular data grid.
%   changem     - Substitute values in a data array.
%   encodem     - Fill in regular data grid from seed values and locations.
%   findm       - Return latitude/longitude of non-zero data grid elements.
%   geoloc2grid - Convert a geolocated data array to a regular data grid.
%   gradientm   - Calculate gradient, slope and aspect of data grid.
%   imbedm      - Encode data points into a regular data grid.
%   latlon2pix  - Convert latitude-longitude coordinates to pixel coordinates.
%   limitm      - Calculate latitude/longitude bounds for a regular data grid.
%   ltln2val    - Extract data grid values for specified locations.
%   makerefmat  - Construct an affine spatial-referencing matrix.
%   map2pix     - Convert map coordinates to pixel coordinates.
%   mapbbox     - Compute bounding box of a georeferenced image or data grid.
%   mapoutline  - Compute outline of a georeferenced image or data grid.
%   mapprofile  - Interpolate between waypoints on a regular data grid.
%   meshgrat    - Construct a graticule for a surface map object.
%   nanm        - Construct a regular data grid of all NaNs.
%   neworig     - Rotate a regular data grid on the sphere.
%   onem        - Construct a regular data grid of all ones.
%   pix2latlon  - Convert pixel coordinates to latitude-longitude coordinates.
%   pix2map     - Convert pixel coordinates to map coordinates.
%   pixcenters  - Compute pixel centers for georeferenced image or data grid.
%   refmat2vec  - Convert a referencing matrix to a referencing vector.
%   refvec2mat  - Convert a referencing vector to a referencing matrix.
%   resizem     - Resize a regular data grid.
%   setltln     - Convert data grid rows and colums to latitude-longitude.
%   setpostn    - Convert latitude-longitude to data grid rows and columns.
%   sizem       - Row and column dimension needed for a regular data grid.
%   spzerom     - Construct a sparse regular data grid of all zeros.
%   vec2mtx     - Convert latitude-longitude vectors to a regular data grid.
%   zerom       - Construct a regular data grid of all zeros.
%
% Visibility in Terrain.
%   viewshed    - Areas visible from a point on a digital elevation model.
%   los2        - Line of sight visibility between two points in terrain.
%
% Geometry of Sphere and Ellipsoid.
%   almanac     - Parameters for Earth and other objects in the Solar System.
%   antipode    - Point on the opposite side of the globe.
%   areaint     - Surface area of a polygon on a sphere or ellipsoid.
%   areaquad    - Surface area of a latitude-longitude quadrangle.
%   azimuth     - Azimuth between points on a sphere/ellipsoid.
%   departure   - Compute departure of longitudes at specific latitudes.
%   distance    - Distance between points on a sphere/ellipsoid.
%   elevation   - Elevation angle between points on a sphere/ellipsoid.
%   ellipse1    - Construct ellipse from center, semimajor axes, eccentricity and azimuth.
%   elpcalc     - Volume and surface area of an oblate spheroid.
%   eqacalc     - Transform data to/from an equal area space.
%   gc2sc       - Compute center and radius of a great circle.
%   gcxgc       - Compute intersection points between great circles.
%   gcxsc       - Compute intersection points between great and small circles.
%   merccalc    - Transform data to/from a Mercator space.
%   reckon      - Point at specified azimuth, range on a sphere/ellipsoid.
%   rhxrh       - Compute intersection points between rhumb lines.
%   scircle1    - Construct small circle from center, range and azimuth.
%   scircle2    - Construct small circle from center and perimeter.
%   scxsc       - Compute intersection points between small circles.
%   sphcalc     - Compute volume and surface area for a sphere.
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
% Data Manipulation.
%   bufferm     - Compute buffer zones for vector data.
%   flatearthpoly - Insert points along the dateline to the pole.
%   interpm     - Interpolate vector data to a specified data separation.
%   intrplat    - Interpolate a latitude for a given longitude.
%   intrplon    - Interpolate a longitude for a given latitude.
%   maptriml    - Trim a line map to a specified region.
%   maptrimp    - Trim a patch map to a specified region.
%   maptrims    - Trim surface map to a specified region.
%   nanclip     - Clip vector data with NaNs at specified pen-down locations.
%   polybool    - Perform boolean operations on polygons.
%   polycut     - Compute branch cuts for holes in polygons.
%   polyjoin    - Convert polygon segments from cell array to vector format.
%   polymerge   - Merge line segments with matching endpoints.
%   polysplit   - Extract segments of NaN-delimited polygon vectors to cell arrays.
%   polyxpoly   - Compute line or polygon intersection points.
%   reducem     - Reduce the number of points in vector data.
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
%
% See also MAPDEMOS, MAPDISP, MAPFORMATS, MAPPROJ.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/12/13 02:50:01 $


% Undocumented functions.
%   mapgate          - Gateway routine to call private functions.
%   unitstr          - Test for valid unit strings or abbreviations.
%   createShapeLayer - Used internally by MAPVIEW.
%   geoidtst         - Test for a valid geoid vector.
%   warnobsolete     - Issue a warning indicating the filename is obsolete.
%   ignoreComplex    - Convert complex input to real and issue warning.
%   num2ordinal      - Convert positive integer to ordinal string.
