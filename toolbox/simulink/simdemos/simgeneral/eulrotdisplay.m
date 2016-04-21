function [sys,x0,str,ts] = eulrotdisplay(t,x,u,flag)
%EULROTDISPLAY Animation for EULROT.C
%   [SYS,XO]=EULROTDISPLAY(T,X,U,FLAG) is the S-Function used
%   for the Euler rotation block in Simulink.  
%
%   WORKINGFIG is the handle of the figure that the animation takes
%   place on.  It is stored in the userdata of the block.
%
%   See also EULROT.C, QUATDEMO.

%   Loren Dean 
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $

BlockHandle=gcb;
WorkingFig=get_param(BlockHandle,'UserData');
if ~ishandle(WorkingFig)|~strcmp(get(WorkingFig,'Tag'),'QuatWorkingFig'),  
  WorkingFig=[];
  set_param(BlockHandle,'UserData',[]);  
end  % if

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(WorkingFig);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u,WorkingFig);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u,WorkingFig);

  case {1,2,4},
    % Don't do anything  
  
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(WorkingFig)

if ~isempty(WorkingFig)& ...
  ~strcmp(get_param('simquat','SimulationStatus'),'stopped'),  
    quatdemo('Dynamic',2,3); % This will force the dynamic page
    Data=get(WorkingFig,'UserData');    
    set([Data.StaticButton Data.DynamicButton],'Visible','off');
end % if ~isempty
  
sizes = simsizes;

sizes.NumContStates  = 0 ;
sizes.NumDiscStates  = 0 ;
sizes.NumOutputs     = 0 ;
sizes.NumInputs      = 3 ;
sizes.DirFeedthrough = 1 ;
sizes.NumSampleTimes = 1 ;   % at least one sample time is needed

sys = simsizes(sizes);
x0  = [];
str = [];
ts  = [0 0];

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u,WorkingFig,Data)

if ~isempty(WorkingFig),
  psi=u(1);theta=u(2);phi=u(3);
  quatdemo(WorkingFig,psi,theta,phi);
end % WorkingFig
sys=[];

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u,WorkingFig)

sys=[];
if ~isempty(WorkingFig),
  Data=get(WorkingFig,'UserData');    
  set([Data.StaticButton Data.DynamicButton],'Visible','on');
  quatdemo('Static',2,3); % This will force the dynamic page    
end % if ~isempty
