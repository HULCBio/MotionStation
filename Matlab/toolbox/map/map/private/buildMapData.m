function mapdata = buildMapData(mapfilename, dataArgs, coordSys, displayType, ...
                                ax, layerName, spec, HGpairs)
%BUILDMAPDATA Build the mapdata structure from inputs.
%
%   MAPDATA = BUILDMAPDATA(DATAARGS, COORDSYS, DISPLAYTYPE, AX, ...
%   LAYERNAME, SPEC, HGPAIRS) returns MAPDATA as a structure. For a
%   complete description of the MAPDATA fields, see PARSEMAPINPUTS.
%
%   DATAARGS is a cell array containing input data arguments. DATAARGS must
%   conform to the output of PARSEMAPINPUTS.
%
%   COORDSYS is a string with name 'geographic' or 'map'. 
%
%   DISPLAYTYPE is a string with name 'mesh', 'surface', 'contour', 
%   'point', 'line', 'polygon', or 'image', 
%
%   AX is the axes that the DATAARGS will be rendered on.
%
%   LAYERNAME is the desired name of the layer and may be empty.
%
%   SPEC is a SymbolSpec and may be empty.
%
%   HGPAIRS is a cell array containing parameter/value pairs for the Handle
%   Graphics objects and may be empty.
%  
%   See also MAPSHOW, MAPVIEW, PARSEMAPINPUTS, READMAPDATA.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:58:00 $

%-------------------------------------------------------------------------

% Build the rules for parsing the map data
[mapRules, buildFcn, buildArgs] = buildMapRules(dataArgs, ...
                        coordSys, displayType, ax, layerName, spec, HGpairs);

% Swap arg1 with arg2 if needed
if mapRules.swapC1C2
  dataArgs(1:2) = fliplr(dataArgs(1:2));
end

% Build the component
mapdata = feval(buildFcn, mapfilename, dataArgs, buildArgs{:});

% Add the parent axes
mapdata.HGparams(1).Parent = ax;

%----------------------------------------------------------------------
function [mstruct, isMappedAxes] = getProjection(ax)
% Returns the mstruct if it is present on the axes.

% Check if the current axis has a mstruct
if ismap(ax)
  mstruct = gcm(ax);
  isMappedAxes = true;
else
  mstruct = [];
  isMappedAxes = false;
end

%----------------------------------------------------------------------
function mapDataType = getMapDataType(dataArgs, displayType )
% Returns the type of component.

if numel(dataArgs) == 1
  mapDataType = 'Geostruct';
  else 
    switch displayType
      case {'point','line','polygon'}
        mapDataType = 'Vector';
      case {'mesh','surface','contour'}
        mapDataType = 'Grid';
      case 'texturemap'
        mapDataType = 'Texture';
      otherwise
        mapDataType = 'Image';
    end
end


%----------------------------------------------------------------------
function [rules, buildFcn, buildArgs] = ...
          buildMapRules(dataArgs, coordSys, displayType, ax, ...
                        layerName, spec, HGpairs)
% Build the logical rules for parsing the data args.

% Get the mstruct from the axes, if set
[mstruct, isMappedAxes] = getProjection(ax);

% Get the type of input data: 'Grid', 'Image', 'Vector'
mapDataType = getMapDataType(dataArgs, displayType);
numArgs = numel(dataArgs);

% number of arguments in the dataArg input
rules.numArgs = numArgs;

% Rule for determining if the image syntax contains C1, C2 input
rules.isImageC1C2  = numArgs == 4 || ...
                     (strcmp('Image',mapDataType) && numArgs == 3 && ...
                     numel(dataArgs{3}) > 6 && size(dataArgs{2},3) ~= 3);

% Rule for swapping the C1 and C2 inputs
%swapVector = numArgs ==2  && strcmp('Vector',mapDataType) && ...
%             ~isMappedAxes && strcmp('map',coordSys); 
% Vectors are converted to GEOSTRUCT
%  swapping will be done by GEOSTRUCT logic
swapVector = false;

