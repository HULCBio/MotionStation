function [y,t,x] = impulse(varargin)
%IMPULSE  Impulse response of LTI models.
%
%   IMPULSE(SYS) plots the impulse response of the LTI model SYS (created 
%   with either TF, ZPK, or SS).  For multi-input models, independent
%   impulse commands are applied to each input channel.  The time 
%   range and number of points are chosen automatically.  For continuous 
%   systems with direct feedthrough, the infinite pulse at t=0 is 
%   disregarded.
%
%   IMPULSE(SYS,TFINAL) simulates the impulse response from t=0 to the 
%   final time t=TFINAL.  For discrete-time systems with unspecified 
%   sampling time, TFINAL is interpreted as the number of samples.
%
%   IMPULSE(SYS,T) uses the user-supplied time vector T for simulation. 
%   For discrete-time models, T should be of the form  Ti:Ts:Tf  
%   where Ts is the sample time.  For continuous-time models, 
%   T should be of the form  Ti:dt:Tf  where dt will become the sample 
%   time of a discrete approximation to the continuous system.  The
%   impulse is always assumed to arise at t=0 (regardless of Ti).
%
%   IMPULSE(SYS1,SYS2,...,T) plots the impulse response of multiple
%   LTI models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      impulse(sys1,'r',sys2,'y--',sys3,'gx').
%
%   When invoked with left-hand arguments,
%      [Y,T] = IMPULSE(SYS) 
%   returns the output response Y and the time vector T used for 
%   simulation.  No plot is drawn on the screen.  If SYS has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the impulse response of the 
%   j-th input channel.
%
%   For state-space models, 
%      [Y,T,X] = IMPULSE(SYS, ...) 
%   also returns the state trajectory X which is an LT-by-NX-by-NU 
%   array if SYS has NX states.
%
%   See also  STEP, INITIAL, LSIM, LTIVIEW, LTIMODELS.

%	J.N. Little 4-21-85
%	Revised: 8-1-90  Clay M. Thompson, 2-20-92 ACWG, 10-1-94 
%	Revised: P. Gahinet, 4-24-96
%	Revised: A. DiVergilio, 6-16-00
%       Revised: B. Eryilmaz, 10-01-01
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.45.4.1 $  $Date: 2002/11/11 22:21:41 $

ni = nargin;
no = nargout;
if ni == 0 
   eval('exresp(''impulse'')')
   return
end

% Parse input list
try
   for ct = length(varargin):-1:1
      ArgNames(ct,1) = {inputname(ct)};
   end
   [sys, SystemName, InputName, OutputName, PlotStyle, ExtraArgs] = ...
      rfinputs('impulse', ArgNames, varargin{:});
catch
   rethrow(lasterror)
end
t = ExtraArgs{1};
nsys = length(sys);

% Simulate the impulse response
if no
   % Call with output arguments
   sys = sys{1};  % single model
   x = [];
   if (nsys>1 | ndims(sys)>2)
      error('IMPULSE takes a single model when used with output arguments.')
   elseif no<3 | ~isa(sys,'ss')
      % No state vector requested
      [y,t,focus] = gentresp(sys, 'impulse', t);
   elseif any(sys.ioDelay(:))
      error('State trajectory only available for models without I/O delays.')
   else
      [y,t,focus,x] = gentresp(sys, 'impulse', t);
   end
   % Clip to FOCUS
   [t,y,x] = roundfocus('time',focus,t,y,x);
   
else
   % Impulse response plot
   % Create plot
   try
      h = ltiplot(gca, 'impulse', InputName, OutputName, cstprefs.tbxprefs);
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
      r.DataFcn = {'timeresp' src 'impulse' r t};
      r.Context = struct('Type','impulse');
      % Styles and preferences
      initsysresp(r,'impulse',h.Preferences,PlotStyle{ct})
   end
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot created with Visible='off'
   else
      draw(h)  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h, 'impulse');
   lticharmenu(h, m.Characteristics, 'impulse');
end
