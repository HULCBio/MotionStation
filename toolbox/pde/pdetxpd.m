function [f1,f2,f3]=pdetxpd(p,t,u,time,f1,f2,f3)
%PDETXPD Evaluate on triangles.

%       A. Nordmark 12-21-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:12:09 $


nt=size(t,2);
np=size(p,2);

nf=nargout;
if nf<1 || nf>3,
  error('PDE:pdetxpd:nargout', 'pdetxpd handles 1 to 3 expressions.');
end

if nargin-nf==2,
  if nf>2, % 3 that is
    f3=f1;
  end
  if nf>1,
    f2=time;
  end
  f1=u;
  uu=[];
  u=[];
  ux=[];
  uy=[];
  time=[];
elseif nargin-nf==3,
  if nf>2, % 3 that is
    f3=f2;
  end
  if nf>1,
    f2=f1;
  end
  f1=time;
  time=[];
  uu=u;
  u=pdeintrp(p,t,uu);
  [ux,uy]=pdegrad(p,t,uu);
elseif nargin-nf==4,
  uu=u;
  u=pdeintrp(p,t,uu);
  [ux,uy]=pdegrad(p,t,uu);
else
  error('PDE:pdetxpd:nargin', 'wrong number of arguments in pdetexpd.');
end

% Find midpoints of triangles
x=(p(1,t(1,:))+p(1,t(2,:))+p(1,t(3,:)))/3;
y=(p(2,t(1,:))+p(2,t(2,:))+p(2,t(3,:)))/3;

% Subdomains
sd=t(4,:);


for k=1:nf,
  % Expand as function first
  fn=['f' int2str(k)];
  eval([fn '=pdetfxpd(p,t,uu,time,' fn ');']);
  eval(['nrf=size(' fn ',1);']);

  fsize=1; % Number of columns so far
  ff=zeros(0,1);
  for l=1:nrf,
    % Expand as expression
    eval(['fff=pdetexpd(x,y,sd,u,ux,uy,time,' fn '(l,:));']);
    if length(fff)>fsize,
      fsize=length(fff);
      ff=ff*ones(1,fsize);
    elseif length(fff)<fsize,
      fff=fff*ones(1,fsize);
    end
    ff=[ff;fff];
  end
  eval([fn '=ff;']);
end

