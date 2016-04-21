function [y,u,ym,KF] = cmpc(plant,model,yweight,uweight,...
                           no_moves,horizon,tfinal,...
                           setpoint,uconstraint,yconstraint,...
                           tfilter,distplant,distmodel,diststep)

%CMPC	Simulation of the constrained Model Predictive Controller.
%	 [y,u,ym] = cmpc(plant, model, ywt, uwt,M,P, tend, r, ulim,ylim,...
%                        tfilter, dplant, dmodel, dstep)
% REQUIRED INPUTS:
% plant (model): step response coefficient matrix of the plant (model).
% ywt: weight matrix for the difference between the output variables and the
%      reference trajectory in the objective function.
% uwt: weight matrix for the man. variable move in the objective function
% M: If M contains only one element it is the input horizon. If M contains
%    more than one element then each element specifies blocking intervals.
% P: number of steps in the time horizon for the quadratic objective function.
%    P = Inf indicates the infinite control horizon.
% tend: final time of simulation.
% r: a constant or time-varying reference trajectory.
% OPTIONAL INPUTS:
% ulim: matrix of manipulated variable constraints.  It is a trajectory of
%       lower limits (Ulow), upper limits (Uhigh) and rate of change (DelU).
%       If there are no constraints or usat=[], ulim is set appropriately.
% ylim: matrix of output variable constraints. It is a trajectory of lower
%       (Ylow) and upper limits (Yhigh) on the output variables. Default=[].
% tfilter:  time constants for noise filter and unmeasured disturbance lags.
%           Default is no filtering and step disturbance.
% dplant: step response coefficient matrix for the disturbance effect on the
%         plant output.If dplant is provided, dstep is required.Default=[].
% dmodel: step response coefficient matrix for the measured disturbance effect
%         on the model output. If dmodel is provided, dstep is also required.
%         Default=[].
% dstep: For output step disturbances it is a trajectory of disturbance values
%        For disturbances through step response models,it is a trajectory of
%        disturbance model inputs.Default value is the empty matrix,[].
% OUTPUT ARGUMENTS: y (system response) , u (manipulated variables) and
%                   ym (model response)
% See also PLOTALL, PLOTEACH, MPCCL, MPCCON, MPCSIM.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if (nargin==0)
   disp('usage: [y,u,ym] = cmpc(plant,model,ywt,uwt,M,P,tend,r,ulim,...');
   disp('                       ylim,tfilter,dplant,dmodel,dstep)');
   return;
end;

if (nargin < 8)
    error('  Too few arguments !!');
    return;
elseif (nargin > 14)
    error('  Too many arguments !!');
    return;
end;

[npny,nu] = size(plant);           [nmny,nu1] = size(model);
ny = plant(npny-1,1);              ny1 = model(nmny-1,1);
delt = plant(npny,1);              deltm = model(nmny,1);
nfinal = fix(tfinal/delt);
if (nu<ny)
%    error(' The program runs only as dimU>=dimY.');
end;
if (ny1~=ny)
    error(' Check the dimensions of PLANT & MODEL.');
end;
if (nu1~=nu)
    error(' Check the dimensions of PLANT & MODEL.');
end;
if (deltm~=delt)
    error(' The sampling time must be the same in PLANT & MODEL.');
end;
npny = npny-2-ny;
nmny = nmny-2-ny;
np = npny/ny;                      nm = nmny/ny;
noutp = plant(npny+1:npny+ny,1);  noutm = model(nmny+1:nmny+ny,1);
intp = ones(ny,1)-noutp;          intm = ones(ny,1)-noutm;
noutdp = ones(ny,1);               noutdm = ones(ny,1);

p = horizon;
if horizon == Inf,
   p = sum(no_moves) + nm + 1;
end

[rows,m]=size(no_moves);
if rows ~= 1
   error('NO_MOVES must be a row vector')
elseif any(no_moves(1,:) < 1)
   error('An element of NO_MOVES was zero or negative')
