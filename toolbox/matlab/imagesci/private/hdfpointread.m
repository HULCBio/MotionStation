function data = hdfpointread(hinfo,level,fieldname,varargin)
%HDFPOINTREAD
%  
%   DATA=HDFPOINTREAD(HINFO,LEVEL) reads data from the LEVEL of an
%   HDF-EOS Point structure identified by HINFO.  
%   
%   DATA=HDFPOINTREAD(HINFO,LEVEL,PARAM,VALUE,PARAM2,VALUE2,...) reads
%   data from an HDF-EOS point structure identified by HINFO.  The data is
%   subset with the parameters PARAM, PARAM2,... with the particular type of
%   subsetting defined in SUBSET.  
%   
%   SUBSET may be any of the strings below, defined in HDFINFO:
%   
%             Point           |   'Level'          (required)
%                             |   'Field'          (required)
%                             |   'RecordNumbers'  (exclusive)
%                             |	  'Box'            (exclusive)
%                             |	  'Time'           (exclusive)
%   
%   The 'Fields' and 'Level' subsetting methods are required. The other
%   SUBSET methods may not be used with any other method of subsetting the
%   Point data. 

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:09 $

data = [];

%Verify inputs are valid
parseInputs(hinfo,level,fieldname,varargin{:});

%Open interfaces
msg = sprintf('Unable to open Point interface for ''%s'' data set. File may be corrupt.',hinfo.Name);
fileID = hdfpt('open',hinfo.Filename,'read');
if fileID==-1
  warning('MATLAB:hdfpointread:openInterface', '%s', msg);
  return;
end
pointID = hdfpt('attach',fileID,hinfo.Name);
if pointID==-1
  hdfpt('close',fileID);
  warning('MATLAB:hdfpointread:attachInterface', '%s', msg);
  return;
end

if isnumeric(level)
  %HDF-EOS defines level as zero based
  level = level-1;
else
  levelStr = level;
  level = hdfpt('levelindx',pointID,level);
  if level==-1
    closePTInterfaces(fileID,pointID);
    error('MATLAB:hdfpointread:badPointName', ...
          '%s is not a valid Level name for this Point.', levelStr);
  end
end


%Default 
numPairs = length(varargin)/2;
if numPairs==0
  numPairs = 1;
  params = {'RecordNumbers'};
  values = {0:hinfo.Level(level+1).NumRecords-1};
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
   case 'box'
    if iscell(values{i})
      if length(values{i})==2
	[lon,lat] = deal(values{i}{:});
      else
	closePTInterfaces(fileID,pointID);
	error('MATLAB:hdfpointread:wrongNumberOfValues', msg, params{i}, 2);
      end
    else
      closePTInterfaces(fileID,pointID);
      error('MATLAB:hdfpointread:wrongNumberOfValues', msg, params{i}, 2);
    end
    regionID = hdfpt('defboxregion',pointID,lon,lat);
    hdfwarn(regionID);
    try
      [data, status]  = hdfpt('extractregion',pointID,regionID,level,fieldname);
      hdfwarn(status)
    catch
      warning('MATLAB:hdfpointread:extractregion', '%s', lasterr);
    end
   case 'time'
    if iscell(values{i})
      if length(values{i}) == 2
      [start, stop] = deal(values{i}{:});
      else
	closePTInterfaces(fileID,pointID);
        error('MATLAB:hdfpointread:wrongNumberOfValues', msg, params{i}, 2);
      end
    else
      closePTInterfaces(fileID,pointID);
      error('MATLAB:hdfpointread:wrongNumberOfValues', msg, params{i}, 2);
    end
    regionID = hdfpt('deftimeperiod',pointID,start,stop);
    hdfwarn(regionID);
    try
      [data, status] = hdfpt('extractperiod',pointID,regionID,level,fieldname);
      hdfwarn(status)
    catch
      warning('MATLAB:hdfpointread:extractperiod', '%s', lasterr);
    end
   case 'recordnumbers'
    if iscell(values{i})
      if length(values{i}) == 1
	try
	  [data, status] = hdfpt('readlevel',pointID,level,fieldname,values{i}{:});
	  hdfwarn(status)
	catch
	  warning('MATLAB:hdfpointread:readlevel', '%s', lasterr);
	end
      else
	closePTInterfaces(fileID,pointID);
        error('MATLAB:hdfpointread:wrongNumberOfValues', msg, params{i}, 2);
      end
    else
      try
	[data, status] = hdfpt('readlevel',pointID,level,fieldname,values{i});    
	hdfwarn(status)
      catch
	warning('MATLAB:hdfpointread:readlevel', '%s', lasterr);
      end
    end
   otherwise
    closePTInterfaces(fileID,pointID);
    error('MATLAB:hdfpointread:unknownSubsetMethod', ...
          'Unrecognized subsetting method %s.',params{i});
  end
end
closePTInterfaces(fileID,pointID);

%Permute data to be the expected dimensions
%data = permute(data{1},ndims(data):-1:1);
return;

%=================================================================
function closePTInterfaces(fileID,pointID)
%Close interfaces
status = hdfpt('detach',pointID);
hdfwarn(status)
status = hdfpt('close',fileID);
hdfwarn(status)
return;

%=================================================================
function parseInputs(hinfo,level,fieldname,varargin)

if isempty(fieldname)
  error('MATLAB:hdfpointread:missingFieldsParam', ...
        'Must use ''Fields'' parameter when reading HDF-EOS Point data sets.');
end

if isempty(level)
  error('MATLAB:hdfpointread:missingLevelParam', ...
        'Must use ''Level'' parameter when reading HDF-EOS Point data sets.');
end

if isnumeric(level)
  if level<1
    error('MATLAB:hdfpointread:badLevel', ...
          'LVL must be a number greater than 1.');
  end
elseif ~ischar(level)
  error('MATLAB:hdfpointread:badLevel', ...
        'LVL must be a string represeting the level name or a number representing the level index.');
end

if rem(length(varargin),2)
  error('MATLAB:hdfpointread:wrongParamValCount', ...
        'The parameter/value inputs must always occur as pairs.');
end

msg = 'HINFO is not a valid structure describing HDF-EOS Point data.';
%Verify hinfo structure has all required fields
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Name','Level'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfpointread:invalidHinfoStruct', msg);
    end
  end
else 
  error('MATLAB:hdfpointread:invalidHinfoStruct', msg);
end

%Check to see if methods are exclusive.
exclusiveMethods = {'Box','Time','NumRecords'};
numPairs = length(varargin)/2;
params = varargin(1:2:end);

for i=1:numPairs
  match = strmatch(params{i},exclusiveMethods);
  if ~isempty(match) && numPairs>1
    error('MATLAB:hdfpointread:badSubsetParams', ...
          'Multiple exclusive subsetting parameters used.');
  end
end
