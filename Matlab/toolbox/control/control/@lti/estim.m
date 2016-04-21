function est = estim(sys,l,sensors,known)
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

%   Clay M. Thompson 7-2-90
%   Revised: P. Gahinet 7-30-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2003/01/07 19:32:01 $

ni = nargin;
error(nargchk(2,4,ni))
if ~isa(sys,'ss'),
   error('SYS must be a state-space LTI model.')
elseif hasdelay(sys),
   if sys.Ts,
      % Map delay times to poles at z=0 in discrete-time case
      sys = delay2z(sys);
   else
      error('Not supported for continuous-time delay systems.')
   end
end

% Extract state-space data
[a,b,c,d] = ssdata(sys);
Nx = size(a,1);
[pd,md] = size(d);

% Eliminate outputs that are not sensors
if ni<3,
   sensors = 1:pd;
elseif any(sensors<=0) | any(sensors>pd),
   error('Index in SENSORS out of range.')
end
c = c(sensors,:);
d = d(sensors,:);
Ny = length(sensors);

% Check dimensions of L
if ~isequal(size(l),[Nx Ny]),
   error('L must have as many rows as states and as many columns as measurements y.')
end

% Select known inputs
if ni<4,
   known = [];
elseif any(known<=0) | any(known>md),
   error('Index in KNOWN out of range.')
end

% Extract matrices B and D
b = b(:,known);
d = d(:,known);
Nu = length(known);

% Get observer matrices
ae = a-l*c;
be = [b-l*d l];
ce = [c ; eye(Nx)];
de = [[d ; zeros(Nx,Nu)] , zeros(Nx+Ny,Ny)];

% Get names for u and y
Uname = sys.InputName(known);
Yname = sys.OutputName(sensors);

% Set input groups to 'KnownInput' and 'Measurement'
InputGroup = struct;
if Nu,  
   InputGroup.KnownInput = 1:Nu;  
end
if Ny,  
   InputGroup.Measurement = Nu+1:Nu+Ny;  
end

% Set output groups to 'OutputEstimate' and 'StateEstimate'
OutputGroup = struct;
if Ny,  
   OutputGroup.OutputEstimate = 1:Ny;  
end
if Nx,  
   OutputGroup.StateEstimate = Ny+1:Ny+Nx; 
end

% Form resulting estimator system
est = ss(ae,be,ce,de,sys.Ts);
est.InputName = [Uname ; Yname];
est.InputGroup = InputGroup;
est.OutputGroup = OutputGroup;

