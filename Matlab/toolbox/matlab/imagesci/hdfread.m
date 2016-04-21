function varargout = hdfread(varargin)
%HDFREAD extract data from HDF file
%   
%   HDFREAD reads data from a data set in an HDF or HDF-EOS file.  If the
%   name of the data set is known, then HDFREAD will search the file for the
%   data.  Otherwise, use HDFINFO to obtain a structure describing the
%   contents of the file. The fields of the structure returned by HDFINFO are
%   structures describing the data sets contained in the file.  A structure
%   describing a data set may be extracted and passed directly to HDFREAD.
%   These options are described in detail below.
%   
%   DATA = HDFREAD(FILENAME,DATASETNAME) returns in the variable DATA all 
%   data from the file FILENAME for the data set named DATASETNAME.  
%   
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is a
%   structure extracted from the output structure of HDFINFO.
%   
%   DATA = HDFREAD(...,PARAMETER,VALUE,PARAMETER2,VALUE2...) subsets the
%   data according to the string PARAMETER which specifies the type of
%   subsetting, and the values VALUE.  The table below outlines the valid
%   subsetting parameters for each type of data set.  Parameters marked as
%   "required" must be used to read data stored in that type of data set.
%   Parameters marked "exclusive" may not be used with any other subsetting
%   parameter, except any required parameters.  When a parameter requires
%   multiple values, the values must be stored in a cell array.  Note that
%   the number of values for a parameter may vary for the type of data set.
%   These differences are mentioned in the description of the parameter.
%
%   [DATA,MAP] = HDFREAD(...) returns the image data and the colormap for an
%   8-bit raster image.
%   
%   Table of available subsetting parameters
%
%
%           Data Set          |   Subsetting Parameters
%          ========================================
%           HDF Data          |
%                             |
%             SDS             |   'Index'
%                             |
%             Vdata           |   'Fields'
%                             |   'NumRecords'
%                             |   'FirstRecord'
%          ___________________|____________________
%           HDF-EOS Data      |   
%                             |
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%                             |
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |   'ExtMode'
%                             |
%             Point           |   'Level'          (required)
%                             |   'Fields'         (required)
%                             |   'RecordNumbers'
%                             |   'Box'
%                             |   'Time'
%
%    There are no subsetting parameters for Raster Images
%
%
%   Valid parameters and their values are:
%
%   'Index' 
%   Values for 'Index': START, STRIDE, EDGE
%
%     START, STRIDE and EDGE must be arrays the same size as the
%     number of dimensions. START specifies the location in the data set to
%     begin reading.  Each number in START must be smaller than its
%     corresponding dimension.  STRIDE is an array specifying the interval
%     between the values to read.  EDGE is an array specifying the length of
%     each dimension to read.  The region specified by START, STRIDE and EDGE
%     must be within the dimensions of the data set.  If either START, 
%     STRIDE, or EDGE is empty, then default values are calculated assuming:
%     starting at the first element of each dimension, a stride of one, and
%     EDGE to read the from the starting point to the end of the dimension.
%     The defaults are all ones for START and STRIDE, and EDGE is an array
%     containing the lengths of the corresponding dimensions.  START,STRIDE
%     and EDGE are one based. START,STRIDE and EDGE vectors must be stored
%     in a cell as in the following notation: {START,STRIDE,EDGE}.
%
%   'FIELDS'
%    Values for 'Fields' are: FIELDS
%
%      Read data from the field(s) FIELDS of the data set.  FIELDS must be a
%      single string.  For multiple field names, use a comma separated list.
%      For Grid and Swath data sets, only one field may be specified.
%
%   'Box'
%   Values for 'Box' are: LONG, LAT, MODE
%
%     LONG and LAT are numbers specifying a latitude/longitude  region. MODE
%     defines the criterion for the inclusion of a cross track in a region.
%     The cross track in within a region if its midpoint is within the box,
%     either endpoint is within the box or any point is within the box.
%     Therefore MODE can have values of: 'midpoint', 'endpoint', or
%     'anypoint'. MODE is only valid for Swath data sets and will be ignored
%     if specified for Grid or Point data sets.
%
%   'Time'
%   Values for 'Time' are: STARTTIME, STOPTIME, MODE
%
%     STARTTIME and STOPTIME are numbers specifying a region of time. MODE
%     defines the criterion for the inclusion of a cross track in a region.
%     The cross track in within a region if its midpoint is within the box,
%     either endpoint is within the box or any point is within the box.
%     Therefore MODE can have values of: 'midpoint', 'endpoint', or
%     'anypoint'. MODE is only valid for Swath data sets and will be ignored
%     if specified for Grid or Point data sets.
%
%   'Vertical'
%   Values for 'Vertical' are: DIMENSION, RANGE
%
%     RANGE is a vector specifying the min and max range for the
%     subset. DIMENSION is the name of the field or dimension to subset by.  If
%     DIMENSION is the dimension, then the RANGE specifies the range of
%     elements to extract (1 based).  If DIMENSION is the field, then RANGE
%     specifies the range of values to extract. Vertical subsetting may be
%     used in conjunction with 'Box' and/or 'Time'.  To subset a region along
%     multiple dimensions, vertical subsetting may be used up to 8 times in
%     one call to HDFREAD.
%
%   'ExtMode'
%   Values for 'ExtMode' are: EXTMODE
%
%     EXTMODE is either 'Internal' (default) or 'External'.  If the mode is
%     set to 'Internal then the geolocation fields and data fields must be
%     in the same swath.  If the mode is set to 'External' then the
%     geolocation fields and data fields may be in different swaths.  This
%     parameter is only used for Swath data when extracting a time period or
%     a region.
%
%   'Pixels'
%   Values for 'Pixels' are: LON, LAT
%
%     LON and LAT are numbers specifying a latitude/longitude region.  The
%     longitude/latitude region will be converted into pixel rows and
%     columns with the origin in the upper left-hand corner of the grid.
%     This is the pixel equivalent of reading a 'Box' region.
%
%   'RecordNumbers'
%   Available parameter for 'RecordNumbers' is: RecNums
%
%     RecNums is a vector specifying the record numbers to read.  
%
%   'Level'
%   Value for 'Level' is: LVL
%   
%     LVL is a string representing the name of the level to read or a one
%     based number specifying the index of the level to read or  from an
%     HDF-EOS Point data set.
%
%   'NumRecords'
%   Available parameter for 'NumRecords' is: NumRecs
%
%     NumRecs is a number specifying the total number of records to read.
%
%   'FirstRecord'
%   Required value for 'FirstRecord' is: FirstRecord
%
%     FirstRecord is a one based number specifying the first record from which
%     to begin reading.
%
%   'Tile'
%   Required value for 'Tile' is: TileCoords
%
%     TileCoords is a vector specifying the tile coordinates to read. The
%     elements of TileCoords are one based numbers.
%
%   'Interpolate'
%   Values for 'Interpolate' are: LON, LAT
%
%     LON and LAT  are numbers specifying a latitude/longitude
%     points for bilinear interpolation.
%
%    References: 
%
%    Example 1:
%            
%             %  Read data set named 'Example SDS' 
%             data = hdfread('example.hdf','Example SDS');
%
%    Example 2:
%
%             %  Retrieve info about example.hdf
%             fileinfo = hdfinfo('example.hdf');
%             %  Retrieve info about Scientific Data Set in example.hdf
%             data_set_info = fileinfo.SDS;
%             %  Check the size
%             data_set_info.Dims.Size
%             % Read a subset of the data using info structure
%             data = hdfread(data_set_info,...
%                              'Index',{[3 3],[],[10 2 ]});
%
%   See also HDFTOOL, HDFINFO, HDF.  
  
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:56 $

