function [sys,x0,str,ts] = sfundsc2(t,x,u,flag)
%SFUNDSC2 Example unit delay M-File S-function
%   The M-file S-function is an example of how to implement a unit
%   delay.
%   
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL.
    
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.17 $

switch flag,
 
  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,                                                
    [sys,x0,str,ts] = mdlInitializeSizes;    
    
  %%%%%%%%%%  
  % Update %
  %%%%%%%%%%
  case 2,                                               
    sys = mdlUpdate(t,x,u);
    
  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3,                                               
    sys = mdlOutputs(t,x,u);    

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,                                               
    sys = [];

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

%end sfundsc2

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = 0;
str = [];
ts  = [.1 0]; % Sample period of 0.1 seconds (10Hz)

% end mdlInitializeSizes

%
%=======================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=======================================================================
%
function sys = mdlUpdate(t,x,u)
sys = u;    

%end mdlUpdate

%
%=======================================================================
% mdlOutputs
% Return the output vector for the S-function
%=======================================================================
%
function sys = mdlOutputs(t,x,u)
sys = x;

%end mdlOutputs

