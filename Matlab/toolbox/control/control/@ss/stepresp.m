function [y,t,x] = stepresp(sys,Ts,t,t0)
%STEPRESP  Step response of a single LTI model
%
%   [Y,T,X] = STEPRESP(SYS,TS,T,T0) computes the step response
%   of the LTI model SYS with sample time TS at the time stamps
%   T (starting at t=0).  The response from t=0 to t=T0 is 
%   discarded if T0>0.
%
%   LOW-LEVEL UTILITY, CALLED BY STEP.

%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.12 $  $Date: 2002/04/10 06:00:18 $

ComputeX = (nargout>2);
lt = length(t);
dt = t(2)-t(1);
nx = size(sys.a{1},1);  % true number of states

% Discretize system if continuous
if Ts==0,
	sys = c2d(sys,dt);
end

% Extract data
[a,b,c,d] = ssdata(sys);
[ny,nu] = size(d);

% Pre-allocate outputs
y = zeros(lt,ny,nu);
if ComputeX, 
   x = zeros(lt,nx,nu);  
end

% Extract discrete-time delays and reduce to a pair
% (TDIN,TDOUT) of input and output delays to be used
% in the simulation of each input channel
if ComputeX | ny==0
   % State trajectory required -> no I/O delays
   Tdin = get(sys.lti,'inputdelay')';
   Tdout = repmat(get(sys.lti,'outputdelay'),[1 nu]);
else
   % Get cumulative I/O delays
   Tdio = totaldelay(sys);
   Tdin = min(Tdio,[],1);              % input delays for each input channel
   Tdout = Tdio - Tdin(ones(1,ny),:);  % output delays for each input channel
end


% Simulate step response of each input channel
dtr = d.';
ctr = c.';
u = ones(lt,1);

for j=find(Tdin<lt),
   % Simulate state trajectory from t=Ts*Tdin(j) to t=T(END) with LTITR
   xj = ltitr(a,b(:,j),u(1:lt-Tdin(j)),zeros(size(a,1),1));
   if ComputeX & nx>0,
      % Note: Td then consists of input + output delays
      x(Tdin(j)+1:end,:,j) = xj(:,1:nx);  
   end
      
   % Set output trajectory for j-th input channel
   if any(Tdout(:,j)),
      Tdj = Tdout(:,j) + Tdin(j);  % I/O delays for j-th channel 
      for i=1:ny,
         y(Tdj(i)+1:lt,i,j) = xj(1:lt-Tdj(i),:) * ctr(:,i) + d(i,j);
      end
   else
      y(Tdin(j)+1:lt,:,j) = xj * ctr + dtr(j(ones(1,lt-Tdin(j))),:);
   end
end


% Clip response if T0>0
if t0>0,  
   keep = find(t>=t0);
   y = y(keep,:,:);   
   t = t(keep);  
   if ComputeX,
      x = x(keep,:,:);
   end
end
