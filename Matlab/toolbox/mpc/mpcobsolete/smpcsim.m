function [y,u,ym]=smpcsim(pmod,imod,Ks,tend,setpts,ulim,...
                          Kest,ydist,mdist,umdist,udist)
%SMPCSIM Simulate closed-loop systems with saturation constraints.
%	[y,u,ym]=smpcsim(pmod,imod,Ks,tend,r,ulim,Kest,z,v,w,wu)
% State-space closed-loop simulation for MPC with saturation
% constraints on manipulated variables.  Otherwise, unconstrained.
%
% Inputs:
%  pmod:     plant model in MOD format
%  imod:     internal model in MOD format -- used as basis for
%            controller design.
%  Ks:       MPC controller gain, calculated using SMPCCON.
%  tend:     duration of the simulation.
%  r:        setpoint sequence, one column for each output.
%  ulim:     0 or [] for no constraint, or [ Ulow Uhigh delU].
%  Kest:     Estimator gain matrix.
%  z:        Measurement noise.
%  v:        Measured disturbance (for feedforward control).
%  w:        General unmeasured disturbance.
%  wu:       Unmeasured disturbance added to manipulated variables.
%
% Outputs: y (system response), u (manipulated variables),
%	   ym (model response)
%
% See also PLOTALL, PLOTEACH, SCMPC, SMPCCL, SMPCCON, SMPCEST.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

% +++ Check input arguments for errors and set default values +++

if nargin == 0
   disp('USAGE:  [y,u,ym]=smpcsim(pmod,imod,Ks,tend,r,ulim,Kest,z,v,w,wu)')
   return
elseif nargin < 5
   error('Too few input arguments')
end

if isempty(imod)
   error('Internal model not specified')
end
if isempty(pmod)
   error('Plant model not specified')
end

[phip,gamp,cp,dp,minfop]=mod2ss(pmod);

tsamp=minfop(1);  % Sampling period
np=minfop(2);     % Order of plant model.
nup=minfop(3);    % Number of manipulated variables in plant.
nvp=minfop(4);    % Number of measured disturbances.
nwp=minfop(5);    % Number of modeled unmeasured disturbances.
ninp=nup+nvp+nwp; % Total number of plant inputs.
nymp=minfop(6);   % Number of measured outputs.
nyup=minfop(7);   % Number of unmeasured outputs.
nyp=nymp+nyup;    % Total number of plant outputs.

nstep=max(fix(tend/tsamp)+1,2);

[phii,gami,ci,di,minfoi]=mod2ss(imod);

ni=minfoi(2);
nui=minfoi(3);
nvi=minfoi(4);
nwi=minfoi(5);
nymi=minfoi(6);
nyui=minfoi(7);
nyi=nymi+nyui;

% If the internal model has unmeasured disturbances, remove the corresponding
% columns from gamma and d.

if nwi > 0
   gami=gami(:,1:nui+nvi);
   di=di(:,1:nui+nvi);
end
mi=nui+nvi;

% +++ Error checks on model specifications +++

if minfoi(1) ~= tsamp
   error('PMOD and IMOD have different sampling periods')
elseif nui ~= nup
   error('PMOD and IMOD must have equal number of manipulated variables')
elseif nvi ~= nvp
   error('PMOD and IMOD must have equal number of measured disturbances')
elseif nymi ~= nymp
   error('PMOD and IMOD must have equal number of measured outputs')
elseif nyui ~= nyup
   error('PMOD and IMOD must have equal number of unmeasured outputs')
end

% +++ Check remaining inputs +++

KsCols=2*nyi+ni+nvi;
if isempty(Ks)
   Ks=zeros(nui,KsCols);   % default condition
   openloop=1;
elseif any(any(Ks))
   [nrow,ncol]=size(Ks);
   if ncol ~= KsCols
      error('Ks matrix has wrong number of columns.')
   elseif nrow ~= nui
      error('Ks matrix has wrong number of rows')
   end
   openloop=0;
else
   Ks=zeros(nui,KsCols);
   openloop=1;
end

if isempty(setpts)
   nset=1;
   setpts=zeros(1,nyi);
else
   [nset,ncol]=size(setpts);
   if openloop
      if ncol ~= nui
         error(['OPEN-LOOP simulation:  R must have nu=',int2str(nui),...
                ' columns.'])
      end
   else
      if ncol ~= nyi
         error(['CLOSED-LOOP simulation:  R must have ny=',int2str(nyi),...
                ' columns.'])
      end
   end
