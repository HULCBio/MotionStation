function [sys,x0,str,ts]=vdlmintm(t,x,u,flag, lb, ub, xi, h)
%VDLMINTM Vectored discrete limited integrator implementation M-File S-function
%   This M-file is an example of a discrete limited integrator
%   S-Function.  This illustrates how to use the size entry of
%   -1 to build a S-Function that can accomodate a dynamic
%   input/state width.
%   
%   Inputs:
%       lb - lower bound (vector or scalar)
%       ub - upper bound (vector or scalar)
%       xi - initial state (vector or scalar)
%       h  - sampling period in seconds.
%   
%   See sfuntmpl.m for a general S-function template.
%
%   See also SFUNTMPL.    
    
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.17 $


switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0         
    [sys,x0,str,ts] = mdlInitializeSizes(lb,ub,xi,h);   

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys = mdlUpdate(t,x,u,lb,ub,h);

  %%%%%%%%%%
  % Output %
  %%%%%%%%%%  
  case 3
    sys = mdlOutputs(t,x,u); 

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9                    
    sys = []; % do nothing

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

% end vdlmintm

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(lb,ub,xi,h)

llb = length(lb);
lub = length(ub);
lxi = length(xi);

if ((llb == 0) | (lub == 0))
  error('Empty matrices not allowed')
elseif (llb > 1)
  if (lxi ~= llb)
    xi = xi * ones(llb, 1);
  end
  nd = llb;
elseif (lub > 1)
  if (lxi ~= lub)
    xi = xi * ones(lub, 1);
  end
  nd = lub;
elseif (lxi > 1)
  nd = lxi;
else
  nd = -1;  % Number states, input and outputs is dynamically sized.
            % Specifying -1 indicates the the states, input and output
            % support vectorization, i.e. the appropriate number will 
            % be determined at run time by the size of the input vector.
end
    
if ~isfinite(h) | h <= 0,
   error('Invalid sampling period');
end

sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = nd;
sizes.NumOutputs     = nd;
sizes.NumInputs      = nd;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = xi;
str = [];
ts  = [h 0];

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys = mdlUpdate(t,x,u,lb,ub,h)

sys = x + u * h;

% if a scalar is given for a bound, it needs to be
% expanded to the proper size vector
if (length(lb) == 1),
    lb = lb * ones(size(u));
end
if (length(ub) == 1),
  ub = ub * ones(size(u));
end

% now limit them
z = find((x <= lb & u < 0) | (x >= ub & u > 0));
sys(z) = x(z);

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u)

sys = x;

% end mdlOutputs