isGeoCoord = strcmp('geographic',coordSys);
isMapCoord = strcmp('map',coordSys); 

swapGrid   = (numArgs ==3 && strcmp('Grid',mapDataType)) && ... 
             ((~isMappedAxes && isGeoCoord) || ...
               (isMappedAxes && isMapCoord));

swapImage  = rules.isImageC1C2 && ~isMappedAxes && isGeoCoord;

rules.swapC1C2 = swapVector || swapGrid || swapImage;

% Rules for C1, C2 name
if isMapCoord && ~isMappedAxes
  C1 = 'X';
  C2 = 'Y';
else
  C1 = 'LAT';
  C2 = 'LON';
end

if rules.swapC1C2
  rules.C1 = C2;
  rules.C2 = C1;
  rules.posC1C2 = [2,1];
else
  rules.C1 = C1;
  rules.C2 = C2;
  rules.posC1C2 = [1,2];  
end


% Rules for the referencing object
rules.needRefVec = isMappedAxes && isGeoCoord;
rules.needRefMat = (~isMappedAxes && isGeoCoord) || isMapCoord;

% Rule for using the Mapping Toolbox 'm' functions
rules.isMfunction = rules.needRefVec && ~rules.needRefMat;

% Rule for if the axes has a projection
rules.isMappedAxes = isMappedAxes;

% Rule for requiring a texture mapped surface
isTextureMap = isMappedAxes && isGeoCoord;
isTextureMapImage = strcmp('Image',mapDataType) && ...
                     ( ( (numArgs == 2) && isTextureMap) || ...
                       ( (numArgs == 3) && (isTextureMap || rules.isImageC1C2)) || ...
                       (numArgs == 4) );
rules.isTextureMap = isTextureMapImage; 

if rules.isTextureMap
  mapDataType = 'Texture';
end

buildFcn  = str2func(['build' mapDataType 'Component']);
buildArgs = {coordSys, displayType, ax, layerName, ...
             mstruct, spec, HGpairs, rules};


%----------------------------------------------------------------------
function mapdata = buildImageComponent(mapfilename, dataArgs, ...
                                       coordSys, displayType, ...
                                       ax, layerName,  mstruct, ...
                                       spec, HGpairs, rules)
% Build an image component
checkmapnargin(2,3,rules.numArgs,mapfilename,displayType);
switch rules.numArgs
  case 2
     % (I,  R)
     % (BW, R)
     % (RGB,R)
     mapdata = parseImageInputs(mapfilename, dataArgs{:},  [], rules );

  case 3
     % (X, CMAP, R)
     mapdata = parseImageInputs(mapfilename, dataArgs{[1,3,2]}, rules);
end
[mapdata.HGparams, params] = getHGpairs(HGpairs);

%----------------------------------------------------------------------
function HGpairs = addTextureMapPairs(HGpairs, A)
HGpairs{end+1} = 'CData';
HGpairs{end+1} = A;
HGpairs{end+1} = 'facecolor';
HGpairs{end+1} = 'texturemap';

%----------------------------------------------------------------------
function mapdata = buildTextureComponent(mapfilename, dataArgs, ...
                                     coordSys, displayType, ...
                                     ax, layerName,  mstruct, ...
                                     spec, HGpairs, rules)