else
   if m == 1    % If true, interpret NO_MOVES in normal DMC fashion
      m=no_moves;
      if m > p
         disp('WARNING:  NO_MOVES > HORIZON.')
         disp('          Will use NO_MOVES = HORIZON.')
         m=p;
         moves=ones(1,m);
      elseif m == p
         moves=ones(1,m);
      else
         moves=[ones(1,m) p-m];
      end
   else         % Otherwise, treat NO_MOVES as a set of blocking factor
      moves=no_moves;
      ichk=find(cumsum(moves) > p);
      if isempty(ichk)
         if sum(moves) < p
            moves=[moves p-sum(moves)];
            disp('WARNING:  sum(NO_MOVES) < HORIZON.')
            disp('          Will extend to HORIZON.')
         end
      else
         disp('WARNING:  sum(no_moves) > horizon.')
         disp('          Moves will be truncated at horizon.')
         m=ichk(1);
         moves=moves(1,1:m);
      end;
   end;
end;

if isempty(yweight)
    yweight=ones(1,ny);
end;
if isempty(uweight)
    uweight=zeros(1,nu);
end;
[lyw,wyw] = size(yweight);
[luw,wuw] = size(uweight);

if (wyw~=ny)
    error(' Dimension of YWEIGHT is wrong.');
end;
if (wuw~=nu)
    error(' Dimension of UWEIGHT is wrong.');
end;

mnu = m*nu;
pny = p*ny;

%
% extend UCONSTRAINT over m steps and check if uconstraint = empty or not given
%
if (nargin==8)
   uconstraint=[];
end;
if (isempty(uconstraint))
   for i=1:m
       uconstraint(i,:)= [(-inf)*ones(1,nu) inf*ones(1,nu) 1e6*ones(1,nu)];
   end;
end;

[luc,wuc] = size(uconstraint);
if (wuc~=3*nu)
   error('The dimension of UCONSTRAINT is wrong.')
end;
if any(any(uconstraint(:,2*nu+1:3*nu) < 0))
   error('A constraint on delta u was < 0');
elseif any(any(uconstraint(:,nu+1:2*nu)-uconstraint(:,1:nu) < 0))
   error('A lower bound on u was greater than corresponding upper bound.');
end;

% When using the DANTZGMP routine for the QP problem, we must have all
% bounds on delta u finite.  A bound that is finite but large can cause
% numerical problems.  Similarly, it can't be too small.
% The following loop checks for this.

idumax=[1:nu]+2*nu;  % Points to columns of ulim containing delta u max.
ichk=0;
for i=idumax
   ifound=find(uconstraint(:,i) > 1e6);
   if ~ isempty(ifound)
      ichk=1;
      uconstraint(ifound,i)=1e6*ones(length(ifound),1);
   end
   ifound=find(uconstraint(:,i) < 1e-6);
   if ~ isempty(ifound)
      ichk=1;
      uconstraint(ifound,i)=1e-6*ones(length(ifound),1);
   end
end
if ichk
   disp('One or more constraints on delta_u were > 1e6 or < 1e-6.')
   disp('Modified to prevent numerical problems in QP.')
end

if (luc < m)
   for ic = luc+1:m
      uconstraint(ic,:) = uconstraint(luc,:);
   end;
end;

%
% extend SETPOINT over the horizon
%
if isempty(setpoint)
    setpoint=zeros(1,ny);
end;
[ls,ws] = size(setpoint);
if (ws~=ny)
    error('Check the dimension of SETPOINT.');
end;

if (ls < p)
    for is = ls+1:p
        setpoint(is,:) = setpoint(ls,:);
    end;
end;

%
% if [p(horizon)+1] > nm (the truncation order of the model),
% make nm = p+1, and add the last step response coefficients
% (p+1-nm) times to the MODEL
%

if ((p+1)>nm)
    k = nmny;  kx = nmny-ny+1;
    int = intm*ones(1,nu);
    for ib = nm+1:p+1
         model(k+1:k+ny,:) = model(kx:k,:)+int.*(model(kx:k,:)...
	 			-model(kx-ny:kx-1,:));
            k = k+ny;  kx = kx+ny;
    end;
    nmny = k;  nm = p+1;
