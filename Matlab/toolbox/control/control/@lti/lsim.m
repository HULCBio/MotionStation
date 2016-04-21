function [ys,ts,xs] = lsim(varargin)
%LSIM  Simulate time response of LTI models to arbitrary inputs.
%
%   LSIM(SYS) opens the Linear Simulation Tool for the LTI model SYS
%   (created with either TF, ZPK, or SS), which enables interactive
%   specification of driving input(s), the time vector, and initial
%   state.
%
%   LSIM(SYS1,SYS2,...) opens the Linear Simulation Tool for multiple
%   LTI models SYS1,SYS2,.... Driving inputs are common to all specified
%   systems but initial conditions can be specified separately for each.
%
%   LSIM(SYS,U,T) plots the time response of the LTI model SYS to the
%   input signal described by U and T.  The time vector T consists of 
%   regularly spaced time samples. For MIMO systems U is a matrix with
%   as many columns as inputs and whose i-th row specifies the input value
%   at time T(i). For SISO systems U can be specified either as a row or
%   column vector.
%   For example, 
%           t = 0:0.01:5;   u = sin(t);   lsim(sys,u,t)  
%   simulates the response of a single-input model SYS to the input 
%   u(t)=sin(t) during 5 seconds.
%
%   For discrete-time models, U should be sampled at the same rate as SYS
%   (T is then redundant and can be omitted or set to the empty matrix).
%   For continuous-time models, choose the sampling period T(2)-T(1) small 
%   enough to accurately describe the input U.  LSIM issues a warning when
%   U is undersampled and hidden oscillations may occur.
%         
%   LSIM(SYS,U,T,X0) specifies the initial state vector X0 at time T(1) 
%   (for state-space models only).  X0 is set to zero when omitted.
%
%   LSIM(SYS1,SYS2,...,U,T,X0) simulates the response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The initial condition X0 
%   is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      lsim(sys1,'r',sys2,'y--',sys3,'gx',u,t).
%
%   Y = LSIM(SYS,U,T) returns the output history Y.  No plot is drawn on 
%   the screen.  The matrix Y has LENGTH(T) rows and as many columns as 
%   outputs in SYS.  For state-space models, 
%      [Y,T,X] = LSIM(SYS,U,T,X0) 
%   also returns the state trajectory X, a matrix with LENGTH(T) rows
%   and as many columns as states.
%
%   For continuous-time models,
%      LSIM(SYS,U,T,X0,'zoh')  or  LSIM(SYS,U,T,X0,'foh') 
%   explicitly specifies how the input values should be interpolated 
%   between samples (zero-order hold or linear interpolation).  By 
%   default, LSIM selects the interpolation method automatically based 
%   on the smoothness of the signal U.
%
%   See also GENSIG, STEP, IMPULSE, INITIAL, LTIMODELS.

%   To compute the time response of continuous-time systems, LSIM uses linear 
%   interpolation of the input between samples for smooth signals, and 
%   zero-order hold for rapidly changing signals like steps or square waves. 

%	J.N. Little 4-21-85
%	Revised 7-31-90  Clay M. Thompson
%       Revised A.C.W.Grace 8-27-89 (added first order hold)
%	                    1-21-91 (test to see whether to use foh or zoh)
%	Revised 12-5-95 Andy Potvin
%       Revised 5-8-96  P. Gahinet
%       Revised 6-16-00 A. DiVergilio
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.50.4.3 $  $Date: 2004/04/10 23:13:18 $

ni = nargin;
no = nargout;

% Parse input list
try 
   for ct=length(varargin):-1:1
      ArgNames(ct,1)={inputname(ct)};
   end
   [sys, SystemName, InputName,OutputName,PlotStyle,ExtraArgs]=...
      rfinputs('lsim',ArgNames,varargin{:});
   % If t or u entries are empty
   if  no>0 && (isempty(ExtraArgs{1}) || max(size((ExtraArgs{3})))==0) %  If the input width is 0, ok
       error('LSIM requires input and time vectors to be specified when using output arguments')
   end
   [t,x0,u,InterpRule] = deal(ExtraArgs{:});
catch
   rethrow(lasterror);
end
nsys = length(sys);

% Check start time
if length(t)>1 && abs(t(1))>1e-5*(t(2)-t(1))
   warning('Simulation will start at the nonzero initial time T(1).');
end

% Simulate the time response to input U
% Use try/catch due to local error checking on initial condition
if no,
   % Call with output arguments
   sys = sys{1};
   ComputeX = no>2 & isa(sys,'ss');
   if (nsys>1 | ndims(sys)>2),
      error('LSIM takes a single model when used with output arguments.')
   elseif ComputeX,   
      % State vector required
      if any(sys.ioDelay(:)),
         error('State trajectory only available for models without I/O delays.')
      end
      [ys,ts,junk,xs] = gentresp(sys,'lsim',t,x0,u,InterpRule);
   else
      [ys,ts] = gentresp(sys,'lsim',t,x0,u,InterpRule);
      xs = [];
   end
     
else
   % Can only plot real data
   if ~isreal(u) | ~isreal(x0)
      error('Input data U and initial condition X0 must be real valued.')
   end
   
   % Create plot
   try
      h = ltiplot(gca,'lsim',InputName,OutputName,cstprefs.tbxprefs);
   catch
      rethrow(lasterror)
   end
   
   % Add responses
   for ct=1:nsys
      src = resppack.ltisource(sys{ct},'Name',SystemName{ct});
      r = h.addresponse(src);
      r.DataFcn = {'lsim' src r}; 
      % Styles and preferences
      initsysresp(r,'lsim',h.Preferences,PlotStyle{ct})
      % Place any specified initial conditions in responses jgo
      r.context.IC = x0;
   end
   
    
   % Assign default InputIndex values
   h.localizeInputs;
   h.input.Interpolation = InterpRule; % Assign interpolation rule 
   % If no inputs specified, open the lsim GUI 
   thisDataExceptionWarning = h.DataExceptionWarning;
   if isempty(u)
       % Temporaily turn off data exception warning to supress 
       % insufficient inputs warning
       h.DataExceptionWarning = 'off';
       h.lsimgui('lsiminp'); %open lsim GUI
   else % Otherwise add input data etc.      
       setinput(h,t,u,'TimeUnits','sec'); % Add input signal
       h.Input.Visible = 'on'; 
   end
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
       h.Visible = 'on';  % new plot created with Visible='off'
   else
       draw(h)  % hold mode
   end
   h.DataExceptionWarning = thisDataExceptionWarning;
   % Right-click menus
   m = ltiplotmenu(h,'lsim');
   lticharmenu(h,m.Characteristics,'lsim');
end
