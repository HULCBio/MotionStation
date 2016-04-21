function [sys,x0,str,ts] = linsnap(t,x,u,flag,VarName,SampleTime)
%LINSNAP  S-function for the snapshot linearization block
%
%   See also LINSETUP, LINMOD, DLINMOD

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $

persistent leftcrumb;

switch flag,
  % Initialization
  case 0
    evalin('base',[VarName '=[];']);	% Clear any previous values
    sizes = simsizes;
    sizes.NumContStates  = 0;
    sizes.NumDiscStates  = 0;
    sizes.NumOutputs     = 0;
    sizes.NumInputs      = 0;
    sizes.DirFeedthrough = 0;
    sizes.NumSampleTimes = 1;
    sys = simsizes(sizes);
    x0  = zeros(0,1);
    str = [];
    ts = [-1 0];

  % Output
  case 3
    sys = [];           % no outputs to compute
  
    % don't re-enter
    if isempty(leftcrumb)
      leftcrumb = VarName;
    else
      return;
    end

    % Call either LINMOD or DLINMOD, depending on mask variable Ts
    % disp('Linearizing..');
    if SampleTime == 0
      tmpmodel = linmod(bdroot);
    else
      tmpmodel = dlinmod(bdroot,SampleTime);
    end

    % Currently no easy way to get [x u] from Simulink while running.
    % Consider adding [x u] to get_param(bdroot,'Jacobian') output.
    % If you need these for now, try saving states and clock to the
    % workspace (via Simulation Parameters dialog options) and matching
    % them up after the simulation is complete.
    %
    tmpmodel.OperPoint.x = [];
    tmpmodel.OperPoint.u = [];
    tmpmodel.OperPoint.t = t;

    % Append to existing structure if called multiple times
    themodel = evalin('base',VarName);
    if isempty(themodel)
      themodel = tmpmodel;
    else
      themodel(end+1) = tmpmodel;
    end

    % disp(['Assigning ' VarName ' in workspace.']);
    assignin('base',VarName,themodel);
    leftcrumb = [];
    
  case { 1, 2, 4, 9 }
    % do nothing, not handled

  % Unexpected flags
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);
end