end;

 if (nargin >= 11)                                  % Loop nargin > 10
   if (isempty(distplant))
       distmodel=[];
   end;
   if (nargin==12 | nargin==13)
      error(' A term multiplying the disturbance plant must be specified.');
      return;
   end;

   if (nargin>13)                                  % Loop nargin > 13

      %
      % check dimensions of DISTPLANT as constant disturbance input
      %

      [ldp,wdp] = size(distplant);

      if (isempty(distplant)==1 & isempty(diststep)==0)      % Loop pmodel status

         [ld,wd] = size(diststep);
         if (wd~=ny)
            error(' For the chosen configuration the diststep is the wrong dimension');
         end;

         %
         % difference the disturbance
         %
         diststep(1:ld+1,:)= ...
         [diststep;diststep(ld,:)]-[zeros(1,wd);diststep];

         %
         % extend diststep  over the entire simulation
         %
         if (ld+1<(nfinal+npny+1))
             diststep(ld+2:nfinal+npny+1,:) = zeros(nfinal+npny-ld,ny);
         end;

      elseif (isempty(distplant)==1 & isempty(diststep)==1)
         disp(' No modeled disturbances.');
      elseif (isempty(distplant)==0 & isempty(diststep)==0)

         %
         % for DISTSTEP into disturbance model, make the truncation order of Su and Sd equal
         %
         % for the plant

         % extend diststep over the entire simulation

         [ld,wd] = size(diststep);

         % difference the disturbance

         diststep(1:ld+1,:)= ...
         [diststep;diststep(ld,:)] - [zeros(1,wd);diststep];

         if (ld+1<(nfinal+p))
            diststep(ld+2:nfinal+p,:) = zeros(nfinal+p-ld-1,wd);
         end;

         [ndp1,ndp2] = size(distplant);
         ny1 = distplant(ndp1-1,1);
         deltdp = distplant(ndp1,1);

          if (ny1~=ny)
             disp('The number of disturbance plant (DISTPLANT) outputs');
             disp('and system (PLANT) outputs must be the same.');
             return;
          end;

          if (ndp2~=wd)
             disp('The number of disturbance plant (DISTPLANT) inputs');
             disp('and disturbance (DISTSTEP) columns must be the same.');
             return;
          end;

         if (deltdp~=delt)
            error(' The sampling time must be the same in PLANT & DISTPLANT.');
         end;

         ndp1 = ndp1-2-ny;
         ndp = ndp1/ny;
	 noutdp = distplant(ndp1+1:ndp1+ny,1);
	 intdp = ones(ny,1)-noutdp;

         if (ndp>np)
             k = npny;	kx = npny-ny+1;
	     int = intp*ones(1,nu);
             for ib=np+1:ndp
                 plant(k+1:k+ny,:)=plant(kx:k,:)+int.*(plant(kx:k,:)...
					-plant(kx-ny:kx-1,:));
		  kx=kx+ny;
                  k = k+ny;
             end;
             npny = k;  np=ndp;
         else
             k = ndp1;	kx = ndp1-ny+1;
	     int = intdp*ones(1,ndp2);
             for ib=ndp+1:np,
                  distplant(k+1:k+ny,:)=distplant(kx:k,:)+int.*...
				  (distplant(kx:k,:)-distplant(kx-ny:kx-1,:));
                  k = k + ny;
		  kx = kx + ny;
             end;
         end;

%         Sd = zeros(npny, p*wd);
%         ki = 0;
%
%
%         for i = 0:p-1,
%             Sd(ki+1:npny,ki+1:ki+wd) = distplant(1:npny-ki,1:wd);
%             ki = ki + wd; i
%         end;


         % for the model

         if (isempty(distmodel)==0)
               [ndm1,ndm2] = size(distmodel);
               ny1 = distmodel(ndm1-1,1);
               deltdm = distmodel(ndm1,1);

             if (ny1~=ny)
                  disp(' The number of disturbance model (DISTMODEL) outputs');
                  disp(' and system (PLANT) outputs must be the same.');
                  return;
              end;

             if (ndm2~=wd)
                  disp(' The number of disturbance model (DISTMODEL) inputs');
                  disp(' and disturbance (DISTSTEP) columns must be the same.');
                  return;
              end;

               if (deltdm~=delt)
                   error('The sampling time must be the same in PLANT & DISTMODEL.');
               end;

               ndm1 = ndm1-2-ny;
               ndm = ndm1/ny;
	       noutdm = distmodel(ndm1+1:ndm1+ny,1);
	       intdm = ones(ny,1)-noutdm;

               if (ndm>nm)
                   k = nmny;  kx = nmny-ny+1;
		   int = intm*ones(1,nu);
                   for ib=nm+1:ndm
                       model(k+1:k+ny,:) = model(kx:k,:)+int.*(model(kx:k,:)...
					  -model(kx-ny:kx-1,:));
                      k = k+ny;
		      kx = kx+ny;
                   end;
                   nmny = k;  nm = ndm;
               elseif (ndm<nm)
                   k = ndm1;  kx = ndm1-ny+1;
		   int = intdm*ones(1,ndm2);
                   for ib=ndm+1:nm
                      distmodel(k+1:k+ny,:) = distmodel(kx:k,:)+int.*...
				(distmodel(kx:k,:)-distmodel(kx-ny:kx-1,:));
	              k = k+ny;
		      kx = kx+ny;
                   end;
               end;

