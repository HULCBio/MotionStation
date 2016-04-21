function CompilerInfo = slgetcompilerinfo
%SLGETCOMPILERINFO returns information on the compiler specified when 
% mex('-setup') was run.  

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/15 00:47:49 $ 

if isunix
  error('simulink:slgetcompilerinfo:IsUNIXorMAC','slgetcompilerinfo is not supported on this platform.');
  return;
else
  if (num2str(strtok(version,'.')) < 6)
    directoryList = {pwd,prefdir,fullfile(matlabroot,'bin'),fullfile(matlabroot,'bin','nt')};
  else
    directoryList = {pwd,prefdir,fullfile(matlabroot,'bin','mexopts'),fullfile(matlabroot,'bin','win32','mexopts')};
  end
  
  mexOptsFile = '';
  for i=1:length(directoryList)
    tempOptsFile = fullfile(directoryList{i},'mexopts.bat');
    if(exist(tempOptsFile,'file'))
      mexOptsFile = tempOptsFile;
      break;
    end
  end
  
  if(isempty(mexOptsFile))
    CompilerInfo.compilerName = 'lcc';
    CompilerInfo.mexOptsFile = '';
    return;
  end
  
  %--- Parsing of mexopts file is done here
  fid = fopen(mexOptsFile,'rt');
  if fid<=2
    CompilerInfo.compilerName = 'lcc';
    CompilerInfo.mexOptsFile = '';
    return;
  end
  mexOptsContents = '';
  for i=1:20
    mexOptsContents = [mexOptsContents fgets(fid)];
  end
  fclose(fid);
  mexOptsContents = lower(mexOptsContents);
  CompilerInfo.mexOptsFile = mexOptsFile;
  
  if ~isempty(regexp(mexOptsContents,'msvc', 'once'))
    if ~isempty(regexp(mexOptsContents,'msvc50opts','once'))
      CompilerInfo.compilerName = 'msvc50';
    elseif ~isempty(regexp(mexOptsContents,'msvc60opts', 'once'))
      CompilerInfo.compilerName = 'msvc60';
    elseif ~isempty(regexp(mexOptsContents,'msvc70opts', 'once'))
      CompilerInfo.compilerName = 'msvc70';
    elseif ~isempty(regexp(mexOptsContents,'msvcopts','once'))
      CompilerInfo.compilerName = 'msvc4x';
    end
  elseif ~isempty(regexp(mexOptsContents,'watcom','once'))
    CompilerInfo.compilerName = 'watcom';
  elseif ~isempty(regexp(mexOptsContents,'bccopts', 'once')) | ~isempty(regexp(mexOptsContents,'borland','once'))
    CompilerInfo.compilerName = 'borland';
  elseif ~isempty(regexp(mexOptsContents,'lccopts','once'))
    CompilerInfo.compilerName = 'lcc';
  end
end
