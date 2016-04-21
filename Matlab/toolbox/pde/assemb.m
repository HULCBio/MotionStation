function [Q,G,H,R]=assemb(bl,p,e,u,time,sdl)
%ASSEMB Assembles boundary condition contributions in a PDE problem.
%
%       [Q,G,H,R]=ASSEMB(B,P,E) assembles the matrices Q and
%       H, and the vectors G and R.
%       Q should be added to the system matrix and contains contributions
%       from Mixed boundary conditions.
%       G should be added to the right-hand side and contains contributions
%       from Neumann and Mixed boundary conditions.
%       H*u=R represents the Dirichlet type boundary conditions.
%
%       The following call sequences are also allowed:
%       [Q,G,H,R]=ASSEMB(B,P,E,U0)
%       [Q,G,H,R]=ASSEMB(B,P,E,U0,TIME)
%       [Q,G,H,R]=ASSEMB(B,P,E,U0,TIME,SDL)
%       [Q,G,H,R]=ASSEMB(B,P,E,TIME)
%       [Q,G,H,R]=ASSEMB(B,P,E,TIME,SDL)
%
%       The input parameters B, P, E, U0, TIME, and SDL have the same
%       meaning as in ASSEMPDE.
%
%       See also ASSEMPDE, PDEBOUND

%       A. Nordmark 11-08-94, AN 12-20-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/10/21 12:25:59 $


gotu=0;
gottime=0;
gotsdl=0;

if nargin==3
  % No action
elseif nargin==4
  if size(u,1)>1
    gotu=1;
  else
    time=u;
    gottime=1;
  end
elseif nargin==5
  if size(u,1)>1
    gotu=1;
    gottime=1;
  else
    sdl=time;
    time=u;
    gottime=1;
    gotsdl=1;
  end
elseif nargin==6,
  gotu=1;
  gottime=1;
  gotsdl=1;
else
  error('PDE:assemb:nargin', 'Wrong number of input arguments.');
end

if ~gotsdl
  ie=pdesde(e);
else
  ie=pdesde(e,sdl);
end

np=size(p,2); % Number of points

if gotu
  N=size(u,1)/np;
end

% Stupid case where we must determine the number of variables in a kludgy way
if length(ie)==0 && ~gotu
  % Look at the first edge
  [q,g,h,r]=pdeexpd(p,e(:,1),bl);
  N=size(g,1);
end

% Nothing to do?
if length(ie)==0
  Q=sparse(N*np,N*np);
  G=sparse(N*np,1);
  H=sparse(N*np,N*np);
  R=sparse(N*np,1);
  % Done
  return;
end

% Get rid of unwanted edges
e=e(:,ie);

ne=size(e,2); % Number of edges

if ~gotu && ~gottime
  [q,g,h,r]=pdeexpd(p,e,bl);
elseif gotu && ~gottime
  [q,g,h,r]=pdeexpd(p,e,u,bl);
elseif ~gotu && gottime
  [q,g,h,r]=pdeexpd(p,e,time,bl);
else % gotu & gottime
  [q,g,h,r]=pdeexpd(p,e,u,time,bl);
end

if ~gotu
  N=size(g,1);
end

Q=sparse(N*np,N*np);
G=sparse(N*np,1);
H=sparse(N*np,N*np);
R=sparse(N*np,1);

ie1=e(1,:);
ie2=e(2,:);
d=sqrt((p(1,ie1)-p(1,ie2)).^2+(p(2,ie1)-p(2,ie2)).^2); % Side length

% G
if any(size(g)-[N ne])
  error('PDE:assemb:SizeG', 'g has wrong size.');
end
if any(g(:))
  g=(g.*(ones(N,1)*d/2));
  for k=1:N
	G=G+sparse(ie1+(k-1)*np,1,g(k,:),N*np,1);
    G=G+sparse(ie2+(k-1)*np,1,g(k,:),N*np,1);
  end
end

% Q
if any(size(q)-[N^2 ne])
  error('PDE:assemb:SizeQ', 'q has wrong size.');
end
if any(q(:))
  qd=(q.*(ones(N*N,1)*d/3)); % Diagonal values
  qod=0.5*qd; % Off diagonal values
  m=1;
  for l=1:N,
    for k=1:N,
      Q=Q+sparse(ie1+(k-1)*np,ie2+(l-1)*np,qod(m,:),N*np,N*np);
      Q=Q+sparse(ie2+(k-1)*np,ie1+(l-1)*np,qod(m,:),N*np,N*np);
      Q=Q+sparse(ie1+(k-1)*np,ie1+(l-1)*np,qd(m,:),N*np,N*np);
      Q=Q+sparse(ie2+(k-1)*np,ie2+(l-1)*np,qd(m,:),N*np,N*np);
	  m=m+1;
    end
  end
end

if any(size(h)-[N^2 2*ne])
  error('PDE:assemb:SizeH', 'h has wrong size.');
end
if any(size(r)-[N 2*ne])
  error('PDE:assemb:SizeR', 'r has wrong size.');
end
if any(h(:))

  % Preprocess h & r

  ie=[ie1 ie2];
  % Now remove redundant entries
  [ie,k]=sort(ie);
  h=h(:,k);
  r=r(:,k);

  k=diff(ie);
  kk=find(k);
  k(kk)=ones(size(kk));
  iie=cumsum([1 k]);
  aa=sparse(1:length(ie),iie,0.5);
  ie=ie([kk length(ie)]);
  h=h*aa;
  r=r*aa;

  nie=length(ie);

  % Spread out to one equation per column
  ie=ones(N,1)*ie;
  ie=ie(:)';
  i1=(1:N)'*ones(1,N);
  i1=ones(N*N,1)*N*(0:nie-1)+i1(:)*ones(1,nie);
  i2=ones(N,1)*(1:N);
  i2=i2(:)*ones(1,nie);
  hh=zeros(N,N*nie);
  hh(i2+N*(i1-1))=h(:);
  h=hh;
  r=r(:).';
  nie=length(ie);

  % Remove more redundancy
  if N==1
    k=find(h);
  else
    k=find(max(abs(h)));
  end
  ie=ie(k);
  h=h(:,k);
  r=r(:,k);
  nie=length(ie);

  % H
  i1=ones(N,1)*(1:nie);
  i2=ones(N,1)*ie+(0:N-1)'*np*ones(1,nie);
  H=sparse(i1,i2,h,nie,N*np);

  % R
  
  R=sparse(1:nie,1,r,nie,1);

end