%               Sm = zeros(npny, pny);
%               ki = 0;
%               for i = 1:np-1
%                   ki = ki + ny;
%                   Sm(ki+1:npny,ki+1:ki+ny) = Sd(1:npny-ki,1:ny);
%               end;
%
%               ki = 1 + ny;
%               for i = 1:p-1
%                   Sm(ki:npny,ki:ki+ny-1) = Sm(1:npny-ki+1,1:ny);
%               end;
           end;                                     % Loop dmodel status
end;
   else
     distplant = [];
     distmodel = [];
     diststep = [];
   end;                                             % Loop nargin>13

 elseif (nargin<=10)
         tfilter = [];
	 if (nargin~=10)
           yconstraint = [];
         end;
         distplant = [];
         distmodel = [];
         diststep = [];
 end;
                                             % Loop nargin > 10
%
% Check TFILTER
%

[nrtfil,nctfil]=size(tfilter);

if (isempty(tfilter))
    tdist=[];
elseif (nctfil ~= ny)
    error('   No. of columns of tfilter should be equal to no. outputs.');
    return;
elseif (nrtfil==1)
    tdist=[];
else
    tdist=tfilter(2,:);
    tfilter=tfilter(1,:);
end;

%
% extend YCONSTRAINT over p steps
%

if (isempty(yconstraint)==1)
    yconstraint = inf*[(-1)*ones(1,ny) ones(1,ny)];
end;

[lyc,wyc] = size(yconstraint);

if (wyc~=2*ny)
    error(' The dimension of YCONSTRAINT is wrong.')
end;
if any(any(yconstraint(:,ny+1:2*ny)-yconstraint(:,1:ny) < 0))
      error('A lower bound on y was greater than corresponding upper bound.');
end;

if (lyc < p)
    for ic = lyc+1:p
        yconstraint(ic,:) = yconstraint(lyc,:);
    end;
end;


%
% set up the Su matrix
% set up Cu, Cp for C and record the indices that constraints exist(s)
%

Cu = [];     Cp = [];

IL = eye(nu);
for i = 1:m-1
   IL = [IL;eye(nu)];
end;
IL(:,nu+1:mnu) = zeros(mnu,mnu-nu);
Su = [model(1:pny,:) zeros(pny,mnu-nu)];

if (m > 1)
    k = nu;
    moves=cumsum(moves);
    for i = 2:m
        row0=moves(i-1)*ny;
        Su(row0+1:pny,k+1:k+nu) = model(1:pny-row0,:);
        k = k+nu;
    end;
end;
ki=nu+1; kj=nu; km=mnu-nu;
for j=2:m
    IL(ki:mnu,kj+1:kj+nu)=IL(1:km,1:nu);
    ki=ki+nu;
    kj=kj+nu;
    km=km-nu;
end;

%
% set up GAMMA and LAMBDA matrix
%

GAMMA = zeros(pny);        LAMBDA = zeros(mnu);
k = 0;
for i = 1:p
    j = i;
    if (lyw<i)
        j = lyw;
    end;
    k1 = k + 1;
    k2 = k + ny;
    if i == p & horizon == Inf,
       GAMMA(k1:k2,k1:k2) = 100*diag(max([yweight;zeros(1,ny)]));
    elseif i == p-1 & horizon == Inf,
       Intweight = diag(max(ones(ny,1),100*(1-noutm)));
       GAMMA(k1:k2,k1:k2) = diag(max([yweight;zeros(1,ny)]))*Intweight;
    else
       GAMMA(k1:k2,k1:k2) = diag(yweight(j,:));
    end
    k = k + ny;
end;

k = 0;
for i = 1:m
    j = i;
    if (luw<i)
       j = luw;
    end;
    k1 = k + 1;
    k2 = k + nu;
    LAMBDA(k1:k2,k1:k2) = diag(uweight(j,:));
    k = k + nu;
end;

%
% record upper bound for manipulated variables(s)
%

