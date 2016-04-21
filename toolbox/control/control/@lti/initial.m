function [y,t,x] = initial(varargin)
%INITIAL  Initial condition response of state-space models.
%
%   INITIAL(SYS,X0) plots the undriven response of the state-space 
%   model SYS (created with SS) with initial condition X0 on the 
%   states.  This response is characterized by the equations
%                        .
%     Continuous time:   x = A x ,  y = C x ,  x(0) = x0 
%
%     Discrete time:  x[k+1] = A x[k],  y[k] = C x[k],  x[0] = x0.
%
%   The time range and number of points are chosen automatically.  
%
%   INITIAL(SYS,X0,TFINAL) simulates the time response from t=0 
%   to the final time t=TFINAL.  For discrete-time models with 
%   unspecified sample time, TFINAL should be the number of samples.
%
%   INITIAL(SYS,X0,T) specifies a time vector T to be used for 
%   simulation.  For discrete systems, T should be of the form  
%   0:Ts:Tf where Ts is the sample time.  For continuous-time models,
%   T should be of the form 0:dt:Tf where dt will become the sample
%   time of a discrete approximation of the continuous model.
%
%   INITIAL(SYS1,SYS2,...,X0,T) plots the response of multiple LTI 
%   models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      initial(sys1,'r',sys2,'y--',sys3,'gx',x0).
%
%   When invoked with left hand arguments,
%      [Y,T,X] = INITIAL(SYS,X0)
%   returns the output response Y, the time vector T used for simulation, 
%   and the state trajectories X.  No plot is drawn on the screen.  The
%   matrix Y has LENGTH(T) rows and as many columns as outputs in SYS.
%   Similarly, X has LENGTH(T) rows and as many columns as states.
%	
%   See also IMPULSE, STEP, LSIM, LTIVIEW, LTIMODELS.

%	Clay M. Thompson  7-6-90
%	Revised: ACWG 6-21-92
%	Revised: PG 4-25-96
%       Revised: A. DiVergilio, 6-16-00
%       Revised: B. Eryilmaz, 10-02-01
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.43.4.3 $  $Date: 2004/04/10 23:13:16 $

ni = nargin;
no = nargout;
if ni == 0,
   eval('exresp(''initial'',1)')
   return
end

% Parse input list
try
   for ct = length(varargin):-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys, SystemName, InputName, OutputName, PlotStyle, ExtraArgs] = ...
      rfinputs('initial', ArgNames, varargin{:});
   t = ExtraArgs{1};  % Time vector
   x0 = ExtraArgs{2}; % Initial state
catch
   rethrow(lasterror)
end
nsys = length(sys);

% Simulate the initial response
if no
   % Call with output arguments
   sys = sys{1};  % single model
   if (nsys>1 | ndims(sys)>2)
      error('INITIAL takes a single model when used with output arguments.')
   else
      [y,t,focus,x] = gentresp(sys, 'initial', t, x0);
      % Clip to FOCUS
      [t,y,x] = roundfocus('time',focus,t,y,x);
   end
   
else
   % Initial response plot
   if ~isreal(x0)
      % Accept complex x0 with output arguments
      error('Initial condition X0 must be a vector of real numbers.')
   end
   % Create plot
   try
      h = ltiplot(gca, 'initial', InputName, OutputName, cstprefs.tbxprefs);
   catch
      rethrow(lasterror)
   end
   
   % Set global time focus for user-defined range/vector (sets preferred X limits)
   if length(t) == 1
      h.setfocus([0, t],'sec')
   elseif ~isempty(t)
      h.setfocus([t(1) t(end)],'sec')
   end
   
   % Create responses
   for ct = 1:nsys
      src = resppack.ltisource(sys{ct}, 'Name', SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'initial' src r t};
      r.Context = struct('Type','initial','IC',x0);
      % Styles and preferences
      initsysresp(r,'initial',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h, 'initial');
   lticharmenu(h, m.Characteristics, 'initial');
end
