function [sys,x0,str,ts] = heatex_gdata(t,x,u,flag)
% HEATEX_GDATA This S function reads in time t, and output data u, 
% from the Simulink model heatex_sim.mdl
% The data is then passed to a graphics update function in heatex.m
% The general structure of an S-function is used

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 06:40:50 $

switch flag,
case 0, % Initialization %
    [sys,x0,str,ts]=mdlInitializeSizes;
case 1,% Derivatives %
    % Do nothing not used    
    % sys=mdlDerivatives(t,x,u);
case 2,  % Update %
    [sys] = mdlUpdate(t,x,u);
case 3,  % Outputs %
    % Do nothing not used
    % sys=mdlOutputs(t,x,u);
case 4,  % GetTimeOfNextVarHit %
    % Do nothing not used
    % sys=mdlGetTimeOfNextVarHit(t,x,u);
case 9,  % Terminate %
    sys=mdlTerminate(t,x,u);
otherwise  % Unexpected flags %
    error(['Unhandled flag = ',num2str(flag)]);
end
% end sfuntmpl

%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
function [sys,x0,str,ts]=mdlInitializeSizes
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
sizes = simsizes;
sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed
sys = simsizes(sizes);
% initialize the initial conditions
x0  = [];
% str is always an empty matrix
str = [];
% initialize the array of sample times
ts  = [0 0];
% end mdlInitializeSizes

%=============================================================================
% mdlUpdate     flag = 2
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
function [sys] = mdlUpdate(t,x,u)		%flag = 2

% Call the function in heatex to udate the display and mimic screen
% Get the function handle which has been stored in the Userdat field of BlockData

LinkData = get_param('heatex_sim/Get Data','UserData');
feval(LinkData.UpDateFcn,LinkData.FigHandle,t,u);

% Return nothing in sys
sys = [];
% end mdlUpdate

%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
function sys=mdlTerminate(t,x,u)
sys = [];
% end mdlTerminate