checkmapnargin(2,4,rules.numArgs,mapfilename,displayType);
switch rules.numArgs
  case 2
     if strcmp(displayType,'image')
       % (I,  R)
       % (BW, R)
       % (RGB,R)
       mapdata = convertImage(mapfilename, dataArgs{1}, [], 1, 2);
     else
       % (Z,R)
       mapdata.Image = dataArgs{1};
       checkinput(mapdata.Image,'numeric',{'real','2d','nonempty'}, ...
                  mapfilename,'Z', 1);
     end
     mapdata.RefMatrix = dataArgs{2};

  case 3
     if strcmp(displayType,'image')
       if rules.isImageC1C2
          % (C1, C2, I)
          % (C1, C2, BW)
          % (C1, C2, RGB)
          mapdata = convertImage(mapfilename, dataArgs{3}, [], 3, 2);
       else
          % (X, CMAP, R) with mapped axes
          mapdata = convertImage(mapfilename, dataArgs{1}, dataArgs{2}, 1, 2);
          mapdata.RefMatrix = dataArgs{3};
       end
     else
       % (C1, C2, Z)
       mapdata.Image = dataArgs{3};
       checkinput(mapdata.Image,'numeric',{'real','2d','nonempty'}, ...
                  mapfilename,'Z', 3);
       rules.isImageC1C2 = true;
     end


  case 4
     % (C1, C2, X, CMAP)
     mapdata = convertImage(mapfilename, dataArgs{3}, dataArgs{4}, 3, 4);
end

% Build a texture mapped surface with zero elevation.
%  The image is the CData of the surface.

displayType = 'surface';
HGpairs = addTextureMapPairs(HGpairs, mapdata.Image);
if ~rules.isImageC1C2
   % mapdata.Image may be RGB (M-by-N-by-3)
   %  set size of M and N
   sz = size(mapdata.Image);
   A = zeros(sz(1),sz(2));
   dataArgs = {A, mapdata.RefMatrix};
   rules.numArgs = 2;
   rules.needRefVec = 1;
   rules.needRefMat = 0;
else
   [C1,C2] = deal(dataArgs{1:2});
   if isequal(size(C1),size(C2))
     sz = size(C1);
     A = zeros(sz);
   else
     if isvector(C1) && isvector(C2)
       sz(1:2) = [numel(C2), numel(C1)];
       A = zeros(sz);
     else
       % This will error later in checkMatrixSizes
       %  delay until then
       sz = size(mapdata.Image);
       A = zeros(sz(1),sz(2));
     end
   end
   dataArgs = {C1, C2, A};
   rules.numArgs = 3;
end
mapdata = buildGridComponent(mapfilename, dataArgs, coordSys, displayType, ...
                            ax, layerName,  mstruct, ...
                            spec, HGpairs, rules);

%----------------------------------------------------------------------
function mapdata = parseImageInputs(mapfilename, A, R, cmap, rules)
% Parse the image input and return the mapdata structure.
%  If the image is indexed, it will be converted 
%   to uint8 RGB using CMAP.
%  If the image is logical is will be converted to uint8 RGB.
%  Input which requires a refvec will be texture-mapped.

R_position = rules.numArgs;
checkinput(A, {'uint8', 'uint16', 'int16', 'double', 'logical'}, ...
              {'real', 'nonsparse', 'nonempty'}, ...
              mapfilename, 'I or X or RGB', 1);

R = checkRefObj(mapfilename, R, size(A), rules.isMfunction, R_position);
if ~isequal(size(R),[3,2])
  eid = sprintf('%s:%s:internalError', getcomp, mapfilename);
  msg = sprintf('%s','Expected RefMatrix to be size [3,2].');
  error(eid, '%s',msg)
end

mapdata = convertImage(mapfilename, A, cmap, 1, 2);
mapdata.type = 'image';
mapdata.RefMatrix = R;
mapdata.Info = struct([]);
mapdata.cmap = cmap;

h = size(mapdata.Image,1);
w = size(mapdata.Image,2);
cc = pix2map(mapdata.RefMatrix,[1  1; h  w]);
mapdata.XData = cc(:,1);
mapdata.YData = cc(:,2);
mapdata.fcn = 'renderImageComponent';
mapdata.args = {mapdata.Image, mapdata.XData, mapdata.YData};

%---------------------------------------------------------------------
function mapdata = convertImage(mapfilename, A, cmap, imagePos, cmapPos)
% Convert the image to RGB.

if islogical(A)
  u = uint8(A);
  u(A) = 255;
  A = u;
end

