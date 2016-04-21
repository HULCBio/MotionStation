function [y,t,x] = impresp(sys,Ts,t,t0)
%IMPRESP  Impulse response of a single LTI model
%
%   [Y,T,X] = IMPRESP(SYS,TS,T,T0) computes the impulse response
%   of the LTI model SYS with sample time TS at the time stamps
%   T (starting at t=0).  The response from t=0 to t=T0 is 
%   discarded if T0>0.
%
%   LOW-LEVEL UTILITY, CALLED BY IMPULSE.

%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.7 $  $Date: 2002/04/10 06:07:51 $

x = [];
if Ts==0,
   error('Only meant for discrete-time transfer functions')
end

% Get cumulative I/O delays
Tdio = totaldelay(sys);

% Pre-allocate output
lt = length(t);
[ny,nu] = size(sys.num);
y = zeros(lt,ny,nu);

% Simulate with FILTER
u = zeros(lt,1);
u(1) = 1;
for k=find(Tdio(:)<lt)',
   y(Tdio(k)+1:lt,k) = filter(sys.num{k},sys.den{k},u(1:lt-Tdio(k)));
end

% Clip response if T0>0
if t0>0,  
   keep = find(t>=t0);
   y = y(keep,:,:);   
   t = t(keep);   
end

