function [ac,bc,cc,dc] = reg(a,b,c,d,k,l,e,f,g)
%REG  Form regulator given state-feedback and estimator gains.
%
%   RSYS = REG(SYS,K,L) produces an observer-based regulator RSYS
%   for the state-space system SYS, assuming all inputs of SYS are 
%   controls and all outputs are measured.  The matrices K and L 
%   specify the state-feedback and observer gains.  For
%              .
%       SYS:   x = Ax + Bu ,   y = Cx + Du 
%
%   the resulting regulator is 
%        .
%       x_e = [A-BK-LC+LDK] x_e + Ly
%         u = -K x_e  
%
%   This regulator should be connected to the plant using positive
%   feedback.  REG behaves similarly when applied to discrete-time 
%   systems.
%
%   RSYS = REG(SYS,K,L,SENSORS,KNOWN,CONTROLS) handles more 
%   general regulation problems where 
%     * the plant inputs consist of controls u, known inputs Ud, 
%       and stochastic inputs w, 
%     * only a subset y of the plant outputs are measured. 
%   The I/O subsets y, Ud, and u are specified by the index vectors
%   SENSORS, KNOWN, and CONTROLS.  The resulting regulator RSYS    
%   uses [Ud;y] as input to generate the commands u. 
%
%   You can use pole placement techniques (see PLACE) to design the
%   gains K and L, or alternatively use the LQ and Kalman gains 
%   produced by LQR/DLQR and KALMAN.
%
%   See also PLACE, LQR, DLQR, LQGREG, ESTIM, KALMAN, SS.

%Old help
%REG    Form continuous LQG controller.
%   [Ac,Bc,Cc,Dc] = REG(A,B,C,D,K,L) produces the LQG controller based
%   on the continuous system (A,B,C,D) with feedback gain matrix, K,
%   and Kalman gain matrix L, assuming all the inputs of the system 
%   are control inputs and all the outputs of the system are sensor 
%   outputs.  The resulting state-space controller is
%        .
%       xHat = [A-BK-LC+LDK] xHat + Ly
%       uHat = [K] xHat
%
%   and has control feedback commands uHat as outputs and sensors y as
%   inputs.  The controller should be connected to the plant using 
%   negative feedback.
%
%   [Ac,Bc,Cc,Dc] = REG(A,B,C,D,K,L,SENSORS,KNOWN,CONTROLS) forms the
%   LQG controller using the sensors specified by SENSORS, the 
%   additional known inputs specified by KNOWN, and the control inputs
%   specified by CONTROLS. The resulting system has control feedback
%   commands as outputs and the known inputs and sensors as inputs. 
%   The KNOWN inputs are non-stochastic inputs of the plant and are 
%   usually additional control inputs or command inputs.
%
%   See also: DREG,ESTIM,DESTIM,LQR,DLQR,LQE and DLQE.

%   Clay M. Thompson 6-29-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:25:21 $

ni = nargin;
if ~((ni==6)|(ni==9)), 
   error('Wrong number of input arguments.'); 
end

[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

[nx,na] = size(a);
[ny,nu] = size(d);

if (ni==6)
   sensors = [1:ny]; known = []; controls = [1:nu];
end
if (ni==9)
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

% --- Form continuous LQG controller ---
ac = a;
bc = [b,l];
cc = [c;k];
dc = [d, zeros(ny,nsens);zeros(nfb,nu), zeros(nfb,nsens)];

% close sensor and internal control feedback loops
[ac,bc,cc,dc] = cloop(ac,bc,cc,dc,[fdbk,sensors],-[controls,inputs]);
[ac,bc,cc,dc] = ssselect(ac,bc,cc,dc,[known,inputs],fdbk);

% end reg
