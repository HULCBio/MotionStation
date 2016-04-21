function data = hdfswathread(hinfo,fieldname,varargin)
%HDFSWATHREAD
%  
%   DATA=HDFSWATHREAD(HINFO,FIELD) reads data from the field FIELD of an
%   HDF-EOS Swath structure identified by HINFO.  
%   
%   DATA=HDFSWATHREAD(HINFO,FIELD,PARAM,VALUE,PARAM2,VALUE2,...) reads
%   data from an HDF-EOS swath structure identified by HINFO.  The data is
%   subset with the parameters PARAM, PARAM2,... with the particular type of
%   subsetting defined in SUBSET.  
%   
%   SUBSET may be any of the strings below, defined in HDFINFO:
%   
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |   'ExtMode'
%   
%   The 'Fields' subsetting method is required. The SUBSET method 'Index' may 
%   not be used with any other method of subsetting the Swath data.  'Time' 
%   may be used alone, following 'Box', or following 'Vertical' subsetting.  
%   'Vertical may be used without previous subsetting, following 'Box' or 
%   'Time' subsetting.  When subsetting by time or region, 'ExtMode' can be
%   set to either 'Internal', geolocation fields and data fields must be
%   in the same swath, or 'External', geolocation fields and data fields may
%   be in different swaths.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:18 $

data = [];
regionID = [];

%Verify inputs are valid
parseInputs(hinfo,fieldname,varargin{:});

%Open interfaces
msg = sprintf('Unable to open Swath interface for ''%s'' data set. File may be corrupt.',hinfo.Name);
fileID = hdfsw('open',hinfo.Filename,'read');
if fileID==-1
  warning('MATLAB:hdfswathread:interfaceOpen', '%s', msg);
  return;
end
swathID = hdfsw('attach',fileID,hinfo.Name);
if swathID==-1
  hdfsw('close',fileID);
  warning('MATLAB:hdfswathread:interfaceAttach', '%s', msg);
  return;
end

%Defaults
numPairs = length(varargin)/2;
if numPairs==0
  numPairs = 1;
  params = {'index'};
  values = {{[],[],[]}};
