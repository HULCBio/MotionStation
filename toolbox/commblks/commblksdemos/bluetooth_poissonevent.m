function [sys,x0,str,ts] = bluetooth_poissonevent(t,x,u,flag,lambda,m,v,seed)
%VSFUNC Variable step S-function example.
%   This example S-function illustrates how to create a variable step
%   block in SIMULINK.  This block implements a variable step delay
%   in which the first input is delayed by an amount of time determined
%   by the second input:
%
%     dt      = u(2)
%     y(t+dt) = u(t)
%
%   See also SFUNTMPL, CSFUNC, DSFUNC.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date $

%
% The following outlines the general structure of an S-function.
%
start_time=0;

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(seed);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u,start_time);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u,lambda,m,v,start_time);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);
  
  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  case 1,
    sys = [];

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(seed)

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 0;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;     % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [0];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-2 0];      % variable sample time


rand('state',seed)
    

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,start_time)

if x(1),
   sys = 0;
else
   sys = 1;
   start_time=t;
end

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

sys = x(1);

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.
%=============================================================================

function sys=mdlGetTimeOfNextVarHit(t,x,u,lambda,m, v,start_time)

if x==0 % Time until next packet is poisson distributed
    sys = t -log(rand)/lambda - start_time;
else    % Time until end of packet is gaussian distributed
    sys= t + m + randn*sqrt(v);
end

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
