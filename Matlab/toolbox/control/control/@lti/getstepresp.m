function [y,t,x] = getstepresp(sys,t)
%  GETSTEPRESP  Step response of a single LTI model
%
%  [Y,T,X] = GETSTEPRESP(SYS,T) computes the step response
%  of the LTI model SYS at the time stamps T (if T is a vector) or
%  from 0 to final time T (if T is a sclar).
%
%  LOW-LEVEL UTILITY, CALLED BY STEP.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2001 The MathWorks, Inc. 
%  $Revision: 1.3 $ $Date: 2001/09/14 20:03:25 $

Tfinal = [];   % final time
if ~isempty(t) & isequal(size(t),[1 1])
  % t is final time, not time vector
  Tfinal = t; 
  t = [];
end

% Compute sample times and system type flag
Ts = sys.Ts;
NotTF = ~isa(sys, 'tf');
ComputeX = nargout>2 & isa(sys, 'ss');

% Check time vector T if supplied, generate it otherwise
if isempty(t), 
  % Generate time vector TVEC for the model
  if Ts == -1
    % Adjust TFINAL when the sample time is unspecified
    % N samples -> simulate from 0 to N-1 (note: harmless when TFINAL=[])
    Tfinal = Tfinal-1;   % n samples -> 0 to n-1
  end
  
  % Generate appropriate time vector for the system
  tvec = trange('step',Tfinal,[],sys);
  tvec = tvec{1}{1};
  t0 = 0;
else
  % Supplied time vector T 
  t0 = t(1);   % when T(1) is not zero
  dt = t(2)-t(1);
  
  % Override T if not evenly spaced
  nt0 = round(t0/dt);
  t0 = nt0*dt;
  t = dt * (0:1:nt0+length(t)-1)';
  
  % Create time vector
  tvec = t;
end

% Convert all models to state-space (simulated with SS/STEPRESP)
% except discrete-time TFs (simulated with TF/STEPRESP)
if find(Ts==0 | NotTF)
  sys = ss(sys);
end

% Simulate the step response
if ComputeX,   
  % State vector required
  [y,t,x] = stepresp2(sys,Ts,tvec,t0);
else
  [y,t]   = stepresp2(sys,Ts,tvec,t0);
  x = [];
end
