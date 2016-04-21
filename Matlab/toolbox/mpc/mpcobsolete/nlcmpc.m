function [sys,x0,str,Ts] = nlcmpc(t,x,sysu,flag,modelpd,mp,tfilter,ryuwt,ud0,yulim);

%
%NLCMPC S-function for SIMULINK block nlcmpc.

% Usage: [sys,x0,str,Ts] = nlcmpc(t,x,sysu,flag,modelpd,mp,tfilter,ryuwt,ud0,yuwt);
%
% Masked inputs (required):
%   modelpd:  Step response model in MPC Step Format for the plant and measured disturbances.
%   ryuwt: =[r ywt uwt]. r is a constant or time-varying reference trajectory.
%      	   ywt and uwt are  matrices of constant or time-varying output and input weights
%   mp:  number of control moves and output (prediction) horizon length.
%   yulim: =[ylim ulim]. ulim is a matrix of manipulated variable constraints.
%      		ylim is a matrix of output variable constraints.
%   tfilter:  time constants for noise filter and unmeasured disturbance lags.
%             Default is no filtering and step disturbance.
%   ud0:  initial conditions for controlled variables and measured disturbances

%       Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

%
%  Determine system size
%    nu: number of inputs to the plant (= outputs from the MPC controller)
%    ny: number of outputs from the plant
%    nd: number of measured disturbances
%
global MPCfname    % Holds name of file for temporary data storage.

sys=[]; x0=[]; str=[]; Ts=[];  % Initialize outputs

[nrow,nund] = size(modelpd);
m = mp(1:max(size(mp))-1);
p = mp(max(size(mp)));
ny = modelpd(nrow-1,1);
nd = 0;
for i = 2:nund,
   if modelpd(nrow-1,i) ~= 0 & modelpd(nrow-1,i) == ny,
      nd = nund-i+1;
   elseif modelpd(nrow-1,i) ~= 0 & modelpd(nrow-1,i) ~= ny,
      error('Number of outputs for model and dmodel must be the same')
      return
   end
end
nu = nund - nd;
model = modelpd(:,1:nu);
dmodel = modelpd(:,nu+1:nund);
tsamp = model(nrow,1);
if isempty(ud0),
   ud0 = zeros(1,nund);
end

if isempty(yulim),
   ylim = [];
   ulim = [];
else
   ylim = yulim(:,1:2*ny);
   ulim = yulim(:,2*ny+1:2*ny+3*nu);
end

if isempty(ryuwt),
   r = zeros(1,ny);
   ywt = ones(1,ny);
   uwt = zeros(1,nu);
else
   r = ryuwt(:,1:ny);
   ywt = ryuwt(:,ny+1:2*ny);
   uwt = ryuwt(:,2*ny+1:2*ny+nu);
end

if flag == 0,
   sys = [0 nu nu ny+nd 0 1 1];
   x0 = ud0(1:nu);
   Ts=[tsamp 0];
   MPCfname=tempname;

elseif flag == 3,	%  The outputs are equal to the states.
   sys = x;

elseif flag == 2,
   sys = x;		%  If not at sampling time, states (therefore outputs) are not changed.
   yp = sysu;	        %  Get the current measurement.

   if t == 0,
%
%  Initialize ym -- predicted outputs due to inputs and filtering.
%	 ym = [y1 y2 ... yny] has dimension Pnstep * ny.
%
      y0 = sysu(1:ny)';
      nstep = (nrow - ny -2)/ny;	% number of SR coefficients
      Pnstep = max(p,nstep);
      ym = y0;
      for i = 2:Pnstep,
         ym = [ym;y0];
      end
      ymd = zeros(Pnstep,ny);
      Xd = zeros(ny,1);
%
%  Initialize ymd -- predicted outputs due to measured disturbances.
%        ymd has the same structure as ym
%
      ymd = zeros(Pnstep,ny);
      dist = sysu(ny+1:ny+nd) - ud0(nu+1:nu+nd)';
%
%   Call mpcsim to determine KF and check everything for consistency.
%
      Kmpc = mpccon(model,ywt,uwt,m,p);
      [dummy1,dummy2,dummy3,KF] = mpcsim(model,model,Kmpc,0,r,[],tfilter,dmodel,dmodel,[]);
      [rKF,cKF] = size(KF);
      if rKF == Pnstep*ny,
         KF(ny*Pnstep+1:ny*(Pnstep+1),:) = zeros(ny);
      end
%
%  determine Ad (See the paper by Lee and Morari, 1993)
%
      Ad = zeros(ny);
      [nrf,ncf] = size(tfilter);
      if nrf <= 1,
         for i = 1:ny,
            if (model(nrow-ny-1+i)==0)
               Ad(i,i)=1;
            else
               Ad(i,i)=0;
            end;
         end
      else
         for i = 1:ny,
             if tfilter(2,i)==0
                Ad(i,i)=0;
             else
                Ad(i,i)= exp(-tsamp/tfilter(2,i));
             end
         end
      end
      Xd = zeros(ny,1);
      k = 0;
      save(MPCfname,'ym','ymd','k','KF','Ad','Xd','dist');  % Save these variables for later use.
   end

   load(MPCfname);

