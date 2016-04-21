% [gopt,h2opt,K,Pcl,X] = msfsyn(P,r,obj,region,tol)
%
% Multi-model/multi-objective state-feedback synthesis
%
% Given a plant with state-space equations
%	 dx/dt = A  * x + B1  * w + B2  * u
%	 zinf  = C1 * x + D11 * w + D12 * u
%	 z2    = C2 * x + D21 * w + D22 * u
% MSFSYN computes a state-feedback control  u = Kx  that
%  * keeps the RMS gain G from w to zinf below the value OBJ(1)
%  * keeps the H2-norm  H from w to z2 below the value OBJ(2)
%  * minimizes a trade-off criterion of the form
%              OBJ(3) * G^2 + OBJ(4) * H^2
%  * places the closed-loop poles in the LMI region specified
%    by REGION.
%
% REMARK:  the H2 norm is finite iff. D21=0
%
% Input:
%  P        LTI plant or polytopic/parameter-dependent system
%           (see PSYS)
%  R        R(1) = # of outputs z2,  R(2) = # of controls u
%  OBJ      four-entry vector specifying the H2/Hinf objective:
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
%  TOL      optional: desired relative accuracy on the objective
%                     value  (Default = 1e-2)
%
% Output:
%  GOPT     computed bound on the closed-loop RMS gain w -> zinf
%  H2OPT    computed bound on the closed-loop H2 norm  w -> z2
%  K        optimal state-feedback gain
%  Pcl      closed-loop system for u = Kx
%  X        Lyapunov matrix yielding the optimal trade-off
%
%
% See also  LMIREG, PSYS, HINFLMI.

% Authors: M. Chilali and P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [gopt,h2opt,K,Pcl,X]=msfsyn(P,r,obj,region,tol)

if nargin < 3,
  error('usage:  [gopt,h2opt,K] = msfsyn(P,r,obj,region)');
end
if nargin < 4, region=[]; end
if nargin < 5, tol=[]; end
if isempty(tol), tol=1e-2; end

if ~ispsys(P) & ~islsys(P),
  error('P must be a SYSTEM matrix or a polytopic system');
elseif islsys(P),
  P=psys(P);
elseif min(size(obj))~=1 | max(size(obj))~=4 | any(obj < 0),
  error('OBJ must be a 4-entry vector of positive real numbers');
end


[typ,nsys,ns,ni,no]=psinfo(P);
if strcmp(typ,'aff'),
   P=aff2pol(P); [typ,nsys]=psinfo(P);
elseif ~any(P(7,1)==[0 10]),
   error('Polytopic systems with varying E matrix are not allowed');
end

X=[]; K=[]; gopt=[]; h2opt=[]; Pcl=[];
g0=obj(1); nu0=obj(2);
hic=(g0~=0);  hioptim=(obj(3)~=0);  hinf=hic | hioptim;
h2c=(nu0~=0); h2optim=(obj(4)~=0);  h2=h2c | h2optim;
if hioptim, sclf=1+9*h2; else sclf=max(1,g0); end
if ~hic, g0=1000; end
gam0=g0^(1+h2);

% check dimensions
p2=r(1); p1=no-p2; m2=r(2); m1=ni-m2;
if m1 <= 0,
   error('Input w defined as empty by R(2)');
elseif p1 < 0,
   error('D11 has negative dimensions according to R');
elseif hinf & ~p1,
   error('D11 must be nonempty for Hinf optimization');
elseif h2 & ~p2,
   error('D22 must be nonempty for H2 optimization');
end

if nsys>1,
  P1=psinfo(P,'sys',1);
  c20=hinfpar(P1,r,'c2');
  d220=hinfpar(P1,r,'d22');
end
var2=0;


% Form the LMI system
%%%%%%%%%%%%%%%%%%%%%

setlmis([]);

%% Variables
if hioptim, gam=lmivar(1,[1 0]); end        % gamma or gamma^2
if h2, [Q,xxx,Qdec]=lmivar(1,[p2 1]); end   % Q
X=lmivar(1,[ns 1]);                         % X
Y=lmivar(2,[m2,ns]);                        % Y