varargout{1} = [];

[hinfo,subsets] = dataSetInfo(varargin{:});

if isempty(hinfo)
  warning('MATLAB:hdfread:noDataSets', ...
          'No data set found. Make sure the filename and data set name are correct.');
  return;
end

[start,stride,edge,fields,numrecords,firstRecord,level] = parseSubsets(subsets);

switch hinfo.Type
 case 'Scientific Data Set'
  varargout{1} = hdfsdsread(hinfo,start,stride,edge);
 case 'Vdata set'
  varargout{1} = hdfvdataread(hinfo,fields,numrecords,firstRecord);
 case '8-Bit Raster Image'
  [varargout{1},varargout{2}] = hdfraster8read(hinfo);
 case '24-Bit Raster Image'
  varargout{1} = hdfraster24read(hinfo);  
%From here on, all read functions will parse the subsetting parameters
 case  'HDF-EOS Grid'
  varargout{1} = hdfgridread(hinfo,fields,subsets{3:end});
 case  'HDF-EOS Swath'
  varargout{1} = hdfswathread(hinfo,fields,subsets{3:end});
 case  'HDF-EOS Point'
  varargout{1} = hdfpointread(hinfo,level,fields,subsets{5:end});
 case 'Vgroup'
  error('MATLAB:hdfread:specificDataset', ...
        'A Vgroup is a container for other data sets. A specific data set must be specified.');
 case 'Obsolete'
  [varargout{1},varargout{2},varargout{3}] = obsoletehdfread(hinfo.Filename,hinfo.TagRef);
 otherwise 
  error('MATLAB:hdfread:datatype', '%s', ...
        'Data set type not recognized. Verify the HINFO structure is \ncorrect. Consider using HDFINFO to obtain this structure.');
