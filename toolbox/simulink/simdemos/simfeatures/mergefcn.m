function [sys,x0,str,ts] = mergefcn(t,x,u,flag)
% S-Function for Simulink merge demonstration.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

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

%   $Revision: 1.7 $  $Date: 2002/04/10 18:42:40 $

%
%=============================================================================
% mdlInitializeSizes
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes()

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);
str = [];
x0  = [];
ts  = [-1 0];   % inherited sample time

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
%=============================================================================
%
function sys = mdlUpdate(t,x,u)

root = get_param(bdroot,'Handle');
subs = find_system(root,'Tag','MergeExample');
parent = get_param(get_param(gcbh,'Parent'),'Handle');

notme = subs(find(subs ~= parent));
me = subs(find(subs == parent));
if ~strcmp(get_param(me,'BackgroundColor'),'green')
  set_param(me,'BackgroundColor','green');
  drawnow
  set_param(notme,'backgroundcolor','white')
end

shortpause

sys = [];

function sys = mdlTerminate

root = get_param(bdroot,'Handle');
subs = find_system(root,'Tag','MergeExample');
set_param(subs,'Backgroundcolor','white')

sys = [];

function shortpause

pause(0.1)

