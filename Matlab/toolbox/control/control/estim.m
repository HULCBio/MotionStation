function [ae,be,ce,de] = estim(a,b,c,d,l,e,f)
%ESTIM  Form estimator given estimator gain.
%
%   EST = ESTIM(SYS,L) produces an estimator EST with gain L for
%   the outputs and states of the state-space model SYS, assuming 
%   all inputs of SYS are stochastic and all outputs are measured.
%   For a continuous system
%             .
%      SYS:   x = Ax + Bw ,   y = Cx + Dw   (with w stochastic),
% 
%   the resulting estimator
%        .
%       x_e  = [A-LC] x_e + Ly
%
%      |y_e| = |C| x_e 
%      |x_e|   |I|
%
%   generates estimates x_e and y_e of x and y.  ESTIM behaves 
%   similarly when applied to discrete-time systems.
%
%   EST = ESTIM(SYS,L,SENSORS,KNOWN) handles more general plants
%   SYS with both deterministic and stochastic inputs, and both 
%   measured and non-measured outputs.  The index vectors SENSORS 
%   and KNOWN specify which outputs y are measured and which inputs 
%   u are known, respectively.  The resulting estimator EST uses 
%   [u;y] as input to produce the estimates [y_e;x_e].  
%
%   You can use pole placement techniques (see PLACE) to design 
%   the estimator (observer) gain L, or use the Kalman filter gain
%   returned by KALMAN or KALMD.
%
%   See also PLACE, KALMAN, KALMD, REG, LQGREG, SS.

%Old help
%ESTIM  Form continuous Kalman estimator.
%   [Ae,Be,Ce,De] = ESTIM(A,B,C,D,L) produces the Kalman estimator 
%   based on the continuous system (A,B,C,D) with Kalman gain matrix
%   L assuming all the outputs of the system are sensor outputs.  The
%   resulting state-space estimator is
%         .
%        xHat  = [A-LC] xHat + Ly
%
%       |yHat| = |C| xHat
%       |xHat|   |I|
%
%   and has estimated sensors yHat and estimated states xHat as 
%   outputs, and sensors y as inputs.  
%
%   [Ae,Be,Ce,De] = ESTIM(A,B,C,D,L,SENSORS,KNOWN) forms the Kalman 
%   estimator using the sensors specified by SENSORS, and the 
%   additional known inputs specified by KNOWN.  The resulting system
%   has estimated sensors and states as outputs, and the known inputs
%   and sensors as inputs.  The KNOWN inputs are non-stochastic inputs
%   of the plant and are usually control inputs.
%
%   See also: REG,DESTIM,LQR,DLQR,LQE and DLQE.

%   Clay M. Thompson 7-2-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:23:50 $

ni = nargin;
if ~((ni==5)|(ni==7)),
   error('Wrong number of input arguments.');
end
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

[nx,na] = size(a);
[ny,nu] = size(d);

if (ni==5)
   sensors = [1:ny]; known = [];
end
if (ni==7)
   sensors = e; known = f;
end

nsens = length(sensors); 
nknown = length(known);

% Check size of L with number of states and sensors
[nl,ml] = size(l);
if (ml~=nsens)
   error('Number of sensors and size of L matrix don''t match.'); 
end
if (nl~=nx)
   error('The A and L matrices must have the same number of rows.');
end

inputs = [1:nsens] + nu; 
states = [1:nx] + ny;

% --- Form continuous Kalman estimator ---
ae = a;
be = [b,l];
ce = [c;eye(nx)];
de = [d, zeros(ny,nsens);zeros(nx,nu), zeros(nx,nsens)];

% close sensor feedback loop
[ae,be,ce,de] = cloop(ae,be,ce,de,sensors,-inputs);
[ae,be,ce,de] = ssselect(ae,be,ce,de,[known,inputs],[sensors,states]);

% end estim
