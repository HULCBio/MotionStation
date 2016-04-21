function [ax, mapdata, layerName] = parseMapInputs(mapfilename, varargin)
%PARSEMAPINPUTS Parse the command line and return the map parameters.
%
%   [AX, MAPDATA, LAYERNAME] = PARSEMAPINPUTS(VARARGIN) returns the axes
%   handle in AX, the data arguments into the structure MAPDATA and the
%   LAYERNAME (which may be empty). 
%   
%   The MAPDATA structure contains the following fields:
%
%   type      A string defining the type of map data. 
%             Valid names are: image grid vector
%
%   function  A string defining the name of the function to render
%             the components.
%
%   args      A cell array containing the arguments to pass to the
%             rendering function.
%
%   HGparams  A structure defining the Handle Graphics parameter/value
%             pairs. In addition, HGparams contains the fieldname 
%             Parent with an Handle Graphics axes value.
%
%   Info      A structure containing meta data information, which is
%             empty if the data is not from a file.
%
%   If the type is image, then the following additional fields are present:
%
%   XData     The Handle Graphics XData.
%
%   YData     The Handle Graphics YData.
%
%   cmap      The color map. 
%   


%  
%   See also BUILDMAPDATA, MAPSHOW, MAPVIEW, READMAPDATA.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:39 $

%----------------------------------------------------------------------
checknargin(2,inf,nargin,mapfilename);

% Obtain the data arguments and the property/value pairs in a cell 
%  from the command line.
[dataArgs, paramPairs] = splitDataAndParamPairs(mapfilename,varargin{:});

% Verify that the parameter/value pairs are 
%  string, value combinations.
checkParamValuePairs(mapfilename,paramPairs);

% Obtain the 'qualifiers' (non-HG prop/value pairs)
%  from the parameter pairs.
% HGpairs will be the remaining prop/value pairs that
%   are passed through to the HG object.
[ax, layerName, spec, coordSys, displayType, HGpairs] = ...
                     parseQualifiers(mapfilename, numel(dataArgs), paramPairs{:});

% Obtain the axes and the mapdata structure.
[ax, mapdata] = parseMapData(mapfilename, ax, layerName, dataArgs, ...
                             coordSys, displayType, spec, HGpairs);

%----------------------------------------------------------------------
function [dataArgs, propValuePairs] = splitDataAndParamPairs(mapfilename, ...
                                                             varargin)
% Split the data from the paramater/value pairs.
startIndex = 1;
nnargin = nargin -1;
if any(ishandle(varargin{1}))  % (AX, ...)
  if nnargin == 1
    eid = sprintf('%s:%s:tooFewInputs', getcomp, mapfilename);
    msg = sprintf('%s%s%s\n%s', 'Function ', upper(mapfilename),...
                 ' expected at least two input arguments', ...
                 'but was called instead with one input argument.');
    error(eid, '%s',msg)
  end
  startIndex = 2;
end

if ischar(varargin{startIndex})  % (FILENAME)
  startIndex = startIndex + 1;
end

% numArgs is the number of arguments to the first
%  string input, (except a filename input)
numArgs = getNumDataArgs(varargin{startIndex:end}) + startIndex - 1;
if numArgs ~= 0
  dataArgs = {varargin{1:numArgs}};
else
  % Should never get here
  %  except by internal error
  eid = sprintf('%s:%s:tooFewInputs', getcomp, mapfilename);
  msg = sprintf('%s%s%s\n%s', 'Function ', upper(mapfilename),...
                 ' expected at least one input data argument', ...
                 'but was called instead with zero data arguments.');
  error(eid, '%s',msg)
end

varargin(1:numArgs) = [];

% Property/value pairs is the remainder of the arguments
propValuePairs = varargin;

%----------------------------------------------------------------------
function numArgs = getNumDataArgs(varargin)
% Get the number of arguments to the first string input.
numArgs = nargin;
for i=1:nargin
  if ischar(varargin{i})
     numArgs = i-1;
     return;
  end
end

