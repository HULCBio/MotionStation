function [ac,bc,cc,dc] = dreg(a,b,c,d,k,l,e,f,g)
%DREG   Form discrete LQG controller.
%
%   [Ac,Bc,Cc,Dc] = DREG(A,B,C,D,K,L) produces the LQG controller 
%   based on the discrete system (A,B,C,D) with feedback gain matrix,
%   K, and Kalman gain matrix L, assuming all the inputs of the system
%   are control inputs and all the outputs of the system are sensor 
%   outputs.  The resulting state-space controller is
%
%   xBar[n+1] = [A-ALC-(B-ALD)E(K-KLC)] xBar[n] + [AL-(B-ALD)EKL] y[n]
%   uHat[n]   = [K-KLC+KLDE(K-KLC)]     xBar[n] + [KL+KLDEKL]     y[n]
%
%   where E=inv(I+KLD) and has control feedback commands uHat as 
%   outputs and sensors y as inputs.  The controller should be 
%   connected to the plant using negative feedback.  
%
%   [Ac,Bc,Cc,Dc] = DREG(A,B,C,D,K,L,SENSORS,KNOWN,CONTROLS) forms the
%   LQG controller using the sensors specified by SENSORS, the 
%   additional known inputs specified by KNOWN, and the control inputs
%   specified by CONTROLS. The resulting system has control feedback
%   commands as outputs and the known inputs and sensors as inputs. 
%   The KNOWN inputs are non-stochastic inputs of the plant and are 
%   usually additional control inputs or command inputs.
%
%   See also  DESTIM, DLQR, DLQE, REG.

%   Clay M. Thompson 7-2-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:33:50 $

if ~((nargin==6)|(nargin==9)),
   error('Wrong number of input arguments.');
end
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

[nx,na] = size(a);
[ny,nu] = size(d);

if (nargin==6)
   sensors = [1:ny]; known = []; controls = [1:nu];
end
if (nargin==9)
   sensors = e; known = f; controls = g;
end

nsens = length(sensors); nknown = length(known); nfb = length(controls);

% Check size of K and L with number of states, sensors and controls
[nk,mk] = size(k); [nl,ml] = size(l);
if (nk~=nfb)
   error('Number of controls and size of K matrix don''t match.');
end
if (mk~=nx)
   error('The A and K matrices must have the same number of columns.');
end
if (ml~=nsens)
   error('Number of sensors and size of L matrix don''t match.');
end
if (nl~=nx)
   error('The A and L matrices must have the same number of rows.'); 
end

fdbk = [1:nfb] + ny;
inputs = [1:nsens] + nu;

% --- Form discrete LQG controller ---
ac = a;
bc = [b,a*l];
cc = [c;k];
dc = [d, zeros(ny,nsens);zeros(nfb,nu), k*l];

% close sensor and internal control feedback loops
[ac,bc,cc,dc] = cloop(ac,bc,cc,dc,[fdbk,sensors],-[controls,inputs]);
[ac,bc,cc,dc] = ssselect(ac,bc,cc,dc,[known,inputs],fdbk);

% end dreg
