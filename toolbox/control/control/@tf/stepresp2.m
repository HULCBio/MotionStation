function [y,t,x] = stepresp2(sys,Ts,t,t0)
%  STEPRESP  Step response of a single LTI model in tranfer function format.
%
%  [Y,T,X] = STEPRESP(SYS,TS,T,T0) computes the step response of the LTI
%  model SYS with sample time TS at the time stamps T (starting at t=0).
%  The response from t=0 to t=T0 is discarded if T0>0.
%
%  LOW-LEVEL UTILITY.

%  Author:  P. Gahinet,  4-98
%  Revised: B. Eryilmaz, 6-01
%  Copyright 1986-2001 The MathWorks, Inc. 
%  $Revision: 1.2 $  $Date: 2001/10/01 15:11:35 $

x = [];
if Ts == 0,
  error('Only meant for discrete-time transfer functions')
end

% Get cumulative I/O delays
Tdio = totaldelay(sys);

% Pre-allocate output
lt = length(t);
[ny,nu] = size(sys.num);
y = zeros(lt,ny,nu);

% Simulate with FILTER
u = ones(lt,1);
for k = find(Tdio(:)<lt)'
  y(Tdio(k)+1:lt,k) = filter(sys.num{k}, sys.den{k}, u(1:lt-Tdio(k)));
end

% Clip response if t0>0
if t0 > 0
  keep = find(t>=t0);
  y = y(keep,:,:);
  t = t(keep);
end
