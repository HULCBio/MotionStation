function makeInfo=rtwmakecfg()                                             
%RTWMAKECFG Add include and source directories to RTW make files.          
%  makeInfo=RTWMAKECFG returns a structured array containing               
%  following fields:                                                       
%                                                                          
%     makeInfo.includePath - cell array containing additional include      
%                            directories. Those directories will be        
%                            expanded into include instructions of rtw     
%                            generated make files.                         
%                                                                          
%     makeInfo.sourcePath  - cell array containing additional source       
%                            directories. Those directories will be        
%                            expanded into rules of rtw generated make     
%                            files.                                        
%                                                                          
%     makeInfo.library     - structure containing additional runtime library
%                            names and module objects.  This information   
%                            will be expanded into rules of rtw generated 
%                            make files.  

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.4.4.4 $ $Date: 2004/04/16 22:17:11 $
  ;
  cg_dir = fullfile(matlabroot,'toolbox','physmod','mech','c');
  makeInfo.includePath = { cg_dir };
  makeInfo.sourcePath  = { cg_dir,fullfile(matlabroot,'toolbox','physmod','mech','mech')};

  arch = lower(computer);
  if ispc, arch = 'win32'; end

  makeInfo.precompile = 1;
  makeInfo.library(1).Name     = 'mech_cg';
  makeInfo.library(1).Location = fullfile(matlabroot,'toolbox','physmod', 'mech', 'lib', arch);
  makeInfo.library(1).Modules  = strrep(getfilesbytype(cg_dir, '*.c'),'.c','');

% Function: getfilesbytype =====================================================
% Abdtract:
%      Returns a cell array with filenames that maches the 'pattern' (eg. *.c)
%      within the given 'directory' tree.
%      Returns a cell array of directories if the 'pattern' equals 'd'.
%
function cellFiles = getfilesbytype(directory, pattern)
  cellFiles = {};
  if pattern == 'd'
    bDir = 1;
    localPattern = '*';
  else
    bDir = 0;
    localPattern = pattern;
  end
  currDir = pwd;
  
  cd(directory);
  
  if ~bDir
    files = dir(localPattern);
    for i=1:length(files)
      if ~(files(i).isdir)
	cellFiles{end+1} = files(i).name;
      end
    end
  end
  
  %% recurse on directories
  strDir = dir;
  for i=1:length(strDir)
    if strDir(i).isdir & strDir(i).name(1) ~= '.'
      if bDir
	cellFiles{end+1} = fullfile(pwd, strDir(i).name);
      end
      tempCell = getfilesbytype(strDir(i).name, pattern);
      cellFiles = {cellFiles{:}, tempCell{:}};
    end
  end
  
  cd(currDir);

% [EOF] rtwmakecfg.m                               