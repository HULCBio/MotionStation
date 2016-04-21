function [p,e,t]=poimesh(g,n1,n2)
%POIMESH Make regular mesh on a rectangular geometry.
%
%       [P,E,T]=POIMESH(G,NX,NY) constructs a regular mesh
%       on the rectangular geometry specified by G, by dividing
%       the "x edge" into NX pieces and the "y edge" into NY pieces,
%       and placing (NX+1)*(NY+1) points at the intersections.
%
%       The x edge is the one that makes the smallest angle
%       with the x axis.
%
%       [P,E,T]=POIMESH(G,N) uses NX=NY=N, and
%       [P,E,T]=POIMESH(G) uses NX=NY=1;
%
%       For best performance with POISOLV, the larger of NX and NY
%       should be a power of 2.
%
%       If G does not seem to describe a rectangle, P is zero on return.
%
%       See also INITMESH, POISOLV

%       A. Nordmark 1-24-95.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:22 $

if nargin==2
  n2=n1;
elseif nargin==1
  n1=1;
  n2=1;
end

nbs=pdeigeom(g); % Number of boundary segments
% A rectangle has 4 BS
if nbs~=4
  p=0;
  return
end

d=pdeigeom(g,1:nbs);
% SD 0 must be on one side
if min(d(3:4,:))~=zeros(1,nbs)
  p=0;
  return
end
% and SD 1 on the other
if max(d(3:4,:))~=ones(1,nbs)
  p=0;
  return
end

% Start to identify points
[x,y]=pdeigeom(g,[1:nbs;1:nbs],d(1:2,:));
small=1000*eps; % Equality tolerance
scale=max(max(max(abs(x))),max(max(abs(y))));
tol=small*scale;

p=[x(1,1);y(1,1)]; % A first point
np=1;

for i=1:nbs,
  for j=1:2,
    xy=[x(j,i);y(j,i)];
    l=find(sum(abs(p(1:2,:)-xy*ones(1,size(p,2))))<tol);
    if isempty(l),
      p=[p [xy]]; % New point
      np=np+1;
      d(4+j,i)=np;
    else
      d(4+j,i)=l; % Old point
    end
  end
end
% Row 5 and 6 of d now contains indices of starting and ending points
% of each BS

if np~=4
  p=0;
  return
end

% Make SD 1 be on the left side
ix=find(d(4,:));
d([2 1 4 3 6 5],ix)=d(1:6,ix);

ev=[p(:,d(6,:))-p(:,d(5,:))];

% Small check for line-ness
nn=10; % for example
[x,y]=pdeigeom(g,(1:4)'*ones(1,nn), ...
     d(2,:)'*linspace(0,1,nn)+d(1,:)'*linspace(1,0,nn));
for k=1:4
  ev1=[diff(x(k,:));diff(y(k,:))];
  if any(ev1-ev(:,k)*ones(1,nn-1)/(nn-1)>small)
    p=0;
    return
  end
end

ev1=ev./(ones(2,1)*sqrt(ev(1,:).^2+ev(2,:).^2));

i1=find(ev1(1,:)==max(ev1(1,:)));
i1=i1(1);

% Find cycle
i2=find(d(5,:)==d(6,i1));
i3=find(d(5,:)==d(6,i2));
i4=find(d(5,:)==d(6,i3));

% last check for rectangle-ness
if abs(ev1(:,i2)'*ev1(:,i1))>small
  p=0;
  return
end
if abs(ev1(:,i3)'*ev1(:,i1)+1)>small
  p=0;
  return
end
if abs(ev1(:,i4)'*ev1(:,i1))>small
  p=0;
  return
end

p1=p(:,d(5,[i1 i2 i3 i4]));

% Generate mesh
np=(n1+1)*(n2+1);
ne=2*(n1+n2);
nt=2*n1*n2;

p=zeros(2,np);
e=zeros(7,ne);
t=zeros(4,nt);

ip=0:(np-1);
ip2=floor(ip/(n1+1));
ip1=(ip-(n1+1)*ip2);
p=p1(:,1)*ones(1,np)+[p1(:,2)-p1(:,1) p1(:,3)-p1(:,2)]*[ip1/n1; ip2/n2];

e(:,1:n1)= ...
[1:n1;2:(n1+1); ...
d(1,i1)+(0:(n1-1))/n1*(d(2,i1)-d(1,i1)); ...
d(1,i1)+(1:n1)/n1*(d(2,i1)-d(1,i1)); ...
i1*ones(1,n1);ones(1,n1);zeros(1,n1)];
e(:,n1+1:n1+n2)= ...
[n1+1:n1+1:n2*(n1+1);2*(n1+1):n1+1:(n2+1)*(n1+1); ...
d(1,i2)+(0:(n2-1))/n2*(d(2,i2)-d(1,i2)); ...
d(1,i2)+(1:n2)/n2*(d(2,i2)-d(1,i2)); ...
i2*ones(1,n2);ones(1,n2);zeros(1,n2)];
e(:,n1+n2+1:2*n1+n2)= ...
[(n2+1)*(n1+1):-1:n2*(n1+1)+2;(n2+1)*(n1+1)-1:-1:n2*(n1+1)+1; ...
d(1,i3)+(0:(n1-1))/n1*(d(2,i3)-d(1,i3)); ...
d(1,i3)+(1:n1)/n1*(d(2,i3)-d(1,i3)); ...
i3*ones(1,n1);ones(1,n1);zeros(1,n1)];
e(:,2*n1+n2+1:ne)= ...
[n2*(n1+1)+1:-(n1+1):n1+2;(n2-1)*(n1+1)+1:-(n1+1):1; ...
d(1,i4)+(0:(n2-1))/n2*(d(2,i4)-d(1,i4)); ...
d(1,i4)+(1:n2)/n2*(d(2,i4)-d(1,i4)); ...
i4*ones(1,n2);ones(1,n2);zeros(1,n2)];

it=0:(nt/2-1);
it2=floor(it/n1);
it1=(it-n1*it2);
t(1:4,1:(nt/2))=[it1+(n1+1)*it2+1;it1+(n1+1)*it2+2;it1+(n1+1)*(it2+1)+2;ones(1,nt/2)];
t(1:4,(nt/2+1):nt)=[it1+(n1+1)*it2+1;it1+(n1+1)*(it2+1)+2;it1+(n1+1)*(it2+1)+1;ones(1,nt/2)];

% Shuffle t to get around qsort() bug on some platforms
r=rand(1,nt);[r,i]=sort(r);t=t(:,i);

