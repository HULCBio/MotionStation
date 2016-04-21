function [y,u,ym]=scmpc(pmod,imod,ywt,uwt,blocks,...
                        p,tend,setpts,ulim,ylim, ...
                        Kest,ydist,mdist,umdist,udist)
%SCMPC Simulate CL systems for constrained problems.
% 	[y,u,ym]=scmpc(pmod,imod,ywt,uwt,M,P,tend, ...
%                 r,ulim,ylim,Kest,z,v,w,wu)
% SCMPC designs an MPC-type controller for constrained problems
% and simulates the closed-loop system with hard constraints
% (inputs and outputs) using quadratic programming.
% NOTE:  This version does not anticipate setpoint changes.  The
%        current setpoint is assumed to be constant over the
%        prediction horizon.
%        See SCMPCR for an alternative approach.
% Inputs:
%  pmod: plant model in MOD format
%  imod: internal model in MOD format -- used as basis for
%        controller design.
%  ywt:  Penalty weighting for setpoint tracking.
%  uwt:  Penalty weighting for changes in manipulated variables.
%  M:    Number of moves OR sequence of blocking factors.
%  P:    Length of prediction horizon.
%  tend: duration of the simulation.
%  r:    setpoint sequence, one column for each output.
%  ulim: [Ulow Uhigh delU].  NOTE:  delU must be finite.
%  ylim: [Ylow Yhigh].
%  Kest: Estimator gain matrix.
%  z:    Measurement noise.
%  v:    Measured disturbance (for feedforward control).
%  w:    General unmeasured disturbance.
%  wu:   Unmeasured disturbance added to manipulated variables.
% Outputs: y (system response), u (manipulated variables),
%	   ym (model response).
% See also PLOTALL, PLOTEACH, SMPCCL, SMPCCON, SMPCEST, SMPCSIM.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

% +++ Check input arguments for errors and set default values. +++

if nargin == 0
   disp('USAGE:  [y,u,ym]=scmpc(pmod,imod,ywt,uwt,M,P,tend, ...')
   disp('                       r,ulim,ylim,Kest,z,v,w,wu)')
   return
elseif nargin < 8
   error('Too few input arguments')
end

if isempty(pmod) | isempty (imod)
   error('Plant and internal model must be in non-empty MOD format.')
end

% Get plant, internal, and reference models in state-space form.

[phip,gamp,cp,dp,minfop]=mod2ss(pmod);
tsamp=minfop(1);
np=minfop(2);
nup=minfop(3);
nvp=minfop(4);
nwp=minfop(5);
mp=nup+nvp+nwp;
nymp=minfop(6);
nyup=minfop(7);
nyp=nymp+nyup;

[phii,gami,ci,di,minfoi]=mod2ss(imod);
ni=minfoi(2);
nui=minfoi(3);
nvi=minfoi(4);
mi=nui+nvi;
nwi=minfoi(5);
if nwi > 0                % Strip off unmeasured disturbance model if necessary.
   gami=gami(:,1:mi);
   di=di(:,1:mi);
end
nymi=minfoi(6);
nyui=minfoi(7);
nyi=nymi+nyui;


% Check for errors and inconsistencies in the models.

if any(any(dp(:,1:nup)))
   error(['PMOD:  first nu=',int2str(nup),' columns of D must be zero.'])
elseif any(any(di(:,1:nui)))
   error(['IMOD:  first nu=',int2str(nui),' columns of D must be zero.'])
end


if minfoi(1) ~= tsamp
   error('PMOD and IMOD have different sampling periods')
elseif nui ~= nup
   error('PMOD and IMOD must have equal number of manipulated variables')
elseif nvi ~= nvp
   error('PMOD and IMOD must have equal number of measured disturbances')
elseif nymi ~= nymp
   error('PMOD and IMOD must have equal number of measured outputs')
end

if isempty(p)
   p=1;
elseif p < 1
   error('Specified prediction horizon is less than 1')
end

if isempty(ywt)
   ywt=ones(1,nyi);
   nywt=1;
else
   [nywt,ncol]=size(ywt);
   if ncol ~= nyi | nywt <= 0
      error('YWT is wrong size')
   end
   if any(any(ywt < 0))
      error('One or more elements of YWT are negative')
   end
end

if isempty(uwt),
   uwt=zeros(1,nui);
   nuwt=1;
else
   [nuwt,ncol]=size(uwt);
   if ncol ~= nui | nuwt <= 0
      error('UWT is wrong size')
   end
   if any(any(uwt < 0))
      error('UWT is negative')
   end
