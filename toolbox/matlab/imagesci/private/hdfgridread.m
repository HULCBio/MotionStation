function data = hdfgridread(hinfo,fieldname,varargin)
%HDFGRIDREAD
%  
%   DATA=HDFGRIDREAD(HINFO,FIELD) reads data from the field FIELD of an
%   HDF-EOS Grid structure identified by HINFO.  
%   
%   DATA=HDFGRIDREAD(HINFO,FIELD,PARAM,VALUE,PARAM2,VALUE2,...) reads
%   data from an HDF-EOS grid structure identified by HINFO.  The data is
%   subset with the parameters PARAM,PARAM2,... with the particular type of
%   subsetting defined in SUBSET.  
%   
%   SUBSET may be any of the strings below, defined in HDFINFO:
%   
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%   
%   The 'Fields' subsetting method is required. The SUBSET methods 'Index',
%   'Tile', and 'Interpolate' and 'Pixels' are  exclusive.  They may not be
%   used with any other method of subsetting the Grid data.  'Time' may be used
%   alone, following 'Box', or following 'Vertical' subsetting.  'Vertical may
%   be used without previous subsetting, following 'Box' or 'Time' subsetting.
%   For example the following command 
%   
%   data=hdfgridread(hinfo,'Fields',fieldname,'Box',{long,lat},'Time',{1.1,1.2})
%   
%   will first subset the grid be defining a box region, then subset the grid
%   along the time period.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:07 $

data= [];
regionID = [];

%Verify inputs are valid
parseInputs(hinfo,fieldname,varargin{:});

%Open interfaces
msg = sprintf('Unable to open Grid interface to read ''%s'' data set. Data set may not exist or file may be corrupt.',hinfo.Name);

fileID = hdfgd('open',hinfo.Filename,'read');
if fileID==-1
  warning('MATLAB:hdfgridread:openInterface', '%s', msg);
  return
end

gridID = hdfgd('attach',fileID,hinfo.Name);
if gridID==-1
  hdfgd('close',fileID);
  warning('MATLAB:hdfgridread:attachInterface', '%s', msg);
  return
end

%Default
numPairs = length(varargin)/2;
if numPairs==0
  numPairs = 1;
  params = {'index'};
  values = {{[],[],[]}};
else
  params = varargin(1:2:end);
  values = varargin(2:2:end);
end

%Just in case
params = lower(params);

