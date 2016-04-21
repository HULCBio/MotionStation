function [mu,am,bm,cm,dm,as,bs,cs,ds]=fixmult(varargin)
% FIXMULT LMI/Multiplier Mu analysis.
%
% [mu,sysm,syss] = fixmult(sys1,k,n) or
% [mu,am,bm,cm,dm,as,bs,cs,ds]=fixmult(a,b,c,d,k,n)
% computes a scalar upper bound MU on the real/complex structured singular
% value of G(s) := [A,B,C,D] and a corresponding fixed-order optimal
% diagonal multiplier M(s) .  The multiplier MU bound is computed by solving:
%
%        min MU
%         Mi
%            s.t. hinfnorm(G(s)) <= 1 where
%        G(s) := blt( M(s) * blt( G(s)/MU ))
%        M(s) := diag(M1(s)*I, ... , Mn(s)*I).
% blt(X) = (I-X)/(I+X) and Mi(s) (for i=1,...,n) is constrained to be
% proper, rational, and have denominator DEN (default 1) with real(M(jw))>=0.
%
% This function uses LMI lab to compute a multiplier using LMI
% formulation of Ly, Safonov and Chiang ACC '94.
%
% INPUTS :
%  [A,B,C,D], or SYS --- state space of G(s)
% OPTIONAL INPUTS :
%  k --- n rows of k specify uncertainty structure as follows:
%       k(i,1) --- -1 for real, 1 for complex.
%       k(i,2) --- size of i-th uncertainty. (square block)
%       k(i,3) --- repeated block
%  n --- degree of i-th multiplier, has to be a EVEN no.
%
%   Note : the following structured uncertainties are allowed:
%           real scalar, repeated real scalar`
%           complex scalar, repeated complex scalar
%           complex full block
%
% OUTPUTS :
%  MU --- scalar structured singular value of G(s)
%  [AM,BM,CM,DM] state space of multiplier M(s) := diag(M1(s)*I,...,Mn(s)*I)
%  [AS,BS,CS,DS] state space of optimal "scaled system"
%
% Author : J. H. Ly   5/95
% Updated by R. Y. Chiang 2/96

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.

%----------------------------------------------------------------
%   Checking for the validity of the uncertainty structure

ngin = nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,k,n]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

% -----------------------------------------------

[rowk,colk]=size(k);

if colk == 1
   k = [k abs(k) abs(k)];
end

for i = 1:rowk
        if k(i,1) == -1 & k(i,2) > 1,
            error('No full real Delta is allowed')
        end
        if k(i,1) == 1 & k(i,2) > 1 & k(i,3) > 1,
            error('Repeated complex blocks not implemented')
        end
end
%----------------------------------------------------------------
%   Selecting MU upper bound and lower bound
%

hnorm = normhinf(a,b,c,d);
km_lb = 1/hnorm;                         %km = 1/mu
km = km_lb;
km_ub = [];
stopflag = 1;

%
%

% finding ordre of G(s)
[ot,ot]=size(a);        % order of T(s)
n_chnls = sum(k(:,2).*k(:,3));            % total number of chnls
o_m = n*n_chnls;        % order of M(s)
s_p = ot+o_m;           % order of M(s)T(s)


% creating LMIS

%lmisys = newlmi([],[s_p,n_chnls],s_p+n_chnls);
%lmisys = newlmi(lmisys,[o_m,n_chnls],n_chnls+o_m);

setlmis([])

% creating variables

lmivar(1,[s_p,1]);   % P
[rowk,colk]=size(k);
pmdim = [n*k(:,2).*k(:,3), ones(rowk,1)];
lmivar(1,pmdim);    % Pm
lmisys = getlmis;

% setting up multiplier structure
de=1;
for jj=1:n/2
    de = conv(de,[1 0 -1]);
end

%
% default am bm for full real and complex uncertainty
%
ac = [ -de(1,2:n+1)
        eye(n-1) zeros(n-1,1)];
bc = [1;zeros(n-1,1)];

am = []; bm=[];
wcm =[];  wdm =[];

nn=decnbr(lmisys);

[rowk,colk] = size(k);
for i = 1:rowk,
    if (k(i,1) == -1) & (k(i,3) == 1)     % real
       tempv = 1:n;
       tempc = nn+tempv;
       tempd = nn+n+1;
       nn = nn + n+1;
       for j = 1:k(i,2),
           am = diagmx(am,ac);
           bm = diagmx(bm,bc);
           wcm = diagmx(wcm,tempc);
           wdm = diagmx(wdm,tempd);
       end
    end

    if (k(i,1) == -1) & (k(i,3) > 1)     % real and repeated delta
       tvc = 1:k(i,3)^2*n;
       tvd = k(i,3)^2*n+1:k(i,3)^2*(n+1);
       tempc =[];tempd=[];
       for j= 0:k(i,3)-1
           tempc =[tempc; tvc(j*n*k(i,3)+1:(j+1)*n*k(i,3))+nn];
           tempd = [tempd;tvd(j*k(i,3)+1:(j+1)*k(i,3))+nn];
       end
       amt = [];
       for jj=1:n/2
           amt=[amt zeros(k(i,3),k(i,3)) -de(1,2*jj+1)*eye(k(i,3))];
       end
       am = diagmx(am,[amt;eye((n-1)*k(i,3))...
                                   zeros((n-1)*k(i,3),k(i,3))]);
       bm = diagmx(bm,[eye(k(i,3));zeros((n-1)*k(i,3),k(i,3))]);
       wcm = diagmx(wcm,tempc);
       wdm = diagmx(wdm,tempd);
       [rtvd,ctvd]=size(tvd);
       nn = nn+tvd(1,ctvd);
    end

    if (k(i,1) == 1) & ( k(i,3) == 1)    % complex and full delta
       tempc = zeros(1,n);
       for j=1:n/2
           tempc(1,2*j) = j + nn;
       end
       tempd = nn + j+1;
       nn = nn+ j+1;
       for j = 1:k(i,2),
           am = diagmx(am,ac);
           bm = diagmx(bm,bc);
           wcm = diagmx(wcm,tempc);
           wdm = diagmx(wdm,tempd);
       end
    end

    if (k(i,1) == 1) & ( k(i,3)>  1)    % complex repeated scalar
       tc = zeros(k(i,3),k(i,3));
       tempc = [];
       for kk=1:n/2+1
           for jj=1:k(i,3)
               for j = 1:jj
                   nn=nn+1;
                   tc(j,jj) = nn;
                   tc(jj,j) = nn;
               end
           end
           if kk < n/2+1
              tempc = [tempc tc*0 tc];
           else
              tempd = tc;
           end
       end
       amt = [];
       for jj=1:n/2
           amt=[amt zeros(k(i,3),k(i,3)) -de(1,2*jj+1)*eye(k(i,3))];
       end
       am = diagmx(am,[amt;eye((n-1)*k(i,3))...
                                 zeros((n-1)*k(i,3),k(i,3))]);
       bm = diagmx(bm,[eye(k(i,3));zeros((n-1)*k(i,3),k(i,3))]);
       wcm = diagmx(wcm,tempc);
       wdm = diagmx(wdm,tempd);
    end
end
[rwcm,cwcm]=size(wcm);
cm_til = [ eye(cwcm);
           zeros(rwcm,cwcm)];
dm_til = [ zeros(cwcm,rwcm);
           eye(rwcm)];
%
% multiplier structure complete ...........
%
%   Note    M(s) = [I   0    0    [ am        bm
%                   0   wcm  wdm ]  cm_til    dm_til];
%
%                                        M_til

% creating wcm wdm variables

setlmis(lmisys)
lmivar(3,[wcm wdm]);
lmisys = getlmis;

%
%----------------------------------------------------------------
%

while stopflag
  if size(km_ub) == 0,
        km = 2*km
  else
        km = (km_ub + km_lb)/2
  end;

%---------------------------------------------------------------------
  ckm = km*c;  dkm = km*d;
%
%  sector transformation sector [-1,1] -> [0,inf]
%
  [rd,cd] = size(d);
  invd = inv(eye(rd)+dkm);
  at = a-b*invd*ckm;
  bt = b*invd;
  ct = 2*dkm*invd*ckm - 2*ckm;
  dt = eye(rd)-2*dkm*invd;
%           [at,bt,ct,dt] = sectf(a,b,ckm,dkm,[-1,1],[0,inf])
  eit = eig(at);
  ei_unstable = find(real(eit)>=0)
%---------------------------------------------------------------------
  if isempty(ei_unstable)        % sect(G(s)) is stable

%
%  setting up  M_t*sect(G(s))
%
      atil = [am bm*ct
              zeros(ot,cwcm), at];
      btil = [bm*dt
               bt];
      ctil = [ cm_til dm_til*ct];

      dtil = dm_til*dt;

%     LMI for M(s)T(s)
%
      setlmis(lmisys);

      lmiterm([-1 1 1 1],1,atil,'s');
      lmiterm([-1 2 1 3],1,ctil);
      lmiterm([-1 2 1 1],btil',1);
      lmiterm([-1 2 2 3],1,dtil,'s');

%     LMI for M(s)
%

      lmiterm([-2 1 1 2],1,am,'s');
      lmiterm([-2 2 1 3],1,cm_til);
      lmiterm([-2 2 1 2],bm',1);
      lmiterm([-2 2 2 3],1,dm_til,'s');

      lmisys = getlmis;

%
%
      target = -1e-7;
      [tmin,xfeas] = feasp(lmisys,[0 50,0,5,0],target);

      if tmin < 0,
          w = dec2mat(lmisys,xfeas,3);
          PP= dec2mat(lmisys,xfeas,1);
          Pm = dec2mat(lmisys,xfeas,2);
          cm = w(:,1:cwcm);
          dm = w(:,cwcm+1:cwcm+rwcm);
          km_lb = km;
      else
          km_ub = km;
      end
  else
     km_ub = km;
  end

% 2% or less diff between upper and lower bound, then stop
  if abs((km_ub - km_lb)/km_ub) < 0.002,

	stopflag = 0;
  end


end                 % while {gamma iteration}

%---------------------------------------------------------------------
% output data
%
mu = 1/km;

%
%  setting up  M(s)*sect(G(s))
%
bas = [am bm*ct
       zeros(ot,cwcm), at];

bbs = [bm*dt
        bt];

bcs = [ cm dm*ct];

bds  = dm*dt;

%
%  sector transformation sector [0,inf] -> [-1,1]
%
[rd,cd] = size(bds);
invd = inv(eye(rd)+bds);
as = bas-bbs*invd*bcs;
bs = bbs*invd;
cs = 2*bds*invd*bcs - 2*bcs;
ds = eye(rd)-2*bds*invd;
%           [as,bs,cs,ds]=sectf(bas,bbs,bcs,bds,[0,inf],[-1,1]);

% ----------------------------------------

if xsflag
   am = mksys(am,bm,cm,dm);
   bm = mksys(as,bs,cs,ds);
end

disp(' ')
disp(['Mu = ' num2str(mu) '. This is the best answer under order ' num2str(n) ' multiplier.']);
% ----------------------------------------

%%-------  END OF fixmult.M ----   JLY  11/94 %  