end

if isempty(setpts)
   nset=1;
   setpts=zeros(1,nyi);
else
   [nset,ncol]=size(setpts);
   if ncol ~= nyi
      error('Setpoint input matrix has incorrect dimensions')
   end
end

if isempty(blocks)
   blocks=ones(1,p);
   nb=p;
else
   [nrow,nb]=size(blocks);
   if nrow ~= 1 | nb < 1 | nb > p
      error('M vector is wrong size')
   end
   if any(blocks < 1)
      error('M contains an element that is < 1')
   end

   if nb == 1

%  This section interprets "blocks" as a number of moves, each
%  of one sampling period duration.

      if blocks > p
         disp('WARNING: M > P.  Truncated.')
         nb=p;
      elseif blocks <= 0
         disp('WARNING: M <= 0.  Set = 1.')
         nb=1;
      else
         nb=blocks;
      end
      blocks=[ones(1,nb-1) p-nb+1];

   else

% This section interprets "blocks" as a vector of blocking factors.

      sumblocks=sum(blocks);
      if sumblocks > p
               disp('WARNING:  sum(M) > P.')
               disp('          Moves will be truncated at P.')
               nb=find(cumsum(blocks) > p);
               nb=nb(1);
               blocks=blocks(1,1:nb);
      elseif sumblocks < p
         nb=nb+1;
         blocks(nb)=p-sumblocks;
         disp('WARNING:  sum(M) < P.  Will extend to P.')
      end
   end
end

% Check the constraint specifications.  First set up some indices to pick out
% certain columns of the ulim and ylim matrices.

iumin=[1:nui];     % Points to columns of ulim containing umin.
iumax=iumin+nui;   % Points to columns of ulim containing umax.
idumax=iumax+nui;  % Points to columns of ulim containing delta u max.
iymin=[1:nyi];     % Points to columns of ylim containing ymin.
iymax=iymin+nyi;   % Points to columns of ylim containing ymax.

% Now check the values supplied by the user for consistency.

if nargin > 8
	if isempty(ulim)
		ulim=[-inf*ones(1,nui)  inf*ones(1,nui)  1e6*ones(1,nui)];
	else
		[nulim,ncol]=size(ulim);
		if ncol ~= 3*nui | nulim <= 0
		   error('ULIM matrix is empty or wrong size.')
		elseif any(any(ulim(:,idumax) < 0))
		   error('A constraint on DELTA U was < 0')
		elseif any(any(ulim(:,iumax)-ulim(:,iumin) < 0))
		   error('A lower bound on U was greater than its upper bound')
 	    end
	end
else
	ulim=[-inf*ones(1,nui)  inf*ones(1,nui)  1e6*ones(1,nui)];
end

% When using the DANTZGMP routine for the QP problem, we must have all
% bounds on delta u finite.  A bound that is finite but large can cause
% numerical problems.  Similarly, it can't be too small.
% The following loop checks for this.

ichk=0;
for i=idumax
   ifound=find(ulim(:,i) > 1e6);
   if ~ isempty(ifound)
      ichk=1;
      ulim(ifound,i)=1e6*ones(length(ifound),1);
   end
   ifound=find(ulim(:,i) < 1e-6);
   if ~ isempty(ifound)
      ichk=1;
      ulim(ifound,i)=1e-6*ones(length(ifound),1);
   end
end
if ichk
   disp('One or more constraints on delta_u were > 1e6 or < 1e-6.')
   disp('Modified to prevent numerical problems in QP.')
end

if nargin > 9
   if isempty(ylim)
      ylim=[-inf*ones(1,nyi) inf*ones(1,nyi)];
   else
      [nylim,ncol]=size(ylim);
      if ncol ~= 2*nyi | nylim <= 0
         error('YLIM matrix is wrong size')
      elseif any(any(ylim(:,iymax)-ylim(:,iymin) < 0))
         error('A lower bound on y was greater than its upper bound')
      end
   end
else
   ylim=[-inf*ones(1,nyi) inf*ones(1,nyi)];
end

if nargin > 10
   if isempty(Kest)
      Kest=[zeros(ni,nymi)
                eye(nymi)
           zeros(nyui,nymi)];
   else
      [nrow,ncol]=size(Kest);
      if nrow ~= ni+nyi | ncol ~= nymi
         error('Estimator gain matrix is wrong size')
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

