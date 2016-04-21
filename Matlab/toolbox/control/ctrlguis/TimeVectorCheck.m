function t = TimeVectorCheck(t,t0)
%TIMEVECTORCHECK  Check time input is valid vector or final time.

%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2002 The MathWorks, Inc. 
%  $Revision: 1.2 $ $Date: 2002/04/04 15:22:42 $

% RE: T0 is the absolute start time (e.g., t=0 for step)

lt = prod(size(t));
if lt==1
   if ~isreal(t) | t<=0,
      error('Final time must be a positive number.')
   elseif ~isfinite(t)
      t = [];
   end
elseif lt>1
   % Time vector specified
   t = t(:);
   dt = t(2)-t(1);
   if ~isreal(t) | any(diff(t)<=0) | any(~isfinite(t)),
      error('The time samples must be real and monotonically increasing.')
   elseif any(abs(diff(t)-dt)>0.01*dt)
      error('Time samples must be evenly spaced.')
   end
   
   if nargin==1
      % LSIM-type simulation (no fixed-time event)
      t0 = t(1);
   elseif t(1)<t0
      % Simulation with event at t=t0 (step,...)
      error(sprintf('Start time must be greater than %0.3g',t0))
   end
   
   % Enforce even spacing
   nt0 = round((t(1)-t0)/dt);
   t = t0 + dt * (nt0:nt0-1+length(t))';
end  
