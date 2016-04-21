function data = hdfraster24read(hinfo)
%HDFRASTER24READ
%
%   DATA = HDFRASTER24READ(HINFO) returns in the variable DATA the image
%   from the file for the particular 24-bit raster image described by HINFO.
%   HINFO is A structure extraced from the output structure of HDFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:12 $

data = [];

parseInputs(hinfo);
try
  status = hdfdf24('readref',hinfo.Filename,hinfo.Ref);
  hdfwarn(status)

  [data, status] = hdfdf24('getimage',hinfo.Filename);
  hdfwarn(status)
catch
  warning('MATLAB:hdfraster24read:getimage', '%s', lasterr)
end
status = hdfdf24('restart');
hdfwarn(status)
%Put the image data in the right order for image display in MATLAB
data = permute(data,[3 2 1]);
return;

%=======================================================================
function parseInputs(hinfo)

error(nargchk(1,1,nargin, 'struct'));
	  
%Verify required fields
msg = 'Invalid input arguments.  HINFO must be a structure with fields ''Filename'', and ''Ref''.  Consider using HDFIFNO to obtain this structure.';

if ~isstruct(hinfo)
    error('MATLAB:hdfraster24read:invalidInputs', '%s', msg);
end
fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Ref'};
numReqFields = length(reqFields);
if numFields >= numReqFields
  for i=1:numReqFields
    if ~isfield(hinfo,reqFields{i})
      error('MATLAB:hdfraster24read:invalidInputs', '%s', msg);
    end
  end
else 
  error('MATLAB:hdfraster24read:invalidInputs', '%s', msg);
end
