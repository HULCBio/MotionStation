function varargout = updategeostruct(varargin)
%UPDATEGEOSTRUCT Update a version 1 geographic data structure. 
%
%   The Mapping Toolbox supports two ways of encoding vector features in
%   MATLAB structure arrays.  In both cases there is one feature per array
%   element, and in both cases the array elements are called "geographic
%   data structures" or "geostructs," for short.  Toolbox Version 1.3.1 and
%   earlier supported only version 1 geographic data structure arrays
%   ("geostruct1" arrays), in which:
%
%   -- A 'tag' field names an individual feature or object
%   -- A 'type' field specifies a MATLAB graphics object type
%      ('line', 'patch', 'surface', 'text', or 'light') or has the
%      value 'regular', specifying a regular data grid.
%   -- All coordinates are in latitude-longitude, stored in fields
%      'lat' and 'long'
%   -- An 'altitude' coordinate array extends coordinates to 3-D
%   -- A 'string' property contains text to be displayed if 'type' is
%      'text'
%   -- MATLAB graphics properties are specified explicitly, on a
%      per-feature basis, in an 'otherproperty' field.
%
%   The choice of options for the type field reveal that a geostruct1 can
%   contain:
%
%   -- Vector geodata ('type' is 'line' or 'patch')
%   -- Raster geodata ('type' is 'surface' or 'regular')
%   -- Graphic objects ('type' is 'text' or 'light')
%
%   Beginning with Mapping Toolbox 2.0, geographic data structures can take
%   a more general form ("geostruct2")---but only for vector geodata:
%
%   -- Coordinates can be in either latitude-longitude (stored in
%      fields ('Lat' and 'Lon') or map x-y (stored in fields 'X' and
%      'Y')
%   -- An optional field, 'Height' or 'Z', extends coordinates to 3-D
%   -- A 'Geometry' field designates the geometric nature of the
%      feature: 'Point', 'Multipoint', 'Line', or 'Polygon' rather
%      than a graphics object type
%   -- Additional attribute fields, which are dataset-specific, describe
%      the nongeometric properties (name, ownership, age, code or
%      identifier, ...) describe each feature
%
%   This is the form used for the output of SHAPEREAD. The version 2
%   geographic data structures allow for a greater amount of information to
%   be carried about each vector feature.  They also separate graphics
%   display properties from the fundamental properties of the geographic
%   features themselves.
%
%   Instead of being assigned in advance, graphics properties are
%   determined at display time by matching up attribute values against
%   rules provided in a "symbol spec."  For example, a road class attribute
%   can be used to display major highways with a distinctive color and
%   greater line width than secondary roads.  The same geographic data
%   structure can be display in many different ways, without altering any
%   of its contents, and shapefile data imported from external sources need
%   not be altered to control its graphic display.
%
%   Some toolbox functions (MAPSHOW, GEOSHOW, MAPVIEW) accept either type
%   of geographic data structure.  Other functions (DISPLAYM, EXTRACTM)
%   accept only version 1 geographic data structures.  The purpose of
%   UPDATEGEOSTRUCT, which supports the implementation of MAPSHOW and
%   GEOSHOW, is to restructure version 1 geographic data structures
%   containing vector geodata, converting them to the newer form.
%
%   G2 = UPDATEGEOSTRUCT(G) accepts a geographic data structure G.  If G is
%   a geostruct1 for which the 'type' field has value 'line' or 'patch',
%   UPDATEGEOSTRUCT restructures its elements to create a geostruct2, G2.
%   If G is a geostruct2, it is copied unaltered to G2.  UPDATEGEOSTRUCT
%   should not be used for geostruct1 arrays of type 'text', 'light',
%   'regular', or 'surface'.
%
%   G2 = UPDATEGEOSTRUCT(G, STR) selects only elements whose 'tag' field
%   begins with the string STR (and whose type field is either 'line' or
%   'patch'). The selection is case-insensitive.
%
%   [G2, SYMBOLSPEC] = UPDATEGEOSTRUCT(G,...) restructures a geographic
%   data structure and determines a SYMBOLSPEC based on the graphic
%   properties specified in the 'otherproperty' field for each element of G
%   and, if necessary, the JET color map.
%
%   [G2, SYMBOLSPEC] = UPDATEGEOSTRUCT(G,...,CMAP) specifies a colormap,
%   CMAP, to define the colors used in SYMBOLSPEC.
%
%   Example
%   --------
%   % Draw the United States with colors from the autumn colormap
%   patches = usahi('statepatch');
%   cmap = autumn(numel(patches));
%   [states, spec] = updategeostruct(patches, cmap);
%   mapshow(states,'SymbolSpec',spec)
%
%   See also EXTRACTM, GEOSHOW, MAKESYMBOLSPEC, MAPSHOW, MAPVIEW, SHAPEREAD.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/02/01 21:58:16 $

% Verify argument count
checknargin(1,3,nargin,mfilename);
msg = nargoutchk(0,2,nargout);
if (~isempty(msg))
   eid = sprintf('%s:%s:tooManyOutputs', getcomp, mfilename);
   error(eid, '%s', msg)
end

% Parse the inputs, check for current version
[S, v1, cmap] = parseInputs(varargin{:});

% Update the structure
if v1
   [S, symbolSpec] = convertgstruct(S, nargout == 2, cmap);
else
   symbolSpec = getSymbolSpec(nargout ==2, S, cmap);
end

varargout{1} = checkgeostruct(calcBBox(S));
if nargout == 2
   varargout{2} = symbolSpec;
end

%---------------------------------------------------------------------------
function [S, v1, cmap] = parseInputs(varargin)

% Verify geostruct
S = varargin{1};
cmap = [];
checkstruct(S,mfilename,'S',1);

% Temporary for ShapeType 
S = fixShapeStruct(S);

if isfield(S,'Geometry') && ...
      ((isfield(S,'X')  &&  isfield(S,'Y') ) || ...
      ( isfield(S,'Lat') && isfield(S,'Lon') ) )
   v1 = false;
   return;
end
if ~isfield(S,'lat') || ~isfield(S,'long')
   eid=sprintf('%s:%s:invalidGEOSTRUCT', getcomp, mfilename);
   msg = sprintf('%s%s%s\n%s\n%s','Function ', upper(mfilename), ...
                 ' expected a structure ',...
                 'with ''Geometry'' and coordinate fieldnames,', ...
                 'or a structure with ''lat'' and ''long'' fieldnames.');
   error(eid,'%s', msg)
end

switch nargin
   case 2
      % S = UPDATEGEOSTRUCT(GEOSTRUCT, FINDSTR)
      % S = UPDATEGEOSTRUCT(GEOSTRUCT, CMAP)
      if ischar(varargin{2})
         [lat,lon,indx] = extractm(S,varargin{2});
         S = S(indx);
      else
         cmap = varargin{2};
         checkcmap(cmap, mfilename, 'CMAP', 2);
      end

   case 3
      if ischar(varargin{2})
         [lat,lon,indx] = extractm(S,varargin{2});
         S = S(indx);
      else
         eid=sprintf('%s:%s:invalidString', getcomp, mfilename);
         msg = sprintf('Function %s %s', upper(mfilename), ...
                       'expected its second input argument to be a string.');
         error(eid,'%s', msg)
      end 
      cmap = varargin{3};
      checkcmap(cmap, mfilename, 'CMAP', 3);
end
v1 = true;

%---------------------------------------------------------------------------
function [S, symbolSpec] = convertgstruct(gstruct, reqSymbolSpec, cmap)

%  Update the members
S = updateStruct(gstruct);
symbolSpec = getSymbolSpec(reqSymbolSpec, S, cmap);

%---------------------------------------------------------------------------
function shape = updateStruct(gstruct)

% Default the Geometry to Line type
%  and set the Lat and Lon fields
[shape(1:length(gstruct)).Geometry] = deal('Line');
[shape.Lat] = deal(gstruct.lat);
[shape.Lon] = deal(gstruct.long);

% Set Height if altitude field is present
if isfield(gstruct,'altitude')
   fieldArray = extractfield(gstruct, 'altitude');
   if ~isempty(fieldArray)
      [shape.Height] = deal(gstruct.altitude);
   end
end

% Set the tag field if present
if isfield(gstruct,'tag')
   [shape.tag] = deal(gstruct.tag);
end

% Reset the Geometry based on 'type' field
type = getStructType(gstruct(1));
if strcmp(type,'text')
   [shape.Geometry] = deal('Text');
   if isfield(gstruct,'string')
      [shape.string] = deal(gstruct.string);
   end
   if isfield(gstruct,'text')
      [shape.text] = deal(gstruct.text);
   end
elseif strcmp(type,'patch')
   [shape.Geometry] = deal('Polygon');
elseif strcmp(type,'point')
   [shape.Geometry] = deal('Point');
end

% Add all fields except special field names
fields = fieldnames(gstruct);
for k = 1:length(fields)
   if ~strcmp(fields{k},'tag') && ...
      ~strcmp(fields{k},'text') && ...
      ~strcmp(fields{k},'type') && ...
      ~strcmp(fields{k},'altitude') && ...
      ~strcmp(fields{k},'Geometry')  && ...
      ~strcmp(fields{k},'BoundingBox')  && ...
      ~strcmp(fields{k},'lat')  && ...
      ~strcmp(fields{k},'long')  && ...
      ~strcmp(fields{k},'X')  && ...
      ~strcmp(fields{k},'Y') 
      % remove empty fields
      f=extractfield(gstruct,fields{k});
      if ~isempty(f)
         if ~(numel(f) ==1 && iscell(f) && isempty(f{1}))
           [shape.(fields{k})] = deal(gstruct.(fields{k}));
         end
      end
   end
end

%---------------------------------------------------------------------------
function type = getStructType(gstruct)
type = [];
if isfield(gstruct,'type')
   type = gstruct.type;
end

%---------------------------------------------------------------------------
function symbolSpec = getSymbolSpec(reqSymbolSpec, shape, cmap)

symbolSpec = [];
if reqSymbolSpec
   if isfield(shape,'tag') || isfield(shape,'string')
      if isfield(shape,'string')
         specName = 'string';
      else
         specName = 'tag';
      end
      name = '';
      if isempty(cmap)
        shapeColors = num2cell(jet(numel(shape)),2);
      else
        shapeColors = num2cell(cmap,2);
      end
      %shapeColors = {'green','blue','yellow','magenta','cyan','red'};
      %shapeColors = { [0, 0, 1.0], ...
      %                [0, 0.5, 0], ...
      %                [1.0, 0, 0], ...
      %                [0, 0.75, .75], ...
      %                [0.75,0, 0.75], ...
      %                [0.75, 0.75,0], ...
      %                [0.25, 0.25,0.25]};
      indx = 1;
      k = 1;
      for j = 1:length(shape)
        if ~strcmp(name,shape(j).(specName))
           colors(k,1) = {specName};
           colors(k,2) = {shape(j).(specName)};
           colors(k,3) = shapeColors(indx);
           k = k + 1;
           indx = indx+1;
           if indx > numel(shapeColors) 
              indx = 1;
           end
        end
        name = shape(j).(specName);
      end
   elseif isfield(shape,'otherproperty')
      colors = cell(numel(shape),3);
      for j = 1:length(shape)
        if iscell(shape(j).otherproperty)
           if strmatch(shape(j).otherproperty{1},'color')
              if isfield(shape,'tag')
                 colors(j,1) = {'tag'};
                 colors(j,2) = {shape(j).tag};
                 colors(j,3) = {shape(j).otherproperty{2}};
              end
           end
        end
      end
   else
      %colors = [];
      symbolSpec = [];
      return;
   end
   symbolSpec.ShapeType = shape(1).Geometry;
   if strcmp(symbolSpec.ShapeType,'Line') ...
     || strcmp(symbolSpec.ShapeType,'Text')
      symbolSpec.ShapeType = 'Line';
      symbolSpec.Color = colors;
   elseif strcmp(symbolSpec.ShapeType,'Polygon')
      symbolSpec.facecolor= colors;
      symbolSpec.EdgeColor={'Default'  ''  [0 0 0]};
   else
      symbolSpec = [];
   end
end

%---------------------------------------------------------------------------
function gstruct = checkgeostruct(S) 
gstruct = S;

if ~all(size(S(1).BoundingBox) == [2 2])
   eid=sprintf('%s:%s:invalidBoundingBox', getcomp, mfilename);
   msg = ['The ''BoundingBox'' field must be a 2x2 matrix', ...
          ' with [minX minY;maxX maxY].'];
   error(eid,'%s', msg)
end
if ~any(strcmp(S(1).Geometry,{'Point','MultiPoint','Line','Polygon','Text'}))
   eid=sprintf('%s:%s:invalidGeometry', getcomp, mfilename);
   msg = ['Invalid Geographic Data Structure. Geometry must be one of: ' ...
          '''Point'',''MultiPoint'',''Line'',''Text'', or ''Polygon.'''];
   error(eid,'%s', msg)
end
if isfield(S,'X')
   xName = 'X';
   yName = 'Y';
else
   xName = 'Lon';
   yName = 'Lat';
end
if ~isvector(S(1).(xName)) || ~isvector(S(1).(yName))
   eid=sprintf('%s:%s:invalidCoordinates', getcomp, mfilename);
   msg = 'The coordinate fields must be 1xM or Mx1 vectors.';
   error(eid,'%s', msg)
end
if any(size(S(1).(xName)) ~= size(S(1).(yName)))
   eid=sprintf('%s:%s:invalidCoordinateSize', getcomp, mfilename);
   msg = 'The coordinate fields must be the same size.';
   error(eid,'%s', msg)
end

%---------------------------------------------------------------------------
function b = isvector(v)
s = size(v);
if s(1) == 1 || s(2) == 1
  b = true;
else
  b = false;
end

%---------------------------------------------------------------------------
function S = fixShapeStruct(shape)
if isfield(shape,'ShapeType')
   [S(1:length(shape)).Geometry] = deal(shape.ShapeType);
   if isequal(shape(1).ShapeType,'PolyLine')
      [S.Geometry] = deal('Line');
   elseif isequal(shape(1).ShapeType,'Multipoint')
      [S.Geometry] = deal('MultiPoint');
   end
   % Add all fields except special field names
   fields = fieldnames(shape);
   for k = 1:length(fields)
      if ~strcmp(fields{k},'ShapeType') 
         [S.(fields{k})] = deal(shape.(fields{k}));
      end
   end
   if ~isfield(shape,'BoundingBox')
      X = extractfield(shape,'X');
      Y = extractfield(shape,'Y');
      BoundingBox = [ min(X), min(Y); max(X), max(Y)];

      % Set all BoundingBox fields to the computed bounding box
      [S.BoundingBox] = deal(BoundingBox);
   end
else
   S = shape;
end

%---------------------------------------------------------------------------
function shape = calcBBox(shape)
if ~isfield(shape,'BoundingBox')

   xName = getCoordName(shape,{'X','Lon'});
   yName = getCoordName(shape,{'Y','Lat'});
   X = extractfield(shape,xName);
   Y = extractfield(shape,yName);
   BoundingBox = [ min(X), min(Y); max(X), max(Y)];

   % Set all BoundingBox fields to the computed bounding box
   [shape.BoundingBox] = deal(BoundingBox);
end

%---------------------------------------------------------------------------
function name = getCoordName(S, names)
name = [];
fields = fieldnames(S);
for i=1:length(names)
   if any(strcmp(names{i},fields))
      name = names{i};
      break
   end
end

