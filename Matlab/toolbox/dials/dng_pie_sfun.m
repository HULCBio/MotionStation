function [sys,x0,str,ts] = dng_pie_sfun(t, x, u, flag, hActx)
%DNG_PIE_SFUN S-function used to communicate with the Dynamic Pie 
%   percent indicator.
%
%   This m-file s-function allows the flexible use of the Dials & Gauges
%   Global Majic Strip Chart within Simulink models. The handle to the
%   Dynamic Pie ActiveX control is passed in as HACTX
%
%   T, X, U, and FLAG are automatically passed into the S-function by 
%   Simulink. Only U is actually used in this example.  U contains the
%   vector of values contained in the input signal to the Dynamic Pie
%   block.
%
%   This s-function also serves as an example of communicating with an
%   ActiveX control from the MATLAB language through an s-function.

%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/12/15 15:53:18 $

%
% The following is a switchyard to handle various calls to the s-function
% from Simulink. The format of this s-function follows Simulink 
% convention; however, the relevant code that handles the inputs, U, is
% contained is the case where FLAG==3.
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
   if ~exist('hActx') | ~i_IsActX(hActx), disp('not activex 1'), return; end  
   
%%%%%%%%%%%%%%%
% Derivatives %
%%%%%%%%%%%%%%%
case 1,
   sys = [];  % Return nothing
   
%%%%%%%%%%
% Update %
%%%%%%%%%%
case 2,
   %
   % This is where the Dynamic Pie percent indicator is updated.
   %
   sys = [];  % Return nothing

   % First check to see if the control is being displayed. If not
   % hActX won't exist, so we should just exit early in this case.
   %
   if ~i_IsActX(hActx), disp('not activex 2'), return; end

   %
   % Normalize the values of the input vector such that the sum of
   % the vector is 100 (percent).
   %
   
   % First make sure there is no division by zero
   if sum(u)==0
       u=u+0.001;
   end
   
   % Now perform the normalization
   u = 100/sum(u).*u;
   
   %
   % Loop through the portions and update their values.
   %
   if (length(u) ~= 0)
      for n=1:length(u)
         hActx.PortionID = n-1;
         hActx.PortionValue = u(n);
     end
   end
   
%%%%%%%%%%%
% Outputs %
%%%%%%%%%%%
case 3,
   %
   % No need to return anything; set return variable to empty
   %
   sys = [];
   
   
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


% Function: i_IsActX ===========================================================
% Abstract:
%   Return 1 if it's an active x control.
%
function out = i_IsActX(hActx),
  out = ~isempty(findstr(class(hActx), 'COM.'));
%endfunction 

