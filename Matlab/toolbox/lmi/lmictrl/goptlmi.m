% [gopt,X1,X2,Y1,Y2] = goptlmi(P,r,gmin,tol,options)
%
% Computes the optimal H-infinity performance GOPT for the
% continuous-time (analog) plant P using the LMI-based
% characterization of suboptimality.
%
% NOT MEANT TO BE CALLED BY THE USER.
%
% On output:
%  GOPT       best H-infinity performance in the interval [GMIN,GMAX]
%  X1,X2,..   X = X2/X1  and  Y = Y2/Y1  are solutions of the
%             two H-infinity Riccati inequalities for gamma = GOPT.
%             Equivalently,  R = X1  and  S = Y1  are solutions
%             of the characteristic LMIs since X2 = Y2 = GOPT*eye.
%
% See also  HINFLMI, KLMI.

% Author: P. Gahinet  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [gopt,x1,x2,y1,y2]=goptlmi(P,r,gmin,tol,options)

ubo=1; lbo=1;   % default = specified bounds

if nargin < 4,
  error('usage:  [gopt,x1,x2,y1,y2] = goptlmi(P,r,gmin,tol)');
end


% tolerances
macheps=mach_eps;
tolsing=sqrt(macheps);
toleig=macheps^(2/3);
feasrad=1e8;


penalr=max(gmin,.1)*10^(-8+7*min(1,max(0,options(1))));
penals=max(gmin,.1)*10^(-8+7*min(1,max(0,options(2))));



% retrieve plant data

[a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r);
na=size(a,1); [p1,m1]=size(d11); [p2,m2]=size(d22);
if ~m1, error('D11 is empty according to the dimensions R of D22'); end



% for numerical stability of the controller computation,
% zero the sing. values of D12 s.t  || B2 D12^+ || > 1/tolsing

[u,s,v]=svd(d12);
abstol=max(toleig*norm(b2,1),tolsing*s(1,1));
ratio=max([s;zeros(1,size(s,2))])./...
      max([tolsing*abs(b2*v);abstol*ones(1,m2)]);
ind2=find(ratio < 1); l2=length(ind2);
if l2 > 0, s(:,ind2)=zeros(p1,length(ind2)); d12=u*s*v'; end

[u,s,v]=svd(d21');
abstol=max(toleig*norm(c2,1),tolsing*s(1,1));
ratio=max([s;zeros(1,size(s,2))])./...
      max([tolsing*abs(c2'*v);abstol*ones(1,p2)]);
ind2=find(ratio < 1); l2=length(ind2);
if l2 > 0, s(:,ind2)=zeros(m1,length(ind2)); d21=v*s'*u'; end



% compute the outer factors

NR=lnull([b2;d12],0,tolsing);
cnr=size(NR,2);
NR=[NR,zeros(na+p1,m1);zeros(m1,cnr) eye(m1)];

NS=rnull([c2,d21],0,tolsing);
cns=size(NS,2);
NS=[NS,zeros(na+m1,p1);zeros(p1,cns) eye(p1)];



% LMI setup

setlmis([]);
lmivar(1,[na 1]);       % R
lmivar(1,[na 1]);       % S
lmivar(1,[1 1]);        % gamma

aux1=[a;c1]; aux2=[eye(na) zeros(na,p1)];
lmiterm([1 0 0 0],NR);
lmiterm([1 1 1 1],aux1,aux2,'s');
lmiterm([1 1 1 3],[zeros(na,p1);eye(p1)],[zeros(p1,na),-eye(p1)]);
lmiterm([1 2 1 0],[b1' d11']);
lmiterm([1 2 2 3],-1,1);

aux1=[a,b1]; aux2=[eye(na);zeros(m1,na)];
lmiterm([2 0 0 0],NS);
lmiterm([2 1 1 2],aux2,aux1,'s');
lmiterm([2 1 1 3],[zeros(na,m1);eye(m1)],[zeros(m1,na),-eye(m1)]);
lmiterm([2 2 1 0],[c1 d11]);
lmiterm([2 2 2 3],-1,1);

lmiterm([-3 1 1 1],1,1);
lmiterm([-3 2 1 0],1);
lmiterm([-3 2 2 2],1,1);

if gmin > 0,      % gamma > .5*gmin to keep penalty effective
  lmiterm([4 1 1 0],.5*gmin);
  lmiterm([-4 1 1 3],1,1);
end

LMIs=getlmis;


% composite criterion  gamma + penalr*Trace(R) + penals*Trace(S)

Rdiag=diag(decinfo(LMIs,1));
Sdiag=diag(decinfo(LMIs,2));
c_obj=[zeros(na*(na+1),1) ; 1];
c_obj(Rdiag)=penalr*ones(na,1);
c_obj(Sdiag)=penals*ones(na,1);



% call mincx
options=[tol 0 feasrad 0 0];    % fixed feasibility radius

[gopt,xopt]=mincx(LMIs,c_obj,options,[],gmin);


if isempty(gopt),
  x1=[]; x2=[]; y1=[]; y2=[];
else
  % X = gamma * inv(R)
  x1=dec2mat(LMIs,xopt,1);
  y1=dec2mat(LMIs,xopt,2);
  gopt=gopt-penalr*sum(diag(x1))-penals*sum(diag(y1));
  x2=gopt*eye(na);
  y2=gopt*eye(na);
end





