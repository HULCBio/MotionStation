function modules = rtwsfcn_modules(projectDir)
%RTWSFCN_MODULES - Helper M-file used by RTW S-function target
%   Returns list of include modules for the RTW S-function module include.
%   See sfcnmoduleinc.tlc

%       Copyright 1994-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.4 $

  cr = sprintf('\n');
  cfiles = dir([projectDir,filesep,'*.c']);
  
  [aDummyPath projectDir] = fileparts(projectDir);
  
  modules = '';
  includeStart = '#include "';
  for fileIdx=1:length(cfiles)
    addFile = true; % assume
      
    file = [projectDir, filesep, cfiles(fileIdx).name];
    fid  = fopen(file,'r');
    if fid == -1,
      error('%s', ['Unable to open ',file]);
    end
    line = fgetl(fid); 
    if ischar(line) && ~isempty(findstr('target specific file',line))
      addFile = false;
    end
    fclose(fid);
    
    % rt_nonfinite.c will be included by parent model.
    if ~isempty(findstr(file,'rt_nonfinite.c'))
      addFile = false;
    end

  if addFile
      modules = [modules,includeStart,file,'"',cr];
      %% moduleList = [moduleList, file,' '];
    end
  end

%endfunction rtwsfcn_modules.m
