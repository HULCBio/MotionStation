% [gopt,h2opt,K,R,S] = hinfmix(P,r,obj,region,dkbnd,tol)
%
% Mixed H2/H-infinity synthesis with regional pole placement
% constraints.
%
% Given an LTI plant P with state-space equations:
%	 dx/dt = A  * x + B1  * w + B2  * u
%	  zinf = Ci * x + Di1 * w + Di2 * u
%	   z2  = C2 * x + D21 * w + D22 * u
%           y  = Cy * x + Dy1 * w + Dy2 * u
% HINFMIX computes an output-feedback control u = K(s)*y
% that
%  * keeps the RMS gain G from w to zinf below the value OBJ(1)
%  * keeps the H2-norm  H from w to z2 below the value OBJ(2)
%  * minimizes a trade-off criterion of the form
%              OBJ(3) * G^2 + OBJ(4) * H^2
%  * places the closed-loop poles in the LMI region specified
%    by REGION.
%
% Input:
%  P        LTI plant
%  R        1x3 vector listing the lengths of z2, y, and u
%  OBJ      4-entry vector specifying the H2/Hinf objective:
%           OBJ(1)  : upper bound on the RMS gain w->zinf (0=none)
%           OBJ(2)  : upper bound on the H2 norm  w->z2   (0=none)
%           OBJ(3:4): relative weighting of the H-infinity and
%                     H2 performances (see above)
%  REGION   optional.  Mx(2M) matrix  [L,M]  specifying the pole
%           placement region as
%                { z :  L + z * M + conj(z) * M' < 0 }
%           Use the interactive function  LMIREG  to generate
%           REGION.  The default  REGION=[]  enforces just
%           closed-loop stability
%  DKBND    optional: bound on the norm of the static gain DK of K(s)
%           (100=default, 0 yields a strictly proper controller)
%  TOL      optional: desired relative accuracy on the objective
%           value  (default=1e-2)
%
% Output:
%  GOPT     guaranteed closed-loop RMS gain from w to zinf
%  H2OPT    guaranteed closed-loop  H2 norm from w to z2
%  K        optimal output-feedback controller
%  R,S      solutions of the LMI solvability conditions
%
%
% See also  LMIREG, HINFLMI, MSFSYN.

% Authors: M. Chilali and P. Gahinet  10/94 revised 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [gopt,h2opt,K,R,S] = hinfmix(G,sysdim,obj,region,dkbnd,tol)

if nargin <3,
  error('usage: [gopt,h2opt,K,R,S] = hinfmix(G,sysdim,obj,region)');
elseif ~islsys(G),
  error('G is not an LTI system');
elseif length(sysdim)~=3,
  error('R must be a 3-entry vector');
elseif min(size(obj))~=1 | max(size(obj))~=4 | any(obj < 0),
  error('OBJ must be a 4-entry vector of positive real numbers');
elseif nargin<4,
  region=[]; tol=1e-2; dkbnd=100;
elseif nargin<5,
  tol=1e-2; dkbnd=100;
elseif nargin<6,
  tol=1e-2;
end
if isempty(dkbnd), dkbnd=100; end

%%% v5 code
macheps = [];

% init
R=[]; S=[]; gopt=[]; h2opt=[]; K=[];
g0=obj(1); nu0=obj(2); penalty=max([g0,nu0,1])*1e-8;
hic=(g0~=0);  hioptim=(obj(3)~=0);  hinf=hic | hioptim;
h2c=(nu0~=0); h2optim=(obj(4)~=0);  h2=h2c | h2optim;
polp=~isempty(region);
if hioptim, sclf=1+9*h2; else sclf=max(1,g0); end
if ~hic, g0=1000; end
gam0=g0^(1+h2);


% retrieve data
[n,ni,no]=sinfo(G);
p2=sysdim(1); p3=sysdim(2); m2=sysdim(3);
p1=no-(p2+p3); m1=ni-m2;
if p2+p3 > no,
  error('zinf has negative length according to R');
elseif m2 >= ni,
  error('Input w is empty according to R(3)');
elseif hinf & ~p1,
   error('D11 must be nonempty for Hinf optimization');
elseif h2 & ~p2,
   error('D22 must be nonempty for H2 optimization');
end
[a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(G,[p2+p3 m2]);
c3=c2(p2+1:p2+p3,:); d31=d21(p2+1:p2+p3,:); d32=d22(p2+1:p2+p3,:);
c2=c2(1:p2,:); d21=d21(1:p2,:); d22=d22(1:p2,:);



%%%%%%%%%%%   SPECIFY THE LMI SYSTEM  %%%%%%%%%%%%%%%

setlmis([]);


%% Variables:
%%%%%%%%%%%%
if hioptim, gam=lmivar(1,[1 0]); end         % gamma or gamma^2
if h2, [Q,xxx,Qdec]=lmivar(1,[p2 1]); end    % Q
R=lmivar(1,[n 1]);                           % R
S=lmivar(1,[n 1]);                           % S
if polp, Ak=lmivar(2,[n n]); end             % Ak
Bk=lmivar(2,[n p3]);                         % Bk
[Ck,ndec]=lmivar(2,[m2 n]);                  % Ck

% take the constraint Dcl2=0 into account when defining the Dk variable
if h2c | h2optim,
  macheps=mach_eps;    mach12=sqrt(macheps);
  [u1,sl,v1,rkl,u2,v2]=svdparts(d22,0,mach12);
  [w1,sr,z1,rkr,w2,z2]=svdparts(d31,0,mach12);
  projl=u2'*d21; projr=d21*z2; n21=norm(d21);
  if any(any(abs(projl)>1e3*macheps*n21)) | ...
     any(any(abs(projr)>1e3*macheps*n21)),
    error('The closed-loop H2 norm is always infinite');
  end
  vdk=[v1,v2]; wdk=[w1,w2];
  if isempty(sl) | isempty(sr),
    dk0=zeros(m2,p3);
  else
    dk0=-v1*diag(1./sl)*u1'*d21*z1*diag(1./sr)*w1';
  end

  % reparametrize dk
  rw1=size(v1,2); rw2=size(v2,2); cl1=size(w1,2); cl2=size(w2,2);
  aux=rw1*cl2; dk12=reshape(ndec+1:ndec+aux,rw1,cl2); ndec=ndec+aux;
  aux=rw2*cl1; dk21=reshape(ndec+1:ndec+aux,rw2,cl1); ndec=ndec+aux;
  aux=rw2*cl2; dk22=reshape(ndec+1:ndec+aux,rw2,cl2);
  struct=[zeros(rw1,cl1) dk12;dk21 dk22];
  isdk=(dkbnd > 0 & any(any(struct)));
  if isdk, Dk=lmivar(3,struct);  end
else
  vdk=1; wdk=1; dk0=zeros(m2,p3);
  isdk=(dkbnd > 0);
  if isdk, Dk=lmivar(2,[m2 p3]); end
end



%%% Hinf/H2 LMI
%%%%%%%%%%%%%%%

if polp & (h2 | hinf),   % pole placement constraint -> LMIs involve Ak

  h2hi=newlmi;
  lmiterm([h2hi 1 1 R],a,1,'s');
  lmiterm([h2hi 1 1 Ck],b2,1,'s');
  lmiterm([h2hi 2 1 0],(a+b2*dk0*c3)');
  lmiterm([h2hi 2 1 Ak],1,1);
  if isdk, lmiterm([h2hi 2 1 -Dk],c3'*wdk,vdk'*b2'); end
  lmiterm([h2hi 2 2 S],1,a,'s');
  lmiterm([h2hi 2 2 Bk],1,c3,'s');
  lmiterm([h2hi 1 3 0],sclf*(b1+b2*dk0*d31));
  if isdk, lmiterm([h2hi 1 3 Dk],sclf*b2*vdk,wdk'*d31); end
  lmiterm([h2hi 2 3 S],sclf,b1);
  lmiterm([h2hi 2 3 Bk],sclf,d31);
  if h2,
    lmiterm([h2hi 3 3 0],-sclf^2);
  elseif hioptim,
    lmiterm([h2hi 3 3 gam],-1,1);
  else
    lmiterm([h2hi 3 3 0],-gam0);
  end
  if hinf,
    lmiterm([h2hi 4 1 R],c1,1);
    lmiterm([h2hi 4 1 Ck],d12,1);
    lmiterm([h2hi 4 2 0],c1+d12*dk0*c3);
    lmiterm([h2hi 4 3 0],sclf*(d11+d12*dk0*d31));
    if isdk,
      lmiterm([h2hi 4 2 Dk],d12*vdk,wdk'*c3);
      lmiterm([h2hi 4 3 Dk],sclf*d12*vdk,wdk'*d31);
    end
  end
  if hioptim,
    lmiterm([h2hi 4 4 gam],-1,1);
  elseif hic,
    lmiterm([h2hi 4 4 0],-gam0);
  end

elseif h2 | hinf,   % no pole clustering -> separate LMIs

  Rlmi=newlmi;
  lmiterm([Rlmi 1 1 R],a,1,'s');
  lmiterm([Rlmi 1 1 Ck],b2,1,'s');
  lmiterm([Rlmi 1 2 0],sclf*(b1+b2*dk0*d31));
  if isdk, lmiterm([Rlmi 1 2 Dk],sclf*b2*vdk,wdk'*d31); end
  if h2,
    lmiterm([Rlmi 2 2 0],-sclf^2);
  elseif hioptim,
    lmiterm([Rlmi 2 2 gam],-1,1);
  else
    lmiterm([Rlmi 2 2 0],-gam0);
  end
  if hinf,
    lmiterm([Rlmi 3 1 R],c1,1);
    lmiterm([Rlmi 3 1 Ck],d12,1);
    lmiterm([Rlmi 3 2 0],sclf*(d11+d12*dk0*d31));
    if isdk,
      lmiterm([Rlmi 3 2 Dk],sclf*d12*vdk,wdk'*d31);
    end
  end
  if hioptim,
    lmiterm([Rlmi 3 3 gam],-1,1);
  elseif hic,
    lmiterm([Rlmi 3 3 0],-gam0);
  end


  Slmi=newlmi;
  lmiterm([Slmi 1 1 S],1,a,'s');
  lmiterm([Slmi 1 1 Bk],1,c3,'s');
  lmiterm([Slmi 1 2 S],sclf,b1);
  lmiterm([Slmi 1 2 Bk],sclf,d31);
  if h2,
    lmiterm([Slmi 2 2 0],-sclf^2);
  elseif hioptim,
    lmiterm([Slmi 2 2 gam],-1,1);
  else
    lmiterm([Slmi 2 2 0],-gam0);
  end
  if hinf,
    lmiterm([Slmi 3 1 0],c1+d12*dk0*c3);
    lmiterm([Slmi 3 2 0],sclf*(d11+d12*dk0*d31));
    if isdk,
      lmiterm([Slmi 3 1 Dk],d12*vdk,wdk'*c3);
      lmiterm([Slmi 3 2 Dk],sclf*d12*vdk,wdk'*d31);
    end
  end
  if hioptim,
    lmiterm([Slmi 3 3 gam],-1,1);
  elseif hic,
    lmiterm([Slmi 3 3 0],-gam0);
  end

end



% Xcl > 0 :
%%%%%%%%%%%
if h2,
  h2lmi=-newlmi;
  lmiterm([h2lmi 1 1 Q],1,1);
  lmiterm([h2lmi 2 1 R],1,c2');
  lmiterm([h2lmi 2 1 -Ck],1,d22');
  lmiterm([h2lmi 2 2 R],1,1);
  lmiterm([h2lmi 3 1 0],(c2+d22*dk0*c3)');
  if isdk, lmiterm([h2lmi 3 1 -Dk],c3'*wdk,vdk'*d22'); end
  lmiterm([h2lmi 3 2 0],1);
  lmiterm([h2lmi 3 3 S],1,1);
else
  posX=-newlmi;
  lmiterm([posX 1 1 R],1,1);
  lmiterm([posX 2 1 0],1);
  lmiterm([posX 2 2 S],1,1);
end


% pole placement LMIs
[rr,rc]=size(region);
if rc~=2*rr, error('REGION must be a Mx(2M) matrix'); end
r1=0;

while r1<rr,  % scan each region (L,M) (diagonal blocks)
  bs=round(imag(region(r1+1,r1+1)));
  if ~bs, bs=rr-r1; end
  L=real(region(r1+1:r1+bs,r1+1:r1+bs));
  M=region(r1+1:r1+bs,rr+r1+1:rr+r1+bs);
  pole=newlmi;  % pole placement in the region (L,M)

  for i=1:bs,
    nbi=2*i-1;   % row of block in target LMI

    % off-diagonal 2x2  block
    for j=1:i-1,
      nbj=2*j-1; % col of block in target LMI
      lmiterm([pole,nbi,nbj,R],L(i,j),1);          % lij R
      lmiterm([pole,nbi,nbj,R],a,M(i,j));          % mij AR
      lmiterm([pole,nbi,nbj,R],M(j,i),a');         % mji RA'
      lmiterm([pole,nbi,nbj,Ck],b2,M(i,j));        % mij B2Ck
      lmiterm([pole,nbi,nbj,-Ck],M(j,i),b2');      % mji Ck'B2'

      lmiterm([pole,nbi+1,nbj+1,S],L(i,j),1);      % lij S
      lmiterm([pole,nbi+1,nbj+1,S],M(i,j),a);      % mij SA
      lmiterm([pole,nbi+1,nbj+1,S],a',M(j,i));     % mji A'S
      lmiterm([pole,nbi+1,nbj+1,Bk],M(i,j),c3);    % mij BkC3
      lmiterm([pole,nbi+1,nbj+1,-Bk],c3',M(j,i));  % mji C3'Bk'

      lmiterm([pole,nbi+1,nbj,0],L(i,j));          % lij I
      lmiterm([pole,nbi+1,nbj,Ak],M(i,j),1);       % mij Ak
      lmiterm([pole,nbi+1,nbj,0],M(j,i)*(a+b2*dk0*c3)');   % mji A'

      lmiterm([pole,nbi,nbj+1,0],L(i,j));          % lij I
      lmiterm([pole,nbi,nbj+1,-Ak],M(j,i),1);      % mji Ak'
      lmiterm([pole,nbi,nbj+1,0],M(i,j)*(a+b2*dk0*c3));    % mij A
      if isdk,
        lmiterm([pole,nbi+1,nbj,-Dk],M(j,i)*c3'*wdk,vdk'*b2'); % mji C3'Dk'B2'
        lmiterm([pole,nbi,nbj+1,Dk],M(i,j)*b2*vdk,wdk'*c3);    % mij B2DkC3
      end
    end

    % diagonal 2x2  block
    lmiterm([pole,nbi,nbi,R],L(i,i),1);          % lii R
    lmiterm([pole,nbi,nbi,R],a,M(i,i),'s');      % mii (AR+RA')
    lmiterm([pole,nbi,nbi,Ck],b2,M(i,i),'s');    % mii (B2Ck+..)
    lmiterm([pole,nbi+1,nbi+1,S],L(i,i),1);      % lii S
    lmiterm([pole,nbi+1,nbi+1,S],M(i,i),a,'s');  % mii (A'S+SA)
    lmiterm([pole,nbi+1,nbi+1,Bk],M(i,i),c3,'s');% mii (BkC3+...)
    lmiterm([pole,nbi+1,nbi,0],L(i,i));          % lii I
    lmiterm([pole,nbi+1,nbi,Ak],M(i,i),1);       % mii Ak
    lmiterm([pole,nbi+1,nbi,0],M(i,i)*(a+b2*dk0*c3)');  % mii A'

    if isdk,
       lmiterm([pole,nbi,nbi+1,Dk],M(i,i)*b2*vdk,wdk'*c3); % mii B2DkC3
    end
  end

  r1=r1+bs;
end  % while


% bound on Dk
if isdk,
  lmidk=-newlmi;
  lmiterm([lmidk 1 1 0],dkbnd);
  lmiterm([lmidk 2 2 0],dkbnd);
  lmiterm([lmidk 2 1 Dk],1,1);
end


% Additional hard constraints: g<g0 and Trace(Q)<nu0^2
if hioptim,
   lmig=newlmi;
   sclf=max(1,gam0/1e3);
   lmiterm([lmig,1,1,gam],1,1/sclf);
   lmiterm([lmig,1,1,0],-gam0/sclf);
end

if h2c,
   trQ=newlmi;     % Trace(Q) < nu0^2
   tv=lmivar(3,diag(Qdec));
   sclf=max(1,nu0^2/1e3);
   lmiterm([trQ,1,1,tv],ones(1,p2),0.5/sclf,'s');
   lmiterm([trQ,1,1,0],-nu0^2/sclf);
end


lmis=getlmis;


%%%%%%%%%%%%%%%%%%%%%%%%% LMI OPTIMIZATION %%%%%%%%%

if hioptim | h2optim,

   % objective = alpha gamma^2 + beta Trace(Q) + eps * Trace(R+S)

   c_obj = zeros(decnbr(lmis),1);
   if hioptim, c_obj(1) = obj(3); end
   if h2optim,
      Qdiag=diag(decinfo(lmis,Q));
      c_obj(Qdiag)=obj(4)*ones(length(Qdiag),1);
   end
   Rdiag=diag(decinfo(lmis,R));
   Sdiag=diag(decinfo(lmis,S));
   c_obj(Rdiag)=penalty*ones(n,1);    % eps*Trace(R)
   c_obj(Sdiag)=penalty*ones(n,1);    % eps*Trace(S)


   slow=5+5*(tol<1e-1);
   opt = [tol, 300, 1e8, slow, 0];
   if h2,
     target=1e-6;
     str=sprintf('\n Optimization of  %6.3f * G^2 + %6.3f * H^2 :',...
                  obj(3),obj(4));
   else
     target=1e-3;
     str=sprintf('\n Optimization of the H-infinity performance G :');
   end
   disp(str);
   disp([' ' setstr('-'*ones(1,length(str)-2))]);

   [cost,xopt] = mincx(lmis,c_obj,opt,[],target);

   if isempty(xopt),
      disp('Infeasible pole placement constraints or criterion value > 1000');
      return
   end


   if hioptim, gopt=dec2mat(lmis,xopt,gam); elseif hic, gopt=gam0; end
   if h2, gopt=sqrt(gopt); end

   if h2optim,
      Qopt=dec2mat(lmis,xopt,Q); h2opt=sqrt(trace(Qopt));
   elseif h2c,
      h2opt=nu0;
   end

   if hinf,
     disp(sprintf(' Guaranteed Hinf performance: %6.2e',gopt));
   end
   if h2,
     disp(sprintf(' Guaranteed   H2 performance: %6.2e',h2opt));
   end

else


  opt = [0, 200, 1e8, 0, 0];
  [tmin,xopt] = feasp(lmis,opt);

  if tmin>1e-4,
    disp('The specifications were found infeasible'); return
  elseif tmin>0,
    disp('WARNING: marginally feasible specs.  Further checking needed');
  end

  if hic, gopt=g0; end
  if h2c, h2opt=nu0; end

end



%%%%%%%%%  COMPUTE THE CONTROLLER   %%%%%%


R = dec2mat(lmis,xopt,R);
S = dec2mat(lmis,xopt,S);
bk=dec2mat(lmis,xopt,Bk);
ck=dec2mat(lmis,xopt,Ck);
if isdk,
  dk=dec2mat(lmis,xopt,Dk); dk=dk0+vdk*dk*wdk';
else
  dk=zeros(m2,p3);
end


% get Ak
if polp,
  ak=dec2mat(lmis,xopt,Ak);
elseif ~hinf,
  ak=-(a+b2*dk*c3)'-(S*b1+bk*d31)*(b1+b2*dk*d31)';
elseif h2,
  tmp=-(d11+d12*dk*d31)/gopt;
  ak=-((a+b2*dk*c3)'+[S*b1+bk*d31 , (c1+d12*dk*c3)'/gopt]/...
       [eye(m1) tmp';tmp eye(p1)]*...
       [(b1+b2*dk*d31)';(c1*R+d12*ck)/gopt]);
else
  tmp=-(d11+d12*dk*d31);
  ak=-((a+b2*dk*c3)'+[S*b1+bk*d31 , (c1+d12*dk*c3)']/...
     [gopt*eye(m1) tmp';tmp gopt*eye(p1)]*[(b1+b2*dk*d31)';c1*R+d12*ck]);
end


% undo the change of variable
[u,sd,v]=svd(eye(n)-R*S);  % factorize I-RS
sd=diag(sqrt(1./diag(sd)));
Ni=sd*v';  Mti=u*sd;

ak=Ni*(ak-S*(a-b2*dk*c3)*R-bk*c3*R-S*b2*ck)*Mti;
bk=Ni*(bk-S*b2*dk);
ck=(ck-dk*c3*R)*Mti;


%clpoles=eig([a+b2*dk*c3 b2*ck;bk*c3 ak])



% loop shifting if d32 nonzero
if norm(d32,1) > 0,
  if norm(dk,1) > 0,
     M2k=eye(p3)+d32*dk; Mk2=eye(m2)+dk*d32;
     s=svd(M2k);
     if min(s) < sqrt(macheps)*max(s),
       K=[];
       error('Algebraic loop due to nonzero D32!  Perturb D32 and recompute K(s)');
     else
       tmp=Mk2\ck;
       K=ltisys(ak-bk*d32*tmp,bk/M2k,tmp,Mk2\dk);
     end
  else
     K=ltisys(ak-bk*d32*ck,bk,ck,dk);
  end
else
  K=ltisys(ak,bk,ck,dk);
end


% end hinfmix
