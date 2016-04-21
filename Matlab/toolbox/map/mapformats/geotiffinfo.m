function info = geotiffinfo(varargin)
%GEOTIFFINFO Information about a GeoTIFF file.
%
%   INFO = GEOTIFFINFO(FILENAME) returns a structure whose
%   fields contain file and cartographic information about 
%   a GeoTIFF file.
%
%   FILENAME is a string that specifies the name of the GeoTIFF file.  
%   FILENAME may include the directory name; otherwise, the file must be
%   in the current directory or in a directory on the MATLAB path.  If the
%   named file includes the extension '.TIF' or '.TIFF'  (either upper or
%   lower case), the extension may be omitted from  FILENAME.
%
%   If FILENAME is a file containing more than one GeoTIFF image, 
%   INFO is a structure array with one element for each image in 
%   the file.  For example, INFO(3) would contain information about 
%   the third image in the file. If more than one image exists
%   in the file it is assumed that each image will have the same
%   cartographic information and the same image width and height.
%
%   INFO = GEOTIFFINFO(URL) reads the GeoTIFF image from an Internet URL.
%   The URL must include the protocol type (e.g., "http://").
%
%   The INFO structure contains the following fields:
%
%   Filename       A string containing the name of the file.
%
%   FileModDate    A string containing the modification date of
%                  the file.
%
%   FileSize       An integer indicating the size of the file in
%                  bytes.
%
%   Format         A string containing the file format, 
%                  which should always be 'tiff'.
%
%   FormatVersion  A string or number specifying the file format
%                  version.
%
%   Height         An integer indicating the height of the image
%                  in pixels.
%
%   Width          An integer indicating the width of the image
%                  in pixels.
%
%   BitDepth       An integer indicating the number of bits per pixel.  
%
%   ColorType      A string indicating the type of image; either
%                  'truecolor' for a truecolor (RGB) image,
%                  'grayscale' for a grayscale intensity image,
%                  or 'indexed', for an indexed image. 
%
%   ModelType      A string indicating the type of coordinate system 
%                  used to georeference the image; either
%                  'ModelTypeProjected', 'ModelTypeGeographic' or ''.
%
%   PCS            A string describing the projected coordinate system.
%
%   Projection     A string describing the EPSG identifier for the 
%                  underlying projection method.
%
%   MapSys         A string indicating the map system; if applicable:
%                  'STATE_PLANE_27', 'STATE_PLANE_83', 
%                  'UTM_NORTH', 'UTM_SOUTH', or ''.
%
%   Zone           A double indicating the UTM or State Plane Zone 
%                  number; zero if not applicable or unknown.
%
%   CTProjection   A string containing the GeoTIFF identifier for the 
%                  underlying projection method.
%
%   ProjParm       A N-by-1 double containing projection parameter values.
%                  The identify of each element is specified by the
%                  corresponding element of ProjParmId. Lengths are in meters,
%                  angles in decimal degrees.
%
%   ProjParmId     A N-by-1 cell array listing the projection parameter 
%                  identifier for each corresponding numerical element 
%                  ProjParm.  The possible values are:
%                  'ProjNatOriginLatGeoKey'   
%                  'ProjNatOriginLongGeoKey'
%                  'ProjFalseEastingGeoKey'   
%                  'ProjFalseNorthingGeoKey'
%                  'ProjFalseOriginLatGeoKey' 
%                  'ProjFalseOriginLongGeoKey'
%                  'ProjCenterLatGeoKey'      
%                  'ProjCenterLongGeoKey'
%                  'ProjAzimuthAngleGeoKey'   
%                  'ProjRectifiedGridAngleGeoKey'
%                  'ProjScaleAtNatOriginGeoKey'
%                  'ProjStdParallel1GeoKey'   
%                  'ProjStdParallel2GeoKey'
%
%   GCS            A string indicating the Geographic Coordinate System.
%
%   Datum          A string indicating the projection datum type, such as
%                  'North American Datum 1927' or 'North American Datum 1983'.
%
%   Ellipsoid      A string indicating the ellipsoid name as defined by
%                  the ellipsoid.csv EPSG file.
%
%   SemiMajor      A double indicating the length of the semi-major axis 
%                  of the ellipsoid, in meters.
%
%   SemiMinor      A double indicating the length of the semi-minor axis
%                  of the ellipsoid, in meters.
%
%   PM             A string indicating the prime meridian location, for
%                  example, 'Greenwhich' or 'Paris'.
%
%   PmLongToGreenwich A double indicating the decimal degrees of longitude 
%                  between this prime meridian and Greenwich.  Prime 
%                  meridians to the west of Greenwich are negative.
%
%   UOMLength      A string indicating the units of length used in the
%                  projected coordinate system.
%
%   UOMLengthInMeters A double defining the UOMLength unit in meters.
%
%   UOMAngle       A string indicating the angular units used for 
%                  geographic coordinates.
%
%   UOMAngleInDegrees A double defining the UOMAngle unit in degrees.
%
%   TiePoints      A structure containing the image tiepoints.
%                  The structure contains these fields:
%
%                  ImagePoints  A structure containing the image coordinates
%                               of the tiepoints
%                  WorldPoints  A structure containing the world coordinates
%                               of the tiepoints
%
%                  The ImagePoints and WorldPoints structures each contain
%                  these fields:
%
%                  X  A double array of size N-by-1 for the X values
%                  Y  A double array of size N-by-1 for the Y values
%                  Z  A double array of size N-by-1 for the Z values
%
%   PixelScale     A 3-by-1 double array that specifies the X,Y,Z 
%                  pixel scale values.
%
%   RefMatrix      The 3-by-2 double referencing matrix which must be
%                  unambiguously defined by the GeoTIFF file, otherwise 
%                  it is returned empty ([]).
%
%   BoundingBox    A 2-by-2 double array that specifies the
%                  minimum (row 1) and maximum (row 2) values for each
%                  dimension of the image data in the GeoTIFF file.
%
%   CornerCoords   The CornerCoords structure contains the GeoTIFF image 
%                  corners in projected and latitude-longitude coordinates.  
%                  The  corner coordinate values are stored counter-clockwise 
%                  starting at the upper left corner followed by lower left,
%                  lower right and ending at the upper right corner.
%           
%                  The CornerCoords structure contains four fields.
%                  Each is a 4-by-1 double array, or empty ([]),
%                  if unknown.
%
%                  PCSX Coordinates in the Projected Coordinate System.
%                       Equals LON if The model type is 'ModelTypeGeographic'.
%
%                  PCSY Coordinate in the Projected Coordinate System, 
%                       Equals LAT if the model type is 'ModelTypeGeographic'.
%
%                  LON  Longitudes of the corner. 
%
%                  LAT  Latitudes of the corner. 
%
%   GeoTIFFCodes   A structure containing raw numeric values
%                  for those GeoTIFF fields which are encoded 
%                  numerically in the file.  These raw values, 
%                  converted to a string elsewhere in the INFO 
%                  structure, are provided here for reference.
%
%                  The following fields are included:
%
%                  Model
%                  PCS
%                  GCS
%                  UOMLength
%                  UOMAngle
%                  Datum
%                  PM
%                  Ellipsoid
%                  ProjCode
%                  Projection
%                  CTProjection
%                  ProjParmId    
%                  MapSys
%
%                  Each is scalar except for ProjParmId which is a column
%                  vector.
%
%   ImageDescription A string describing the image; omitted if not included.
%
%   Example
%   -------
%   info = geotiffinfo('boston.tif');
%
%   See also IMFINFO, GEOTIFFREAD, MAKEREFMAT, PROJFWD, PROJINV, PROJLIST.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2004/02/01 21:58:48 $