if ~isempty(cmap)
  checkcmap(cmap, mapfilename, 'CMAP', cmapPos);
  checkinput(A, {'numeric'}, {'2d'}, mapfilename, 'RGB', imagePos);
  A = ind2rgb8(A, cmap);
end

if ndims(A) == 2
  A = repmat(A,[1 1 3]);

elseif ndims(A) ~= 3
  eid = sprintf('%s:%s:invalidImageDimension', getcomp, mapfilename);
  msg = sprintf('%s','Image dimension must be 2 or 3.');
  error(eid, '%s',msg)
end

mapdata.Image = checkRGBImage(A);

%---------------------------------------------------------------------
function RGB = checkRGBImage(RGB)

% RGB images can be only uint8, uint16, or double
if ~isa(RGB, 'double') && ...
   ~isa(RGB, 'uint8')  && ...
   ~isa(RGB, 'uint16') 
  eid = sprintf('%s:%s:invalidRGBClass', getcomp, mfilename);
  error(eid, 'RGB images must be uint8, uint16, or double.');
end

if size(RGB,3) ~= 3
  eid = sprintf('%s:%s:invalidRGBSize', getcomp, mfilename);
  error(eid, 'RGB images must be size M-by-N-by-3.');
end

% Clip double RGB images to [0 1] range
if isa(RGB, 'double')
  RGB = max(min(RGB,1),0);
end


%---------------------------------------------------------------------
function mapdata = buildGridComponent(mapfilename, dataArgs, ...
                                      coordSys, displayType, ...
                                      ax, layerName,  mstruct, ...
                                      spec, HGpairs, rules)
% Build a grid component (surface, mesh, contour)

mapdata.type = 'grid';
mapdata.fcn = displayType;
checkmapnargin(2,3,rules.numArgs,mapfilename,displayType);
switch rules.numArgs
  case 2
     [Z,R] = deal(dataArgs{:});
     checkinput(Z, {'double','float'},{'real','2d','nonempty'}, ...
                mapfilename, 'Z' ,1);
     R = checkRefObj(mapfilename, R, size(Z), rules.isMfunction, 2);
     if rules.isMfunction
        [x,y]=meshgrat(Z,R);
     else
        [x,y] = pixcenters(R,size(Z));
     end
        
  case 3
     [x,y,Z] = deal(dataArgs{:});
     checkinput(x,'numeric',{'real','2d','nonempty'}, ...
                mapfilename,rules.C1,rules.posC1C2(1));
     checkinput(y,'numeric',{'real','2d','nonempty'}, ...
                mapfilename,rules.C2,rules.posC1C2(2));
     checkinput(Z,'numeric',{'real','2d','nonempty'}, ...
                mapfilename,'Z', 3);
end
mapdata.args={x,y,Z};


if rules.isMfunction
  mapdata.fcn = [mapdata.fcn 'm'];

  if strcmp(mapdata.fcn,'meshm') 
    % meshm does not support (x,y,Z) syntax
    %  and produces the same result.
    mapdata.fcn = 'surfacem';
  end
else
  % Check the matrix sizes if not using a mapping function
  % (The mapping function do not require sizes to be equal)
  checkMatrixSizes(x,y,Z, coordSys, rules.isMappedAxes)
end

% Convert the HGpairs to a structure
[mapdata.HGparams, params] = getHGpairs(HGpairs);

% Add specific HG flags depending on the HG type
% The contour functions must be wrapped since they do
%  not have a h = syntax.
switch displayType
  case 'contour'
    mapdata.contourFcn = mapdata.fcn;
    mapdata.fcn = 'contourwrap';
    fnames = fieldnames(mapdata.HGparams);
    index = strmatch('lines',lower(fnames));
    if ~isempty(index)
      lineStyle = mapdata.HGparams.(fnames{index});
    else
      lineStyle = '-';
    end
    if ~isempty(findstr(version,'R14')) && ~rules.isMfunction
      mapdata.args={mapdata.contourFcn,'v6',mapdata.args{:},'LineStyle',lineStyle};
    else
      mapdata.args={mapdata.contourFcn,mapdata.args{:},'LineStyle',lineStyle};
    end

  case 'surface'
    if any(cellfun('isempty',params)) || ~any(strmatch('edgec',lower(params)))
      mapdata.HGparams(1).EdgeColor = 'none';
    end
