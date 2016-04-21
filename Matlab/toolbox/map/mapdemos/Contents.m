% Mapping Toolbox Demos and Data Sets.
%
%   mapdemos     - Index of Mapping Toolbox demos.
%
% Scripts and Demos.
%   mapexenhance - Enhancing Multispectral GeoTIFF Images.
%   mapexfindcity - Interactive Global City Finder.
%   mapexgeo     - Creating Maps Using GEOSHOW (Latitude,Longitude).
%   mapexmap     - Creating Maps Using MAPSHOW (X,Y).
%   mapexrefmat  - Creating and Using Referencing Matrices.
%   mapexreg     - Georeferencing an Image to an Orthotile Base Layer.
%   viewmaps     - GUI demonstrating map projections.
%
% MAT-Files Containing Sample Data Sets.
%   korea        - Terrain and bathymetry for the Korean peninsula.
%   koreaEQdata  - Earthquake locations and magnitudes.
%   layermtx     - Geolocated terrain grids for pedagogical use.
%   mapmtx       - Geolocated terrain grids for pedagogical use.
%   russia       - Gridded land, water, boundaries, external areas.
%   seatempm     - Global grid of multi-channel sea surface temperatures.
%   usgslulegend - List of USGS land use categories.
%
% IKONOS-2 Images of Boston, Massachusetts, USA in GeoTIFF Format.
%   RGB composite (boston), visible red, green, and blue bands (boston_red,
%   boston_green, boston_blue), enhanced panchromatic image
%   (boston_enhanced_pan), overview image (boston_ovr, in JPEG format),
%   panchromatic band (boston_pan).  See accompanying .txt files for source
%   and descriptive metadata.
%
%     boston.tif
%     boston.txt
%     boston_red.tif
%     boston_red.txt
%     boston_green.tif
%     boston_green.txt
%     boston_blue.tif
%     boston_blue.txt
%     boston_enhanced_pan.tif
%     boston_enhanced_pan.txt
%     boston_ovr.jgw
%     boston_ovr.jpg
%     boston_ovr.txt
%     boston_pan.tif
%     boston_pan.txt
%
% Shapefiles.
%   Shapefiles, including selected areas and attributes, derived from
%   MassGIS data base.  Placenames and roads for Boston, Massachusetts, USA
%   (boston_placenames, boston_roads).  Hydrography and roads for Concord,
%   Massachusetts, USA (concord_hydro_area, concord_hydro_line,
%   concord_roads).   See accompanying .txt files for source and
%   descriptive metadata.
%
%     boston_placenames.dbf
%     boston_placenames.shp
%     boston_placenames.shx
%     boston_placenames.txt
%     boston_roads.dbf
%     boston_roads.shp
%     boston_roads.shx
%     boston_roads.txt
%     concord_hydro.txt
%     concord_hydro_area.dbf
%     concord_hydro_area.shp
%     concord_hydro_area.shx
%     concord_hydro_line.dbf
%     concord_hydro_line.shp
%     concord_hydro_line.shx
%     concord_roads.dbf
%     concord_roads.shp
%     concord_roads.shx
%     concord_roads.txt
%
% Unregistered Aerial Photograph.
%   Unregistered true color aerial image covering part of the village of
%   West Concord, Massachusetts, USA.  See the .txt file for source and
%   descriptive metadata.
%
%     concord_aerial_sw.jpg
%     concord_aerial.txt
%
% TIFF Images Georeferenced with World Files.
%   Subsets of panchromatic orthoimage tiles from the MassGIS database,
%   covering the village of West Concord, Massachusetts, USA and their
%   georeferencing worldfiles.  See the .txt file for source and
%   descriptive metadata.
%
%     concord_ortho_e.tfw
%     concord_ortho_e.tif
%     concord_ortho_w.tfw
%     concord_ortho_w.tif
%     concord_ortho.txt
%
% Digital Elevation Model in SDTS Format.
%   USGS 7.5-minute Digital Elevation Model (DEM) for the Mt. Washington
%   Quandrangle, White Mountains, New Hampshire, USA, in Spatial Data
%   Transfer Standard (SDTS) Raster Profile format.   See the .txt file for
%   source and descriptive metadata.
%
%     9129CATD.DDF
%     9129CATS.DDF
%     9129CEL0.DDF
%     9129DDDF.DDF
%     9129DDOM.DDF
%     9129DDSH.DDF
%     9129DQAA.DDF
%     9129DQCG.DDF
%     9129DQHL.DDF
%     9129DQLC.DDF
%     9129DQPA.DDF
%     9129IDEN.DDF
%     9129IREF.DDF
%     9129LDEF.DDF
%     9129RSDF.DDF
%     9129SPDM.DDF
%     9129STAT.DDF
%     9129XREF.DDF
%     9129.txt
% 
% Digital Elevation Models in Arc ASCII Grid Format.
%   USGS 7.5-minute Digital Elevation Model (DEM) for the Mount Dartmouth
%   and Mt. Washington Quandrangles, White Mountains, New Hampshire, USA,
%   translated to Arc ASCII Grid format.   See the .txt files for source
%   and descriptive metadata.
%
%     MountDartmouth-ft.grd
%     MountDartmouth-ft.txt
%     MtWashington-ft.grd    
%     MtWashington-ft.txt
%
% Credits.
%
%   Boston GeoTIFF images: 
%     Includes material copyrighted by Space Imaging LLC, all rights
%     reserved. For more information, please call 1.800.232.9037 or
%     +1.301.552.0537  or visit http://www.spaceimaging.com  
%
%   Boston and Concord shapefiles, Concord orthoimage tiles:  
%     Office of Geographic and Environmental Information (MassGIS),
%     Commonwealth of Massachusetts  Executive Office of Environmental
%     Affairs (http://www.state.ma.us/mgis/)
%
%   Unregistered aerial photograph:
%     Courtesy of mPower3/Emerge
%
%   Mt. Washington and Mount Dartmouth DEMs:
%      U.S. Geological Survey
%
%   MAT-Files:
%      Various sources; see the "source" variable in each file.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:00:21 $


% Undocumented files.
%   mapexreg.mat