j = 0;
jj = 0;
nuhighc = 0;
for km = 1:m
    for iu = nu+1:2*nu
        jj = jj+1;
        if (uconstraint(km,iu)~=inf)
            j = j+1;
            Cu(j,:) = -IL(jj,:);
            Cp(j) = -uconstraint(km,iu);
            nuhighc = nuhighc+1;
            iuhighc(nuhighc) = iu-nu;
        end;
    end;
end;
nc1 = j;

%
% record lower bound for manipulated variables
%

jj = 0;
nulowc = 0;
for km = 1:m
    for iu = 1:nu
        jj = jj+1;
        if (uconstraint(km,iu)~=-inf)
            j = j+1;
            Cu(j,:) = IL(jj,:);
            Cp(j) = uconstraint(km,iu);
            nulowc = nulowc+1;
            iulowc(nulowc) = iu;
        end;
    end;
end;

nc2 = j;

%
% record upper bound for output(s)
%

jj = 0;
nyhighc = 0;
for kp = 1:p
    for iy = ny+1:2*ny
        jj = jj+1;
        if (yconstraint(kp,iy)~=inf)
            j = j+1;
            Cu(j,:) = -Su(jj,:);
            Cp(j) = -yconstraint(kp,iy);
            nyhighc = nyhighc+1;
            iyhighc(nyhighc) = jj;
        end;
    end;
end;

nc3 = j;

%
% record lower bound for output(s)
%

jj = 0;
nylowc = 0;
for kp = 1:p
    for iy = 1:ny
        jj = jj+1;
        if (yconstraint(kp,iy)~=-inf)
            j = j+1;
            Cu(j,:) = Su(jj,:);
            Cp(j) = yconstraint(kp,iy);
            nylowc = nylowc+1;
            iylowc(nylowc) = jj;
        end;
    end;
end;

nc4 = j;

%
% set up delU constraint matrix
%

j = 0;
for km = 1:m
    for iu = 2*nu+1:3*nu
        j = j+1;
        BDU(j) = uconstraint(km,iu);
    end;
end;
%
% set up constant matrix for simulation
%

GAMMASu = GAMMA*Su;
Gc = GAMMASu'*GAMMA;
Hu = GAMMASu'*GAMMASu+LAMBDA'*LAMBDA;
svdHu = svd(Hu);
maxsvd = max(svdHu);
minsvd = min(svdHu);
if minsvd < 1e-6,
   Hu = Hu + max(maxsvd,1)/1e8*eye(mnu);
end
%
% set up constant input data for calling DANTZGMP.M --  QP routine.
%

