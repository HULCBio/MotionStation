function srcFile = sfunddg_fs(varargin)
%SFUNDDG_FS Function to help S-Function Edit button callback to find source files

% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

sfun = varargin{1};

% --- If S-function is reported to be a MEX file, look
%     for other supported source file types in order
%     but not M-files because they can be used as help files.
extensions = { ...
    '.c',   '.cpp',                 ...
    '.f',   '.for', '.f77', '.f90', ...
    '.adb', '.ada', '.ads'};

% --- First look on the MATLAB path and in simulink/src

loc = [ matlabroot, filesep, 'simulink', filesep, 'src', filesep ];

for i=1:length(extensions),
  
  srcCandidate = [ sfun, extensions{i} ];
  
  % --- MATLAB path
  srcFile = which(srcCandidate);
  if exist(srcFile,'file') == 2,
    return;
  end
  
  % --- simulink/src directory
  srcFile = [ loc, srcCandidate ];
  if exist(srcFile,'file') == 2,
    return;
  end
  
end

% --- Next, look in the Real-Time Workshop S-function source areas 
%     for C and CPP files using all the rtwmakecfg.m files found

rtwsrc = which('rtwmakecfg','-all');
pwd_init = pwd;

for k = 1:length(rtwsrc),
  makeInfo = [];
  pth = fileparts(rtwsrc{k});
  if exist(pth, 'dir'),
    cd(pth);
    [logtest,makeInfo] = evalc('rtwmakecfg','cd(pwd_init)');
    cd(pwd_init);
  end
  
  % --- Look for S-function sources 
  %     "anywhere not under toolbox/rtw"
  
  if ~isempty(makeInfo) && isfield(makeInfo, 'sourcePath'),
    extensions = { '.c', '.cpp' };
    for m = 1:length(makeInfo.sourcePath),
      loc = makeInfo.sourcePath{m};
      if isempty(strfind(loc, ['toolbox', filesep, 'rtw'])),
        for n = 1:length(extensions),
          srcCandidate = [ sfun, extensions{n} ];
          srcFile = [loc, filesep, srcCandidate];
          if exist(srcFile,'file') == 2,
            return;
          end
        end
      end
    end
  end
  
end

% --- Finally, look in simulink/ada/examples directories for ada

if length(sfun) > 4 && strcmp(sfun(1:4),'ada_'),
  
  adaExRoot = [ ...
      matlabroot, filesep, ...
      'simulink', filesep, ...
      'ada',      filesep, ...
      'examples' ];
  adaExt    = { '.adb', '.ada', '.ads' };
  exDirs    = dir(adaExRoot);
  
  % look in each directory
  for k = 1:length(exDirs),
    if exDirs(k).isdir,
      loc = [ adaExRoot, filesep, exDirs(k).name ];
      
      for i=1:length(adaExt),
        % look for each extension
        srcCandidate = [ sfun(5:end), adaExt{i} ];
        srcFile = [ loc, filesep, srcCandidate ];
        if exist(srcFile,'file') == 2,
          return;
        end
      end
    end
    
  end
end

% --- If nothing found, return empty
srcFile = '';
return;