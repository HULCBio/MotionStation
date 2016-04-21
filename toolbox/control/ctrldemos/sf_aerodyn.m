function [sys,x0,str,ts] = sf_aerodyn(t,x,u,flag)
% S-function sf_aerodyn.M
% This S-function represents the nonlinear aircraft dynamics

% Copyright 1986-2002 The MathWorks, Inc. 
% $Revision: 1.5 $  $Date: 2002/04/10 06:40:35 $


switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes;

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case 1,
    sys=mdlDerivatives(t,x,u);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

% end sfuntmpl


%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 8;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 8;
sizes.NumInputs      = 4;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% Initial conditions
% x = [u,v,w,p,q,r,theta,phi]';
% To linearized the model assume  phi = 0 and theta = 0; 

x0  = [0 0 0 0 0 0 0 0];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [0 0];

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

a1 = [-0.0404    0.0618    0.0501   -0.0000   -0.0005    0.0000 
   -0.1686   -1.1889    7.6870         0    0.0041         0
    0.1633   -2.6139   -3.8519    0.0000    0.0489   -0.0000 
   -0.0000   -0.0000   -0.0000   -0.3386   -0.0474   -6.5405  
   -0.0000    0.0000   -0.0000   -1.1288   -0.9149   -0.3679  
   -0.0000   -0.0000   -0.0000    0.9931   -0.1763   -1.2047 
         0         0    0.9056         0         0   -0.0000
         0         0   -0.0000         0    0.9467   -0.0046];
a = [a1, zeros(8,2)];
 
b1 =[ -0.0404    0.0618    0.0501
   -0.1686   -1.1889    7.6870
    0.1633   -2.6139   -3.8519
   -0.0000   -0.0000   -0.0000
   -0.0000    0.0000   -0.0000
   -0.0000   -0.0000   -0.0000
         0         0    0.9056
         0         0   -0.0000];
 
b2 =[ 20.3929   -0.4694   -0.2392   -0.7126
    0.1269   -2.6932    0.0013    0.0033
  -64.6939  -75.6295    0.6007    3.2358
   -0.0000         0    0.1865    3.6625
   -0.0000         0   23.6053    5.6270
   -0.0001         0    3.9462  -41.4112
         0         0         0         0
         0         0         0         0];

g=32.2;
%% The state vector is x = [u,v,w,p,q,r,theta,phi]'%%  

n1 = -g*sin(x(7));
n2 = g*cos(x(7))*sin(x(8));
n3 = g*cos(x(7))*cos(x(8));
n7 = x(5)*cos(x(8))-x(6)*sin(x(8));
n8 = (x(5)*sin(x(8)) + x(6)*cos(x(8)))*tan(x(7));

% dx/dt = a*x + b1*w + b2*u + [n1;n2;n3;0;0;0;n7;n8];
sys = a*x + b2*u + [n1;n2;n3;0;0;0;n7;n8];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)

sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

sys = x;

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

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






