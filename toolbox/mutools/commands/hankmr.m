% function [sh,su,hsvu]=hankmr(sys,sig,k,opt)
%
%   Performs an optimal Hankel norm approximation of order K
%   on the state-space system SYS of order n. The input system
%   SYS must be a balanced realization with Hankel singular
%   values SIG (i.e. SYS and SIG must be the output of SYSBAL).
%   OPT may be omitted or
%
%     -set to 'a' to stop with an anti-causal term. The anticausal
%         part will be absorbed into SH, and SU = 0.
%     -set to 'd' to calculate a D-term which satisfies
%         the H infinity error bound the sum of the neglected
%         Hankel singular values SIG(i). That is SH+SU will always
%         be an optimal H infinity norm approximation to SYS with
%         K stable poles.
%
%   The anticausal will be absorbed into SH, and SU = 0, if OPT = 'a',
%   otherwise SU contains the anticausal term and SH the Kth order
%   causal system. With the 'd' option the Hankel singular values
%   of SU are given in HSVU.
%
%   See also: SFRWTBAL, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL,
%             SRESID, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [sh,su,hsvu]=hankmr(sys,sig,k,opt)
if nargin < 3
  disp(['usage: [sh,su,hsvu] = hankmr(sys,sig,k,opt)']);
  return
end
if nargin==3,
  opt='s';
end

sh = []; su = []; hsvu = []; % Added for matlab v5
[mattype,p,m,n]=minfo(sys);
if k<0 | k>=n,error('k must be between 0 and n-1');return;end;
[a,b,c,d]=unpck(sys);
kp=k+1;
skp=sig(kp);skp2=skp^2;
if k>0,
  while sig(k)<1.01*skp&k>0,
    k=k-1;
    if k == 0
    	disp('  Unable to find a solution since sig(1)<1.01*sig(2)');
	return
    else
        disp('  sig(k)<1.01*sig(k+1), k reduced');
    end
  end;%while sig(k)
end%if k>0
kp=k+1;
skp=sig(kp);skp2=skp^2;
for r=1:n-k,
  if sig(k+r)<0.99*skp,
    kr=k+r-1;break;
  end;
  kr=k+r;
end;
r=kr-k;sig=sig';krp=kr+1;
u=-c(:,kp:kr)*pinv(b(kp:kr,:)');
ds=diag([(sig(1:k).^2-skp2*ones(1,k)).^(-0.5),-(skp2*...
   ones(1,n-kr)-sig(krp:n).^2).^(-0.5)]);
sig1=diag([sig(1:k),sig(krp:n)]);
aw=ds*(sig1*a([1:k,krp:n],[1:k,krp:n])*sig1+skp2*a([1:k,krp:n],...
   [1:k,krp:n])'-skp*c(:,[1:k,krp:n])'*u*b([1:k,krp:n],:)')*ds;
if kp<=(n-r), aw(:,kp:(n-r))=-aw(:,kp:(n-r));
  end % if kp<=(n-r)
bw=ds*(sig1*b([1:k,krp:n],:)+skp*c(:,[1:k,krp:n])'*u);
cw=(c(:,[1:k,krp:n])*sig1+skp*u*b([1:k,krp:n],:)')*ds;
if kp<=(n-r), cw(:,kp:(n-r))=-cw(:,kp:(n-r));
  end %if kp<=(n-r),
dw=d-skp*u;
if opt=='a',
    sh=pck(aw,bw,cw,dw);
    return;
 end; %if opt=='a'
if krp>n, %i.e. dim of SU is zero
  su=zeros(p,m);
  if n>r, sh=pck(aw,bw,cw,dw);
   else, sh=dw;
   end %if n>r,
else, %if krp>n
  if k==0,
     au=aw;bu=bw;cu=cw;du=zeros(p,m);
     su=pck(au,bu,cu,du);
     dh=dw; sh=dh;
   end; %if k==0
  if k>0,
    [sh,su]=sdecomp(pck(aw,bw,cw,dw));
    [au,bu,cu,du]=unpck(su);
   end; %if k>0
  if opt=='d',
    if (m==1)&(p==1), du=0.5*(cu/au)*bu;
        [su,hsvu]=sysbal(pck(-au,bu,cu,du));
        [au,bu,cu,du]=unpck(su);
      else
      [su,hsvu]=sysbal(pck(-au,bu,cu,du));
      [au,bu,cu,du]=unpck(su);
      if ~isempty(au),
         du=-dcalc(bu,cu,hsvu,2*(p+m));
        end; %if ~isempty(au)
     end; %if (m==1)
    dh=dw-du;
    if k==0,
      sh=dh;
     else,
      sh(kp:k+p,kp:k+m)=dh;
     end; %if k==0
    if ~isempty(au),
       su=pck(-au,bu,cu,du);
     end; %if ~isempty(au)
  end; %if opt=='d'
end;%if krp>n
%
%