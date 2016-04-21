function [datatypesout]=mxpcany2byte(datatypes)

% MXPCANY2BYTE - Mask Initialization function for UDP Byte Packing Block
% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/03/25 03:58:45 $


if ~isa(datatypes,'cell')
  error('datatypes argument must be a cell array');
end

datatypesout=[];
for i=1:length(datatypes)
  datatype=datatypes{i};
  if ~isa(datatype,'char')
    error('datatypes elements must be char arrays');
  end
  if strcmp(datatype,'double')
     dtypeout=0;
  elseif strcmp(datatype,'single')
    dtypeout=1;
  elseif strcmp(datatype,'int8')
    dtypeout=2;
  elseif strcmp(datatype,'uint8')
    dtypeout=3;
  elseif strcmp(datatype,'int16')
    dtypeout=4;
  elseif strcmp(datatype,'uint16')
    dtypeout=5;
  elseif strcmp(datatype,'int32')
    dtypeout=6;
  elseif strcmp(datatype,'uint32')
    dtypeout=7;
  elseif strcmp(datatype,'boolean')
    dtypeout=8;
  else
    error('the supported data types are: double, single, int, uint8, int16, uint16, int32, uint32, boolean');
  end
  datatypesout=[datatypesout,dtypeout];
end
