%  [sys,delta] = aff2lft(affsys)
%
%  Given an affine parameter-dependent system AFFSYS with
%  equations
%
%             E(p) dx/dt  =  A(p) x  +  B(p) u
%                      y  =  C(p) x  +  D(p) u
%
%  AFF2LFT generates an equivalent linear fractional
%  representation of the form
%
%                    ___________
%                    |         |
%               |----|  DELTA  |<---|
%               |    |_________|    |
%               |                   |
%               |    ___________    |
%               |--->|         |----|
%                    |   SYS   |
%           u  ----->|_________|----->  y
%
%  where
%    * the nominal system SYS corresponds to the AVERAGE
%      values of the parameters p1, ..., pK
%    * DELTA is a block-diagonal uncertainty structure
%      of the form
%            DELTA =  blockdiag (d1*I , ... , dK*I)
%      with
%              | dj |  <=  (pj_max - pj_min)/2
%
%
%
%  See also  PSYS, PVEC, UBLOCK, PSINFO, PVINFO, UINFO.

%   Author: P. Gahinet  6/94
%   Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [sys,delta] = aff2lft(affsys)

if nargin~=1,
  error('usage: [sys,delta]=aff2lft(affsys)')
elseif size(affsys,1)<2,
  error('First argument is not an affine parameter-dependent system');
elseif ~ispsys(affsys) | affsys(2,1)~=2,
  error('First argument is not an affine parameter-dependent system');
end


[typ,nv,ns,ni,no]=psinfo(affsys);
pv=psinfo(affsys,'par');
[typ,np,npv]=pvinfo(pv);
if ~strcmp(typ,'box'),
  error('PV must be of type ''box'' (see PVEC)');
end
[range,rate]=pvinfo(pv,'par');
tol=mach_eps^(2/3);


% center parameter range by redefining S0
pmed=(range(:,1)+range(:,2))/2;
s0=psinfo(affsys,'eval',pmed);


% get delta bounds
bnds=(range(:,2)-range(:,1))/2;


% construct the nominal plant SYS
delta=[];

[a0,b0,c0,d0,e0]=ltiss(s0);
if rcond(e0) < mach_eps^(4/5),
  error('E(p) is singular for the median value of p');
end

L=[]; M=[]; R=[]; S=[]; T=[];

for i=2:nv,

    [ai,bi,ci,di,ei]=ltiss(psinfo(affsys,'sys',i));
    [u,s,v,rk]=svdparts([ei ai bi;zeros(no,ns) ci di],0,tol);

    if rk > 0
      W=u*diag(sqrt(s));   Z=diag(sqrt(s))*v';
      L=[L  W(1:ns,:)];  M=[M  W(ns+1:ns+no,:)];
      T=[T ; Z(:,1:ns)]; R=[R ; Z(:,ns+1:2*ns)];
      S=[S ; Z(:,2*ns+1:2*ns+ni)];
      if max(abs(rate(i-1,:))) > 0,
         ub=ublock(rk,bnds(i-1),'ltvrs');
      else
         ub=ublock(rk,bnds(i-1),'ltirs');
      end
      delta(1:length(ub),size(delta,2)+1)=ub;
    end
end

T=T/e0;

sys=ltisys(a0,[L b0],[R-T*a0 ; c0],[-T*L  S-T*b0 ;M d0],e0);