if nargin > 11
   if isempty(ydist)
      nyd=1;
      ydist=zeros(1,nyi);
   else
      [nyd,ncol]=size(ydist);
      if ncol ~= nyi
         error('Z (output disturbance) matrix has incorrect dimensions')
      end
   end
else
   nyd=1;
   ydist=zeros(1,nyi);
end

if nargin > 12
   if ~isempty(mdist)
      [nmd,ncol]=size(mdist);
      if nvi == 0
         error('Process model does not include measured disturbances')
      elseif ncol ~= nvi
         error('Measured disturbance (V) matrix has incorrect dimensions')
      end
      if nmd > 1  % following statement differences these inputs
         mdist(2:nmd,:)=mdist(2:nmd,:)-mdist(1:nmd-1,:);
      end
      nmd=nmd+1;
      mdist(nmd,:)=zeros(1,nvi);
   else
      nmd=1;
      mdist=zeros(1,nvi);
   end
else
   nmd=1;
   mdist=zeros(1,nvi);
end

if nargin > 13
   if ~isempty(umdist)
      [numd,ncol]=size(umdist);
      if nwp == 0 & ncol > 0
         error('W specified but PMOD does not include model for it')
      elseif ncol ~= nwp
         error('Unmeasured disturbance (W) matrix has incorrect dimensions')
      end
      if numd > 1  % following statement differences these inputs
         umdist(2:numd,:)=umdist(2:numd,:)-umdist(1:numd-1,:);
      end
      numd=numd+1;
      umdist(numd,:)=zeros(1,nwp);
   else
      numd=1;
      umdist=zeros(1,nwp);
   end
else
   numd=1;
   umdist=zeros(1,nwp);
end

if nargin > 14
   if isempty(udist)
      nud=1;
      udist=zeros(1,nui);
   else
      [nud,ncol]=size(udist);
      if ncol ~= nui
         error('WU disturbance matrix has incorrect dimensions')
      end
      if nud > 1  % following statement differences these inputs
         udist(2:nud,:)=udist(2:nud,:)-udist(1:nud-1,:);
      end
      nud=nud+1;
      udist(nud,:)=zeros(1,nui);
   end
else
   nud=1;
   udist=zeros(1,nui);
end

if nargin > 15
   error('Too many input arguments')
end

Hwait=waitbar(0,'SCMPC Simulation in Progress ...');

% ++++ Beginning of controller design calculations. ++++

% The following index vectors are used to pick out certain columns
% or rows in the state-space matrices.

iu=[1:nui];         % columns of gami, gamp, di, dp related to delta u.
iv=[nui+1:nui+nvi];  % points to columns for meas. dist. in gamma.
iw=[nup+nvp+1:nup+nvp+nwp]; % columns of gamp and dp related to delta w.
iym=[1:nymi];       % index of the measured outputs.

% +++ Augment the internal model state with the outputs.

[PHI,GAM,C,D,N]=mpcaugss(phii,gami,ci,di);

% +++ Calculate the basic projection matrices +++

pny=nyi*p;          % Total # of rows in the final projection matrices.
mnu=nb*nui;             % Total number of columns in final Su matrix.

Cphi=C*PHI;
Sx=[      Cphi
    zeros(pny-nyi,N)];
Su=[    C*GAM(:,iu)
    zeros(pny-nyi,nui)];
if nvi > 0
   Sv0=[ C*GAM(:,iv)
        zeros(pny-nyi,nvi)    ];
else
   Sv0=[];
end

r1=nyi+1;
r2=2*nyi;
for i=2:p
   if nvi > 0
      Sv0(r1:r2,:)=Cphi*GAM(:,iv);
   end
   Su(r1:r2,:)=Cphi*GAM(:,iu);
   Cphi=Cphi*PHI;
   Sx(r1:r2,:)=Cphi;
   r1=r1+nyi;
   r2=r2+nyi;
end

Sdel=eye(nui); % Sdel is to be a block-lower-triangular matrix in which each
               % block is an identity matrix.  Used in constraint definition.
eyep=eye(nyi); % eyep is a matrix containing P identity matrices (dimension nyi)
               % stacked one on top of the other.
for i=2:p
   eyep=[eyep;eye(nyi)];
end
for i=2:nb
   Sdel=[Sdel;eye(nui)];
end

% If number of moves > 1, fill the remaining columns of Su and Sdel,
% doing "blocking" at the same time.

