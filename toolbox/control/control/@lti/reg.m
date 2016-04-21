function rsys = reg(sys,k,l,sensors,known,controls)
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

%   Clay M. Thompson 6-29-90
%   Revised: P. Gahinet  7-26-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15.4.1 $  $Date: 2003/01/07 19:32:30 $

ni = nargin;
error(nargchk(3,6,ni))
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

% Determine sensor outputs
[p,m] = size(sys);
Nx = size(sys,'order');
if ni<4,
   sensors = 1:p;
elseif any(sensors<=0) | any(sensors>p),
   error('Index in SENSORS out of range.')
end
Ny = length(sensors);

% Partition inputs into u,Ud,w
switch ni,
case 5
   if any(known<=0) | any(known>m),
      error('Index in KNOWN out of range.')
   end
   known = known(:);
   controls = (1:m)';
   controls(known) = [];
case 6
   if any(controls<=0) | any(controls>m),
      error('Index in CONTROLS out of range.')
   elseif length(controls)+length(known)>m,
      error('Combined length of KNOWN and CONTROLS exceeds input dimension of SYS.')
   end
   known = known(:);
   controls = controls(:);
otherwise
   known = [];
   controls = (1:m)';
end
Nu = length(controls);

% Compute estimator
if ~isequal(size(l),[Nx Ny]),
   error('L must have as many rows as states and as many columns as measurements y.')
end
est = estim(sys,l,sensors,[controls;known]);


% Close the loop 
%
%      +-------| -K  |<---+
%   u  |                  | 
%      |       +-----+    |
%      +------>|     |--- | ---> y_e
%   Ud ------->| EST |    |
%    y ------->|     |----+----> x_e
%              +-----+
%
if ~isequal(size(k),[Nu Nx]),
   error('K must have as many rows as controls u and as many columns as states.')
end
rsys = feedback(est,k,1:Nu,Ny+1:Ny+Nx);

% Keep control names
kss = ss(-k);
if Nu,  
   kss.OutputGroup = struct('Controls',1:Nu);  
end
kss.OutputName = sys.InputName(controls);

% Get rid of u,y_e and add gain K so that output is u = K x_e
iselect = {Ny+1:Ny+Nx , Nu+1:Nu+Ny+length(known)};
rsys = kss * subsref(rsys,substruct('()',iselect));