for k=1:nsys,

 Pk=psinfo(P,'sys',k);
 [a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(Pk,r);
 if any(any(d21)) & (h2c | h2optim),
    error('Nonzero D21: the H2 norm is infinite!');
 elseif k>1,
    varc2=c2-c20; vard22=d22-d220;
    var2=any(varc2(:)) | any(vard22(:));
 end

 % Hinf constraint or H2 Lyapunov
 if h2 | hinf,
   lmi1=newlmi;
   lmiterm([lmi1,1,1,X],a,1,'s');
   lmiterm([lmi1,1,1,Y],b2,1,'s');
   lmiterm([lmi1,1,2,0],sclf*b1);
   if h2,
     lmiterm([lmi1 2 2 0],-sclf^2);
   elseif hioptim,
     lmiterm([lmi1 2 2 gam],-1,1);
   else
     lmiterm([lmi1 2 2 0],-gam0);
   end
   if hinf,
     lmiterm([lmi1,3,1,X],c1,1);
     lmiterm([lmi1,3,1,Y],d12,1);
     lmiterm([lmi1,3,2,0],sclf*d11);
   end
   if hioptim,
     lmiterm([lmi1,3,3,gam],-1,1);
   elseif hic,
     lmiterm([lmi1,3,3,0],-gam0);
   end
 end

 % H2 Q-constr or X > 0
 if h2 & (k==1 | var2),
   lmih2=newlmi;
   lmiterm([-lmih2,1,1,X],1,1);
   lmiterm([-lmih2,2,1,X],c2,1);
   lmiterm([-lmih2,2,1,Y],d22,1);
   lmiterm([-lmih2,2,2,Q],1,1);
 end

 % Pole Clustering Constraint
 m=size(region,1);
 if size(region,2)~=2*m,
    error('REGION must be a Mx(2M) matrix');
 end
 r1=1;
 while r1<=m,
   mr=round(imag(region(r1,r1)));
   if mr==0, mr=m-r1+1; end
   pole=newlmi;
   r2=r1+mr-1;
   for i=r1:r2,
    i1=i-r1+1;
    for j=i+1:r2,
     j1=j-r1+1;
     lmiterm([pole,i1,j1,X],region(i,j),1);
     lmiterm([pole,i1,j1,X],region(i,j+m)*a,1);
     lmiterm([pole,i1,j1,Y],region(i,j+m)*b2,1);
     lmiterm([pole,i1,j1,X],1,region(j,i+m)*a');
     lmiterm([pole,i1,j1,-Y],1,region(j,i+m)*b2');
    end
    lmiterm([pole,i1,i1,X],real(region(i,i)),1);
    lmiterm([pole,i1,i1,X],region(i,i+m)*a,1,'s');
    lmiterm([pole,i1,i1,Y],region(i,i+m)*b2,1,'s');
   end
   r1=r2+1;
 end

end  % for k=1:nsys


% X > 0 if no H2
if ~h2,
 lmiX=newlmi;
 lmiterm([-lmiX,1,1,X],1,1);
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


%  Solve the LMI problem
%%%%%%%%%%%%%%%%%%%%%%%%

if hioptim | h2optim,

  cobj=zeros(1,decnbr(lmis));
  if hioptim, cobj(1)=obj(3); end
  if h2optim,
    ind=1:p2; ind=round((ind.*(ind+1))/2)+(hioptim~=0);
    cobj(ind)=obj(4)*ones(1,p2);
  end

  options = [tol, 200, 1e10, 0, 0];

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


  [cost,xopt] = mincx(lmis,cobj,options,[],target);

  if isempty(xopt),
    disp('Infeasible pole placement constraints or criterion value > 1000');
    return
  end

  X=dec2mat(lmis,xopt,X);
  Y=dec2mat(lmis,xopt,Y);
  K=Y/X;

  if hioptim, gopt=dec2mat(lmis,xopt,gam); elseif hic, gopt=gam0; end
  if h2, gopt=sqrt(gopt); end
  if h2optim,
     Q=dec2mat(lmis,xopt,Q); h2opt=sqrt(sum(diag(Q)));
  elseif h2c, h2opt=nu0; end

  if hinf,
    disp(sprintf(' Guaranteed Hinf performance: %6.2e',gopt));
  end
  if h2,
    disp(sprintf(' Guaranteed   H2 performance: %6.2e',h2opt));
  end

else

  options = [0, 200, 1e9, 0, 0];
  [tmin,xopt] = feasp(lmis,options);

  if tmin>1e-4,
    disp('The specifications were found infeasible'); return
  elseif tmin>0,
    disp('WARNING: marginally feasible specs.  Further checking needed');
  end

  X=dec2mat(lmis,xopt,X);
  K=dec2mat(lmis,xopt,Y)/X;
  if hic, gopt=g0; end
  if h2c, h2opt=nu0; end

end


if nargout>3,
 Pcl=[];
 for j=1:nsys,
   Pj=psinfo(P,'sys',j);
   [a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(Pj,r);

   Pcl=[Pcl ltisys(a+b2*K,b1,[c1;c2]+[d12;d22]*K,[d11;d21])];
 end
 if nsys>1, Pcl=psys(Pcl); end
end
