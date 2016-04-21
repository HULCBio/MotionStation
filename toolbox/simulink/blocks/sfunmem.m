function [sys,x0,str,ts] = sfunmem(t,x,u,flag)
%SFUNMEM A one integration-step memory block S-function.
%   This M-File S-function is provided for backwards compability.
%   Simulink models using this S-function as a memory block should
%   replace the block with a memory block.
%
%   This M-File S-function performs a one integration-step delay and hold 
%   "memory" function. Thus, no matter how large or small the last time 
%   increment was in the integration process, this function will hold the 
%   input variable from the last integration step.
%   
%   Use this function with a clock as input to get the step-size 
%   of the simulation.
%   
%   See sfuntmpl.m for a general S-function template.
%
%   See also SLUPDATE, SFUNTMPL.
    
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.19 $

switch flag
  
  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,                                              
    [sys,x0,str,ts] = mdlInitializeSizes;    

  %%%%%%%%%%%%%%%%%%%%%%%%%
  % Discrete State Update %
  %%%%%%%%%%%%%%%%%%%%%%%%%
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
    sys = []; % do nothing

  otherwise,
    error(['unhandled flag = ',num2str(flag)]);
end

%
%==============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function
%==============================================================================
%
function [sys, x0, str, ts] = mdlInitializeSizes

warning(['The S-function memory block, ''',gcb,''' should be ' ...
         'replaced with the built-in memory block which can be ' ...
         'found in the Simulink block library. Note, slupdate can be ', ...
         'used to automatically update your block diagram.']);

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
ts  = [0 1];  % continuous sample time [period, offset]

%end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys = mdlUpdate(t,x,u)

sys = u;

%end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u)

sys = x;

%end mdlOutputs
