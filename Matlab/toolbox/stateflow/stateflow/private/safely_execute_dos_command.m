function cmdFailed = safely_execute_dos_command(targetDirectory,dosCommand)
%   CMDFAILED = SAFELY_EXECUTE_DOS_COMMAND(TARGETDIR,DOSCOMMAND)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/04/15 00:59:14 $

cmdFailed = 0;

if(sf('RunningWin95'))
   bangCommandWorks = check_bang_in_dir(targetDirectory);
else
   bangCommandWorks = 1;
end

currDirectory = pwd;
try,
   if(bangCommandWorks)
      cd(targetDirectory);
      sf_dos(dosCommand);
      cd(currDirectory);
      cmdFailed = 1;
   else
      cmdFailed = win95_exec_command(targetDirectory, dosCommand);
   end
catch,
   cd(currDirectory);
   error(lasterr);
end


%------------------------------------------------------------------------------------------
function cmdFailed = win95_exec_command(targetDirectory, dosCommand)
%
% 
%
cmdFailed = 1;
colonIndex = find(targetDirectory==':');
if(isempty(colonIndex))
   %%%
   %%% enhance error message
   sf_display('Make',sprintf('Directory %s does not appear to be a valid DOS path.',targetDirectory));
   return;
end
targetDrive = lower(targetDirectory(1:colonIndex(1)));

% cache away the initial directory so we can restore it after the monkey business	
currDirectory = pwd;

% cd to the top level directory so that mkdir using bang will work
cd([targetDrive,'\']);
destDirName = '_sftmp';

if(~exist([targetDrive,'\',destDirName],'dir'))
   mkdir(destDirName);
end

while(1)
   tmpDirName = tempname;
   slashes = find(tmpDirName=='\');
   tmpDirName = tmpDirName(slashes(end):end);
   
   executionDirectory = fullfile(targetDrive,destDirName,tmpDirName);
   if(~exist(executionDirectory,'dir'))
      break;
   end
end

msgString = ['Stateflow Warning:',10,...
      'The directory ',targetDirectory,10,...
      'has a long name which is not properly handled by Windows95/98.',10,...
      'Hence this directory is temporarily moved to a directory ',executionDirectory,10,...
      'for invoking the compilation process, at the end of which ',10,...
      'it will be moved back to its original location.',10];

sf_display('Make',msgString);

dos(['move "',targetDirectory,'" "',executionDirectory,'"']);
if(~exist(executionDirectory,'dir'))
   %%% error message for failed move
   return;
end

cd(executionDirectory);
sf_dos(dosCommand);

% cd to the top level directory so that bang will work
cd([targetDrive,'\']);
dos(['move "',executionDirectory ,'" "',targetDirectory,'"']);
if(~exist(targetDirectory,'dir'))
   %%% error message for failed move
   return;
end

% cd to currDirectory to resume
cd(currDirectory);
cmdFailed = 0;


