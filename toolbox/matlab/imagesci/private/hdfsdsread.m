function data  = hdfsdsread(hinfo,start,stride,edge)
%HDFSDREAD read HDF Scientific Data Set
%
%   DATA = HDFREAD(HINFO) returns in the variable DATA all data from the
%   file for the particular data set described by HINFO.  HINFO is A
%   structure extraced from the output structure of HDFINFO.
%   
%   DATA = HDFREAD(HINFO,START,STRIDE,EDGE) reads data from a Scientific
%   Data Set.  START specifys the location in the data set to begin
%   reading. Each number in START must be smaller than its corresponding
%   dimension.  STRIDE is an array specifying the interval between the
%   values to be read.  EDGE is an array specifying the length of each
%   dimension to be read.  The sum of EDGE and START must not exceed the
%   size of the corresponding dimension.  The START, STRIDE and EDGE arrays
%   must be arrays the same size as the number of dimensions.  If START, 
%   STRIDE, or EDGE is empty then the default values are used.  START,
%   STRIDE and EDGE are one based.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:16 $

data = [];

%Parse inputs and assign default parameters
[start,stride,edge] = parseSDSInputs(hinfo,start,stride,edge);

msg = sprintf('Problem reading Scientific Data Set ''%s''. The data set may not exist or file may be corrupt.',hinfo.Name);
sdID = hdfsd('start',hinfo.Filename,'read');
if sdID == -1
  warning('MATLAB:hdfsdsread:sdsStart', '%s', msg);
  return;
end
sdsID = hdfsd('select',sdID,hinfo.Index);
if sdsID == -1
  hdfsd('end',sdID);
  warning('MATLAB:hdfsdsread:sdsSelect', '%s', msg);
end

%  HDFSD('readdata',... will error with incorrect input arguments.  To prevent
%  leaving open identifiers if an error occurs, catch the error then and return
%  a warning.
try
  [data,status] = hdfsd('readdata',sdsID,start,stride,edge);
  hdfwarn(status)
catch
  warning('MATLAB:hdfsdsread:sdsReaddata', '%s', lasterr);
end

%Permute data to be the expected dimensions
data = permute(data,ndims(data):-1:1);

status = hdfsd('endaccess',sdsID);
hdfwarn(status)
status = hdfsd('end',sdID);
hdfwarn(status)
return;

%============================================================
function [start,stride,edge] = parseSDSInputs(hinfo,start,stride,edge)
%Check for valid inputs to HDFSDSREAD
%There must be START, STRIDE, and EDGE parameters
error(nargchk(1,4,nargin, 'struct'));

msg = 'HINFO is not a valid structure describing a Scientific Data Set.  Consider using HDFINFO to obtain this structure.';
if ~isstruct(hinfo)
  error('MATLAB:hdfsdsread:invalidSDS', '%s', msg);
end

%Check for required fields in hinfo structure
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Rank','Dims','Index','Name'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfsdsread:invalidSDS', '%s', msg);
    end
  end
else 
  error('MATLAB:hdfsdsread:invalidSDS', '%s', msg);
end
if ~isfield(hinfo.Dims,'Size')
  error('MATLAB:hdfsdsread:invalidSDS', '%s', msg)
end

%Assign default values to parameters not defined in input
%start, stride and edge are one based. 
if any([start<1, stride<1, edge<1])
  error('MATLAB:hdfsdsread:invalidStartStrideEdge', ...
        'START, STRIDE, and EDGE values must be 1 or greater.');
end

if isempty(start)
  start = zeros(1,hinfo.Rank);
else
  start = start-1;
end

if isempty(stride)
  stride = ones(1,hinfo.Rank);
end

if isempty(edge)
  for i=1:hinfo.Rank
    edge(i) = fix((hinfo.Dims(i).Size-start(i))/stride(i));
  end
end