end
return;

%================================================================
function [start,stride,edge,fields,numrecords,firstRecord,level] = parseSubsets(subsets)
%PARSESUBSETS 
%  Parse some of the subsetting param/value pairs. Values for parameters
%  that are required for data sets are extracted from the variable list of
%  subsetting parameters. This routine will error if the input parameters
%  are not consistent with the param/value syntax described in the help for
%  HDFREAD.

%Return empty structures if not assigned on the command line
start = [];
stride = [];
edge = [];
fields = [];
numrecords = [];
firstRecord = [];
level = [];

if rem(length(subsets),2)
  error('MATLAB:hdfread:subsetValuePairs', ...
        'The subset/value inputs must always occur as pairs.');
end

%Parse subsetting parameters
numPairs = length(subsets)/2;
params = subsets(1:2:end);
values = subsets(2:2:end);

allStrings = {'index','fields','numrecords','firstrecord','tile','interpolate',...
	      'pixels','box','time','vertical','extmode','level','recordnumbers'};
for i=1:length(params)
  idx = strmatch(lower(params{i}),allStrings);
  switch length(idx)
   case 0
    error('MATLAB:hdfread:unknownArgument', ...
          'Unknown string argument: "%s."', params{i});
   case 1
    params{i} = allStrings{idx};
   otherwise
    error('MATLAB:hdfread:ambiguousArgument', ...
          'Ambiguous string argument: "%s."',params{i});
  end
end

