function [oFileExits, oIsNewer] = sl_file_is_newer(iFile, iDateNum)
% check if the input file is newer than a specified date

% Outputs: 
%   oFileExits: return true if the file exists
%   oIsNewer: return true if the file is newer than the specified date
%
  
% Copyright 2004 The MathWorks, Inc.
  % $Revision: 1.1.6.2 $
  
  oFileExits = false; %% failure. File not found
  oIsNewer   = false;  %% does not matter
  
  file = which(iFile);
  if isempty(file),
    % this can happen if iFile has no extension
    file = iFile;
  end
  fileDate = sl_get_file_date(file);
  if isempty(fileDate)
    % File not found
    oFileExits = false;
  else
    oFileExits = true;
    oIsNewer = (datenum(fileDate) > iDateNum);
  end

%endfunction
