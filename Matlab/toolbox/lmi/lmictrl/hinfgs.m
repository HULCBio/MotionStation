% [gopt,pdk,R,S]=hinfgs(pds,r,gmin,tol,tolred)
%
% Gain-scheduled H-infinity control of parameter-dependent
% systems with an affine dependence on the time-varying
% parameters. These parameters are assumed to be measured
% in real-time.
%
% This function implements the quadratic H-infinity performance
% approach.
%
% Input:
%  PDS       parameter-dependent plant (see PSYS).
%  R         1x2 vector specifying the dimensions of D22:
%                     R(1) = nbr of measurements
%                     R(2) = nbr of controls
%  GMIN      target value for GOPT.  Set GMIN = 0 to compute the
%            optimum GOPT, and set GMIN = GAMMA to test whether
%            the performance GAMMA is achievable   (Default = 0)
%  TOL       desired relative accuracy on the optimal performance
%            GOPT  (Default = 1e-2)
%  TOLRED    optional (default value = 1e-4).  Reduced-order
%            synthesis is performed whenever
%                   rho(X*Y) >=  (1 - TOLRED) * GAMA^2
%
% Output
%  PDK       polytopic representation  PDK = [K1 , ... , Kn]  of
%            the gain-scheduled controller. The vertex controller
%            Kj  is associated with the  j-th  corner of the
%            parameter box as given by POLYDEC
%  GOPT      optimal performance if GMIN=0, and some achievable
%            performance < GMIN  otherwise
%  R,S       solutions of the characteristic LMI system
%
%
% See also  PSYS, POLYDEC, PDSIMUL, HINFLMI.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [gopt,pdk,Ropt,Sopt]=hinfgs(pds,r,gmin,tol,tolred)

if nargin < 2,
  error('usage: [gopt,pdk,R,S]=hinfgs(pds,r,gmin,tol,tolred)');
elseif length(r)~=2,
  error('R must be a two-entry vector');
elseif min(r)<=0,
  error('The entries of R must be positive integers');
elseif ~ispsys(pds),
  error('PDS must be a parameter-dependent system');
elseif pds(7,1)~=10,
  error('Not available when the E matrix varies');
elseif nargin == 2,
  gmin=0;  tol=1e-2; tolred=1e-4;
elseif nargin == 3,
  tol=1e-2; tolred=1e-4;
elseif nargin == 4,
  tolred=1e-4;
end
Ropt=[]; Sopt=[]; pdk=[];


% convert to polytopic if necessary
if strcmp(psinfo(pds),'aff'), pds=aff2pol(pds); end


% tolerances
macheps=mach_eps;
tolsing=sqrt(macheps);
penalty=max(gmin,1)*1e-8;


% dimensions
p2=r(1);  m2=r(2);
[aux,nv,ns,ni,no] = psinfo(pds);       % nv = number of vertices
p1=no-p2;   m1=ni-m2;
if p1<0 | m1<0,
  error('D11 is empty according to the input R');
end

[A,B1,b2,C1,c2,D11,d12,d21,d22]=hinfpar(psinfo(pds,'sys',1),r);


% check that b2,c2,d12,d21,d22 cte
for ii=2:nv,
  [x,x,b2x,x,c2x,x,d12x,d21x,d22x]=hinfpar(psinfo(pds,'sys',ii),r);
  if norm(b2-b2x,1) > 0 | norm(d12-d12x,1) > 0,
    error('B2 and D12 should be constant: filter the input u');
  elseif norm(c2-c2x,1) > 0 | norm(d21-d21x,1) > 0,
    error('C2 and D21 should be constant: filter the output y');
  elseif norm(d22-d22x,1) > 0,
    error('D22 should be constant: filter u or y');
  end
end


%%%%% LMI synthesis set-up

[u,s,u,rkR,NR]=svdparts([b2;d12],0,tolsing);
cnr=size(NR,2);
NR=mdiag(NR,eye(m1));

[u,s,u,rkS,u,NS]=svdparts([c2,d21],0,tolsing);
cns=size(NS,2);
NS=mdiag(NS,eye(p1));


% vars
setlmis([]);
lmivar(1,[ns 1]);        % R
lmivar(1,[ns 1]);        % S
lmivar(1,[1 0]);         % gamma



% terms
for ii=1:nv,

  [A,B1,b2,C1,c2,D11]=hinfpar(psinfo(pds,'sys',ii),r);

  jj=newlmi;
  aux1=[A;C1]; aux2=[eye(ns) zeros(ns,p1)];
  lmiterm([jj 0 0 0],NR);
  lmiterm([jj 1 1 1],aux1,aux2,'s');
  lmiterm([jj 1 1 3],[zeros(ns,p1);eye(p1)],[zeros(p1,ns),-eye(p1)]);
  lmiterm([jj 2 1 0],[B1' D11']);
  lmiterm([jj 2 2 3],-1,1);

  jj=newlmi;
  aux1=[A,B1]; aux2=[eye(ns);zeros(m1,ns)];
  lmiterm([jj 0 0 0],NS);
  lmiterm([jj 1 1 2],aux2,aux1,'s');
  lmiterm([jj 1 1 3],[zeros(ns,m1);eye(m1)],[zeros(m1,ns),-eye(m1)]);
  lmiterm([jj 2 1 0],[C1 D11]);
  lmiterm([jj 2 2 3],-1,1);
end

jj=newlmi;
lmiterm([-jj 1 1 1],1,1);
lmiterm([-jj 2 1 0],1);
lmiterm([-jj 2 2 2],1,1);

lmisys=getlmis;


% objective = gamma + eps * Trace(R+S)

nvars=ns*(ns+1)+1;
Rdiag=diag(decinfo(lmisys,1));
Sdiag=diag(decinfo(lmisys,2));
c_obj = zeros(nvars,1);
c_obj(nvars)=1;                     % gamma
c_obj(Rdiag)=penalty*ones(ns,1);    % eps*Trace(R)
c_obj(Sdiag)=penalty*ones(ns,1);    % eps*Trace(S)



options=[tol 200 1e8 0 0];

[gopt,xopt]=mincx(lmisys,c_obj,options,[],gmin);


if ~isempty(gopt),
   Ropt=dec2mat(lmisys,xopt,1);
   Sopt=dec2mat(lmisys,xopt,2);
   gopt=gopt-penalty*(sum(diag(Ropt))+sum(diag(Sopt)));
   disp(sprintf('\n Optimal quadratic RMS performance:  %9.4e',gopt));
else
   gopt=Inf; return
end



% controller computation

orderK=-1;

while isempty(pdk),

  for ii=1:nv,
      kv=klmi(psinfo(pds,'sys',ii),r,gopt,...
                  Ropt,gopt*eye(ns),Sopt,gopt*eye(ns),tolred);

      nk=sinfo(kv);   % order of K

      if ~isempty(pdk) & nk~=orderK,
         pdk=[];  gopt=1.01*gopt;  break
      else
         orderK=nk;  pdk=[pdk kv];
      end
  end

end;

pdk=psys(pdk);


if norm(d22,1)>0,
   disp(' Warning: nonzero D22!  See user''s manual for proper action');
end
