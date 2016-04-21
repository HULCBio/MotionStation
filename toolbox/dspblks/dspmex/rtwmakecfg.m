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
%                            will be expanded into rules of rtw generated make
%                            files.

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.22.4.3 $ $Date: 2004/04/12 23:07:56 $

rtDir = fullfile(matlabroot,'toolbox','rtw','dspblks','c');  
  
makeInfo.includePath = { ...
    fullfile(matlabroot,'toolbox','dspblks','include') };

if (exist(rtDir)==7)
	rtSubDirs = getfilesbytype(rtDir, 'd');
	makeInfo.sourcePath = { rtSubDirs{:}, ...
    	fullfile(matlabroot,'toolbox','dspblks','src','v4'), ...
    	fullfile(matlabroot,'toolbox','dspblks','src','v3') };
else
	makeInfo.sourcePath = { 
    	fullfile(matlabroot,'toolbox','dspblks','src','v4'), ...
    	fullfile(matlabroot,'toolbox','dspblks','src','v3') };
end

arch = lower(computer);
if ispc, arch = 'win32'; end

makeInfo.precompile = 1;
% xPC target on Windows uses static libraries, others use dsp_rt.dll,
% so when building for the xPC target or when precompiling static
% libraries,  use dsp_rt, otherwise use dsp_dyn_rt (import libraries
% for dsp_rt.dll).
if ispc,
    modelName = get_param(0, 'CurrentSystem');
    isxPCTarget = strcmp(get_param(modelName,'RTWSystemTargetFile'),...
                         'xpctarget.tlc');
    isPrecomp = strcmp(modelName, 'precomplib');
    if isPrecomp || isxPCTarget,
        makeInfo.library(1).Name = 'dsp_rt';
    else
        makeInfo.library(1).Name = 'dsp_dyn_rt';
    end
else
    makeInfo.library(1).Name     = 'dsp_rt';
end
makeInfo.library(1).Location = fullfile(matlabroot,'toolbox','dspblks', 'lib', arch);
if (exist(rtDir)==7)
    makeInfo.library(1).Modules  = strrep(getfilesbytype(rtDir, '*.c'),'.c','');
else
    makeInfo.library(1).Modules  = '';
end

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
  
  strDir = dir;
  for i=1:length(strDir)
    if strDir(i).isdir & strDir(i).name(1) ~= '.' & strDir(i).name(1) ~= 'CVS'
      if bDir
	    cellFiles{end+1} = fullfile(pwd, strDir(i).name);
      else
          tempCell = getcmodules(strDir(i).name);
          cellFiles = {cellFiles{:}, tempCell{:}};
      end
    end
  end
  
  cd(currDir);
  
% -------------------------------------------------------------------------
function cellFiles = getcmodules(directory)

  cellFiles = {};
  files = dir([directory '/*.c']);
  for i=1:length(files)
	cellFiles{end+1} = files(i).name;
  end
  
% [EOF] rtwmakecfg.m
