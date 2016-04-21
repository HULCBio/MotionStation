function compilerInfo = compilerman(method, varargin)
% STATEFLOW COMPILER MANAGER
% VARARGOUT = COMPILERMAN( METHOD, VARARGIN)

%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.3 $  $Date: 2004/04/15 00:56:23 $

persistent sCompilerInfo

%%% this persistent structure holds all the relevant info.

if(isempty(sCompilerInfo))
  sCompilerInfo.compilerName = '';
  sCompilerInfo.mexOptsFile = '';
  sCompilerInfo.optsFileTimeStamp = 0.0;
  sCompilerInfo.ignoreMexOptsFile = 0;
end

if(~ispc)
  compilerInfo = sCompilerInfo;
  return;
end


switch(method)
case 'get_compiler_info'
   if(sCompilerInfo.ignoreMexOptsFile==0)
      if(nargin<2)
         mexOptsFile = '';
      else
         mexOptsFile = varargin{1};
      end
      sCompilerInfo = parse_opts_file(sCompilerInfo,mexOptsFile);
   end
case 'set_compiler_info'
   if(nargin<2)
      error('Usage: compilerman(''set_compiler_info'',customMexOptsFileName)');
   end
   sCompilerInfo = parse_opts_file(sCompilerInfo,varargin{1});
   sCompilerInfo.ignoreMexOptsFile = 1;
case 'reset_compiler_info'
   sCompilerInfo.compilerName = '';
   sCompilerInfo.mexOptsFile = '';
   sCompilerInfo.optsFileTimeStamp = 0.0;
   sCompilerInfo.ignoreMexOptsFile = 0;
end

compilerInfo = sCompilerInfo;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newCompilerInfo = parse_opts_file(cachedCompilerInfo,mexOptsFile)

newCompilerInfo = cachedCompilerInfo;


if(isempty(mexOptsFile))
   %% look in current directory
   if (sf('MatlabVersion') < 600),
	   directoryList = {pwd,prefdir,fullfile(matlabroot,'bin'),fullfile(matlabroot,'bin','nt')};
   else,
	   directoryList = {pwd,prefdir,fullfile(matlabroot,'bin','mexopts'),fullfile(matlabroot,'bin','win32','mexopts')};
   end;

   mexOptsFile = '';
   for i=1:length(directoryList)
      tempOptsFile = fullfile(directoryList{i},'mexopts.bat');
      if(exist(tempOptsFile,'file'))
         mexOptsFile = tempOptsFile;
         break;
      end
   end
end

if(isempty(mexOptsFile))
   newCompilerInfo.compilerName = 'lcc';
   newCompilerInfo.mexOptsFile = '';
   newCompilerInfo.optsFileTimeStamp = 0.0;
   return;
end


if(strcmp(cachedCompilerInfo.mexOptsFile,mexOptsFile) &...
      check_if_file_is_in_sync(cachedCompilerInfo.mexOptsFile,cachedCompilerInfo.optsFileTimeStamp))
   return;
end


%%% parsing of mexopts file is done here

mexOptsContents = file2str(mexOptsFile);

mexOptsContents = lower(mexOptsContents);

newCompilerInfo.mexOptsFile = mexOptsFile;
optsFileDirInfo = dir(mexOptsFile);
newCompilerInfo.optsFileTimeStamp = sf_date_num(optsFileDirInfo.date);

success = 0;
if ~isempty(regexp(mexOptsContents,'set\s+intel=', 'once'))
   sf_display('compilerman',sprintf('\nStateflow Warning: Intel compiler is not currently supported by Stateflow.'),1);
   sf_display('compilerman','Stateflow will use Lcc-win32 compiler installed with MATLAB during this session.',1);
   sf_display('compilerman','To use a different C Compiler installed on your system, run mex -setup.',1);
   newCompilerInfo.compilerName = 'lcc';
   success = 1;