end

%---------------------------------------------------------------------
function checkMatrixSizes(x,y,Z, coordSys, isMappedAxes)
% Validate the sizes of the x,y,Z inputs.

[m, n] = size(Z);
if length(x) ~= n || length(y) ~= m
   if ( any(size(x) ~= size(y)) ) || ...
      ( any(size(x) ~= size(Z)) )

      if strcmp('map',coordSys)  && ~isMappedAxes
        coordString = 'X and Y';
      else
        coordString = 'LAT and LON';
      end

      eid = sprintf('%s:%s:invalidCoordinateDimensions', getcomp, mfilename);
      msg = sprintf('%s%s', coordString, ' dimensions do not agree with Z.');
      error(eid, '%s',msg)
   end
end

%---------------------------------------------------------------------
function R = checkRefObj(mapfilename, R, sz, needRefVec, pos)
% Return a refencing object (RefVec, or RefMatrix)

if numel(R) == 3
  checkrefvec(R, mapfilename, 'R', pos);
else
  checkrefmat(R, mapfilename, 'R', pos);
end

if needRefVec
  R = refmat2vec(R,sz);
else
  R = refvec2mat(R,sz);
end

%---------------------------------------------------------------------
function [S, params] = getHGpairs(HGpairs)
% Convert the HGpairs cell array to a structure

if ~isempty(HGpairs)
  params = HGpairs(1:2:end);
  values = HGpairs(2:2:end);
  S = cell2struct(values,params,2);
else
  S = struct([]);
  params = {};
end

%---------------------------------------------------------------------
function mapdata = buildVectorComponent(mapfilename, dataArgs, ...
                                        coordSys, displayType, ...
                                        ax, layerName, mstruct, ...
                                        spec, HGpairs, rules)
% Build a vector component by converting to a geographic data structure.

% check the inputs
checkmapnargin(2,2,rules.numArgs,mapfilename,displayType);
checkinput(dataArgs{1},{'numeric'},{'real','2d','nonempty'}, ...
           mapfilename,rules.C1,rules.posC1C2(1));
checkinput(dataArgs{2},{'numeric'},{'real','2d','nonempty'}, ...
           mapfilename,rules.C2,rules.posC1C2(2));

% Build the geostruct
if strcmp(coordSys,'geographic');
   S.Lat = dataArgs{1};
   S.Lon = dataArgs{2};
else
   S.X = dataArgs{1};
   S.Y = dataArgs{2};
end
S.Geometry = [upper(displayType(1)) displayType(2:end)];

% Convert to mapdata
rules.numArgs = 1;
mapdata  = buildGeostructComponent(mapfilename, {S}, coordSys, displayType, ...
                      ax, layerName, mstruct, spec, HGpairs, rules);


%---------------------------------------------------------------------
function mapdata = buildGeostructComponent(mapfilename, dataArgs, ...
                                           coordSys, displayType, ...
                                           ax, layerName, mstruct, ...
                                           spec, HGpairs, rules)
% Build a Geostruct component using the MapGraphics objects.

% Verify and update the structure and get a symbol spec
checkmapnargin(1,1,rules.numArgs,mapfilename,displayType);
geostruct = dataArgs{1};
if ~isstruct(geostruct)
  eid = sprintf('%s:%s:invalidGeoStruct', getcomp, mfilename);
  msg = sprintf('%s%s%s\n%s%s', ...
            'Function ', upper(mapfilename), ...
            ' expected its first input argument, S, to be a structure.', ...
            'Instead its type was ', class(geostruct), '.');
  error(eid, '%s',msg)
end
[geostruct, gstructSpec] = updategeostruct(geostruct);

