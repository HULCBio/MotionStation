function f=circlef(p,t,u,time)

%point source at (0,0)

% Copyright 1994-2001 The MathWorks, Inc.
% $Revision: 1.8 $

x=0;
y=0;

np=size(p,2);
nt=size(t,2);

[ar,t1,t2,t3]=pdetrg(p,t);

[t1,tn,t2,t3]=tri2grid(p,t,zeros(np,1),x,y);

f=zeros(1,nt);

if ~isnan(tn)
  f(tn)=1/ar(tn);
end