%----------------------------------------------------------------------
function checkParamValuePairs(mapfilename, varargin)
% Verify the inputs are in 'Parameter', value pairs syntax form,
%  by checking for pairs (even) and a string first pair. 

pairs = varargin{:};
if length(pairs) > 0
  if rem(length(pairs),2)
    eid = sprintf('%s:%s:invalidPairs', getcomp, mapfilename);
    msg = sprintf('The property/value inputs must always occur as pairs.');
    error(eid, '%s',msg)
  end
  params = pairs(1:2:end);
  for i=1:length(params)
    if ~ischar(params{i})
      eid = sprintf('%s:%s:invalidPropString', getcomp, mapfilename);
      msg = sprintf('The paramater/value pairs must be a string followed by value.');
      error(eid, '%s',msg)
    end
  end
end

%---------------------------------------------------------------------
function [ax, layerName, spec, coordSys, displayType, pairs] = ...
                        parseQualifiers(mapfilename, numArgs,varargin)
% Obtain the optional qualifiers from the input.
%  numArgs is the number of initial inputs preceeding varargin.

% Assign empty if not found in varargin.
ax = [];
layerName = [];
spec = [];
coordSys = [];
displayType = [];
deleteIndex = [];

validPropertyNames = ...
    {'DisplayType','CoordinateType', 'SymbolSpec', 'LayerName','Parent'};
for k = 1:2:numel(varargin)
   try
     propName = checkstrs(lower(varargin{k}), validPropertyNames, ...
                                              mapfilename, 'PARAM', k);
   catch
     lasterr('');
     propName = '';
   end
   switch propName
     case 'DisplayType'
        if ~checkDuplicate(mapfilename, displayType, varargin{k}, varargin{k+1});
           displayNames = {'surface','contour', 'mesh','texturemap', ...
                            'image', 'point','line','polygon'};
           displayType = checkstrs(lower(varargin{k+1}),displayNames,...
                                  mapfilename,'DISPLAYTYPE',numArgs+k+1);
        end
        deleteIndex = [deleteIndex, k, k+1];

     case 'CoordinateType'
        if ~checkDuplicate(mapfilename, coordSys, varargin{k}, varargin{k+1});
          coordSys = checkstrs(lower(varargin{k+1}),{'geographic','map'},...
                                mapfilename,'COORDINATETYPE',numArgs+k+1);
        end
        deleteIndex = [deleteIndex, k, k+1];

     case 'SymbolSpec'
        if ~isvalidsymbolspec(varargin{k+1});
           eid = sprintf('%s:%s:invalidSpec', getcomp, mapfilename);
           msg = sprintf('%s%s%s','The ',num2ordinal(numArgs+k+1),...
           ' input argument is not a valid symbol spec.');
           error(eid, '%s',msg)
        end
        spec = [spec, {varargin{k+1}}];
        deleteIndex = [deleteIndex, k, k+1];

     case 'LayerName'
        if ~checkDuplicate(mapfilename, layerName, varargin{k}, varargin{k+1});
          layerName = varargin{k+1};
        end
        deleteIndex = [deleteIndex, k, k+1];

     case 'Parent'
        if ~checkDuplicate(mapfilename, ax, varargin{k}, varargin{k+1});
          ax = varargin{k+1};
        end
        checkAxes(ax, mapfilename, varargin{k}, numArgs+k+1);
        deleteIndex = [deleteIndex, k, k+1];

     otherwise
   end
end
varargin(deleteIndex)=[];
pairs = varargin;

%---------------------------------------------------------------------
function duplicate = checkDuplicate(mapfilename, oldValue, newParam, newValue)
% Warns if oldValue is not empty

