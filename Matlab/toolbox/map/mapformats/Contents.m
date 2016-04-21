% Mapping Toolbox File Formats.
%
% File Formats and Data Set Readers.
%   arcgridread      - Read a gridded data set in Arc ASCII Grid Format.
%   avhrrgoode       - Read AVHRR data product stored in Goode Projection.
%   avhrrlambert     - Read AVHRR data product stored in Lambert Projection.
%   dcwdata          - Read selected data from the Digital Chart of the World.
%   dcwgaz           - Search for entries in a Digital Chart of the World Gazette file.
%   dcwrdx           - Read the Digital Chart of the World index file.
%   dcwread          - Read a Digital Chart of the World file.
%   dcwrhead         - Read Digital Chart of the World file headers.
%   dted             - Read U.S. Department of Defense Digital Terrain Elevation Data (DTED) data.
%   dteds            - Return DTED data file names covering a latitude-longitude box.
%   egm96geoid       - Read 15-minute gridded geoid heights from the EGM96 global geoid model.
%   etopo5           - Read 5-minute gridded terrain/bathymetry from the global ETOPO5 data set.
%   fipsname         - Read the name file used to index the TIGER thinned boundary files.
%   geotiffinfo      - Information about a GeoTIFF file.
%   geotiffread      - Read a georeferenced image from GeoTIFF file.
%   getworldfilename - Derive a worldfile name from an image file name.
%   globedem         - Read Global Land One-km Base Elevation (GLOBE) elevation data.
%   globedems        - Return GLOBE data file names covering a latitude-longitude box.
%   gshhs            - Read Global Self-consistent Hierarchical High-resolution Shoreline data.
%   gtopo30          - Read 30-arc-second global digital elevation model (GTOPO30).
%   gtopo30s         - Return GTOPO30 data file names covering a latitude-longitude box.
%   readfk5          - Read the Fifth Fundamental Catalog of stars and its extension.
%   satbath          - Read 2-minute global terrain/bathymetry from Smith and Sandwell.
%   sdtsdemread      - Read data from an SDTS raster/DEM data set.
%   sdtsinfo         - Information about an SDTS data set.
%   shapeinfo        - Information about a shapefile.
%   shaperead        - Read vector feature coordinates and attributes from a shapefile.
%   tbase            - Read 5-minute global terrain elevations from TerrainBase.
%   tgrline          - Read TIGER/Line data.
%   tigermif         - Read a TIGER MIF thinned boundary file.
%   tigerp           - Read TIGER p and pa thinned boundary files.
%   usgs24kdem       - Read a USGS 7.5-minute (30-meter) Digital Elevation Model.
%   usgsdem          - Read a USGS 1-degree (3-arc-second) Digital Elevation Model.
%   usgsdems         - Return USGS 1-Degree DEM file names covering a latitude-longitude box.
%   vmap0data        - Read selected data from the Vector Map Level 0 CD-ROMs.
%   vmap0rdx         - Read the Vector Map Level 0 index file.
%   vmap0read        - Read a Vector Map Level 0 file.
%   vmap0rhead       - Read Vector Map Level 0 file headers.
%   worldfileread    - Read a worldfile and return a referencing matrix.
%   worldfilewrite   - Construct a worldfile from a referencing matrix.
%
% File Reading Utilities.
%   grepfields       - Identify matching records in fixed record length files.
%   readfields       - Read fields or records from a fixed format file.
%   readmtx          - Read a matrix stored in a file.
%   spcread          - Read columns of data from an ascii text file.
%
% See also MAP, MAPDEMOS, MAPDISP, MAPPROJ.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2003/12/13 02:54:36 $


% Undocumented functions.
%   vmap0phead       - Parse the Digital Chart of the World header string.
