function [q,g,h,r]=pdeexpd(p,e,u,time,bl)
%PDEEXPD Evaluate on edges.

%       A. Nordmark 1-13-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.2 $  $Date: 2004/04/16 22:10:10 $

gotu=0;
gottime=0;

if nargin==3
  bl=u;
elseif nargin==4
  bl=time;
  if size(u,1)>1
    gotu=1;
  else
    time=u;
    gottime=1;
  end
elseif nargin==5
  gotu=1;
  gottime=1;
else
  error('PDE:pdeexpd:nargin', 'Wrong number of input arguments.');
end

np=size(p,2);
ne=size(e,2);

if ~gottime
  time=[];
end

if ~gotu
  u=[];
end

% Try the function case
[q,g,h,r]=pdeefxpd(p,e,u,time,bl);
if ~isempty(q)
  % Great, we are done
  return
end

% Now for the real work
% bl is a boundary condition matrix

% Determine number of variables
if gotu
  N=size(u,1)/np;
  if N~=max(bl(1,:))
    error('PDE:pdeexpd:NumVarsMismatch',...
        'Number of variables mismatch between u and bl.')
  end
else
  N=max(bl(1,:));
end

if gotu
  uu=reshape(u,np,N);
  % Interpolate to edge midpoints
  ue=(uu(e(1,:),:)+uu(e(2,:),:)).'/2;
  % Values at endpoints
  up=[uu(e(1,:),:);uu(e(2,:),:)].';
else
  ue=[];
  up=[];
end

% Coordinates
xe=(p(1,e(1,:))+p(1,e(2,:)))/2;
ye=(p(2,e(1,:))+p(2,e(2,:)))/2;
xp=[p(1,e(1,:)) p(1,e(2,:))];
yp=[p(2,e(1,:)) p(2,e(2,:))];

% Parameter values
se=(e(3,:)+e(4,:))/2;
sp=[e(3,:) e(4,:)];

% Edge related unit vectors
ls=find(e(6,:)==0 & e(7,:)>0); % External region to the left
rs=find(e(7,:)==0 & e(6,:)>0); % External region to the right
nxe=NaN*zeros(1,ne);
nye=NaN*zeros(1,ne);
dx=xp(ne+1:2*ne)-xp(1:ne);
dy=yp(ne+1:2*ne)-yp(1:ne);
dl=sqrt(dx.^2+dy.^2);
nxe(rs)=dy(rs)./dl(rs);
nye(rs)=-dx(rs)./dl(rs);
nxe(ls)=-dy(ls)./dl(ls);
nye(ls)=dx(ls)./dl(ls);
nxp=[nxe nxe];
nyp=[nye nye];

bs=e(5,:);
nbs=size(bl,2);

if find(bs<1 | bs>nbs),
  error('PDE:pdeexpd:InvalidBoundSeg', 'Boundary segment number does not exist.')
end

q=zeros(N*N,ne);
g=zeros(N,ne);
h=zeros(N*N,2*ne);
r=zeros(N,2*ne);

for k=1:nbs,
  if bl(1,k)~=0
    ii=find(bs==k);
    if ~isempty(ii)
      iii=[ii ii+ne]; % for h & r
      % Number of Dirichlet conditions
      M=bl(2,k);
      % lengths
      ql=bl(3:3+N^2-1,k);
      gl=bl(3+N^2:3+N^2+N-1,k);
      hl=bl(3+N^2+N:3+N^2+N+M*N-1,k);
      rl=bl(3+N^2+N+M*N:3+N^2+N+M*N+M-1,k);
      % beginning indices
      qb=cumsum(ql);
      qb=3+N^2+N+M*N+M+[0;qb(1:N^2-1,1)];
      gb=cumsum(gl);
      gb=3+N^2+N+M*N+M+sum(ql)+[0;gb(1:N-1,1)];
      hb=cumsum(hl);
      hb=3+N^2+N+M*N+M+sum(ql)+sum(gl)+[0;hb(1:M*N-1,1)];
      rb=cumsum(rl);
      rb=3+N^2+N+M*N+M+sum(ql)+sum(gl)+sum(hl)+[0;rb(1:M-1,1)];

      if size(ue)==[0 0]
        ueii=[];
        upiii=[];
      else
        ueii=ue(:,ii);
        upiii=up(:,iii);
      end

      % q
      for l=1:N^2
        q(l,ii)=pdeeexpd(xe(ii),ye(ii),se(ii),nxe(ii),nye(ii), ...
                         ueii,time, ...
                         char(bl(qb(l):qb(l)+ql(l)-1,k)));
      end
      % g
      for l=1:N
        g(l,ii)=pdeeexpd(xe(ii),ye(ii),se(ii),nxe(ii),nye(ii), ...
                         ueii,time, ...
                         char(bl(gb(l):gb(l)+gl(l)-1,k)));
      end
      % h
      h(:,iii)=zeros(N^2,length(iii)); % pad with zeros
      m=1;
      for l1=1:N
        for l=1:M
          h(l+N*(l1-1),iii)=pdeeexpd(xp(iii),yp(iii),sp(iii), ...
                                     nxp(iii),nyp(iii), ...
                                     upiii,time, ...
                                     char(bl(hb(m):hb(m)+hl(m)-1,k)));
          m=m+1;
        end
      end
      % r
      r(:,iii)=zeros(N,length(iii)); % pad with zeros
      for l=1:M
        r(l,iii)=pdeeexpd(xp(iii),yp(iii),sp(iii), ...
                          nxp(iii),nyp(iii), ...
                          upiii,time, ...
                          char(bl(rb(l):rb(l)+rl(l)-1,k)));
      end
    end % ~isempty(ii)
  end % bl(1,k)~=0
end % k=1:nbs