%
%  Set up dSu and dSud
%     If output i is integrating, then dSu(i,i) = 1; otherwise, dSu(i,i) = 0.
%     Same for dSud
%
   dSu = diag(1-model(nrow-ny-1:nrow-2,1));
   if nd ~= 0,
      dSud = diag(1-dmodel(nrow-ny-1:nrow-2,1));
   end
   nstep = (nrow - ny -2)/ny;
   Pnstep = max([p nstep]);
   Su = model(1:nrow-ny-2,:);	%  Step response coefficients
   if Pnstep > nstep,		%  Extend SR for plant model.
      Diffmod = model(nrow-2*ny-1:nrow-ny-2,:)-model(nrow-3*ny-1:nrow-2*ny-2,:);
      for i =1:Pnstep-nstep,
         Su = [Su;model(nrow-2*ny-1:nrow-ny-2,:)+i*dSu*Diffmod];
      end
   end
   if nd ~= 0,
      Sud = dmodel(1:nrow-ny-2,:);	%  Step response coefficients
      if Pnstep > nstep,		%  Extend SR for disturbance model
         Diffmod = dmodel(nrow-2*ny-1:nrow-ny-2,:)-dmodel(nrow-3*ny-1:nrow-2*ny-2,:);
         for i = 1:Pnstep-nstep,
            Sud = [Sud;dmodel(nrow-2*ny-1:nrow-ny-2,:)+i*dSud*Diffmod];
         end
      end
%
%  Calculate outputs due to measured disturbances
%
      distprev = dist;		%  Disturbance at previous sampling time
      dist = yp(ny+1:ny+nd)-ud0(nu+1:nu+nd)';	%  Disturbance at current sampling time
      ymd = [ymd(2:Pnstep,:); ymd(Pnstep,:)];
      ymd(Pnstep,:) = ymd(Pnstep,:) + (ymd(Pnstep,:) - ymd(Pnstep-1,:))*dSud;
      ymd = ymd + reshape(Sud*(dist-distprev),ny,Pnstep)';
   end
%
%  Update ym and Xd based on the current measurement, yp.
%
   yerror = yp(1:ny) - ym(1,:)' - ymd(1,:)';
   ym = ym + reshape(KF(1:ny*Pnstep,:)*yerror,ny,Pnstep)';
   ym = [ym(2:Pnstep,:); ym(Pnstep,:)+(ym(Pnstep,:)-ym(Pnstep-1,:))*dSu + Xd'];
   Xd = Ad*(Xd + KF(ny*Pnstep+1:ny*(Pnstep+1),:) * yerror);
%
%  Create actual reference trajectory, r1, at sampling time k
%
   if isempty(r),
      r = zeros(1,ny);
   end
   [N,ncolr]=size(r);
   if N > Pnstep+k,
      r1 = r(k+1:Pnstep+k,:);
   elseif N < k+2,
      r1 = r(N,:);
      for i = 1:Pnstep-1,
         r1 = [r1;r(N,:)];
      end
   else
	  r1 = r(k+1:N,:);
   	  for i = 1:Pnstep-N+k,
         r1 = [r1;r(N,:)];
      end
   end
%
%  Calculate fake reference trajectory, rf = r1 - ym.
%     Idea:  r(k+1) - y(k+1|k) = r(k+1) - M * y(k|k) - S delu
%		 = r1 - ym - S delu = rf - S delu.
%
   rf = r1 - ym - ymd;
%
%  Check ulim and ylim.
%
   if isempty(ulim),
      ulim = [-inf*ones(1,nu) inf*ones(1,nu) 1e6*ones(1,nu)];
   end
   if isempty(ylim),
      ylim = [-inf*ones(1,ny) inf*ones(1,ny)];
   end
%
%  Recompute the limits on the manipulated variables.
%  ulim = [umin1(1) ... uminnu(1) umax1(1) ... umaxnu(1) dumax1(1) ... dumaxnu(1)]
%	   		...			...		...
%	  [umin1(N) ... uminnu(N) umax1(N) ... umaxnu(N) dumax1(N) ... dumaxnu(N)]
%
   [N,ncolusat] = size(ulim);
   ulim1 = zeros(N,3*nu);
   ulim1(:,2*nu+1:3*nu) = ulim(:,2*nu+1:3*nu);
   for i = 1:nu,
   	  ulim1(:,i) = ulim(:,i) - sys(i);
	  ulim1(:,nu+i) = ulim(:,nu+i) - sys(i);
   end
%
%  Recompute the limits on the controlled variables.
%  ylim = [ymin_1(k+1) ... ymin_ny(k+1) ymax_1(k+1) ... ymax_ny(k+1)]
% 			...		...		...
%  	  [ymin_1(k+N) ... ymin_ny(k+N) ymax_1(k+N) ... ymax_ny(k+N)]
%
   [N,ncolylim] = size(ylim);
   if N >= Pnstep,
	  ylim = ylim(1:Pnstep,:);
   else
 	  for i = N+1:Pnstep,
	     ylim = [ylim; ylim(N,:)];
      end
   end
   ylim1 = ylim - [ym ym];
%
%  Determine the optimal control moves.
%
   [ydummy,delu] = cmpc(model,model,ywt,uwt,m,p,0,rf,ulim1,ylim1);
%
%  Update ym based on delu.   At this instant, ym = y(k+1|k).
%
   ym = ym + reshape(Su*delu',ny,Pnstep)';
   sys = x+delu';
   k = k+1;
   save(MPCfname,'ym','ymd','Xd','k','KF','Ad','dist');

end
%
%  End of function nlcmpc.
%
