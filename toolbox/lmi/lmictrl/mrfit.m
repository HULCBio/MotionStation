% [num,den]=mrfit(w,mod,r)
%
% Called by MAGSHAPE
%
% Fits the frequency/magnitude data (W,MOD) with a
% stable transfer function of order R
%
% See also  MAGSHAPE, FRFIT.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [num,den]=mrfit(w,mod,r)


% treat case r=0
if r==0,
  num=pinv(ones(length(mod),1))*mod(:);
  den=1;
  return
end



% get slopes at extremities and set end interval length
sl0=round(log10(mod(2)/mod(1))/log10(w(2)/w(1)));
w(1)=w(2)/10;
if sl0~=0. mod(1)=mod(2)/10^sl0; end

n=length(w);
slinf=round(log10(mod(n)/mod(n-1))/log10(w(n)/w(n-1)));
w(n)=w(n-1)*10;
if slinf~=0, mod(n)=mod(n-1)*10^slinf; end


logw=log10(w);
logmod=log10(mod);
delw=diff(logw);
delmod=diff(logmod);



% add weight at points of large var.
weight=ones(length(w),1);
ind=1+find(abs(diff(delmod./delw)) > .6);
weight(ind)=10*ones(length(ind),1);



% enrich point set
lwnew=[]; modnew=[];
for i=1:length(w)-1,
  nadd=floor(delw(i)/.3)-1;
  if nadd>0,
    slope=delmod(i)/delw(i);
    lwnew=[lwnew logw(i)+.3*(1:nadd)];
    modnew=[modnew logmod(i)+.3*slope*(1:nadd)];
    weight=[weight ; ones(nadd,1)];
  end
end
w=[w ; 10.^lwnew'];
mod=[mod ; 10.^modnew'];


% sort outcome/eliminate redundant pts
[w,ind]=sort(w); mod=mod(ind); weight=weight(ind);
ind=find(diff(w)>0); ind=[ind;length(w)];
w=w(ind); mod=mod(ind); weight=weight(ind);



% call cepstrum to generate phase
fresp=cepstr(w,mod);



% perform frequency response fit
[num,den]=frfit(w,fresp,r,weight);