cellmsg = '''%s'' method requires %i value(s) to be stored in a cell array.';
for i=1:numPairs
  switch params{i}
   case 'index'
    if iscell(values{i})
      if length(values{i})<3
        error('MATLAB:hdfread:badInputToMethod', cellmsg,params{i}, 3);
      else
        [start,stride,edge] = deal(values{i}{:});
      end
    else
      error('MATLAB:hdfread:badInputToMethod', cellmsg,params{i}, 3);
    end
   case 'fields'
    % 1 comma separated string, 1 cell w/comma separated string, 
    % or 1 cell array of strings are all valid values
    if iscell(values{i})
      if iscellstr(values{i})
	fields = sprintf('%s,',values{i}{:});
	fields = fields(1:end-1);
      end
    else
      fields = values{i};
    end
   case 'numrecords'
    if iscell(values{i})   
      if length(values{i})>1
        error('MATLAB:hdfread:badInputToMethod', cellmsg,params{i}, 1);
      end
      numrecords = values{i}{:};
    else
      numrecords = values{i};
    end
   case 'firstrecord'
    if iscell(values{i})
      if length(values{i})>1
        error('MATLAB:hdfread:badInputToMethod', cellmsg, params{i}, 1);
      end
      firstRecord = values{i}{:}; 
    else
      firstRecord = values{i};
    end
   case 'level'
    if iscell(values{i})
      if length(values{i})>1
        error('MATLAB:hdfread:badInputToMethod', cellmsg, params{i}, 1);
      end
      level = values{i}{:};
    else
      level = values{i};
    end
  end
end
return;
    
%=================================================================
function [hinfo,subsets] = dataSetInfo(varargin)
%DATASETINFO Return info structure for data set and subset param/value pairs
%
%  Distinguish between DATA = HDFREAD(FILENAME,DATASETNAME) and 
%  DATA = HDFREAD(HINFO)

msg = 'Invalid input arguments. HDFREAD requires a filename and data set name, \nor an information structure obtained from HDFINFO.';

if nargin<1
  error('MATLAB:hdfread:invalidInput', '%s', msg)
end

if ischar(varargin{1}) %HDFREAD(FILENAME,DATASETNAME...)

  msg = nargchk(2,inf,nargin);
  if (~isempty(msg))
      eid = 'MATLAB:hdfread:numberOfInputs';
      error(eid, msg);
  end
    
  filename = varargin{1};
  %Get full filename
  fid = fopen(filename);
  if fid ~= -1
    filename = fopen(fid);
    fclose(fid);
  else
    error('MATLAB:hdfread:fileOpen', 'File not found.');
  end

  %Use HX interface in case data is in external files
  hdf('HX', 'setdir', fileparts(filename));
  if ischar(varargin{2})
    dataname = varargin{2};
    hinfo = hdfquickinfo(filename,dataname);
    subsets = varargin(3:end);
  elseif isnumeric(varargin{2}) %Obsolete syntax
    subsets = [];
    hinfo.Filename = filename;
    hinfo.TagRef = varargin{2};
    hinfo.Type = 'Obsolete';
    warning('MATLAB:hdfread:obsoleteUsage', ...
            'This ussage of HDFREAD is obsolete and may be removed in a future version.\nConsider using IMREAD instead.');
  else
    error('MATLAB:hdfread:obsoleteUsage', '%s', msg); %Invalid input
  end
elseif isstruct(varargin{1}) %HDFREAD(HINFO,...)
  hinfo = varargin{1};
  if length(hinfo)>1
    error('MATLAB:hdfread:badHINFO', ...
          'HINFO must be a structure describing a specific data set in the file.');
  end
  if ~isfield(hinfo,'Type')
    error('MATLAB:hdfread:badHINFO', '%s', ...
          'HINFO is not a valid structure describing an HDF or HDF-EOS data set.  \nConsider using HDFINFO to obtain this structure.');
  end
  subsets = varargin(2:end);
else %Invalid input
  error('MATLAB:hdfread:obsoleteUsage', '%s', msg);
end
return;

%=================================================================
function [first, second, third]=obsoletehdfread( filename, tagref )
%HDFREAD Read data from HDF file.
%   Note: HDFREAD has been grandfathered; use IMREAD instead.
%
%   I=HDFREAD('filename', [GROUPTAG GROUPREF]) reads a binary
%   or intensity image from an HDF file.  
%
%   [X,MAP]=HDFREAD('filename', [GROUPTAG GROUPREF]) reads an
%   indexed image and its colormap (if available) from an HDF file.
%
%   [R,G,B]=HDFREAD('filename', [GROUPTAG GROUPREF]) reads an
%   RGB image from an HDF file.
%
%   Use the HDFPEEK function to inspect the file for group tags,
%      reference numbers, and image types.  Example:
%      [tagref,name,info] = hdfpeek('brain.hdf');
%      for i=1:size(tagref,1), 
%        if info(i)==8,
%          [X,map] = hdfread('brain.hdf',tagref(i,:)); imshow(X,map)
%        end
%      end
%
%   See also IMFINFO, IMREAD, IMWRITE.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:03:56 $

if (nargin ~= 2)
    error('MATLAB:hdfread:numberOfInputs', 'HDFREAD requires two inputs.');
end

first = [];
second = [];
third = [];

if (~ischar(filename))
    error('MATLAB:hdfread:filename', 'FILENAME must be a string.' );
end

[X,map] = imread(filename,'hdf',tagref(2));

if isempty(map) 
    sizeX = size(X);
    if ndims(X)==3 && sizeX(3)==3   % RGB Image
        first = double(X(:,:,1))/255;
        second = double(X(:,:,2))/255;
        third = double(X(:,:,3))/255;
    elseif ndims(X)==2              % Grayscale Intensity image
        first = double(X)/255;
    end
else                                % Indexed Image
    first = double(X)+1;
    second = map;
end