% Project the data if needed
geostruct = projectGeoStruct(mstruct, geostruct);

% Convert to mapdata
if isempty(spec);
  spec = {gstructSpec};
end

% Create a MapGraphics component
[component, rules] = createVectorComponent(geostruct, spec, HGpairs);

mapdata.type = 'vector';
mapdata.fcn = 'renderComponent';
mapdata.args={component, layerName,rules,ax,'on'};

%---------------------------------------------------------------------
function [component, rules] = createVectorComponent(geoData, spec, HGpairs)

[layer, component] = createVectorLayer(geoData,'layerName');
rules = createSpecRules(geoData(1).Geometry, spec, HGpairs);

%----------------------------------------------------------------------
function rules = createSpecRules(type, spec, HGpairs)
% Create the rules from the SymbolSpec and the command line
%  parameter/value pairs.

rules = createDefaultRules(type);
for i=1:numel(spec) 
  if ~isempty(spec{i})
    rules.append(rmfield(spec{i},'ShapeType'));
  end
end
params = HGpairs(1:2:end);
params = lower(params);
values = HGpairs(2:2:end);
propvalParamsUsed = {};
for i=1:length(params)
  if strncmp('default',params{i},7)
    clear('tmp');
    checkUniqueParam(propvalParamsUsed,{params{i}(8:end)});
    tmp.(params{i}(8:end)) = {'Default','',values{i}};
    propvalParamsUsed = cat(2,propvalParamsUsed,{params{i}(8:end)});
    rules.append(tmp);
  else
    clear('tmp');
    checkUniqueParam(propvalParamsUsed,{params{i}});
    tmp.(params{i}) = {'Default','',values{i}};
    propvalParamsUsed = cat(2,propvalParamsUsed,{params{i}});
    rules.override(tmp);
  end
end

%--------------------------------------------------------------------
function  defaultRules = createDefaultRules(type)
%Create the default SPEC rules object.

