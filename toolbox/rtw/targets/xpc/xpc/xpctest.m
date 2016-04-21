function xpctest(option)

% XPCTEST - xPC Target Test Suite
%
%   xpctest executes the xPC Target test suite to check the correct
%   functioning of the following xPC Target modules:
%
%     1. Initiation of communication from host to target.
%     2. Rebooting the target to reset target environment.
%     3. Building an xPC Target application.
%     4. Downloading an xPC Target application onto the target.
%     5. Host-Target communication for commands.
%     6. Execution of a target application.
%     7. Comparing results of simulation and target application run.
%
%   xpctest('noreboot') skips test 2. Use this option if target hardware
%   does not support software rebooting.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.21.6.3 $ $Date: 2004/01/22 18:36:43 $

xPCTargetProps=getxpcenv('TargetBoot','HostTargetComm','TcpIpTargetAddress','RS232HostPort','Version');

fprintf(2,['\n### xPC Target Test Suite ',xPCTargetProps{5},'\n']);


if strcmp(xPCTargetProps{1}, 'StandAlone')
  disp([ 10, ...
  'Warning: The xPC environment is set up to use StandAlone mode.', 10, ...
  'Not all tests in the test suite will be run.', 10]); % 10 == \n
  standalone = 1;
else
  standalone = 0;
end

fprintf(2,'### Host-Target interface is: ');

if strcmp(xPCTargetProps{2},'TcpIp')

  fprintf(2,'TCP/IP (Ethernet)\n');

  fprintf(2,'### Test 1, Ping target system using standard ping: ... ');
  pingFailed = 0;
  try
    [res,echo]=dos(['ping ',xPCTargetProps{3}]);
  catch
    error('error calling standard ping');
  end
  if ~isempty(findstr(echo,'The name specified is not recognized'))
    fprintf(2,'SKIPPED (ping not found)\n');
  else
    if isempty(findstr(echo,'TTL='))
      fprintf(2,'FAILED\n');
      pingFailed = 1;
    else
      fprintf(2,'OK\n');
    end
  end

  fprintf(2,'### Test 2, Ping target system using xpctargetping: ');

  success=0;
  for i=1:3
    fprintf(2,'.');
    try
      echo=xpctargetping;
    catch
      error('error calling xpctargetping');
    end
    if strcmp(echo,'success')
      success=1;
    end
  end
  if ~success
    fprintf(2,' FAILED\n');
    if pingFailed
      fprintf(2, ['Both standard Windows ping and xPC Target ping ' ...
                  'have failed.\nThere may be a problem with your ' ...
                  'TCP/IP connection.\n']);
    end
    return;
  end
  fprintf(2,' OK\n');
  if pingFailed
    fprintf(2,['\tWindows ping did not pass but xPC Target ping ' ...
               'did pass.\n\tTry running ping from the DOS ' ...
               'command line.\n']);
  end

  if (standalone == 1)
    fprintf(2,'### Test Suite successfully finished\n');
    return
  end

  fprintf(2,'### Test 3, Reboot target using direct call: ');

  if nargin==1 & strcmp(option,'noreboot')

    fprintf(2,'... SKIPPED\n');

  else

    t=clock;
    try
      xpcgate('xpcreboot');
    catch
      error('error calling xpcreboot');
    end
    booted=0;
    while ~booted & etime(clock,t)<150
      fprintf(2,'.');
      pause(3);
      try
        echo=xpctargetping;
      catch
        error('error calling xpctargetping');
      end
      if strcmp(echo,'success')
        booted=1;
      end
    end
    if ~booted
      fprintf(2,' FAILED\n');
      fprintf(2,'\n\n');
      fprintf(2,'The reboot test has failed on this target hardware. Some target hardware does not fully\n');
      fprintf(2,'support software-rebooting. Therefore the ''reboot'' method should not be used for this \n');
      fprintf(2,'target hardware. Reboot the target system by a cold start and execute xpctest(''noreboot'')\n');
      fprintf(2,'to finish testing without the reboot test\n\n');
      return;
    end
    fprintf(2,' OK\n');

  end

  fprintf(2,'### Test 4, Build and download xPC Target application using model xpcosc: ...');
  try
    open_system('xpcosc');
  catch
    error('error loading model xpcosc');
    return
  end
  fid=fopen('xpcnoload.ctr','w');
  fclose(fid);
  xpcerror=0;
  dummy=evalc('make_rtw','xpcerror=1;');
  if xpcerror
    fprintf(2,' FAILED\n');
    close_system('xpcosc');
    delete('xpcnoload.ctr');
    return
  end
  close_system('xpcosc');
  delete('xpcnoload.ctr');
  try
    dummy=evalc('xpcgate(''rlload'',''xpcosc'');','xpcerror=1;');
  catch
    fprintf(2,' FAILED\n');
    return
  end
  if xpcerror
    fprintf(2,' FAILED\n');
    return
  end
  try
    echo=xpctargetping;
  catch
    error('error calling xpctargetping');
  end
  if strcmp(echo,'failed')
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 5, Check host-target communication for commands: ...');
  try
    name=xpcgate('getname');
  catch
    error('error calling getname');
  end
  if ~strcmp(name,'xpcosc')
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 6, Download xPC Target application using OOP: ...');
  try
    tg=xpc;
  catch
    fprintf(2,' FAILED\n');
    return
  end
  xpcerror=0;
  try
    try, load(tg,'xpcosc'); catch, xpcerror=1; end
  catch
    fprintf(2,' FAILED\n');
    return
  end
  if xpcerror
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 7, Execute xPC Target application for 0.2s: ...');
  try
    tg.sampletime=0.000250;
    tg.stoptime=0.2;
    start(tg);
    while ~strcmp(tg.status,'stopped'), end;
  catch
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 8, Upload logged data and compare it with simulation: ...');
  try
    output=tg.outp;
  catch
    fprintf(2,' FAILED\n');
    return
  end
  sim('xpcosc');
  try
    res=max(max(output(1:250,:)-yout(1:250,:)));
  catch
    fprintf(2,' FAILED\n');
    return
  end
  if res > 1e-14
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');