% Verify the input argument count
checknargin(1,1,nargin,mfilename);

% Verify the filename and obtain the full pathname
[filename, url] = checkfilename(varargin{1}, {'tif', 'tiff'}, ...
                                mfilename, 1, true);

% Read the info fields from the filename
info  = readinfo(filename);

% Delete temporary file from Internet download.
if (url)
    deleteDownload(filename);
end

%--------------------------------------------------------------------------
function info = readinfo(filename)
%  Reads the GeoTIFF info from the filename and returns the info structure.
%  The filename will be opened and closed by the MEX info functions.

% Call the tifinfo function to return the tiff_info structure
[tiff_info msg tags] = tifinfo(filename);
if (~isempty(msg))
    eid = sprintf('%s:%s:invalidTiffInfo', getcomp, mfilename);
    error(eid, '%s', msg)
end

% Determine if GeoTIFF Tags exist
tagRange = [33550, 34737];
k=find( (tagRange(1) <= tags) & (tags <= tagRange(2)) );
if isempty(k)
    eid = sprintf('%s:%s:invalidTiffTags', getcomp, mfilename);
    msg = sprintf('The file ''%s'' does not contain GeoTIFF Tags.', filename);
    error(eid, '%s',msg)
end 

% Force all images to have the same Height and Width values
if length(tiff_info) > 1 
   if (~isequal(tiff_info.Height) ||  ...
       ~isequal(tiff_info.Width)  )
      s='Multiple images exist in the file and the HEIGHT or WIDTH values are not equal.';
      eid = sprintf('%s:%s:invalidImages', getcomp, mfilename);
      error(eid, '%s', s);
   end