duplicate = false;
if ~isempty(oldValue)
  duplicate = true;
  wid = sprintf('%s:%s:ignoringParam', getcomp, mapfilename);
  msg = sprintf('%s%s%s%s%s\n%s%s','Parameter ''',newParam, ...
                ''' has already been set with value ''',oldValue, '''',...
                'Ignoring value ',num2str(newValue));
  warning(wid, '%s',msg);
end

%----------------------------------------------------------------------
function checkAxes(ax, function_name, variable_name, argument_position)
% Check for a valid axes object.

foundError = true;
while(foundError)
  if  ~all(ishandle(ax)) 
    eid = sprintf('%s:%s:invalidHandle', getcomp, function_name);
    msg2 = sprintf('The parameter is not a handle.');
    break
  end

  if numel(ax) ~= 1 
    eid = sprintf('%s:%s:tooManyHandles', getcomp, function_name);
    msg2 = sprintf('The parameter is a handle array.');
    break
  end

  if ~isnumeric(ax)
    eid = sprintf('%s:%s:handleNotNumeric', getcomp, function_name);
    msg2 = sprintf('The handle is not numeric.');
    break
  end

  if isprop(ax,'Type') && ~strcmp(get(ax,'Type'),'axes')
    eid = sprintf('%s:%s:handleNotAxes', getcomp, function_name);
    msg2 = sprintf('%s%s%s', ...
                  'The handle type is ''', get(ax,'Type'), ...
                  ''' rather than ''axes''. ');
    break
  end
  foundError = false;
end

if foundError
  if argument_position == 1
     msgHandle = sprintf('%s%s',variable_name, ', to be a valid axes handle.');
  else
     msgHandle =  'PARENT, to be a valid axes handle.';
  end
  msg1 = sprintf('%s%s%s%s%s', ...
                 'Function ', upper(function_name), ' expected its ', ... 
                 num2ordinal(argument_position), ' input argument, ', ...
                  msgHandle);
  error(eid, '%s\n%s', msg1, msg2);
end

%----------------------------------------------------------------------
function [ax, mapdata] = parseMapData(mapfilename, ax, layerName, dataArgs, ...
                                      coordSys, displayType, spec, HGpairs)
% Parse the dataArgs cell array and return the map data in mapdata
%  and the axes handle in ax.
  
% Initialize layerName.
if isempty(layerName)
  layerName = ' ';
end

% Get the axes object.
[dataArgs, ax] = getAxes(mapfilename, dataArgs, ax);

%  Assign the defaults for DisplayType and CoordinateType
if isempty(displayType)
  displaySupplied = false;
  if (numel(dataArgs) == 2) && ...
     (numel(dataArgs{1}) == numel(dataArgs{2})) && ...
      isvector(dataArgs{1}) && isvector(dataArgs{2})
     displayType = 'line';
  else
     displayType = 'image';
  end
else
  displaySupplied = true;
end
if isempty(coordSys) 
  coordSys = 'map';
end

if ischar(dataArgs{1})
  % Obtain the dataArgs from the file
  [dataArgs, type, info] = readMapData(mapfilename, dataArgs{1});

  % Allow the user to override the displayType
  if ~displaySupplied
    displayType = type;
  end
else 
  info = struct([]);
end

% Build the mapdata structure 
mapdata = buildMapData(mapfilename, dataArgs,  coordSys, displayType, ...
                       ax, layerName, spec, HGpairs);

% Assign the info structure to mapdata
% (which is empty if the command line does not contain a filename.)
mapdata.Info = info;

%----------------------------------------------------------------------
function [dataArgs, ax] = getAxes(mapfilename, dataArgs, ax)
% Assign the axes
%  The axes priority is the first argument in the command line
%   even if the axes has been previously assigned by the 
%  'Parent' parameter pair.

if (numel(dataArgs{1}) == 1) && ishandle(dataArgs{1}) 
  % allow for MAPSHOW(X,Y) , where X happens to be a figure handle number
  if ~( (numel(dataArgs) == 2) && isnumeric(dataArgs{1}) && isnumeric(dataArgs{2}) )
    ax = dataArgs{1};
    checkAxes(ax, mapfilename, 'AX', 1);
    dataArgs(1) = [];
  end
end
if isempty(ax)
  ax = newplot;
end

%---------------------------------------------------------------------------
function b = isvector(v)
s = size(v);
if s(1) == 1 || s(2) == 1
  b = true;
else
  b = false;
end
