function out = compute_value_from_rtwoptions(hModel)
% COMPUTE_VALUE_FROM_RTWOPTIONS - Real-Time Workshop internal routine.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $
  
rtwoptions = get_param (hModel, 'RTWOptions');
tmp = findstr (rtwoptions, 'FileSizeThreshold');
if isempty(tmp)
  tmp = findstr (rtwoptions, 'FunctionSizeThreshold');
  if isempty(tmp)
    % Neither FunctionSizeThreshold nor FileSizeThreshold
    % is in RTWOptions
    out = 1;
  else
    % Only FunctionSizeThreshold is in RTWOptions
    out = 2;
  end
else
  tmp = findstr (rtwoptions, 'FunctionSizeThreshold');
  if isempty(tmp)
    % Only FileSizeThreshold is in RTWOptions    
    out = 3;
  else
    % Both FunctionSizeThreshold and FileSizeThreshold
    % are in RTWOptions    
    out = 4;
  end
end