end

% Set temporary Height and Width variables
%  from the first element values. 
Height = tiff_info(1).Height;
Width  = tiff_info(1).Width;

% Obtain the EPSG and PROJ directory
[epsgDirName, projDirName] = feval(mapgate('getprojdirs'));

% Call the gtifinfo function to return the gtiff_info structure
gtiff_info = gtifinfo(filename, epsgDirName, projDirName);

% Get the spatial referencing fields
[TiePoints, RefMatrix, ...
 BoundingBox, CornerCoords]  = getSpatialFields(gtiff_info, Height, Width);

% Copy all the fields and other data to an info structure
info = constructInfo(tiff_info, gtiff_info, ...
                     TiePoints, RefMatrix, ...
                     BoundingBox, CornerCoords);

%--------------------------------------------------------------------------
function [TiePoints, RefMatrix, ...
          BoundingBox, CornerCoords] = getSpatialFields(gtiff_info, Height, Width)
% Returns the spatial referencing fields from the GeoTIFF info structure 
%  and the image height and width

% Create a temporary TiePoints struct
if isempty(gtiff_info.TiePoints)   
    %  The GTIFF TiePoints array is empty
    % Create empty arrays for each of the fields of TiePoints
    TiePoints = struct('ImagePoints',[], ...
                       'WorldPoints',[]);  
else
    % TiePoints is a structure and the GTIFF TiePoints is an array
    % Valid GTIFF TiePoints, create TiePoints struct with each field name
    %  and the corresponding GTIFF TiePoints values   
    TiePoints = struct('ImagePoints',gtiff_info.TiePoints(1:3) + ...
                                     [.5; .5; 0.0], ...
                       'WorldPoints',gtiff_info.TiePoints(4:6));             
end

% Create the RefMatrix from the WorldFileMatrix
RefMatrix   = makerefmat(gtiff_info.WorldFileMatrix);

% The RefMatrix can contain all zeros if the WorldMatrix
%  cantained any errors in its derivation.
%  If so, any coordinate calculations will be incorrect,
%  so set all appropriate fields to []
if ( isequal(RefMatrix, zeros(3,2) ) || ...
   (Height == 0) || (Width  == 0) )
  
   % The RefMatrix contains errors, 
   % Set all appropriate fields to []
   RefMatrix = [];
   BoundingBox = [];
   CornerCoords = struct('PCSX',[], ...
                         'PCSY',[], ...
                         'X'   ,[], ...
                         'Y'   ,[], ...
                         'LAT' ,[], ...
                         'LON' ,[]);
    
