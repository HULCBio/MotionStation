function varargout = shaperead(varargin)
%SHAPEREAD Read vector feature coordinates and attributes from a shapefile.
%
%   S = SHAPEREAD(FILENAME) returns an N-by-1 version 2 geographic data
%   structure (geostruct2) array, S, containing an element for each
%   non-null spatial feature in the shapefile. S combines feature
%   coordinates/geometry and attribute values.
%
%   [S, A] = SHAPEREAD(FILENAME) returns an N-by-1 geostruct2 array,
%   S, and a parallel N-by-1 attribute structure array, A.  Each array
%   constains an element for each non-null spatial feature in the
%   shapefile.
%
%   S = shaperead(FILENAME,PARAM1,VAL1,PARAM2,VAL2,...) or
%   [S, A] = shaperead(FILENAME,PARAM1,VAL1,PARAM2,VAL2,...) returns a
%   subset of the shapefile contents in S or [S,A], as determined by the
%   parameters 'RecordNumbers','BoundingBox','Selector', or 'Attributes'.
%   In addition, the parameter 'UseGeoCoords' can be used in cases where
%   you know that the X- and Y-coordinates in the shapefile actually
%   represent longitude and latitude.
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
%   component files.  SHAPEREAD reads all three files as long as they
%   exist in the same directory and have valid file extensions. If the
%   main file (with extension SHP) is missing, SHAPEREAD returns an
%   error. If either of the other files is missing, SHAPEREAD returns a
%   warning.
%
%   Supported shape types
%   ---------------------
%   SHAPEREAD supports the ordinary 2D shape types: 'Point', 'Multipoint',
%   'PolyLine', and 'Polygon'. ('Null Shape' features are may also be
%   present in a Point, Multipoint, PolyLine, or Polygon shapefile, but
%   are ignored.) SHAPEREAD does not support any 3D or "measured" shape
%   types: 'PointZ', 'PointM', 'MultipointZ', 'MultipointM', 'PolyLineZ',
%   'PolyLineM', 'PolygonZ', 'PolylineM', or 'Multipatch'.
%
%   Output structure
%   ----------------
%   The fields in the output structure array S and A depend on (1) the type
%   of shape contained in the file and (2) the names and types of the
%   attributes included in the file:
%
%     Field name            Field contents          Comment
%     ----------            -----------------       -------
%     'Geometry'            Shape type string
%
%     'BoundingBox'         [minX minY;             Omitted for shape type
%                            maxX maxY]             'Point'
%
%     'X' or 'Lon'          Coordinate vector       NaN-separators used
%                                                   in multi-part PolyLine
%     'Y' or 'Lat'          Coordinate vector       and Polygon shapes
%
%     Attr1                 Value of first          Included in output S
%                           attribute               if output A is omitted
%
%     Attr2                 Value of second         Included in output S
%                           attribute               if output A is omitted
%
%     ...                   ...                     ...
%
%   The names of the attribute fields (listed above as Attr1, Attr2, ...)
%   are determined at run-time from the xBASE table (with extension 'DBF')
%   and/or optional, user-specified parameters.  There may be many
%   attribute fields, or none at all.
%
%   'Geometry' field
%   -----------------
%   The 'Geometry' field will be one of the following values: 'Point',
%   MultiPoint', 'Line', or 'Polygon'.  (Note that these match the standard
%   shapefile types except for shapetype 'Polyline' the value of the
%   Geometry field is simply 'Line'.
%
%   'BoundingBox' field
%   -------------------
%   The 'BoundingBox' field contains a 2-by-2 numerical array specifying
%   the minimum and maximum feature coordinate values in each dimension
%   (min([x, y]); max([x, y] where x and y are N-by-1 and contain the
%   combined coordinates of all parts of the feature).
%
%   Coordinate vector fields ('X','Y' or 'Lon','Lat')
%   -------------------------------------------------
%   These are 1-by-N arrays of class double.  For 'Point' shapes, they
%   are 1-by-1.  In the case of multi-part 'Polyline' and 'Polygon' shapes,
%   NaN are added to separate the lines or polygon rings.  In addition,
%   terminating NaNs are added to support horizontal concatation of the
%   coordinate data from multiple shapes.
%
%   Attribute fields
%   ----------------
%   Attribute names, types, and values are defined within a given
%   shapefile. The following four types are supported: Numeric, Floating,
%   Character, and Date. SHAPEREAD skips over other attribute types.
%   The field names in the output shape structure are taken directly from
%   the shapefile if they contain no spaces or other illegal characters,
%   and there is no duplication of field names (e.g., an attribute named
%   'BoundingBox', 'PointData', etc. or two attributes with the names).
%   Otherwise the following 'name mangling' is applied: Illegal characters
%   are replaced by '_'. If the first character in the attribute name is
%   illegal, a leading 'Z' is added. Numerals are appended if needed to
%   avoid duplicate names. The attribute values for a feature are taken
%   from the shapefile and stored as doubles or character arrays:
%
%   Attribute type in shapefile     MATLAB storage
%   ---------------------------     --------------
%       Numeric                     double (scalar)
%       Float                       double (scalar)
%       Character                   char array
%       Date                        char array
%
%   Parameter-Value Options
%   -----------------------
%   By default, shaperead returns an entry for every non-null feature and
%   creates a field for every attribute.  Use the first three parameters
%   below (RecordNumbers, BoundingBox, and Selector) to be selective about
%   which features to read.  Use the 4th parameter (Attributes) to control
%   which attributes to keep.  Use the 5th (GeodeticCoords) to control the
%   output field names.
% 
%   Name            Description of Value        Purpose
%   ----            --------------------        -------
%   
%   RecordNumbers   Integer-valued vector,      Screen out features whose
%                   class double                record numbers are not
%                                               listed.
% 
%   BoundingBox     2-by-(2,3, or 4) array,     Screen out features whose
%                   class double                bounding boxes fail to
%                                               intersect the selected box.
%                                             
%   Selector        Cell array containing       Screen out features for
%                   a function handle and       which the function, when
%                   one or more attribute       applied to the the
%                   names.  Function must       corresponding attribute
%                   return a logical scalar.    values, returns false.
%                   
%   Attributes      Cell array of attribute     Omit attributes that are
%                   names                       not listed. Use {} to omit
%                                               all attributes. Also sets
%                                               the order of attributes in
%                                               the structure array.
%
%   UseGeoCoords    Scalar logical              If true, replace X and Y
%                                               field names with 'Lon' and
%                                               'Lat', respectively.
%                                               Defaults to false.
%
%   Examples
%   --------
%   % Read the entire concord_roads.shp shapefile, including the attributes
%   % in concord_roads.dbf.
%   S = shaperead('concord_roads.shp');
%
%   % Restrict output based on a bounding box and read only two
%   % of the feature attributes.
%   bbox = [2.08 9.11; 2.09 9.12] * 1e5;
%   S = shaperead('concord_roads','BoundingBox',bbox,...
%                 'Attributes',{'STREETNAME','CLASS'});
% 
%   See also SHAPEINFO, UPDATEGEOSTRUCT.

%   Copyright 1996-2004 The MathWorks, Inc.  
%   $Revision: 1.1.10.5 $  $Date: 2004/04/15 00:00:22 $

%   Reference
%   ---------
%   ESRI Shapefile Technical Description, White Paper, Environmental
%   Systems Research Institute, July 1998.
%   (http://arconline.esri.com/arconline/whitepapers/ao_/shapefile.pdf)

nargoutchk(0,2,nargout);
switch(nargout)
    case {0,1}, separateAttributes = false;
    otherwise,  separateAttributes = true;
end

% Parse function inputs.
[filename, recordNumbers, boundingBox, selector, attributes, useGeoCoords] ...
    = parseInputs(varargin{:});

% Try to open the SHP, SHX, and DBF files corresponding to  the filename
% provided. Selectively validate the header, including the shape type code.
[shpFileId, shxFileId, dbfFileId, headerTypeCode] ...
    = openShapeFiles(filename,'shaperead');

% Get the file offset for the content of each shape record.
if (shxFileId ~= -1)
    contentOffsets = readIndexFromSHX(shxFileId);
else
    contentOffsets = constructIndexFromSHP(shpFileId);
end

% Select which records to read.
records2read = selectRecords(shpFileId, dbfFileId, headerTypeCode,...
                   contentOffsets, recordNumbers, boundingBox, selector);
                   
% Read the shape coordinates from the SHP file into a cell array.
[shapeData, shapeDataFieldNames] ...
    = shpread(shpFileId, headerTypeCode, contentOffsets(records2read));
 
% Read the attribute data from the DBF file into a cell array.
[attributeData, attributeFieldNames] ...
    = dbfread(dbfFileId,records2read,attributes);

% Optionally rename coordinate field names.
if useGeoCoords
    shapeDataFieldNames{strmatch('X',shapeDataFieldNames,'exact')} = 'Lon';
    shapeDataFieldNames{strmatch('Y',shapeDataFieldNames,'exact')} = 'Lat';
end

% Concatenate the cell arrays, if necessary and convert to struct(s).
varargout = constructOutput(shapeData, attributeData,...
              shapeDataFieldNames, attributeFieldNames, separateAttributes);

% Clean up.
closeFiles([shpFileId, shxFileId, dbfFileId]);

%--------------------------------------------------------------------------
function outputs = constructOutput(shapeData, attributeData,...
              shapeDataFieldNames, attributeFieldNames, separateAttributes)

if separateAttributes
    if ~isempty(attributeData)
        A = cell2struct(attributeData,genvarname(attributeFieldNames),2);
    else
        A = [];
    end
    S = cell2struct(shapeData,shapeDataFieldNames,2);
    outputs = {S, A};
else
    if ~isempty(attributeData)
        % Concatenate the shape data field names for the current shape type
        % and the attribute field names from the DBF file (if available).
        % Ensure value, non-duplicate structure field names.
        featureFieldNames = [shapeDataFieldNames,...
           genvarname(attributeFieldNames,feval(mapgate('geoReservedNames')))];
            
        S = cell2struct([shapeData, attributeData],featureFieldNames,2);
    else
        S = cell2struct(shapeData,shapeDataFieldNames,2);
    end
    outputs = {S};
end

%--------------------------------------------------------------------------
function records2read = selectRecords(shpFileId, dbfFileId, headerTypeCode, ...
                          contentOffsets, recordNumbers, boundingBox, selector)
% Select record numbers to read as constrained by shapefile record types,
% user-specified record numbers, user-specified bounding box, and
% user-specified attribute-based selector function.

% Initialize selection to include all non-null shape records.
records2read = recordsMatchingHeaderType(shpFileId,contentOffsets,headerTypeCode);

% Narrow selection based on user-specified record numbers.
if ~isempty(recordNumbers)
    records2read = intersect(recordNumbers,records2read);
end

% Narrow selection based on bounding box.
if ~isempty(boundingBox)
    bbSubscripts = getShapeTypeInfo(headerTypeCode,'BoundingBoxSubscripts');
    if hasBoundingBox(headerTypeCode)
        records2read = recordsIntersectingBox(shpFileId,...
            bbSubscripts,contentOffsets,boundingBox,records2read);
    else
        records2read = recordsWithPointsInbox(shpFileId,...
            bbSubscripts,contentOffsets,boundingBox,records2read);
    end
end

% Finalize selection based on selector function.
if (dbfFileId ~= -1) && ~isempty(selector)
    records2read = recordsMatchingSelector(dbfFileId,selector,records2read);
end

%---------------------------------------------------------------------------
function recs = recordsMatchingHeaderType(shpFileId,contentOffsets,headerTypeCode)
% Select the records that match the headerTypeCode.

totalNumRecords = length(contentOffsets);
recordMatchesHeaderType = false(1,totalNumRecords);
for n = 1:totalNumRecords
	fseek(shpFileId,contentOffsets(n),'bof');
	recordTypeCode = fread(shpFileId,1,'uint32','ieee-le');
	recordMatchesHeaderType(n) = (recordTypeCode == headerTypeCode);
end
recs = find(recordMatchesHeaderType);

%--------------------------------------------------------------------------
function answer = hasBoundingBox(shapeTypeCode)
fieldNames = getShapeTypeInfo(shapeTypeCode,'ShapeDataFieldNames');
answer = ~isempty(strmatch('BoundingBox',fieldNames,'exact'));

%--------------------------------------------------------------------------
function recs = recordsIntersectingBox(...
    shpFileId, bbSubscripts, contentOffsets, box, recs)
% Select the records with bounding boxes intersecting the specified box.

currentNumberOfRecs = numel(recs);
intersectsBox = false(1,currentNumberOfRecs);
for k = 1:currentNumberOfRecs
    n = recs(k);
	fseek(shpFileId,contentOffsets(n) + 4,'bof');
    bbox = fread(shpFileId,8,'double','ieee-le');
    intersectsBox(k) = boxesIntersect(box,bbox(bbSubscripts));
end
recs(~intersectsBox) = [];

%--------------------------------------------------------------------------
function result = boxesIntersect(a,b)
result = ~(any(a(2,:) < b(1,:)) || any(b(2,:) < a(1,:)));

%--------------------------------------------------------------------------
function recs = recordsWithPointsInbox(...
    shpFileId, bbSubscripts, contentOffsets, box, recs)
% Select the point records for locations within the specified box.
% Note: This version assumes 2D-only.

currentNumberOfRecs = numel(recs);
insideBox = false(1,currentNumberOfRecs);
for k = 1:currentNumberOfRecs
    n = recs(k);
	fseek(shpFileId,contentOffsets(n) + 4,'bof');
    point = fread(shpFileId,[1 2],'double','ieee-le');
    insideBox(k) = all(box(1,:) <= point(1,:)) && all(point(1,:) <= box(2,:));
end
recs(~insideBox) = [];

%--------------------------------------------------------------------------
function recs = recordsMatchingSelector(fid,selector,recs)
% Apply selector to DBF file to refine list of records to read.

% The first byte in each record is a deletion indicator
lengthOfDeletionIndicator = 1;

% Initialize things...
info = dbfinfo(fid);
selectfcn  = selector{1};
fieldnames = selector(2:end);

% Determine the position, offset, and format string for each field 
% specified by the selector.  If any fieldnames fail to get a match,
% return without altering the list of records, and issue a warning.
allFieldNames = {info.FieldInfo.Name};
for l = 1:numel(fieldnames)
    m = strmatch(fieldnames{l}, allFieldNames ,'exact');
    if isempty(m)
        wid = sprintf('%s:%s:badSelectorFieldName',getcomp,mfilename);
        wrn = sprintf('Selector field name ''%s'' %s\n%s',...
                 fieldnames{l},'doesn''t match a shapefile attribute name.',...
                 '         Ignoring selector.');
        warning(wid,wrn)
        return;
    end
    position(l)  = m;
    offset(l)    = sum([info.FieldInfo(1:(m-1)).Length]) ...
                   + lengthOfDeletionIndicator;
   formatstr{l} = sprintf('%d*uint8=>char',info.FieldInfo(m).Length);
end

% Check each record in the current list to see if it satisifies the
% selector.
satisfiesSelector = false(1,numel(recs));
for k = 1:numel(recs)
    n = recs(k);
    for l = 1:numel(position)
        m = position(l);
        fseek(fid,info.HeaderLength + (n-1)*info.RecordLength + offset(l),'bof');
        data = fread(fid,info.FieldInfo(m).Length,formatstr{l});
        values(l) = feval(info.FieldInfo(m).ConvFunc,data');
    end
    satisfiesSelector(k) = feval(selectfcn,values{:});
end

% Remove records that don't satisfy the selector.
recs(~satisfiesSelector) = [];

%--------------------------------------------------------------------------
function contentOffsets = readIndexFromSHX(shxFileId)
% Get record content offsets (in bytes) from shx file.

fileHeaderLength    = 100;
recordHeaderLength  =   8;
bytesPerWord        =   2;
contentLengthLength =   4;

fseek(shxFileId,fileHeaderLength,'bof');
contentOffsets = recordHeaderLength + ...
    bytesPerWord * fread(shxFileId,inf,'uint32',contentLengthLength);

%--------------------------------------------------------------------------
function contentOffsets = constructIndexFromSHP(shpFileId)
% Get record content offsets (in bytes) from shp file.

bytesPerWord        =   2;
fileHeaderLength    = 100;
recordHeaderLength  =   8;
contentLengthLength =   4;

fseek(shpFileId,24,'bof');
fileLength = bytesPerWord * fread(shpFileId,1,'uint32','ieee-be');
lengthArray = [];
recordOffset = fileHeaderLength;
while recordOffset < fileLength,
    fseek(shpFileId,recordOffset + recordHeaderLength - contentLengthLength,'bof');
    contentLength = bytesPerWord * fread(shpFileId,1,'uint32','ieee-be');
    lengthArray(end + 1,1) = contentLength;
    recordOffset = recordOffset + recordHeaderLength + contentLength;
end
contentOffsets = fileHeaderLength ...
                 + cumsum([0;lengthArray(1:end-1)] + recordHeaderLength);

%--------------------------------------------------------------------------
function [shpdata, fieldnames] = ...
    shpread(shpFileId, headerTypeCode, contentOffsets)
% Read designated shape records.

shapeTypeLength = 4;
readfcn    = getShapeTypeInfo(headerTypeCode,'ShapeRecordReadFcn');
fieldnames = getShapeTypeInfo(headerTypeCode,'ShapeDataFieldNames');
shpdata = cell(numel(contentOffsets),numel(fieldnames));

for k = 1:numel(contentOffsets)
    fseek(shpFileId,contentOffsets(k) + shapeTypeLength,'bof');
    shpdata(k,:) = feval(readfcn,shpFileId);
end

%--------------------------------------------------------------------------
function [attributeData, attributeFieldNames] ...
    = dbfread(fid, records2read, requestedFieldNames)
% Read specified records and fields from a DBF file.  Fields will follow
% the order given in REQUESTEDFIELDNAMES.

% Return empties if there's no DBF file.
if (fid == -1)
    attributeData = [];
    attributeFieldNames = {};
    return;
end

info = dbfinfo(fid);
fields2read = matchFieldNames(info,requestedFieldNames);
attributeFieldNames = {info.FieldInfo(fields2read).Name};

% The first byte in each record is a deletion indicator
lengthOfDeletionIndicator = 1;

% Loop over the requested fields, reading the attribute data.
attributeData = cell(numel(records2read),numel(fields2read));
for k = 1:numel(fields2read),
    n = fields2read(k);
    fieldOffset = info.HeaderLength ...
                  + sum([info.FieldInfo(1:(n-1)).Length]) ...
                  + lengthOfDeletionIndicator;
    fseek(fid,fieldOffset,'bof');
    formatString = sprintf('%d*uint8=>char',info.FieldInfo(n).Length);
    skip = info.RecordLength - info.FieldInfo(n).Length;
    data = fread(fid,[info.FieldInfo(n).Length info.NumRecords],formatString,skip);
    attributeData(:,k) = feval(info.FieldInfo(n).ConvFunc,data(:,records2read)');
end

%--------------------------------------------------------------------------
function fields2read = matchFieldNames(info, requestedFieldNames)
% Determine which fields to read.

allFieldNames = {info.FieldInfo.Name};
if isempty(requestedFieldNames)
    if ~iscell(requestedFieldNames)
        % Default case: User omitted the parameter, return all fields.
        fields2read = 1:info.NumFields;
    else
        % User supplied '{}', skip all fields.
        fields2read = [];
    end
else
    % Match up field names to see which to return.
    fields2read = [];
    for k = 1:numel(requestedFieldNames)
        index = strmatch(requestedFieldNames{k},allFieldNames,'exact');
        if isempty(index)
            wid = sprintf('%s:%s:nonexistentAttibuteName',getcomp,mfilename);
            wrn = sprintf('Attribute name ''%s'' %s\n%s',requestedFieldNames{k},...
                     'doesn''t match a shapefile attribute name.',...
                     '         It will be ignored.');
            warning(wid,wrn)
        end
        for l = 1:numel(index)
            % Take them all in case of duplicate names.
            fields2read(end+1) = index(l);
        end
    end
end

%--------------------------------------------------------------------------
function [filename, recordNumbers, boundingBox, selector, attributes, useGeoCoords] ...
    = parseInputs(varargin)

validParameterNames = ...
    {'RecordNumbers','BoundingBox','Selector','Attributes','UseGeoCoords'};
checknargin(1, 1 + 2*numel(validParameterNames), nargin, mfilename);

% FILENAME is the only required input.
filename = varargin{1};
checkinput(filename, {'char'},{'vector'},mfilename,'FILENAME',1);

% Assign defaults for optional inputs.
recordNumbers = [];
boundingBox = [];
selector = [];
attributes = [];
useGeoCoords = false;

% Identify and validate the parameter name-value pairs.
for k = 2:2:nargin
    parName = checkstrs(varargin{k}, validParameterNames, mfilename, ...
        sprintf('PARAM%d',k/2), k);
    switch parName
      case 'RecordNumbers'
        checkExistence(k, nargin, mfilename, 'vector of record numbers', parName);
        recordNumbers = checkRecordNumbers(varargin{k+1},k+1);

      case 'BoundingBox'
        checkExistence(k, nargin, mfilename, 'bounding box', parName);
        checkboundingbox(varargin{k+1},mfilename,'BOUNDINGBOX',k+1);
        boundingBox = varargin{k+1};
        
      case 'Selector'
        checkExistence(k, nargin, mfilename, 'selector', parName);
        selector = checkSelector(varargin{k+1},k+1);
        
      case 'Attributes'
        checkExistence(k, nargin, mfilename,'attribute field names', parName);
        attributes = checkAttributes(varargin{k+1},k+1);
      
      case 'UseGeoCoords'
        checkExistence(k, nargin, mfilename, 'geo-coordinates flag (T/F)', parName);
        checkinput(varargin{k+1}, {'logical'}, {'scalar'}, mfilename, 'USEGEOCOORDS', k+1);
        useGeoCoords = varargin{k+1};
        
      otherwise
        eid = sprintf('%s:%s:internalProblem',getcomp,mfilename);
        error(eid,'Internal problem: unrecognized parameter name: %s',parName);
    end
end

%--------------------------------------------------------------------------

function checkExistence(position, nargs, fcnName, ...
                        propertyDescription, propertyName)
% Error if missing the property value following a property name.

if (position + 1 > nargs)
    eid = sprintf('%s:%s:missingParameterValue',getcomp,fcnName);
    error(eid,...
          'Expected %s to follow parameter name ''%s''.',...
          propertyDescription, propertyName);
end

%--------------------------------------------------------------------------

function recordNumbers = checkRecordNumbers(recordNumbers, position)

checkinput(recordNumbers, {'numeric'},...
              {'nonempty','real','nonnan','finite','positive','vector'},...
              mfilename, 'recordNumbers', position);

%--------------------------------------------------------------------------

function selector = checkSelector(selector, position)
% SELECTOR should be a cell array with a function handle followed by
% strings. Do NOT try to check the strings against actual attributes,
% because we won't know the attributes until we've read the DBF file.
% Instead, we issue a warning later on in matchFieldNames.

checkinput(selector, {'cell'}, {}, mfilename, 'SELECTOR', position);

if numel(selector) < 2
    eid = sprintf('%s:%s:selectorTooShort',getcomp,mfilename);
    error(eid,'Expected SELECTOR to have at least two elements.');
end

if ~isa(selector{1},'function_handle')
    eid = sprintf('%s:%s:selectorMissingFcnHandle',getcomp,mfilename);
    error(eid,'Expected the first element of SELECTOR to be a function handle.');
end

for k = 2:numel(selector)
    if ~ischar(selector{k})
        eid = sprintf('%s:%s:selectorHasNonStrAttrs',getcomp,mfilename);
        error(eid,'Expected the %s element of SELECTOR to be a string.',...
              num2ordinal(k));
    end
end

%--------------------------------------------------------------------------

function attributes = checkAttributes(attributes, position)

checkinput(attributes, {'cell'}, {}, mfilename, 'ATTRIBUTES', position);

for k = 1:numel(attributes)
    if ~ischar(attributes{k})
        eid = sprintf('%s:%s:nonCharAttribute',getcomp,mfilename);
        error(eid,'Expected ATTRIBUTES to contain only strings.');
    end
end

%==========================================================================

function varname = genvarname(candidate,protected)
%GENVARNAME Construct a valid MATLAB variable name from a given candidate.
%   VARNAME = GENVARNAME(CANDIDATE) returns a valid variable name VARNAME
%   constructed from the string CANDIDATE.  CANDIDATE can be a string or a
%   cell array of strings.
%
%   A valid MATLAB variable name is a character string of letters, digits
%   and underscores, such that the first character is a
%   letter and the length of the string is <= NAMELENGTHMAX.
%
%   If CANDIDATE is a cell array of strings the resulting cell array of
%   strings in VARNAME are guaranteed to be unique from one another.
%
%   VARNAME = GENVARNAME(CANDIDATE, PROTECTED) returns a valid variable
%   name which is unique from the list of PROTECTED names.  PROTECTED may
%   be a string or cell array of strings.
%
%   Examples:
%       genvarname({'file','file'})     % returns {'file','file1'}
%       a.(genvarname(' field#')) = 1   % returns a.field0x23 = 1
%
%       okName = true;
%       genvarname('ok name',who)       % returns a string 'okName1'
%
%   See also ISVARNAME, ISKEYWORD, ISLETTER, NAMELENGTHMAX, WHO, REGEXP.

%   NOTE:  This is a copy of an R14 function in matlab/toolbox/matlab/lang.
%          We can remove it from SHAPEREAD.M after backporting to R13 to
%         release Mapping 2.

% Argument check
checknargin(1,2,nargin,mfilename);

% Set up protected list if it exists
if nargin < 2
    protected = {};
elseif ~iscell(protected)
    protected = {protected};
end

% Set up inputs for loop
wasChar = true;    % flag to make sure char array is set back to char
if ~iscell(candidate)
    varnameCell = {candidate};
else
    varnameCell = candidate;
    wasChar = false;
end

% Check first input type
if ~isCellString(varnameCell)
    error('MATLAB:genvarname:wrongVarnameType',...
            ['First input argument, VARNAME, must be either a CHAR array '...
            'or a cell array of strings.']);
end


% Check second input type
if ~isCellString(protected)
    error('MATLAB:genvarname:wrongProtectedType',...
        ['Second input argument, PROTECTED, must be either a CHAR array '...
        'or a cell array of strings.']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over all the candidates in varnameCell to make them valid names
for k = 1:numel(varnameCell)

    varname = varnameCell{k};

    if isvarname(varname) % Short-circuit if varname already legal
        varnameCell{k} = varname;
    elseif isempty(varname) % Make empty 'x'
        varnameCell{k} = 'x';
    else
        % Insert x if the first column is non-letter.
        varname = regexprep(varname,'^\s*+([^A-Za-z])','x$1', 'once');

        % Replace whitespace with camel casing.
        [StartSpaces, afterSpace] = regexp(varname,'\S\s+\S');
        for j=afterSpace
            varname(j) = upper(varname(j));
        end
        varname = regexprep(varname,'\s*','');

        % Replace non-word character with its HEXIDECIMAL equivalent
        illegalChars = unique(varname(regexp(varname,'\W')));
        for illegalChar=illegalChars
            if illegalChar <= intmax('uint8')
                width = 2;
            else
                width = 4;
            end
            replace = ['0x' dec2hex(illegalChar,width)];
            varname = strrep(varname, illegalChar, replace);
        end

        % Prepend keyword with 'x' and camel case.
        if iskeyword(varname)
            varname = ['x' upper(varname(1)) varname(2:end)];
        end

        % Truncate varname to NAMLENGTHMAX
        varname = varname(1:min(length(varname),namelengthmax));

        varnameCell{k} = varname;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following section is to uniquify
numPreceedDups = zeros(length(varnameCell));
for i = 1:length(varnameCell)
    varname = varnameCell{i};
    
    % Calc number of dups with in the candidates
    numPreceedDups(i) = ...
        length(find(strcmp(varname,varnameCell(1:i-1))));

    % Check if candidate dups with the protected
    if any(strcmp(varname,protected))
        numPreceedDups(i) = numPreceedDups(i) + 1;
    end

    % Update the protected to include other candidates that might clash
    protectedAll = {varnameCell{:},protected{:}};

    % See if unique candidate is indeed unique - if not up the
    % numPreceedDups
    if numPreceedDups(i)>0 
        uniqueName = appendNumToName(varname, numPreceedDups(i));
        while any(strcmp(uniqueName, protectedAll))
            numPreceedDups(i) = numPreceedDups(i) + 1;
            uniqueName = appendNumToName(varname, numPreceedDups(i));
        end

        % Replace the candidate with the unique string.
        varnameCell{i} = uniqueName;
    end
end

% Make sure return argument is the right type
if wasChar
    varname = varnameCell{1};
else
    varname = varnameCell;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions to make argument type checking more readable
function isIt = isString(content)
    if ischar(content)
        isIt = isvector(content) || isempty(content);
    else
        isIt = false;
    end
    
function isIt = isCellString(argin)
    if iscell(argin)
        for i = 1:numel(argin)
            if ~isString(argin{i})
                isIt = false;
                return;
            end
        end
        isIt = true;
    else 
        isIt = false;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper to append the unique numer to varname
function uniqueName = appendNumToName(name, num)
    numStr = sprintf('%d',num);
    uniqueName = [name numStr];
    if length(uniqueName) > namelengthmax
        uniqueName = [uniqueName(1:namelengthmax-length(numStr)) numStr];
    end

%--------------------------------------------------------------------------
function answer = isvector(v)
answer = (ndims(v) == 2) && (any(size(v) == 1));
