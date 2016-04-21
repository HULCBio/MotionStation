function [sys,x0,str,ts] = ax_strip_sfun(t, x, u, flag, hActx)
%AX_STRIP_SFUN S-function used to communicate with the Strip Chart.
%   This m-file s-function allows the flexible use of the Dials & Gauges
%   Global Majic Strip Chart within Simulink models. The handle to the
%   Strip Chart ActiveX control is passed in as HACTX
%
%   This s-function also serves as an example of communicating with an
%   ActiveX control from the MATLAB language through an s-function.

%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $

%
% The following is a switchyard to handle various calls to the s-function
% from Simulink.
%
switch flag,
   
%%%%%%%%%%%%%%%%%%
% Initialization %
%%%%%%%%%%%%%%%%%%
case 0,
   % Initialize the s-function block properties.
   % Call simsizes for a sizes structure, fill it in and convert it to a
   % sizes array.
   %
   sizes = simsizes;
   
   sizes.NumContStates  =  0;
   sizes.NumDiscStates  =  0;
   sizes.NumOutputs     =  0;
   sizes.NumInputs      = -1;   % inherit the width of the input vector
   sizes.DirFeedthrough =  1;
   sizes.NumSampleTimes =  1;   % at least one sample time is needed
   
   sys = simsizes(sizes);
   
   %
   % Initialize the initial conditions
   %
   x0  = [];
   
   %
   % str is always an empty matrix
   %
   str = [];
   
   %
   % Initialize the array of sample times
   % We are inheriting the sample time from the driving block.
   % Also, we indicate that this block is fixed in minor time steps.
   %
   ts  = [-1 1];
   
   %
   % First check to see if the control is being displayed. If not
   % hActX won't exist, so we should just exit early in this case.
   %
   if ~exist('hActx') | ~localIsActX(hActx), return; end
      
   %
   % Initialize strip chart properties.
   % (more initialization is done in mdlOutputs below)
   %
   hActx.LastX = hActx.XSpan;    % set the whole chart to start at covered time span
   
   
%%%%%%%%%%%%%%%
% Derivatives %
%%%%%%%%%%%%%%%
case 1,
   sys = [];  % Return nothing
   
%%%%%%%%%%
% Update %
%%%%%%%%%%
case 2,
   sys = [];  % Return nothing
   
%%%%%%%%%%%
% Outputs %
%%%%%%%%%%%
case 3,
   %
   % This is where the strip chart is updated.
   %
   % No need to return anything; set return variable to empty
   %
   sys = [];
   
   % First check to see if the control is being displayed. If not
   % hActX won't exist, so we should just exit early in this case.
   %
   if ~localIsActX(hActx),
     return;
   end

   
   %
   % At the start of each simulation run, reset each of the variables
   %
   if (t == 0)
      hActx.Variables = length(u);  % set the number of variables to plot
      for i=1:length(u)
         hActx.VariableID = i-1;    % set each variable to start plotting
         hActx.VariableLastX = 0;   %   at time zero
      end
   end
   
   %
   % Factor to convert seconds to days. The strip chart plots the x-axis
   % time in units of days.
   %
   s2d = 1/60/60/24; 
   
   %
   % Invoke the method to update the trace for each of the input signals.
   %
   if (length(u) ~= 0)
      for i=1:length(u)
         invoke(hActx,'AddXY',i-1,t*s2d,u(i));
      end
   end
   
   % end mdlOutputs
   
%%%%%%%%%%%%%
% Terminate %
%%%%%%%%%%%%%
case 9,
   sys = [];  % Return nothing
   
%%%%%%%%%%%%%%%%%%%%
% Unexpected flags %
%%%%%%%%%%%%%%%%%%%%
otherwise
   error(['Unhandled flag = ',num2str(flag)]);
   
end

% end switchyard


function out = localIsActX(hActx),
    out = ~isempty(findstr(class(hActx), 'COM.'));
