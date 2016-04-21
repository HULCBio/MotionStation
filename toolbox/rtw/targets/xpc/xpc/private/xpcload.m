function [standalone] = xpcload(filename)
% XPCLOAD Loads the model or creates a standalone app, as appropriate.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.3.2.4 $ $Date: 2004/04/08 21:04:42 $

st4mb  = 1;                             % allow 4mb standalone but
st16mb = 0;                             % disallow 16 mb ones
standalone=0;                           % normally not standalone

[env,actpropval]=getxpctargetenv;


if strcmpi(env.TargetBoot, 'StandAlone')
  if (strcmpi(env.MaxModelSize, '4MB') && ~st4mb) || ...
        (strcmpi(env.MaxModelSize, '16MB') && ~st16mb)
    disp(sprintf(['### Creation of %s StandAlone applications' ...
                  ' not supported'], env.MaxModelSize));
    fid = fopen('xpcemb.ctr', 'w'); fclose(fid);
    return;
  end
  kernel = genKernelName(env);
  xpccrembdir(filename, kernel, actpropval);
  
  standalone=1;
else
  if exist('xpcdltimeout.dat')
    load('xpcdltimeout.dat', '-ascii');
    timeout = xpcdltimeout;
    xpcgate('settimeout', timeout);
  end

  commType=env.HostTargetComm;
  if strcmp(commType,'TcpIp')
      arg1= 'TcpIp';
      arg2= env.TcpIpTargetAddress;
      arg3= env.TcpIpTargetPort;
      % arg3= xPCtargetPC.xPCtargetPC;
  else%rs232
      arg1= 'RS232';
      arg2= env.RS232HostPort;
      arg3= eval(env.RS232Baudrate);
  end

  %tg = xpc;
  tg=xpc(arg1,arg2,arg3);
  %tg = xpc;
  alive = 0;
  fprintf(1, 'Looking for target ');
  for i = 1 : 5
    if strcmp(tg.targetping, 'success')
      alive = 1;
      break
    end
    fprintf(1, '.');
    pause(0.2);
  end
  fprintf(1, '\n');
  if ~alive
    error('Could not find target');
  end
  tg.load(filename);
end

function kern = genKernelName(env)
% This function only called for standalone.
if strcmpi(env.HostTargetComm, 'TCPIP')
  comm = 't';
else
  comm = 's';
end

if strcmpi(env.TargetScope, 'Enabled')
  graph = 'g';
else
  graph = 't';
end

mdlSize = env.MaxModelSize;
mdlSize(end - 1 : end) = [];            % get rid of 'MB';

kern = ['xpc', comm, graph, 'a', mdlSize, '.rtb'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [env,actpropval]=getxpctargetenv
env=getappdata(0,'xpcTargetexplrEnv');
if isempty(env)   
    env=getxpcenv;
    env=cell2struct(env.actpropval,env.propname,2);
end
actpropval=struct2cell(env);
actpropval=actpropval(1:25);