end

if strcmp(xPCTargetProps{2},'RS232')

  if strcmp(xPCTargetProps{4},'COM1')
    fprintf(2,'RS232 COM1\n');
  else
    fprintf(2,'RS232 COM2\n');
  end

  fprintf(2,'### Test 1, Ping target system using standard ping: ... SKIPPED\n');


  fprintf(2,'### Test 2, Ping target system using xpctargetping: ...');
  try
    echo=xpctargetping;
  catch
    error('error calling xpctargetping');
  end
  if strcmp(echo,'failed')
    fprintf(2,' FAILED\n');
    return;
  end
  fprintf(2,' OK\n');

  if (standalone == 1)
    fprintf(2,'### Test Suite successfully finished\n');
    return
  end

  fprintf(2,'### Test 3, Reboot target using direct call: ');

  if nargin==1 & strcmp(option,'noreboot')

    fprintf(2,'... SKIPPED\n');

  else

    t=clock;
    try
      xpcgate('xpcreboot');
    catch
      error('error calling xpcreboot');
    end
    booted=0;
    pauseTime = 30;         % pause for 30 seconds the first time
    while ~booted & etime(clock,t)<120
      fprintf(2,'.');
      pause(pauseTime);
      try
        echo=xpctargetping;
      catch
        error('error calling xpctargetping');
      end
      if strcmp(echo,'success')
        booted=1;
      end
      pauseTime = 5;         % only 5 second pause each subsequent time
    end
    if ~booted
      fprintf(2,' FAILED\n');
      fprintf(2,'\n\n');
      fprintf(2,'The reboot test has failed on this target hardware. Some target hardware does not fully\n');
      fprintf(2,'support software-rebooting. Therefore the ''reboot'' method should not be used for this \n');
      fprintf(2,'target hardware. Reboot the target system by a cold start and execute xpctest(''noreboot'')\n');
      fprintf(2,'to finish testing without the reboot test\n\n');
      return;
    end
    fprintf(2,' OK\n');

  end

  fprintf(2,'### Test 4, Build and download xPC Target application using model xpcosc: ...');
  try
    open_system('xpcosc');
  catch
    error('error loading model xpcosc');
    return
  end
  fid=fopen('xpcnoload.ctr','w');
  fclose(fid);
  xpcerror=0;
  dummy=evalc('make_rtw','xpcerror=1;');
  if xpcerror
    fprintf(2,' FAILED\n');
    close_system('xpcosc');
    delete('xpcnoload.ctr');
    return
  end
  close_system('xpcosc');
  delete('xpcnoload.ctr');
  try
    dummy=evalc('xpcgate(''rlload'',''xpcosc'');','xpcerror=1;');
  catch
    fprintf(2,' FAILED\n');
    return
  end
  if xpcerror
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 5, Check host-target communication for commands: ...');
  try
    name=xpcgate('getname');
  catch
    error('error calling getname');
  end
  if ~strcmp(name,'xpcosc')
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 6, Download xPC Target application using OOP: ...');
  try
    tg=xpc;
  catch
    fprintf(2,' FAILED\n');
    return
  end
  xpcerror=0;
  try
    dummy=evalc('load(tg,''xpcosc'');','xpcerror=1');
  catch
    fprintf(2,' FAILED\n');
    return
  end
  if xpcerror
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 7, Execute xPC Target application for 0.2s: ...');
  try
    tg.sampletime=0.000250;
    tg.stoptime=0.2;
    start(tg);
    while ~strcmp(tg.status,'stopped'), end;
  catch
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');

  fprintf(2,'### Test 8, Upload logged data and compare it with simulation: ...');
  try
    output=tg.outp;
  catch
    fprintf(2,' FAILED\n');
    return
  end
  sim('xpcosc');
  try
    res=max(max(output(1:250,:)-yout(1:250,:)));
  catch
    fprintf(2,' FAILED\n');
    return
  end
  if res > 1e-14
    fprintf(2,' FAILED\n');
    return
  end
  fprintf(2,' OK\n');


end


fprintf(2,'### Test Suite successfully finished\n');
