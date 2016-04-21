function [y,t,x] = linresp(sys,Ts,u,t,x0,InterpRule)
%LINRESP   Time response simulation for LTI model.
%
%   [Y,T,X] = LINRESP(SYS,TS,U,T,X0) simulates 
%   the time response of the LTI model SYS to the 
%   input U and initial condition X0.  TS is the 
%   sample time of SYS and T is the vector of time
%   stamps.
%
%   LOW-LEVEL UTILITY, CALLED BY LSIM.

%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.7 $  $Date: 2002/04/10 06:07:33 $

% SYS is assumed discrete of class TF (X0 ignored)
x = [];
if Ts==0,
   error('Only meant for discrete-time transfer functions')
end

% Get cumulative I/O delays
Tdio = totaldelay(sys);

% Pre-allocate output
lt = length(t);
[ny,nu] = size(sys.num);
y = zeros(lt,ny);

% Simulate with FILTER
for j=1:nu,
   for i=1:ny,
      tdij = Tdio(i,j);
      y(tdij+1:lt,i) = ...
         y(tdij+1:lt,i) + filter(sys.num{i,j},sys.den{i,j},u(1:lt-tdij,j));
   end
end
