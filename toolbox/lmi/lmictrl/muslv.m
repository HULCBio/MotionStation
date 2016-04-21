% Called by MUSTAB
%

% Author: P. Gahinet  2/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [alpha,D,G,fmax,xinit,inw,inchg]=...
             muslv(lmi0,mub2,tinit,xinit,x0,a,b,c,d,e,w,w0,inw0,flag)

% [alpha,D,G,fmax]=muslv(...,w,w0,inw0)
%    -> mu upper bound + discontinuity analysis
% [alpha,D,G,fmax,inw]=muslv(...,w,w0,inw0)
%    -> same but also returns inertia(w)
% flag present -> simply return inw,inchg

%%% v5 code (placed here because matlab was warning that
%%% one or more output arguments were not getting
%%% assigned)
alpha = []; D = []; G = [];
fmax = []; xinit = []; inw = []; inchg = [];


j=sqrt(-1); n=size(d,1);
if isempty(inw0), nzg=[]; else nzg=inw0(1:2,:); end
isG=~isempty(nzg);
inw0=inw0(3:size(inw0,1),:);
inchg=0;  % =1 -> inertia change


% mu bound at w
[alpha,D,G,xinit]=mub13(lmi0,mub2,isG,tinit,xinit,x0,a,b,c,d,e,w);
if alpha>mub2, fmax=w; else fmax=w0; end


% compare inertias
if ~isempty(inw0) | nargout > 5,
  k=1;
  for t=[nzg;inw0],
    range=t(1):t(2); bs=t(2)-t(1)+1;
    ev0=t(3:length(t)); ev=zeros(bs,1);
    blG=G(range,range);
    if max(max(abs(blG)))>0,
       ev=real(eig(blG,D(range,range)));

%%% v5 code
       if isempty(ev0),
          ix = find(abs(ev) > .1);
%          if length(find(ev(ix)>0)), inchg=1; end
          inchg=0;
       else
          ix=find(abs(ev0) > .1 & abs(ev) > .1);
          if length(find(ev0(ix)>0))~=length(find(ev(ix)>0)),inchg=1; end
       end

%%% v4 code
%          ix=find(abs(ev0) > .1 & abs(ev) > .1);
%          if length(find(ev0(ix)>0))~=length(find(ev(ix)>0)),inchg=1; end

    end
    inw(1:bs,k)=ev; k=k+1;
  end
end

if ~inchg | nargin==14, return, end


% handle discontinuities:
%%%%%%%%%%%%%%%%%%%%%%%%%

% PHASE 1: reduce interval size to w2/w1<1.1 by dichotomy

if w0<w, w1=w0; w2=w; inw2=inw; else w1=w; w2=w0; inw2=inw0; end

%disp(sprintf('call MUDISC in [%6.4e,%6.4e]',w1,w2))


while w2/w1 > 1.1,
  w=sqrt(w1*w2);
  [alpha,Ds,Gs,fmax,xinit,inw,inchg]=...
          muslv(lmi0,mub2,tinit,xinit,x0,a,b,c,d,e,w,w2,[nzg;inw2],1);
  if inchg, w1=w; else w2=w; end
end


% PHASE TWO: three-point optimization w1,w2

maxeig=Inf; alpha=mub2;

while maxeig > 1.2*alpha,
   [alpha,D,G,xinit]=...
                mub13(lmi0,mub2,isG,tinit,xinit,x0,a,b,c,d,e,w1,w2);
   if alpha>mub2, inw=[]; end

   % test if mu^2 < alpha on [w1,w2]
   f=logspace(log10(w1),log10(w2),10); beta=[];
   for w=f,
      M=d+c*((j*w*e-a)\b);
      beta=[beta,max(real(eig(M'*D*M+j*(G*M-M'*G),D)))];
   end

   [maxeig,imax]=max(beta);
   fmax=f(imax); wm=(w1+w2)/2;
   if fmax<wm, w2=wm; else w1=wm; end
   fmax=wm;
end

alpha=max(alpha,maxeig);
