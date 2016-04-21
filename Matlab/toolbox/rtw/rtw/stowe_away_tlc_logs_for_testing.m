function stow_away_tlc_logs_for_testing(model,buildDir,tlcLogsSaveDir)
%stow_away_tlc_logs_for_testing - RTW TLC code coverage support file
%

%  Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.3 $  $Date: 2004/04/15 00:25:14 $

  ;%
  % Locate the testsuite call site, to get name of directory to save
  % tests to. If not found, use name of current directory.
  %
  
  currDir = pwd;
  chdir(buildDir)
  try
    StowAwayTLCLogs(model,tlcLogsSaveDir);
  catch
  end
  chdir(currDir);


%endfunction



function StowAwayTLCLogs(model, tlcLogsSaveDir)

  ;%
  % First locate the 'tester', i.e. if invoked from a standard tname.m
  % test file, driven by testdrive.m the tester will be something
  % like "sbroot/test/blah/tname.m" or
  % the tester '?' meaning invoked by a user.
  %
  callStack = dbstack('-completenames');
  idx = length(callStack);
  found = 0;
  for idx=length(callStack):-1:2
    if isequal('testdrive',callStack(idx).name)
      found = 1;
      idx = idx - 1;
      break;
    end
  end

  if (found)
    tester = callStack(idx).file;
    subdirname = tester;
    seps = findstr(filesep,subdirname);
    subdirname(1:seps(end)) = [];
    dotm = findstr('.m',subdirname);
    subdirname(dotm) = '_';
    subdirname(dotm+1) = [];
    subdirname = [subdirname callStack(idx).name];
  else
    tester = '?';

    subdirname = pwd;
    seps = findstr(filesep,subdirname);
    subdirname(1:seps(end)) = [];
  end

  %
  % Get the logdir string to copy the log files to
  %
  logdir = fullfile(tlcLogsSaveDir,subdirname);

  n = 1;
  origSubDir = subdirname;
  while exist( logdir )
    subdirname = [origSubDir,'_',num2str(n)];
    logdir = fullfile(tlcLogsSaveDir,subdirname);
    n = n + 1;
  end

  %
  % Create the logdir
  %
  [status,msg]=mkdir(tlcLogsSaveDir,subdirname);
  if strncmp(computer, 'SGI', 3),
    sgiOk = 3;
    while (sgiOk),
      sgiOk = sgiOk - 1;
      if (status ~= 1),
        disp([' *** status returned : ', num2str(status)]);
        disp(['%ls -d ',tempdir]);
        eval(['!ls -d ',tempdir]);
        disp(' *** Trying again ...');
        [status,msg]=mkdir(tempdir,strrep(testdir,tempdir,''));
      end
    end
  end

  if ~isempty(msg);
    disp(['Error in ==> stow_away_tlc_logs_for_testing.m: ' ...
          'Unable to create test directory for saving TLC logs']);
    disp(msg);
    return;
  end

  %
  % Copy the logfiles to the destination.
  %
  % Copyfile is very slow, so we use mv -f on Unix
  %
  if isunix
    [s,msg]=unix(['mv *.log ',logdir,'/']);
    if s ~= 0
      disp(['Error in ==> stow_away_tlc_logs_for_testing.m: ' ...
            'Unable to "mv -f *.log ',logdir, '"']);
      disp(msg);
    end

  else
    temp = dir('*.log');
    logfiles = {};
    for m = 1:size(temp,1)
      logfiles{m} = temp(m).name;
    end
    
    for i=1:length(logfiles)
      logfile = logfiles{i};
      dest    = fullfile(logdir,logfile);
      [status,msg]=rtw_copy_file(logfile, dest);
      if ~isempty(msg);
        disp(['Error in ==> stow_away_tlc_logs_for_testing.m: ' ...
              'Unable to copy tlc log file ',logfile, ' to ',...
              dest]);
        disp(msg);
        return;
      end
      rtw_delete_file(logfile);
    end
  end

  %
  % Create a readme.txt telling me about the model configuration
  %
  
  readme = fullfile(logdir,'readme.txt');
  fid = fopen(readme,'w');
  if fid == -1
    disp(['Unable to create ',readme]);
    return;
  end

  fprintf(fid,'Tester: %s\n',tester);
  fprintf(fid,'Model: %s\n', model);
  fprintf(fid,'ModelPath: %s\n',which(model));
  fprintf(fid,'SystemTargetFile: %s\n', ...
          get_param(model,'RTWSystemTargetFile'));
  fprintf(fid,'TemplateMakefile: %s\n', ...
          get_param(model,'RTWTemplateMakefile'));
  fprintf(fid,'MakeCommand: %s\n', ...
          get_param(model,'RTWMakeCommand'));
  fprintf(fid,'RTWInlineParameters: %s\n',...
          get_param(model,'RTWInlineParameters'));
  fprintf(fid,'RTWOptions: %s\n',...
          get_param(model,'RTWOptions'));
  
  fclose(fid);
  
  disp(' ');
  disp(['Log files have been placed in ',logdir]);
  disp(' ');
  
%endfunction StowAwayTLCLogs