end

if nargin > 5
   if isempty(ulim)
      nulim=1;
      ulim=[-inf*ones(1,nup),inf*ones(1,nup+nup)];  % Default to unconstrained.
   else
      [nulim,ncol]=size(ulim);
      if ncol ~= 3*nup | nulim <= 0
         error('ULIM matrix is wrong size')
      end
      if any(any(ulim(:,2*nup+1:3*nup) < 0))
         error('A constraint on delta u was < 0')
      elseif any(any(ulim(:,nup+1:nup+nup)-ulim(:,1:nup) < 0))
         error('A lower bound on u was greater than corresponding upper bound.')
      end
   end
else
   nulim=1;
   ulim=[-inf*ones(1,nup),inf*ones(1,nup+nup)];
end

if nargin > 6
   if isempty(Kest)
      Kest=[zeros(ni,nymi)       % This is the default value of Kest
              eye(nymi)
            zeros(nyui,nymi)];
   else
      [nrow,ncol]=size(Kest);
      if nrow ~= ni+nymi+nyui | ncol ~= nymi
         error('Kest must have n+nym+nyu rows and nym columns')
      end
   end
else
   Kest=[zeros(ni,nymi)
           eye(nymi)
         zeros(nyui,nymi)];
end

% +++ If there are unmeasured outputs, add columns of zeros
%     to the estimator gain matrix.

if nyup > 0
   Kest=[Kest zeros(ni+nyi,nyup)];
end

if nargin > 7
   if isempty(ydist)
      nyd=1;
      ydist=zeros(1,nyi);
   else
      [nyd,ncol]=size(ydist);
      if ncol ~= nyi
         error('d (output disturbance) matrix has incorrect dimensions')
      end
   end
else
   nyd=1;
   ydist=zeros(1,nyi);
end

if nargin > 8
   if ~isempty(mdist)
      [nmd,ncol]=size(mdist);
      if nvp == 0
         error('Process model does not include measured disturbances')
      elseif ncol ~= nvp
         error('Measured disturbance (v) matrix has incorrect dimensions')
      end

%          Difference the measured disturbance inputs (closed-loop only).
      if ~openloop
         mdist=[mdist;mdist(nmd,:)];
         nmd=nmd+1;
         mdist(2:nmd,:)=mdist(2:nmd,:)-mdist(1:nmd-1,:);
      end
   else
      nmd=1;
      mdist=zeros(1,nvp);
   end
else
   nmd=1;
   mdist=zeros(1,nvp);
end

if nargin > 9
   if ~isempty(umdist)
      [numd,ncol]=size(umdist);
      if nwp == 0 & ncol > 0
         error('Process model does not include unmeasured disturbances')
      elseif ncol ~= nwp
         error('Unmeasured disturbance (w) matrix has incorrect dimensions')
      end

%              Difference the unmeasured disturbance inputs (closed-loop only).
      if ~openloop
         umdist=[umdist;umdist(numd,:)];
         numd=numd+1;
         umdist(2:numd,:)=umdist(2:numd,:)-umdist(1:numd-1,:);
      end
   else
      numd=1;
      umdist=zeros(1,nwp);
   end
else
   numd=1;
   umdist=zeros(1,nwp);
end

if nargin > 10
   if isempty(udist)
      nud=1;
      udist=zeros(1,nup);
   else
      [nud,ncol]=size(udist);
      if ncol ~= nup
         error(['Manipulated variable disturbance matrix (wu) has',...
                ' incorrect dimensions'])
      end

%     Difference the manipulated variable disturbance inputs (closed-loop case).
      if ~openloop
         if nud > 1
         udist(2:nud,:)=udist(2:nud,:)-udist(1:nud-1,:);
         end
         nud=nud+1;
         udist(nud,:)=zeros(1,nup);
      end
   end
else
   nud=1;
   udist=zeros(1,nup);
end

if nargin > 11
   error('Too many input arguments')
end

% +++ If it's an open-loop simulation, just use DLSIMM.

