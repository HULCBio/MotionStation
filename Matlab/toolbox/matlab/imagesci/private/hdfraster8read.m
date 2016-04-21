function [data,map] = hdfraster8read(hinfo)
%HDFRASTER8READ
%
%   [DATA,MAP] = HDFRASTER8READ(HINFO) returns in the variable DATA the
%   image from the file for the particular 8-bit raster image described by
%   HINFO.  MAP contains the colormap if one exists for the image.  HINFO is
%   A structure extraced from the output structure of HDFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:14 $

data = [];
parseInputs(hinfo);

try
  status = hdfdfr8('readref',hinfo.Filename,hinfo.Ref);
  hdfwarn(status)

  [data,map,status]  = hdfdfr8('getimage',hinfo.Filename);
  hdfwarn(status)
catch
  warning('MATLAB:hdfraster8read:getimage', '%s', lasterr);
end
status = hdfdfr8('restart');
hdfwarn(status)
%Put the image data and colormap in the right order for image display in
%MATLAB
data = data';
map = double(map')/255;
return;

%=======================================================================
function parseInputs(hinfo)

error(nargchk(1,1,nargin, 'struct'));

%Verify required fields
msg = 'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.';

if ~isstruct(hinfo)
  error('MATLAB:hdfraster8read:invalidInputs', '%s', msg);
end
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Ref'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfraster8read:invalidInputs', '%s', msg);
    end
  end
else 
  error('MATLAB:hdfraster8read:invalidInputs', '%s', msg);
end
return;





