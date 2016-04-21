function [sys,x0,str,ts] = mixedm(t,x,u,flag)
%MIXEDM An example integrator followed by unit delay M-file S-function 
%   Example M-file S-function implementing a hybrid system consisting
%   of a continuous integrator (1/s) in series with a unit delay (1/z).
%   
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL.
    
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.28 $


% Sampling period and offset for unit delay.
dperiod = 1;
doffset = 0;

switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0         
    [sys,x0,str,ts]=mdlInitializeSizes(dperiod,doffset);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u,dperiod,doffset);
  
  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3        
    sys=mdlOutputs(t,x,u,doffset,dperiod);
  
  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9
    sys = [];       % do nothing

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
  
end

% end mixedm

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(dperiod,doffset)

sizes = simsizes;
sizes.NumContStates  = 1;
sizes.NumDiscStates  = 1;
sizes.NumOutputs     = 1;
sizes.NumInputs      = 1;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 2;

sys = simsizes(sizes);
x0  = ones(2,1); 
str = [];
ts  = [0 0;                 % sample time
       dperiod doffset];

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Compute derivatives for continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

sys = u; 

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,dperiod,doffset)

% next discrete state is output of the integrator
if abs(round((t - doffset)/dperiod) - (t - doffset)/dperiod) < 1e-8
  sys = x(1);
else
  sys = [];
end

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys=mdlOutputs(t,x,u,doffset,dperiod)

% Return output of the unit delay if we have a 
% sample hit within a tolerance of 1e-8. If we
% don't have a sample hit then return [] indicating
% that the output shouldn't change.
if abs(round((t - doffset)/dperiod) - (t - doffset)/dperiod) < 1e-8
  sys = x(2);
else 
  sys = [];
end

% end mdlOutputs