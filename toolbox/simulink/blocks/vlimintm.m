function [sys,x0,str,ts] = vlimintm(t,x,u,flag,lb,ub,xi)
%VLIMINTM Vectored limited integrator implementation M-File S-function
%   This M-file is an example of a limited integrator S-Function.
%   This illustrates how to use the size entry of -1 to build
%   a S-Function that can accomodate a dynamic input/state width.
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
    [sys,x0,str,ts] = mdlInitializeSizes(lb,ub,xi);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1
    sys = mdlDerivatives(t,x,u,lb,ub);

  %%%%%%%%%%%%%%%%%%%%%%%%
  % Update and Terminate %
  %%%%%%%%%%%%%%%%%%%%%%%%
  case {2,9}
    sys = []; % do nothing

  %%%%%%%%%%
  % Output %
  %%%%%%%%%%
  case 3        
    sys = mdlOutputs(t,x,u);

  otherwise
    error(['unhandled flag = ',num2str(flag)]);
end

% end vlimintm

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts] = mdlInitializeSizes(lb,ub,xi)

llb = length(lb);
lub = length(ub);
lxi = length(xi);

if ((llb == 0) | (lub == 0))
  error('Empty matrices not allowed')
elseif (llb > 1)
  if (lxi ~= llb)
    xi = xi(ones(llb, 1));
  end
  nc = llb;
elseif (lub > 1)
  if (lxi ~= lub)
    xi = xi(ones(lub, 1));
  end
  nc = lub;
elseif (lxi > 1)
  nc = lxi;
else
  nc = -1;  % Number states, input and outputs is dynimically sized.
            % Specifying -1 indicates the the states, input and output
            % support vectorization, i.e. the appropriate number will 
            % be determined at run time by the size of the input vector.
end

sizes = simsizes;
sizes.NumContStates  = nc;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = nc;
sizes.NumInputs      = nc;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

x0  = xi;
str = [];
ts  = [0 0];
    
% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Compute derivatives for continuous states.
%=============================================================================
%
function sys = mdlDerivatives(t,x,u,lb,ub)

% compute the unlimitted derivatives
sys = u;

% if a scalar is given for a bound, it needs to be
% expanded to the proper size vector
if (length(lb) == 1),
  lb = lb(ones(size(u)));
end
if (length(ub) == 1),
  ub = ub(ones(size(u)));
end

% limit the derivatives
z = find((x <= lb & u < 0) | (x >= ub & u > 0));
sys(z) = zeros(size(z));
    
% end mdlDerivatives
    
%=============================================================================
% mdlOutputs
% Return the output vector for the S-function
%=============================================================================
%
function sys = mdlOutputs(t,x,u)

sys = x;

% end mdlOutputs