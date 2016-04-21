function [y,t,x] = step(varargin)
%STEP  Step response of LTI models.
%
%   STEP(SYS) plots the step response of the LTI model SYS (created 
%   with either TF, ZPK, or SS).  For multi-input models, independent
%   step commands are applied to each input channel.  The time range 
%   and number of points are chosen automatically.
%
%   STEP(SYS,TFINAL) simulates the step response from t=0 to the 
%   final time t=TFINAL.  For discrete-time models with unspecified 
%   sampling time, TFINAL is interpreted as the number of samples.
%
%   STEP(SYS,T) uses the user-supplied time vector T for simulation. 
%   For discrete-time models, T should be of the form  Ti:Ts:Tf 
%   where Ts is the sample time.  For continuous-time models,
%   T should be of the form  Ti:dt:Tf  where dt will become the sample 
%   time for the discrete approximation to the continuous system.  The
%   step input is always assumed to start at t=0 (regardless of Ti).
%
%   STEP(SYS1,SYS2,...,T) plots the step response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in 
%      step(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [Y,T] = STEP(SYS) returns the output response Y and the time 
%   vector T used for simulation.  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, and LT = length(T), Y is an 
%   array of size [LT NY NU] where Y(:,:,j) gives the step response 
%   of the j-th input channel.
%
%   [Y,T,X] = STEP(SYS) also returns, for a state-space model SYS, the
%   state trajectory X, a LT-by-NX-by-NU array if SYS has NX states.
%
%   See also IMPULSE, INITIAL, LSIM, LTIVIEW, LTIMODELS.

%   Author(s): J.N. Little, 4-21-85
%   Revised:   A.C.W.Grace, 9-7-89, 5-21-92
%   Revised:   P. Gahinet, 4-18-96
%   Revised:   A. DiVergilio, 6-16-00
%   Revised:   B. Eryilmaz, 6-6-01
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.46.4.1 $  $Date: 2002/11/11 22:21:52 $

ni = nargin;
no = nargout;
if ni == 0
   eval('exresp(''step'')')
   return
end

% Parse input list
try
   for ct = length(varargin):-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys, SystemName, InputName, OutputName, PlotStyle, ExtraArgs] = ...
      rfinputs('step', ArgNames, varargin{:});
catch
   rethrow(lasterror)
end
t = ExtraArgs{1};
nsys = length(sys);

% Simulate the step response
if no
   % Call with output arguments
   sys = sys{1};  % single model
   x = [];
   if (nsys>1 | ndims(sys)>2)
      error('STEP takes a single model when used with output arguments.')
   elseif no<3 | ~isa(sys,'ss')
      % No state vector requested
      [y,t,focus] = gentresp(sys, 'step', t);
   elseif any(sys.ioDelay(:))
      error('State trajectory only available for models without I/O delays.')
   else
      [y,t,focus,x] = gentresp(sys, 'step', t);
   end
   % Clip to FOCUS
   [t,y,x] = roundfocus('time',focus,t,y,x);
   
else
   % Step response plot
   % Create plot (visibility ='off')
   try
      h = ltiplot(gca, 'step', InputName, OutputName, cstprefs.tbxprefs);
   catch
      rethrow(lasterror)
   end
   
   % Set global time focus for user-defined range/vector (sets preferred X limits)
   if length(t) == 1
      h.setfocus([0, t],'sec')
   elseif ~isempty(t)
      h.setfocus([t(1) t(end)],'sec')
   end
   
   % Create and configure responses
   for ct=1:nsys
      % Link each response to system source
      src = resppack.ltisource(sys{ct}, 'Name', SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'timeresp' src 'step' r t};
      r.Context = struct('Type','step');
      % Styles and preferences
      initsysresp(r,'step',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot, 'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h, 'step');
   lticharmenu(h, m.Characteristics, 'step');
end