if nb > 1
   k = nui;
   blocks=cumsum(blocks);
   for i = 2:nb
      row0=blocks(i-1)*nyi;
      row1=(i-1)*nui;
      Su(row0+1:pny,k+1:k+nui)=Su(1:pny-row0,1:nui);
      Sdel(row1+1:mnu,k+1:k+nui)=Sdel(1:mnu-row1,1:nui);
      k=k+nui;
   end
end

% Set up weighting matrix on outputs.  Q is a column vector
% containing the diagonal elements of the weighting matrix, SQUARED.

irow=0;
for i=1:p
   Q(irow+1:irow+nyi,1)=ywt(min(i,nywt),:)';
   irow=irow+nyi;
end
Q=Q.*Q;

% Set up weighting matrix on manipulated variables.  R
% is a column vector containing the diagonal elements, SQUARED.

uwt=uwt+10*sqrt(eps);  %for numerical stability
irow=0;
for i=1:nb
   R(irow+1:irow+nui,1)=uwt(min(i,nuwt),:)';
   irow=irow+nui;
end
R=R.*R;

% Usually, some of the general inequality constraints are not used.
% This section sets up index vectors for each type of constraint to
% pick out the ones that are actually needed for the problem.  This
% helps to minimize the size of the QP.

% First set up column vectors containing the bounds for each type of
% constraint over the entire prediction horizon.  For the inputs, the
% resulting vectors must be length mnu.  For outputs, length is pny.

umin=ulim(:,iumin)';
umin=umin(:);         % Stetches the matrix out into one long column
umax=ulim(:,iumax)';
umax=umax(:);
dumax=ulim(:,idumax)';
dumax=dumax(:);
ymin=ylim(:,iymin)';
ymin=ymin(:);
ymax=ylim(:,iymax)';
ymax=ymax(:);
clear ulim ylim       % Releases memory no longer needed.

lenu=length(umin);
if lenu > mnu         % Has user specified more bounds than necessary?
   disp('WARNING:  too many rows in ULIM matrix.')
   disp('          Extra rows deleted.')
   umin=umin(1:mnu);
   umax=umax(1:mnu);
   dumax=dumax(1:mnu);
elseif lenu < mnu     % If fewer rows than needed, must copy last one.
   r2=[lenu-nui+1:lenu];
   for i=1:round((mnu-lenu)/nui)
      umin=[umin;umin(r2,:)];
      umax=[umax;umax(r2,:)];
      dumax=[dumax;dumax(r2,:)];
   end
end

leny=length(ymin);
if leny > pny         % Has user specified more bounds than necessary?
   disp('WARNING:  too many rows in YLIM matrix.')
   disp('          Extra rows deleted.')
   ymin=ymin(1:pny);
   ymax=ymax(1:pny);
elseif leny < pny     % If fewer rows than needed, must copy last one.
   r2=[leny-nyi+1:leny];
   for i=1:round((pny-leny)/nyi)
      ymin=[ymin;ymin(r2,:)];
      ymax=[ymax;ymax(r2,:)];
   end
end

% The bounds on delta u must always be included in the problem.  The
% other bounds should only be included as constraints if they're finite.
% Generate vectors that contain a list of the finite constraints.

iumin=find(umin ~= -inf);
iumax=find(umax ~=  inf);
iymin=find(ymin ~= -inf);
iymax=find(ymax ~=  inf);

% Delete the infinite values.  At the same time, form the coefficient
% matrix for the inequality constraints.  Do this by picking out only
% the equations actually needed according to the lists established above.
% Finally, calculate the constant part of the RHS of the inequality
% constraints for these equations.

A=eye(mnu);        % These are the equations that are always present.
rhscon=2*dumax;    % They are the bounds on delta u.  A is the coefficient
                   % matrix and rhscon is the constant part of the RHS.

if ~ isempty(iumin)    % Add equations for lower bound on u
   umin=umin(iumin);
   A=[A;-Sdel(iumin,:)];
   rhscon=[rhscon;-Sdel(iumin,:)*dumax-umin];
else
   umin=[];
end
if ~ isempty(iumax)    % Add equations for upper bound on u
   umax=umax(iumax);
   A=[A;Sdel(iumax,:)];
   rhscon=[rhscon;Sdel(iumax,:)*dumax+umax];
else
   umax=[];
end
if ~ isempty(iymin)    % Add equations for lower bound on y
   ymin=ymin(iymin);
   A=[A;-Su(iymin,:)];
   rhscon=[rhscon;-Su(iymin,:)*dumax-ymin];