elseif ~isempty(regexp(mexOptsContents,'msvc', 'once'))
   if ~isempty(regexp(mexOptsContents,'msvc71', 'once'))
      newCompilerInfo.compilerName = 'msvc71';
      success = sanity_check_for_msvc50(mexOptsContents,mexOptsFile);
   elseif ~isempty(regexp(mexOptsContents,'msvc50','once')) |... 
       ~isempty(regexp(mexOptsContents,'msvc60', 'once')) |...
       ~isempty(regexp(mexOptsContents,'msvc70', 'once'))
      newCompilerInfo.compilerName = 'msvc50';
      success = sanity_check_for_msvc50(mexOptsContents,mexOptsFile);
   elseif ~isempty(regexp(mexOptsContents,'msvcopts','once'))
      newCompilerInfo.compilerName = 'msvc4x';
      success = sanity_check_for_msvc4x(mexOptsContents,mexOptsFile);
   end
elseif ~isempty(regexp(mexOptsContents,'watcom','once'))
   newCompilerInfo.compilerName = 'watcom';
   success = sanity_check_for_watcom(mexOptsContents,mexOptsFile);
elseif ~isempty(regexp(mexOptsContents,'bccopts', 'once')) | ~isempty(regexp(mexOptsContents,'borland','once'))
   newCompilerInfo.compilerName = 'borland';
   success = sanity_check_for_borland(mexOptsContents,mexOptsFile);
elseif ~isempty(regexp(mexOptsContents,'lccopts','once'))
   newCompilerInfo.compilerName = 'lcc';
   success = 1;
end

if(success==0)
   sf_display('compilerman',sprintf('Stateflow Warning: CMEX options file %s not setup correctly.',mexOptsFile),1);
   sf_display('compilerman','Stateflow will use Lcc-win32 compiler installed with MATLAB during this session.',1);
   sf_display('compilerman','To use a different C Compiler installed on your system, run mex -setup.',1);
   newCompilerInfo.compilerName = 'lcc';
end

function success = check_if_dir_exists(mexOptsSetLine,mexOptsFile)
success = 0;
newLines = find(mexOptsSetLine==10 | mexOptsSetLine==13);
if(isempty(newLines))
   return;
end
dirName = mexOptsSetLine(1:min(newLines)-1);
% expand ennvironmental vars in string
doAgain = 1;
while(doAgain & ~isempty(dirName))
   [s,e] = regexp(dirName,'%[^%]+%', 'once');
   if(isempty(s))
      doAgain = 0;
   else
		dirName = [dirName(1:s-1),getenv(dirName(s+1:e-1)),dirName(e+1:end)];
   end
end
if(isempty(dirName))
   success=0;
   return;
end
if(dirName(1)=='"' & dirName(end)=='"')
   dirName = dirName(2:end-1);
else
   if(sf('RunningWin95') & ~isempty(regexp(dirName,' ','once')))
      msg = sprintf('Directory name %s in your mexopts file %s contains a space.',dirName,mexOptsFile);
      disp(msg);
      msg = sprintf('Please enclose this pathname in double-quotes (") in your mexopts file.');
      disp(msg);
      success = 0;
      return;
   end
end
if(exist(dirName,'dir'))
   success = 1;
end
return;


%function dirName  = get_compiler_root(mexOptsSetLine)
%dirName  = '';
%newLines = find(mexOptsSetLine==10 | mexOptsSetLine==13);
%if(isempty(newLines))
%   return;
%end
%dirName = mexOptsSetLine(1:min(newLines)-1);


function success = sanity_check_for_msvc50(mexOptsContents,mexOptsFile)
success = 0;
[s,e] = regexp(mexOptsContents,'set[\s]*msvcdir=','once');
if(~isempty(s))
   success = check_if_dir_exists(mexOptsContents(e+1:end),mexOptsFile);
end

function success = sanity_check_for_msvc4x(mexOptsContents,mexOptsFile)
success = 0;
[s,e] = regexp(mexOptsContents,'set[\s]*msdevdir=','once');
if(~isempty(s))
   success = check_if_dir_exists(mexOptsContents(e+1:end),mexOptsFile);
end

function success = sanity_check_for_watcom(mexOptsContents,mexOptsFile)
success = 0;
[s,e] = regexp(mexOptsContents,'set[\s]*watcom=','once');
if(~isempty(s))
   success = check_if_dir_exists(mexOptsContents(e+1:end),mexOptsFile);
end

function success = sanity_check_for_borland(mexOptsContents,mexOptsFile)
success = 0;
[s,e] = regexp(mexOptsContents,'set[\s]*borland=','once');
if(~isempty(s))
   success = check_if_dir_exists(mexOptsContents(e+1:end),mexOptsFile);
end







