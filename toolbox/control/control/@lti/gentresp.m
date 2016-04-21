function [y,t,focus,x] = gentresp(sys,RespType,t,x0,u,varargin)
% GENTRESP  Generates time vector and computes time response.
%
%  LOW-LEVEL UTILITY.
%
%  1. Focus = [T(1), T(end)], when T is a vector
%  2. Focus = [0, T],  when T is a scalar (final time)
%  3. Focus = [0, Tf], when T = [], for computed final time Tf.
%  For cases 2 and 3, the actual simulation time (OUTPUT vector T) extends
%  beyond Focus(2).

%  Author(s): B. Eryilmaz, P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc. 
%  $Revision: 1.10 $  $Date: 2002/04/10 05:52:56 $

% RE: 1) sys is a single MIMO model.
%     2) RESPTYPE is 'step', 'impulse', or 'initial'
ni = nargin;
Ts = getst(sys);
isSS = isa(sys,'ss');
ComputeX = nargout>3 & isSS;

% Process time input
if ni<3
   t = [];
else
   t = t(:);
end
if ni<4
   x0 = [];
end
if length(t) == 1
   % t is final time, not time vector
   Tfinal = t; 
   t = [];
else
   Tfinal = [];   % final time
end

% Convert system to state-space (simulated with SS/STEPRESP)
% except for discrete-time TFs (simulated with TF/STEPRESP)
if (Ts == 0) | ~isa(sys,'tf')
   sys = ss(sys);
   if ~isSS & ~isempty(x0)
      x0 = zeros(size(sys,'order'),1);
   end
end

% Generate time vector T if not supplied
if isempty(t), 
   % Generate time vector TVEC for the model
   if Ts == -1
      % Adjust TFINAL when the sample time is unspecified
      % N samples -> simulate from 0 to N-1 (note: harmless when TFINAL=[])
      Tfinal = Tfinal-1;   % n samples -> 0 to n-1
   end
   % Generate appropriate time vector for the system
   [t,focus] = trange(RespType,Tfinal,x0,sys);
   t = t{1}{1};
   t0 = 0;
else
   focus = [t(1),t(end)];
   t0 = t(1);
   if ~strcmp(RespType,'lsim')
      % Extent T to include t=0
      dt  = t(2)-t(1);
      nt0 = round(t0/dt);
      t = [(0:dt:(nt0-1)*dt)'; t];
   end
end

% Simulate the response
x = [];
switch RespType
case 'step'
   if ComputeX,   
      % State vector required
      [y,t,x] = stepresp(sys,Ts,t,t0);
   else
      [y,t]   = stepresp(sys,Ts,t,t0);
   end
   
case 'impulse'
   if ComputeX,   
      % State vector required
      [y,t,x] = impresp(sys,Ts,t,t0);
   else
      [y,t]   = impresp(sys,Ts,t,t0);
   end
   
case 'initial'
   if ComputeX,   
      % State vector required
      [y,t,x] = initresp(sys,Ts,t,t0,x0);
   else
      [y,t]   = initresp(sys,Ts,t,t0,x0);
   end
   
case 'lsim'
   if ComputeX,   
      % State vector required
      [y,t,x] = linresp(sys,Ts,u,t,x0,varargin{:});
   else
      [y,t]   = linresp(sys,Ts,u,t,x0,varargin{:});
   end
end


% --------------------------------------------------------------------------- %
% Local functions
% --------------------------------------------------------------------------- %
function [y,t,x] = initresp(sys,Ts,t,t0,x0)
%INITRESP  Initial response of a single LTI model
%
%   [Y,T,X] = INITRESP(SYS,TS,T,T0,X0) computes the initial response
%   of the LTI model SYS with sample time TS at the time stamps T
%   (starting at t=0).  The response from t=0 to t=T0 is discarded 
%   if T0>0.

lt = length(t);
dt = t(2)-t(1);
[ny,nu] = size(sys);
nx = size(sys,'order');

% Discretize if continuous
if Ts == 0
   sys.InputDelay = zeros(nu,1); % Eliminate input delays 
   sys = c2d(sys,dt);
end

% Simulate state trajectory with LTITR
[a,b,c] = ssdata(sys);
nxd = size(a,1);
x = ltitr(a,zeros(nxd,1),zeros(lt,1),[x0;zeros(nxd-nx,1)]);

% Compute output
Tdout = sys.OutputDelay;
if ~any(Tdout),
   y = x * c.';
else
   ctr = c.';
   y = zeros(lt,ny);
   for i=1:ny,
      y(Tdout(i)+1:lt,i) = x(1:lt-Tdout(i),:) * ctr(:,i);
   end
end

% Truncate state vector if augmented by C2D
if nxd>nx,
   x = x(:,1:nx);
end

% Clip response if T0>0
if (t0 > 0)
   keep = find(t>=t0);
   y = y(keep,:);
   t = t(keep);
   x = x(keep,:);
end