else
   ymin=[];
end
if ~ isempty(iymax)    % Add equations for upper bound on y
   ymax=ymax(iymax);
   A=[A;Su(iymax,:)];
   rhscon=[rhscon;Su(iymax,:)*dumax+ymax];
else
   ymax=[];
end

[nc,dumdum]=size(A);   % Save total number of inequality constraints.

% +++ Define the matrices needed for the QP +++

SuTQ=Su'*diag(Q);
B=SuTQ*Su+diag(R);
clear Su
a=B'*dumax;   % This is a constant term that adds to the initial basis
              % in each QP.
B=B\eye(mnu);
TAB=[-B   B*A' ;A*B   -A*B*A'];
clear A B

%  ++++ SIMULATION SECTION ++++

% Initialization of states, etc.

xi=zeros(ni+nyi,1);   % States of the augmented internal model.
xp=zeros(np,1);       % States of the plant.
yp=zeros(nyp,1);      % Outputs of the plant (NOT including measurement noise).
manvold=zeros(nui,1); % Previous values of the manipulated variables.
w=zeros(nwp,1);

nstep=max(fix(tend/tsamp)+1,2);  % Number of sampling periods in simulation.

IKC=eye(ni+nyi)-Kest*C;

% Simulation

for i=1:nstep
   waitbar(i/nstep);
   ytrue=yp;
   deltal=udist(min(i,nud),:)';    % current additive disturbance at plant input
   if nvi > 0
      deltav=mdist(min(i,nmd),:)'; % current measured disturbance
   end
   if nwp > 0
      deltaw=umdist(min(i,numd),:)'; % current unmeasured disturbance (modeled).
      w=w+deltaw;
      ytrue=ytrue+dp(:,iw)*w;
   end

   ypnew=ytrue+ydist(min(i,nyd),:)';       % current measured plant outputs
   setpt=setpts(min(i,nset),:)';           % current setpoints

% Calculate starting basis vector for the QP

   xi=IKC*xi+Kest*ypnew;  % measurement update for state estimator.
   y0=Sx*xi;
   if nvi > 0
      y0=y0 + Sv0*deltav;
   end
   rhsa=a+SuTQ*(eyep*setpt-y0);

% Update the RHS of the inequality constraints

   rhsc=zeros(mnu,1);
   del=Sdel(:,1:nui)*manvold;      % vector of previous value of manip. vars.

   if ~ isempty(iumin)    % Equations for lower bound on u
      rhsc=[rhsc;del(iumin,:)];
   end
   if ~ isempty(iumax)    % Equations for upper bound on u
      rhsc=[rhsc;-del(iumax,:)];
   end
   if ~ isempty(iymin)    % Equations for lower bound on y
      rhsc=[rhsc;y0(iymin,:)];
   end
   if ~ isempty(iymax)    % Equations for upper bound on y
      rhsc=[rhsc;-y0(iymax,:)];
   end

   rhsc=rhsc+rhscon;      % Add on the constant part computed earlier.

% Set up and solve the QP;

   basisi=[    -TAB(1:mnu,1:mnu)*rhsa
           rhsc-TAB(mnu+1:mnu+nc,1:mnu)*rhsa];
   ibi=-[1:mnu+nc]';
   ili=-ibi;
   [basis,ib,il,iter]=dantzgmp(TAB,basisi,ibi,ili);
   if iter < 0
      disp('Infeasible QP.  Check constraints.');
	  disp(['Step = ',int2str(i)])                
      disp('Simulation terminating prematurely!')               
      break                                       
   end
   deltau=[];
   for j=1:nui
      if il(j) <= 0
         deltau(j,1)=-dumax(j,1);
      else
        deltau(j,1)=basis(il(j))-dumax(j,1);
      end
   end
   manvold=deltau+manvold;

% State updates

   ui=deltau;
   up=ui+deltal;
   if nvi > 0
      ui=[ui;deltav];
      up=[up;deltav];
   end
   if nwp > 0
      up=[up;deltaw];
   end

   y(i,:)=ytrue';
   if nargout > 1
      u(i,:)=manvold';
   end
   if nargout > 2
      ym(i,:)=xi(ni+1:ni+nyi,:)';
   end

   xi=PHI*xi+GAM*ui;          % State update for state estimator.
   xp=phip*xp+gamp*up;
   yp=cp*xp+yp;
end
close(Hwait)

% +++ End of SCMPC +++