%Subset and read
msg = '''%s'' method requires %i value(s) to be stored in a cell array.';
for i=1:numPairs
  switch params{i}
   case 'index'
    if iscell(values{i})
      if length(values{i})==3
	[start,stride,edge] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
	error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 3);
      end
    else
      closeGDInterfaces(fileID,gridID);
      error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 3);
    end
    for j=1:length(hinfo.DataFields)
      match = strmatch(fieldname,hinfo.DataFields(j).Name,'exact');
      if match
	break;
      end
    end
    if isempty(match)
      warning('MATLAB:hdfgridread:wrongNumberOfValues', ...
              '''%s'' field not found.  Data field may not exist.', ...
              fieldname);
    else
    [start,stride,edge] = defaultIndexSubset(hinfo.DataFields(j).Dims,start,stride,edge);
    try
	[data,status] = hdfgd('readfield',gridID,fieldname,start,stride,edge);
	hdfwarn(status)
      catch
	warning('MATLAB:hdfgridread:readfield', '%s', lasterr)
      end
    end
   case 'tile'
    if iscell(values{i})
      if length(values{i})==1
	tileCoords = values{i}{:}-1;
      else
	closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 1);
      end
    else
      tileCoords = values{i}-1;
    end
    if any(tileCoords<1)
      error('MATLAB:hdfgridread:badTile', ...
            '''Tile'' values must not be less than 1.');
    end
    try
      [data,status] = hdfgd('readtile',gridID,fieldname,tileCoords);
      hdfwarn(status)
    catch
      warning('MATLAB:hdfgridread:readtile', '%s', lasterr)
    end
   case 'pixels'
    if iscell(values{i})
      if length(values{i})==2
	[lon,lat] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
      end
    else
      closeGDInterfaces(fileID,gridID);
      error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
    end
    try
      [rows,cols,status] = hdfgd('getpixels',gridID,lon,lat);
      hdfwarn(status)
      [data,status] = hdfgd('getpixvalues',gridID,rows,cols,fieldname);
      hdfwarn(status)
    catch
      warning('MATLAB:hdfgridread:getvalues', '%s', lasterr)
    end
   case 'interpolate'
    if iscell(values{i})
      if length(values{i})==2
	[lon,lat] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
      end
    else
      closeGDInterfaces(fileID,gridID);
      error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
    end
    try
      [data, status] = hdfgd('interpolate',gridID,lon,lat,fieldname);
      hdfwarn(status)
    catch
      warning('MATLAB:hdfgridread:interpolate', '%s', lasterr)
    end
   case 'box'
    if iscell(values{i})
      if length(values{i})==2
	[lon,lat] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
      end
    else
      closeGDInterfaces(fileID,gridID);
      error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
    end
    regionID = hdfgd('defboxregion',gridID,lon,lat);
    hdfwarn(regionID);
   case 'time'
    if iscell(values{i})
      if length(values{i})==2
	[start, stop] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
      end	
    else
      closeGDInterfaces(fileID,gridID);
      error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
    end
    if isempty(regionID)
      regionID = hdfgd('deftimeperiod',gridID,-1,start,stop);
    else
      regionID = hdfgd('deftimeperiod',gridID,regionID,start,stop);
    end
    hdfwarn(regionID);
   case 'vertical'
    if iscell(values{i})
      if length(values{i})==2
	[dimension,range] = deal(values{i}{:});
      else
	closeGDInterfaces(fileID,gridID);
        error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
      end
    else
      closeGDInterfaces(fileID,gridID);
      error('MATLAB:hdfgridread:wrongNumberOfValues', msg, params{i}, 2);
    end
    if isempty(regionID)
      regionID = hdfgd('defvrtregion',gridID,-1,dimension,range);
    else
      regionID = hdfgd('defvrtregion',gridID,regionID,dimension,range);
    end
   otherwise
    closeGDInterfaces(fileID,gridID);
    error('MATLAB:hdfgridread:unknownSubsetMethod', ...
          'Unrecognized subsetting method %s.',params{i});
  end
end

if ~isempty(regionID) && regionID~=-1
  try
    [data,status] = hdfgd('extractregion',gridID,regionID,fieldname);
    hdfwarn(status)
  catch
    warning('MATLAB:hdfgridread:extractregion', '%s', lasterr)
  end
end

closeGDInterfaces(fileID,gridID);

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);


%=================================================================
function closeGDInterfaces(fileID,gridID)
%Close interfaces
status = hdfgd('detach',gridID);
hdfwarn(status)
status = hdfgd('close',fileID);
hdfwarn(status)


%=================================================================
function parseInputs(hinfo,fieldname,varargin)

if isempty(fieldname)
  error('MATLAB:hdfgridread:missingFieldsParam', ...
        'Must use ''Fields'' parameter when reading HDF-EOS Grid data sets.');
else
  fields = parselist(fieldname);
end

if length(fields)>1
  error('MATLAB:hdfgridread:tooManyFields', ...
        'Only one field at a time can be read from a Grid.');
end

if rem(length(varargin),2)
  error('MATLAB:hdfgridread:wrongParamValCount', ...
        'The parameter/value inputs must always occur as pairs.');
end

msg = 'HINFO is not a valid structure describing HDF-EOS Grid data.  Consider using HDFINFO to obtain this structure.';
%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfgridread:invalidHinfoStruct', msg);
    end
  end
else 
  error('MATLAB:hdfgridread:invalidHinfoStruct', msg);
end

%Check to see if methods are exclusive.
exclusiveMethods = {'Index','Tile','Pixels','Interpolate'};
numPairs = length(varargin)/2;
params = varargin(1:2:end);

for i=1:numPairs
  match = strmatch(params{i},exclusiveMethods);
  if ~isempty(match) && numPairs>1
    error('MATLAB:hdfgridread:badSubsetParams', ...
          'Multiple exclusive subsetting parameters used.');
  end
end


%=================================================================
function [start,stride,edge] = defaultIndexSubset(Dims,startIn,strideIn,edgeIn)
%Calculate default start, stride and edge values if not defined in input
%START, STRIDE, and EDGE are one based

if any([startIn<1, strideIn<1, edgeIn<1])
  error('MATLAB:hdfgridread:badSubsetIndex', ...
        'START, STRIDE, and EDGE values must not be less than 1.');
end

rank = length(Dims);
if isempty(startIn) 
  start = zeros(1,rank);
else
  start = startIn-1;
end
if isempty(strideIn)
  stride= ones(1,rank);
else
  stride = strideIn;
end
if isempty(edgeIn)
  edge = zeros(1,rank);
  for i=1:rank
    edge(i) = fix((Dims(i).Size-start(i))/stride(i));
  end
else
  edge = edgeIn;
end
