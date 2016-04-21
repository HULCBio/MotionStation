% Specification of uncertain state-space models
%
%                E dx/dt  =  A x  +  B u
%                      y  =  C x  +  D u
%
% where the SYSTEM matrix   S = [ A+jE  B ; C  D ]   either
%  (1) varies in a fixed polytope of SYSTEM matrices, or
%  (2) is a fixed function  S(p)  of some uncertain/time-
%      varying parameter vector   p = (p1, p2, ... , pk)
%
% Polytopic systems:
% ------------------
%    S = PSYS([S1 S2 ... Sk])    defines a polytopic system
%    varying in the convex hull of the SYSTEM matrices S1,...,SK
%
% Affine parameter-dependent systems:
% -----------------------------------
%    S = PSYS(pv,[S0 S1 ... Sk])    specifies a system  S(p)
%    depending affinely on the parameter vector p, i.e.,
%               S(p)  =  S0 + p1*S1 + ... + pk*Sk
%    where S0,S1,...Sk are given SYSTEM matrices.   The first
%    input PV is the parameter vector description (see PVEC).
%
%    WARNING: to make E(p) independent of p, set the E matrices
%             of S1,...,Sk to zero
%
%
% See also  PSINFO, PVEC, LTISYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function ps=psys(pv,syslist,pstype)


if ~any(nargin==[1 2 3])
  error('usage: s=psys([s1 ... sk]) or s=psys(pv,[s1 ... sk])');
elseif nargin < 3,
  pstype=nargin;
end

if nargin==1, syslist=pv; pv=[]; end

[rs,cs]=size(syslist);
nv=length(find(syslist(rs,:)==-Inf));
if nv==0,
  error('S0,S1,...,Sk must be SYSTEM matrices');
end


% check # systems vs # parameters in affine case
if pstype==2,
  if size(pv,1) < 2,
    error('PV is not a parameter vector description');
  elseif pv(2,1)~=nv-1,
    error(sprintf(...
      ['A parameter-dependent model with %d parameter(s) must be\n' ...
       'specified by %d SYSTEM matrices'],pv(2,1),pv(2,1)+1));
  end
end


% get number of vertices
if rem(cs,nv)~=0,
  error('The SYSTEM matrices S0,S1,...,Sk must have the same dimensions')
end
cs=cs/nv; ns=syslist(1,cs); ni=cs-ns-1; no=rs-ns-1;


% keeping track of dependence of E and A on p
s0=syslist(:,1:cs);
a0=s0(1:ns,1:ns); e0=imag(a0)+eye(ns); a0=real(a0);
ne0=max(max(abs(e0))); na0=max(max(abs(a0)));
ap=0;   % 1 if A depends on p (affine) or varies (polytopic)
ep=0;   % 1 if E depends on p (affine) or varies (polytopic)
aep=0;  % 1 if some pj enters both A and E
% ps(7,1)=[aep ap ep]


% init
ps=[-Inf;pstype;nv;ns;ni;no;0];


% store the SYSTEM data
rps=max(length(ps),rs);
cps=1+nv*(cs+1);
ps(rps,cps)=0;   % ps dimensioned
ps(1:rs,3:2+cs)=s0;

for k=1:nv-1,
  b1=2+k*(cs+1);
  b2=k*cs;
  sys=syslist(:,b2+1:b2+cs);
  a=sys(1:ns,1:ns); e=imag(a)+eye(ns); a=real(a);
  ps(1:rs,b1+1:b1+cs)=sys;

  if pstype==1 & rcond(e) < 100*mach_eps,
     error(sprintf('The descriptor system S%d has singular E matrix',k+1));
  end

  if pstype==1,
     tol=1000*mach_eps;
     if max(max(abs(e-e0)))>tol*ne0, ep=1; end
     if max(max(abs(a-a0)))>tol*na0, ap=1; end
  elseif pstype==2,
     boola=max(max(abs(a))) > 0;
     boole=max(max(abs(e))) > 0;
     if boola & boole, ap=1; ep=1; aep=1;
     elseif boola, ap=1; elseif boole, ep=1; end
  end
end

ps(7,1)=ep+10*ap+100*aep;

if pstype==2 & ep,
  disp('Warning: the E matrix of this affine system depends on p.');
end


% add parameter vector description
[rv,cv]=size(pv);
if rv,
  ps(1:rv,cps+1:cps+cv)=pv;
end
