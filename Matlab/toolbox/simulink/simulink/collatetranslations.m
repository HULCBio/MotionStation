function [out] = collatetranslations(saveAsVersion)
%COLLATETRANSLATIONS Searches the MATLAB path for products with save-as translations.
%
% For internal use only.
%
% Copyright 1990-2004 The MathWorks, Inc.
  
  
  out = [];
  
  % Check for valid versions
  validVersions = {'SAVEAS_R13SP1', 'SAVEAS_R13', 'SAVEAS_R12', 'SAVEAS_R12P1'};
  if ~any(strcmp(saveAsVersion, validVersions))
    error(['Invalid version in collatetranslations.m: ', saveAsVersion]);
    return;
  end
  
  % Return the sltranslate.m results.
  out = processTranslateFiles(saveAsVersion);
    
  
% Function: process_sltranslate_files_l ========================================
% Abstract:
%      Find all sltranslate.m files on the path and execute them. Return the 
% aggregated results.
%
function [table] = processTranslateFiles(saveAsVersion)
  
  table.RefMap = {};
  table.NewBlocks = {};
  table.NewBlockParams = {};
  table.NewCommonBlockParams = {};
  
  % Find all sltranslate.m
  files = which('sltranslate.m', '-all');
  if ~isempty(files)
    files = cellstr(unique(char(files),'rows'));  % Remove any duplicates.
  end
  
  if isempty(files)
    warning('Could not find translation files for save-as.');
    return;
  end
  
  % Cache away the original path
  currentPath = pwd;
  
  % Loop through the occurances of 'sltranslate.m' in the MATLAB path.
  for i=1:size(files,1);
    try
      [path, func] = fileparts(files{i});
      cd(path);
      out = feval(func, saveAsVersion);
     
      if isfield(out, 'RefMap') 
        table.RefMap = cat(2, table.RefMap, out.RefMap);
      end    
      if isfield(out, 'NewBlocks') 
        table.NewBlocks = cat(2, table.NewBlocks, out.NewBlocks);
      end  
      if isfield(out, 'NewBlockParams') 
        table.NewBlockParams = cat(2, table.NewBlockParams, out.NewBlockParams);
      end  
      if isfield(out, 'NewCommonBlockParams') 
        table.NewCommonBlockParams = cat(2, table.NewCommonBlockParams, out.NewCommonBlockParams);
      end  
    catch
      cd(currentPath);
      error(['Error executing ', files{i}, 10, lasterr]);
    end
  end
  
  % Reset the path
  cd(currentPath);