dBinv = inv(Hu);
dC = [eye(mnu); -Cu];
ndr = max(size(dC));
dtab = [-dBinv       dBinv*dC' ;
         dC*dBinv   -dC*dBinv*dC'];
dib = [-[1:mnu+ndr]]';
dil = -dib;
dap = Hu*BDU';
drp1 = 2*BDU';
if isempty(Cu)
   drp2 = [];
else
   drp2 = Cu*BDU';
end

KF = zeros(nmny,ny);
for i = 1:ny
  if (isempty(tfilter)==1)
	  fa(i)=1;
          for j = 1:nm
              KF((j-1)*ny+i,i)=fa(i);
          end;
   else
       if tfilter(i)==0
          fa(i) = 1;
       elseif tfilter(i)==inf
          fa(i) = 0;
       else
          fa(i)=1-exp(-delt/tfilter(i));
          if fa(i) < 0 | fa(i) > 1
             error('Filter time constants must be positive')
          end;
       end;

       for j = 1:nm
           KF((j-1)*ny+i,i)=fa(i);
       end;
   end;
end;

for i=1:ny

  if (isempty(tdist))
     if (noutm(i)==0|noutdm(i)==0)
          alpha(i)=1;
      else
          alpha(i)=0;
      end;
  else
     if tdist(i)==0
           alpha(i)=0;
     elseif tdist(i)==inf
           alpha(i)=1;
     elseif ((noutm(i)==0|noutdm(i)==0) & tdist~=inf)
           disp('WARNING: tdist(i) must equal inf');
           disp('         for integrating outputs.');
           disp('         tdist(i) will be set to inf.');
           alpha(i)=1;
     else
           alpha(i)= exp(-delt/tdist(i));
           if alpha(i) < 0 | alpha(i) > 1
             error('Disturbance time constants must be positive');
           end;
     end;
  end;
  fb(i) = alpha(i)*fa(i)^2/(1+alpha(i)-alpha(i)*fa(i));
end;
KFA = zeros(nmny,ny);
Ad=diag(alpha);
for i=2:nm,
      KFA((i-1)*ny+1:i*ny,1:ny)=KFA((i-2)*ny+1:(i-1)*ny,1:ny) + Ad^(i-2);
end;

KFA(nmny+1:nmny+ny,1:ny)=Ad^(nm-1);
KF(nmny+1:nmny+ny,1:ny)=zeros(ny,ny);

KFB=KFA*diag(fb);
KF = KF + KFB;
hp = noutp.*noutdp-ones(ny,1);
HP = diag(hp);
cm = noutm.*noutdm;
CM = diag(cm);
hm = noutm.*noutdm-ones(ny,1);
HM = diag(hm);
gp = 2*ones(ny,1)-noutp.*noutdp;
GP = diag(gp);
gm = 2*ones(ny,1)-noutm.*noutdm;
GM = diag(gm);

%
% Simulation begins
%

y  = zeros(nfinal+2,ny);
u  = zeros(nfinal+2,nu);
ym = zeros(nfinal+2,ny);

t1 = clock;


E = zeros(pny,1);
Ydiff = zeros(pny,1);

if (isempty(distplant)==1 & isempty(diststep)==0)
    d = diag(diststep(1,:))*ones(ny,np);
    YP = d(:);
    YM = KF(1:nmny,1:ny)*d(:,1);
    y(1,:) = YP(1:ny)';
    ym(1,:) = YM(1:ny)'; 		% time=0;
else
	YP = zeros(npny,1);
	YM = zeros(nmny,1);
end;
Xdist=zeros(ny,1);
if tfinal ~= 0,
   fprintf(' Time remaining %g/%g\n',tfinal,tfinal);
end
setpointblock = setpoint(1:p,:)';
E = setpointblock(:);
Ydiff = YM(ny+1:ny+pny);

if (isempty(distmodel)==0 & isempty(diststep)==0)
    d = diststep(1,:)';
    Ydiff =  Ydiff + distmodel(1:pny,:)*d(:);
end;

E = E-Ydiff;
G = Gc*E;
C = Cp;

i = 0;
for j = nc2+1:nc3
    i = i+1;
    C(j) = Ydiff(iyhighc(i))+C(j);
end;
i = 0;
for j = nc3+1:nc4
    i = i+1;
    C(j) = -Ydiff(iylowc(i))+C(j);
end;

da = G+dap;
dr = [drp1;
    -[C'+drp2]];
dbas = [dBinv*da;
        dr-dC*dBinv*da];

[bas,ib,il,iter,tab] = dantzgmp(dtab,dbas,dib,dil);
if (iter<0)
    error(' The problem has no solution in QP.');
end;

delU = zeros(mnu,1);
for i = 1:mnu
    if(il(i)<=0)
        delU(i) = -BDU(i);
    else
        delU(i) = bas(il(i))-BDU(i);
    end;
end;
Du = delU(1:nu);
u(1,:) = Du';

YPA = plant(1:npny,1:nu)*Du;
YMA = model(1:nmny,1:nu)*Du;

if (isempty(distplant)==1 & isempty(diststep)==0)
    d = diag(diststep(2,:))*ones(ny,np);
    YPA = YPA + d(:);
elseif(isempty(distplant)==0 & isempty(diststep)==0)
    d = diststep(1,:)';
    YPA= YPA + distplant(1:npny,:)*d(:);
	if (isempty(distmodel)==0)
	    YMA = YMA + distmodel(1:nmny,:)*d(:);
    end;
end;

for i = 1:(npny-ny)
    YPA(i) = YP(i+ny) + YPA(i);
end;
YPA(npny-ny+1:npny) = HP*YP(npny-2*ny+1:npny-ny)+GP*YP(npny-ny+1:npny)...
                          +YPA(npny-ny+1:npny);

for i = 1:(nmny-ny)
	 YMA(i) = YM(i+ny)+YMA(i);
end;
YMA(nmny-ny+1:nmny) = HM*YM(nmny-2*ny+1:nmny-ny)+GM*YM(nmny-ny+1:nmny)...
                          +YMA(nmny-ny+1:nmny)+CM*Xdist;
XdistA=Ad*Xdist;

DY = YPA(1:ny)-YMA(1:ny);

YMA = YMA + KF(1:nmny,1:ny)*DY;

XdistA = XdistA + KF(nmny+1:nmny+ny,1:ny)*DY;

YP = YPA;
YM = YMA;
Xdist = XdistA;

y(2,:) = YP(1:ny)';
ym(2,:) = YM(1:ny)';

for k=2:nfinal+1                        % Loop k closed-loop

    if ((fix(k/10)-k/10)==0) & tfinal ~= 0,
       fprintf(' Time remaining %g/%g\n',tfinal-k*delt,tfinal);
    end;

    Ydiff = YM(ny+1:ny+pny);

    setpointblock(:,1:p) = [setpointblock(:,2:p), ...
                                  setpoint(min(ls,p+k-1),:)'];

    E = setpointblock(:);

    if (isempty(distmodel)==0 & isempty(diststep)==0)
       d = diststep(min(k,ld+1),:)';
       Ydiff =  Ydiff + distmodel(1:p*ny,:)*d;
    end;

    E = E-Ydiff;
    G = Gc*E;
    if (length(C)~=0)
        i = 0;
        for j = 1:nc1
            i = i+1;
            C(j) = u(k-1,iuhighc(i))+Cp(j);
        end;
        i = 0;
        for j = nc1+1:nc2
            i = i+1;
            C(j) = Cp(j)-u(k-1,iulowc(i));
        end;
        i = 0;
        for j = nc2+1:nc3
            i = i+1;
            C(j) = Ydiff(iyhighc(i))+Cp(j);
        end;
        i = 0;
        for j = nc3+1:nc4
            i = i+1;
            C(j) = -Ydiff(iylowc(i))+Cp(j);
        end;
    end;

    da = G+dap;
    dr = [drp1;
        -[C'+drp2]];
    dbas = [dBinv*da;
            dr-dC*dBinv*da];

    [bas,ib,il,iter,tab] = dantzgmp(dtab,dbas,dib,dil);
    if (iter<0)
        error('The problem has no solution in QP.');
    end;

    for i = 1:mnu
        if(il(i)<=0)
            delU(i) = -BDU(i);
        else
            delU(i) = bas(il(i))-BDU(i);
        end;
    end;
    Du = delU(1:nu);
    u(k,:) = u(k-1,:)+Du';

    YPA = plant(1:npny,1:nu)*Du;
    YMA = model(1:nmny,1:nu)*Du;

    if (isempty(distplant)==1 & isempty(diststep)==0)
        d = diag(diststep(min(k+1,ld+1),:))*ones(ny,np);
        YPA(1:npny) = YPA(1:npny) + d(:);
    elseif (isempty(distplant)==0 & isempty(diststep)==0)
        d = diststep(min(k,ld+1),:)';
        YPA = YPA + distplant(1:npny,:)*d;
        if (isempty(distmodel)==0)
            YMA = YMA + distmodel(1:nmny,:)*d;
        end;
    end;

    for i=1:(npny-ny)
	   YPA(i) = YP(i+ny)+YPA(i);
    end;
    YPA(npny-ny+1:npny) = HP*YP(npny-2*ny+1:npny-ny)+GP*YP(npny-ny+1:npny)...
                          +YPA(npny-ny+1:npny);

    for i=1:(nmny-ny)
	   YMA(i) = YM(i+ny)+YMA(i);
    end;
    YMA(nmny-ny+1:nmny) = HM*YM(nmny-2*ny+1:nmny-ny)+GM*YM(nmny-ny+1:nmny)...
                          +YMA(nmny-ny+1:nmny)+CM*Xdist;
    XdistA=Ad*Xdist;

    DY = YPA(1:ny) - YMA(1:ny);
    YMA = YMA + KF(1:nmny,1:ny)*DY;

    XdistA = XdistA + KF(nmny+1:nmny+ny,1:ny)*DY;

    y(k+1,1:ny) = YPA(1:ny)';
    ym(k+1,1:ny) = YMA(1:ny)';
    YP = YPA;
    YM = YMA;
    Xdist = XdistA;
end;                                  % Loop k closed-loop

y = y(1:nfinal+1,:);
ym= ym(1:nfinal+1,:);
u = u(1:nfinal+1,:);

if tfinal ~= 0,
   fprintf('Simulation time is %g seconds.\n',etime(clock,t1));
end

% end of function CMPC.M
