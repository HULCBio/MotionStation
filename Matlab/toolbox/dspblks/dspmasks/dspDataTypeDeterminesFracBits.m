function status = dspDataTypeDeterminesFracBits(dataType)
%status = dspDataTypeDeterminesFracBits(dataType)
%   dataType : edit box string from a Signal Processing Blockset source
%              block's 'User defined' data type parameter.
%
%   NOTE: This is a Signal Processing Blockset mask utility function. %
%   It is not intended to be used as a general-purpose function.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:05:45 $

%
%
% THIS FUNCTION SHOULD ONLY BE CALLED FOR THE 'USER-DEFINED' SETTING
% OF DSP BLOCKSET SOURCE BLOCKS (i.e., not the 'Fixed-point' setting)
%
%

dtEval = 1;

try
  dt = eval(dataType);
catch
  dtEval = 0;
end
if ~dtEval
  try
    dt = evalin('caller',dataType);
    dtEval = 1;
  catch
    % nuthin' to do - dtEval is already false
  end
end
if ~dtEval
  try
    dt = evalin('base',dataType);
    dtEval = 1;
  catch
    status = 0;
    return
  end
end

if isfield(dt,'Class')
  className = dt.Class;
elseif strcmp(class(dt),'Simulink.NumericType')
  className = upper(dt.Category);
else
  status = 0;
  return;
end


  switch(className)
   case {'DOUBLE','SINGLE','INT8','UINT8','INT16','UINT16','INT32', ...
         'UINT32','BOOLEAN','INT','FRAC','FLOAT', ...
         'FIXED-POINT: BINARY POINT SCALING', ...
         'FIXED-POINT: SLOPE AND BIAS SCALING' }
    status = 1;
   case {'FIX','FIXED-POINT: UNSPECIFIED SCALING' }
    status = 0;
  end
