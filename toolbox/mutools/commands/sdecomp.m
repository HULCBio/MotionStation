% function [sysst,sysun] = sdecomp(sys,bord,fl)
%
%   Decomposes a system into the sum of two systems,
%      SYS = MADD(SYSST,SYSUN).
%      SYSST has the real parts of all its poles < BORD
%      SYSUN has the real parts of all its poles >= BORD
%      BORD has default value 0.
%
%    The D matrix for SYSUN is zero unless FL = 'd' when
%    that for SYSST is zero.
%
%   See Also: HANKMR, SFRWTBAL, SFRWTBLD, SNCFBAL, SREALBAL, and SYSBAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $


function [sysst,sysun] = sdecomp(sys,bord,fl)
  if nargin < 1
    disp('usage: [sysst,sysun] = sdecomp(sys,bord,fl)')
    return
  end

[mattype,p,m,n]=minfo(sys);
if mattype~='syst',
   disp('usage: [sysst,sysun] = sdecomp(sys,bord,fl)')
   return
end
if nargin==1, bord=0;fl='s'; end
if nargin==2, fl='s';end
[a,b,c,d]=unpck(sys);
[u,a]=schur(a);
[u,a,k]=orsf(u,a,'s',bord);
% if k==0, sysst=zeros(p,m); sysun=sys; end
if isempty(k), sysst=zeros(p,m); sysun=sys; end
if ~isempty(k) & k==n % Added ~isempty(k) for matlab v5
	sysst=sys;
	sysun=zeros(p,m);
end
kp=k+1;
if k<n & k>0,
  x=axxbc(a(1:k,1:k),-a(kp:n,kp:n),-a(1:k,kp:n));
  ah=a(1:k,1:k);
  bh=[eye(k),-x]*u'*b;
  ch=c*u(:,1:k);
  if fl=='s', dh=d; du=zeros(p,m);
     else, du=d; dh=zeros(p,m); end
  sysst=pck(ah,bh,ch,dh);
  au=a(kp:n,kp:n);
  bu=u(:,kp:n)'*b;
  cu=c*u*[x;eye(n-k)];
  sysun=pck(au,bu,cu,du);
 end %if k<n & k>0,
%
%