defaultRules  = [];
switch lower(type)
  case {'point' 'multipoint'}
    spec = makesymbolspec('Point', ...
              {'Default','Color',get(0,'DefaultLineColor')});
    defaultRules  = MapModel.PointLegend(rmfield(spec,'ShapeType'));

  case 'polygon'
     spec = makesymbolspec('Polygon', ...
              {'Default','FaceColor',get(0,'DefaultPatchFaceColor')});
     defaultRules  = MapModel.PolygonLegend(rmfield(spec,'ShapeType'));

  case {'line','polyline'}
     spec = makesymbolspec('Line', ...
             {'Default','Color',get(0,'DefaultLineColor')});
     defaultRules  = MapModel.LineLegend(rmfield(spec,'ShapeType'));
   otherwise
     eid = sprintf('%s:%s:invalidGeometryType', getcomp, mfilename);
     msg = sprintf('%s%s%s', ...
            'Geometry type ''', type, ''' is not supported.');
     error(eid, '%s',msg)
end
for i=1:numel(spec)
  if ~isempty(spec(i))
    defaultRules.append(rmfield(spec(i),'ShapeType'));
  end
end

%----------------------------------------------------------------------
function checkUniqueParam(paramsUsed,newparams)
%Verify the param/value pair is unique

for i=1:length(newparams)
  if any(strcmp(newparams{i},paramsUsed))
    eid = sprintf('%s:%s:invalidProperty', getcomp, mfilename);
    msg = sprintf('%s %s %s\n %s', ...
        'The', newparams{i}, 'property has been set more than once.', ...
        'This is not allowed because the values may conflict.');
    error(eid,'%s',msg)
  end
end

%---------------------------------------------------------------------
function geostruct = projectGeoStruct(mstruct, geostruct)
%Project a GEOSTRUCT if it contains Lat and Lon fields.

if isfield(geostruct,'Lat') && isfield(geostruct,'Lon')

  % Project if the mstruct is available
  if ~isempty(mstruct)
    if isequal(geostruct.Geometry,'Polygon')
      geostruct = projGeoPatch(geostruct, mstruct);
    else
      geostruct = projGeoLine(geostruct, mstruct);
    end
  else
    [geostruct.X] = deal(geostruct.Lon);
    [geostruct.Y] = deal(geostruct.Lat);
  end
  geostruct = rmfield(geostruct,{'Lat','Lon'});
end

%---------------------------------------------------------------------
function geostruct = projGeoPatch(geostruct,mstruct)
%Project a GEOSTRUCT containing Polygon geometry

for i=1:length(geostruct)
  parts = extractgeoparts(geostruct(i).Lon, geostruct(i).Lat);
  for j=1:length(parts)
     z = ones(size(parts(j).Y));
     if size(parts(j).X,1) == 1
        parts(j).X = parts(j).X';
     end
     if size(parts(j).Y,1) == 1
        parts(j).Y = parts(j).Y';
     end
     [parts(j).projx,parts(j).projy,z,savepts] = ...
        mfwdtran(mstruct, parts(j).Y,parts(j).X,z,'patch');
  end
  geostruct(i).X = [extractfield(parts,'projx'), NaN];
  geostruct(i).Y = [extractfield(parts,'projy'), NaN];
end

%---------------------------------------------------------------------
function geostruct = projGeoLine(geostruct,mstruct)
%Project a GEOSTRUCT containing Line geometry

for i=1:length(geostruct)
  z = ones(size(geostruct(i).Lat));
  [x,y,z,savepts] = mfwdtran(mstruct,geostruct(i).Lat,geostruct(i).Lon,z,'line');
  geostruct(i).X = x;
  geostruct(i).Y = y;
end

%---------------------------------------------------------------------
function checkmapnargin(low, high, numInputs, function_name, displayType)
%Check number of data arguments.
%
%   CHECKMAPNARGIN(LOW,HIGH,NUM_INPUTS,FUNCTION_NAME) checks whether 
%   NUM_INPUTS is in the range indicated by LOW and HIGH.  If not,
%   CHECKMAPNARGIN  issues a formatted error message using the string in
%   FUNCTION_NAME.
%
%   LOW should be a scalar nonnegative integer.
%
%   HIGH should be a scalar nonnegative integer or Inf.
%
%   FUNCTION_NAME should be a string.
%

if numInputs < low
  msgId = sprintf('%s:%s:tooFewInputs', getcomp, function_name);
  msgDisp = sprintf('%s%s','with DisplayType set to ',displayType);
  if low == 1
    msg1 = sprintf('Function %s expected at least 1 input data argument', ...
                   upper(function_name));
  else
    msg1 = sprintf('Function %s expected at least %d input data arguments', ...
                   upper(function_name), low);
  end
  
  if numInputs == 1
    msg2 = 'but was called instead with 1 input data argument.';
  else
    msg2 = sprintf('but was called instead with %d input data arguments.', ...
                   numInputs);
  end
  
  error(msgId, '%s,\n%s,\n,%s', msg1, msgDisp, msg2);
  
elseif numInputs > high
  msgId = sprintf('%s:%s:tooManyInputs', getcomp, function_name);
  msgDisp = sprintf('%s%s','with DisplayType set to ',displayType);

  if high == 1
    msg1 = sprintf('Function %s expected at most 1 input data argument', ...
                   upper(function_name));
  else
    msg1 = sprintf('Function %s expected at most %d input data arguments', ...
                   upper(function_name), high);
  end
  
  if numInputs == 1
    msg2 = 'but was called instead with 1 input data argument.';
  else
    msg2 = sprintf('but was called instead with %d input data arguments.', ...
                   numInputs);
  end
  
  error(msgId, '%s,\n%s,\n%s', msg1, msgDisp, msg2);
end

%---------------------------------------------------------------------------
function b = isvector(v)
s = size(v);
if s(1) == 1 || s(2) == 1
  b = true;
else
  b = false;
end


