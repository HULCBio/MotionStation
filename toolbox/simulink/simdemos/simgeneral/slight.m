function [sys,x0,str,ts] = slight(t,x,u,flag)
%SLIGHT S-Function that animates the Light library block.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $

switch flag,
  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts]=mdlInitializeSizes;

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys=mdlUpdate(t,x,u);

  case 9
    sys = mdlTerminate;

  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  case { 1, 3, 4 }
    sys=[];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Unexpected flags (error handling)%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Return an error message for unhandled flag values.
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

% end timestwo

%   $Revision: 1.5 $  $Date: 2002/04/10 18:43:46 $

%
%=============================================================================
% mdlInitializeSizes
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes()

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = -1;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = [0];
ts  = [-1 0];   % inherited sample time

%
% determine if this block is being driven by a logic signal
%
set_param(gcbh,'UserData',DetermineSignalType)


% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
%=============================================================================
%
function sys = mdlUpdate(t,x,u)

dirty     = get_param(bdroot(gcbh),'Dirty');
parent    = get_param(get_param(gcbh,'Parent'),'Handle');
delayFlag = 0;

switch get_param(gcbh,'UserData'),
  case 'enable'
    uTest = u;
  case 'trigger'
    uTest = u ~= x;
    delayFlag = 1;
  case 'unknown'
    uTest = u ~= 0;
  otherwise
    uTest = u ~= 0;
end

currentState = get_param(parent, 'State');
if uTest,
  newState = 'Go';
else
  newState = 'Stop';
end

if ~strcmp(newState, currentState),
  set_param(parent,'State', newState);
  set_param(bdroot(gcbh),'Dirty',dirty)
  drawnow
  if delayFlag,
    pause(0.5);
  end
end
sys = u;

function sys = mdlTerminate

dirty = get_param(bdroot(gcbh),'Dirty');
set_param(get_param(gcbh,'Parent'),'State','Stop')
set_param(bdroot(gcbh),'Dirty',dirty)
sys = [];


%
%=============================================================================
% DetermineSignalType
%=============================================================================
%
function signalType = DetermineSignalType

parent = get_param(gcbh,'Parent');
ports = get_param(parent,'PortHandles');
line = get_param(ports.Outport,'Line');
if ishandle(line),
  dstPort = get_param(line,'DstPortHandle');
else
  dstPort = [];
end
if isempty(dstPort),
  signalType = 'unknown';
else
  if length(dstPort) > 1,
    warning(['Light block connected to multiple destinations, choosing the' ...
             ' first']);
    dstPort = dstPort(1);
  end
  signalType = get_param(dstPort,'PortType');
end

    