else
  params = varargin(1:2:end);
  values = varargin(2:2:end);
  extmodeidx = strmatch('extmode',lower(params));
  if extmodeidx
    extmode = lower(values{extmodeidx});
    params(extmodeidx) = [];
    values(extmodeidx) = [];
    numPairs = numPairs-1;
  else
    extmode = 'internal';
  end
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
	closeSWInterfaces(fileID,swathID);
	error('MATLAB:hdfswathread:paramValues', msg, params{i}, 3);
      end
    else
      closeSWInterfaces(fileID,swathID);
      error('MATLAB:hdfswathread:paramValues', msg, params{i}, 3);
    end
    for j=1:length(hinfo.DataFields)
      match = strmatch(fieldname,hinfo.DataFields(j).Name,'exact');
      if ~isempty(match)
	[start,stride,edge] = defaultIndexSubset(hinfo.DataFields(j).Dims,start,stride,edge);
	break;
      end
    end
    if isempty(match)
      for j=1:length(hinfo.GeolocationFields)
	match = strmatch(fieldname,hinfo.GeolocationFields(j).Name,'exact');
	if ~isempty(match)
	  [start,stride,edge] = defaultIndexSubset(hinfo.GeolocationFields(j).Dims,start,stride,edge);
	  break;
	end
      end
    end
    if isempty(match)
      warning('MATLAB:hdfswathread:fieldNotFound', ...
              ['''' fieldname ''' field not found.']);
    else
      try
	[data,status] = hdfsw('readfield',swathID,fieldname,start,stride,edge);
	hdfwarn(status)
      catch
	warning('MATLAB:hdfswathread:readfield', '%s', lasterr);
      end
    end
   case 'box'
    if iscell(values{i})
      if length(values{i})==3
	[lon, lat, mode] = deal(values{i}{:});
      else
	closeSWInterfaces(fileID,swathID);
	error('MATLAB:hdfswathread:paramValues', msg, params{i}, 3);
      end
    else
      closeSWInterfaces(fileID,swathID);
      error('MATLAB:hdfswathread:paramValues', msg, params{i}, 3);
    end
    try
      regionID = hdfsw('defboxregion',swathID,lon,lat,mode);
      hdfwarn(regionID);
    catch
      warning('MATLAB:hdfswathread:defboxregion', '%s', lasterr);
    end
   case 'time'
    if iscell(values{i})
      if length(values{i})==3
	[start,stop,mode] = deal(values{i}{:});
      else
	closeSWInterfaces(fileID,swathID);
	error('MATLAB:hdfswathread:paramValues', msg, params{i}, 3);
      end
    else
      closeSWInterfaces(fileID,swathID);
    end
    try
      periodID = hdfsw('deftimeperiod',swathID,start,stop,mode);
      hdfwarn(periodID)
      [data,status] = hdfsw('extractperiod',swathID,periodID,fieldname,extmode);
      hdfwarn(status)
    catch
      warning('MATLAB:hdfswathread:extractperiod', '%s', lasterr);
    end
   case 'vertical'
    if iscell(values{i})
      if length(values{i})==2
	[dimension,range] = deal(values{i}{:});
      else
	closeSWInterfaces(fileID,swathID);
	error('MATLAB:hdfswathread:paramValues', msg, params{i}, 3);
      end
    else
      closeSWInterfaces(fileID,swathID);
      error('MATLAB:hdfswathread:paramValues', msg, params{i}, 3);
    end
    if isempty(regionID)
      regionID = hdfsw('defvrtregion',swathID,'NOPREVSUB',dimension,range);
    else
      regionID = hdfsw('defvrtregion',swathID,regionID,dimension,range);
    end
   otherwise
    closeSWInterfaces(fileID,swathID);
      error('MATLAB:hdfswathread:subsetMethod', ...
            'Unrecognized subsetting method: ''%s''.', params{i});
  end
end

if ~isempty(regionID) && regionID~=-1
  try
    [data,status] = hdfsw('extractregion',swathID,regionID,fieldname,extmode);
    hdfwarn(status)
  catch
    warning('MATLAB:hdfswathread:extractregion', '%s', lasterr);
  end
end

closeSWInterfaces(fileID,swathID);

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);


%=================================================================
function closeSWInterfaces(fileID,swathID)
%Close interfaces
status = hdfsw('detach',swathID);
hdfwarn(status)
status = hdfsw('close',fileID);
hdfwarn(status)


%=================================================================
function parseInputs(hinfo,fieldname,varargin)

if isempty(fieldname)
  error('MATLAB:hdfswathread:fieldsNotProvided', ...
        'Must use ''Fields'' parameter when reading HDF-EOS Swath data sets.');
else
  fields = parselist(fieldname);
end

if length(fields)>1
  error('MATLAB:hdfswathread:tooManyFields', ...
        'Only one field at a time can be read from a Swath.');
end


if rem(length(varargin),2)
  error('MATLAB:hdfswathread:paramValuePairs', ...
        'The parameter/value inputs must always occur as pairs.');
end

msg = 'HINFO is not a valid structure describing HDF-EOS Swath data.';
%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','DataFields','GeolocationFields'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfswathread:invalidHinfoStruct', '%s', msg);
    end
  end
else 
  error('MATLAB:hdfswathread:invalidHinfoStruct', '%s', msg);
end

%Check to see if methods are exclusive.
exclusiveMethods = {'Index'};
numPairs = length(varargin)/2;
params = varargin(1:2:end);
foundExclusive = 0;
for i=1:numPairs
  if foundExclusive==1
    error('MATLAB:hdfswathread:inconsistentPararmeters', ...
          'Multiple exclusive subsetting parameters used.');
  else
    match = strmatch(params{i},exclusiveMethods);
    if ~isempty(match) && numPairs>1
      error('MATLAB:hdfswathread:inconsistentPararmeters', ...
            'Multiple exclusive subsetting parameters used.');
    end
  end
end


%=================================================================
function [start,stride,edge] = defaultIndexSubset(Dims,startIn,strideIn,edgeIn)
%Calculate default start, stride and edge values if not defined in input

if any([startIn<1, strideIn<1, edgeIn<1])
  error('MATLAB:hdfswathread:badStartStrideEdge', ...
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
  edge = zeros(1, rank);
  for i=1:rank
    edge(i) = fix((Dims(i).Size - start(i)) / stride(i));
  end
else
  edge = edgeIn;
end