else

   % Create the Bounding box from the referencing matrix and 
   %  the image width and height
   BoundingBox = mapbbox(RefMatrix, Height, Width);
 
   % Calculate the corner coordinates from the RefMatrix
   % and the Width and Height
   % Convert the X and Y values to MATLAB
   % The LAT and LON values will be calculated correctly
   % from gtifinfo  
   [x,y] = mapoutline(RefMatrix, Height, Width);
 
   CornerCoords = struct('PCSX',x, ...
                         'PCSY',y, ...
                         'X',   gtiff_info.GTIFCornerCoords.X + .5, ...
                         'Y',   gtiff_info.GTIFCornerCoords.Y + .5, ...
                         'LAT', gtiff_info.GTIFCornerCoords.LAT, ...
                         'LON', gtiff_info.GTIFCornerCoords.LON);
  
end

%--------------------------------------------------------------------------
function info = constructInfo(tiff_info, gtiff_info, ...
                          TiePoints, RefMatrix, ...
                          BoundingBox, CornerCoords)
% Assign the fields from the tiff_info and gtiff_info structure
%  to the info structure

% tiff info fields
[info(1:length(tiff_info)).Filename] = deal(tiff_info.Filename);
[info.FileModDate]   = deal(tiff_info.FileModDate);
[info.FileSize]      = deal(tiff_info.FileSize);
[info.Format]        = deal(tiff_info.Format);
[info.FormatVersion] = deal(tiff_info.FormatVersion);
[info.Height]        = deal(tiff_info.Height);
[info.Width]         = deal(tiff_info.Width);
[info.BitDepth]      = deal(tiff_info.BitDepth);
[info.ColorType]     = deal(tiff_info.ColorType);

% geotiff info fields
[info.ModelType]     = deal(gtiff_info.Model);
[info.PCS]           = deal(gtiff_info.PCS);
[info.Projection]    = deal(gtiff_info.Projection);
[info.MapSys]        = deal(gtiff_info.MapSys);
[info.Zone]          = deal(gtiff_info.Zone);
[info.CTProjection]  = deal(gtiff_info.CTProjection);
[info.ProjParm]      = deal(gtiff_info.ProjParm);
[info.ProjParmId]    = deal(gtiff_info.ProjParmId);
[info.GCS]           = deal(gtiff_info.GCS);
[info.Datum]         = deal(gtiff_info.Datum);
[info.Ellipsoid]     = deal(gtiff_info.Ellipsoid);
[info.SemiMajor]     = deal(gtiff_info.SemiMajor);
[info.SemiMinor]     = deal(gtiff_info.SemiMinor);
[info.PM]            = deal(gtiff_info.PM);
[info.PMLongToGreenwich] = deal(gtiff_info.PMLongToGreenwich);
[info.UOMLength]         = deal(gtiff_info.UOMLength);
[info.UOMLengthInMeters] = deal(gtiff_info.UOMLengthInMeters);
[info.UOMAngle]          = deal(gtiff_info.UOMAngle);
[info.UOMAngleInDegrees] = deal(gtiff_info.UOMAngleInDegrees);

[info.TiePoints]    = deal(TiePoints);
[info.PixelScale]   = deal(gtiff_info.PixelScale);
[info.RefMatrix]    = deal(RefMatrix);  
[info.BoundingBox]  = deal(BoundingBox); 
[info.CornerCoords] = deal(CornerCoords);  
[info.GeoTIFFCodes] = deal(gtiff_info.GeoTIFFCodes);

% If the ImageDescription field is set, set the info field
if isfield(tiff_info,'ImageDescription')
   [info.ImageDescription]  = deal(tiff_info.ImageDescription);
end
