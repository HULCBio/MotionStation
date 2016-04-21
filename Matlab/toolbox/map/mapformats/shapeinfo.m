function INFO = shapeinfo(varargin)
%SHAPEINFO Information about a shapefile.
%
%   INFO = SHAPEINFO(FILENAME) returns a structure, INFO, whose fields contain 
%   information about the contents of a shapefile.
%
%   The shapefile format was defined by the Environmental Systems Research
%   Institute (ESRI) to store nontopological geometry and attribute
%   information for spatial features. A shapefile consists of a main file,
%   an index file, and an xBASE table. All three files have the same base
%   name and are distinguished by the extensions 'SHP', 'SHX', and 'DBF',
%   respectively (e.g., base name 'concord_roads' and filenames
%   'concord_roads.SHP', 'concord_roads.SHX', and 'concord_roads.DBF').
%
%   FILENAME can be the base name, or the full name of any one of the
%   component files.  SHAPEINFO reads all three files as long as they
%   exist in the same directory and have valid file extensions. If the
%   main file (with extension SHP) is missing, SHAPEINFO returns an
%   error. If either of the other files is missing, SHAPEINFO returns a
%   warning.
%
%   The INFO structure contains the following fields:
%  
%      Filename     A char array containing the names of the files that were
%                   read
%
%      ShapeType    A string containing the shape type
%
%      BoundingBox  A numerical array of size 2-by-N that specifies the 
%                   minimum (row 1) and maximum (row 2) values for each
%                   dimension of the spatial data in the shapefile
%
%      Attributes   A structure array of size 1-by-numAttributes that describes
%                   the attributes of the data. It contains these fields:
%
%                   Name   A string containing the attribute name as given in
%                          the xBASE table
%
%                   Type   A string specifying the MATLAB class of the
%                          attribute data returned by SHAPEREAD. The
%                          following attribute (xBASE) types are supported:
%                          Numeric, Floating, Character, and Date.
%
%      NumFeatures  The number of spatial features in the shapefile 
%
%   Example
%   -------
%   info = shapeinfo('concord_roads')
%   {info.Attributes.Name}'   % Display all the attribute names

%   See also SHAPEREAD.

%   Copyright 1996-2003 The MathWorks, Inc.  
%   $Revision: 1.1.10.4 $  $Date: 2004/02/01 22:01:31 $

%   Reference
%   ---------
%   ESRI Shapefile Technical Description, White Paper, Environmental
%   Systems Research Institute, July 1998.
%   (http://arconline.esri.com/arconline/whitepapers/ao_/shapefile.pdf)

filename = parse_inputs(varargin{:});

% Initialize output structure.
INFO = struct('Filename',     '',...
	          'ShapeType',    'NotValid',...
              'BoundingBox',  [],...
              'NumFeatures',  [],...
	          'Attributes',   struct('Name',{},'Type',{}));

% Try to open the SHP, SHX, and DBF files corresponding to 
% the filename provided.
[shpFileId, shxFileId, dbfFileId, headerTypeCode] = ...
    openShapeFiles(filename, 'shapeinfo');

% Assign 3-by-n array of filenames and the shape type string.
INFO.Filename = [fopen(shpFileId); fopen(shxFileId); fopen(dbfFileId)];
INFO.ShapeType = getShapeTypeInfo(headerTypeCode,'TypeString');

% Read the bounding box for the shapefile.
fseek(shpFileId,36,'bof');
bbox = fread(shpFileId,8,'double','ieee-le');
bbSubscripts = getShapeTypeInfo(headerTypeCode,'BoundingBoxSubscripts');
INFO.BoundingBox = bbox(bbSubscripts);

% Read the attribute names and types, and the number of records.
if dbfFileId ~= -1
    % Use the DBF file if possible
    F = dbfinfo(dbfFileId);
    INFO.Attributes  = transpose(rmfield(F.FieldInfo,{'ConvFunc','Length'}));
    INFO.NumFeatures = F.NumRecords;  
elseif shxFileId ~= -1
    % No DBF file, but we can get the number of records from the SHX file.
    fseek(shxFileId,100,'bof');
    recordOffsets = 2 * fread(shxFileId,[2 inf],'uint32','ieee-be'); %in Bytes
    INFO.NumFeatures = length(recordOffsets);
end

% Clean up.
closeFiles([shpFileId, shxFileId, dbfFileId]);

%---------------------------------------------------------------------------
function filename = parse_inputs(varargin)

checknargin(1, 1, nargin, mfilename);
checkinput(varargin{1},{'char'},{'vector'},mfilename,'FILENAME',1);
filename = varargin{1};