if openloop
   if nstep > nset
      setpts=[setpts;ones(nstep-nset,1)*setpts(nset,:)];
   end
   if nstep > nmd
      mdist=[mdist;ones(nstep-nmd,1)*mdist(nmd,:)];
   end
   if nstep > numd
      umdist=[umdist;ones(nstep-numd,1)*umdist(numd,:)];
   end
   if nstep > nud
      udist=[udist;ones(nstep-nud,1)*udist(nud,:)];
   end
   y=dlsimm(phip,gamp,cp,dp,[setpts+udist, mdist, umdist]);
   u=[];
   ym=[];
   return
end

% +++ Closed-loop from here on.

%    +++ Use following section of MPCCL to get the control law ++++

% +++ Augment the estimator and plant states.

[phii,gami,ci,di,ni]=mpcaugss(phii,gami,ci,di);
[PHI,GAM,C,D,N]=mpcaugss(phip,gamp,cp,dp);

% +++ Break Ks into its components

Kr=Ks(:,1:nyi);
Kx=Ks(:,nyi+1:nyi+ni);
if nvi > 0
   Kv=Ks(:,ni+nyi+1:ni+nyi+nvi);
end

% +++ Define the state-space matrices for the controller +++

iu=[1:nui];

IKC=eye(ni)-Kest*ci;
PKX=phii+gami(:,iu)*Kx;
phic=PKX*IKC;
gamc=[gami(:,iu)*Kr, PKX*Kest];
cc=Kx*IKC;
dc=[Kr, Kx*Kest];

if nvi > 0
   iv=[nui+1:nui+nvi];
   gamc=[gamc, gami(:,iu)*Kv+gami(:,iv)];
   dc=[dc, Kv];
end
[nc,nc]=size(phic);

%                +++ End of section copied from MPCCL. +++

C1=ci*IKC;     % These are for calculating the estimated output
C2=ci*Kest;    % given the current state estimate.

% +++  Carry out the simulation.  +++

% Initialization of states, etc.

xc=zeros(nc,1);
x=zeros(N,1);
manvold=zeros(nup,1);
iv=[nup+1:nup+nvp];
iw=[nup+nvp+1:nup+nvp+nwp];
w=zeros(nwp,1);
deltav=[];
deltaw=[];

% Simulation

for i=1:nstep

   ytrue=C*x;                           % noise-free true plant output.

% Get the current disturbance inputs.

   deltal=udist(min(i,nud),:)';       % Adds to manipulated variable.
   if nvp > 0
      deltav=mdist(min(i,nmd),:)';    % Modeled, measured disturbance
   end
   if nwp > 0
      deltaw=umdist(min(i,numd),:)';  % Modeled, unmeasured disturbance
      ytrue=ytrue+D(:,iw)*deltaw;
   end

% Calculate the current plant output.

   ynew=ytrue+ydist(min(i,nyd),:)';     % ydist is the measurement noise.

% Calculate the controller output.

   setpt=setpts(min(i,nset),:)';      % Current setpoints.
   uc=[setpt;ynew];

   if nvp > 0
      uc=[uc;deltav];
   end
   yc=cc*xc+dc*uc;  % The controller output, yc, is the desired change
                    % in the manipulated variables.

% Enforce constraints on the manipulated variables.

   ulimits=ulim(min(i,nulim),:)';     % Gets the current limits on u.
   for iu=1:nup                                 % This loop enforces the
      dumax=ulimits(2*nup+iu);                  % bounds on rate-of-change.
      if abs(yc(iu)) > dumax
         manv(iu,1)=dumax*sign(yc(iu))+manvold(iu);
      else
         manv(iu,1)=yc(iu)+manvold(iu);
      end
   end
   manv=max([manv ulimits(1:nup)]')';           % Enforce the lower bound.
   manv=min([manv ulimits(nup+1:nup+nup)]')';   % Enforce the upper bound.
   deltau=manv-manvold;            % Allowed changes in man. vars.
   manvold=manv;

% Save the results in the output arguments

   y(i,:)=ytrue';
   if nargout > 1
      u(i,:)=manv';
   end
   if nargout > 2
      ym(i,:)=(C1*xc+C2*ynew)';
   end

% Update the states of the plant and the controller.

   x=PHI*x+GAM*[deltau+deltal;deltav;deltaw];
   xc=phii*(IKC*xc + Kest*ynew) + gami(:,1:nui)*deltau;
   if nvp > 0
      xc=xc + gami(:,iv)*deltav;
   end
end
