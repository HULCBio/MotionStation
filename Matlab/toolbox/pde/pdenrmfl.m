function ddncu = pdenrmfl(p,t,c,u,ar,sl)
%PDENRMFL Fluxes of -div(c grad(u)) through edges of triangles.

%       J. Oppelstrup 10-24-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:11:34 $

[dum,nnod]= size(p);
[dum,nel]= size(t);
[dum,csize]= size(c);
N=length(u)/nnod;

%    ar- triangle areas
%    sl- triangle side lengths

dx = zeros(3,nel); dy = zeros(3,nel);
for j = 1:3,
   j1 = rem(j ,3)+1;
   j2 = rem(j1,3)+1;
   dx(j,:) = p(1,t(j1,:)) - p(1,t(j2,:));
   dy(j,:) = p(2,t(j1,:)) - p(2,t(j2,:));
   end;
% gradients of basis functions
g1x=0.5*dy(1,:)./ar;
g2x=0.5*dy(2,:)./ar;
g3x=0.5*dy(3,:)./ar;
g1y=-0.5*dx(1,:)./ar;
g2y=-0.5*dx(2,:)./ar;
g3y=-0.5*dx(3,:)./ar;
% gradients of solution u
uu=reshape(u,nnod,N);
it1=t(1,:);
it2=t(2,:);
it3=t(3,:);
gxu = uu(it1,:).'.*(ones(N,1)*g1x)+uu(it2,:).'.*(ones(N,1)*g2x)+ ...
      uu(it3,:).'.*(ones(N,1)*g3x);
gyu = uu(it1,:).'.*(ones(N,1)*g1y)+uu(it2,:).'.*(ones(N,1)*g2y)+ ...
      uu(it3,:).'.*(ones(N,1)*g3y);

% c grad u
nrc=size(c,1);
cgxu=zeros(N,nel);
cgyu=zeros(N,nel);
if nrc==1
  for k=1:N
    cgxu(k,:)=c.*gxu(k,:);
    cgyu(k,:)=c.*gyu(k,:);
  end
elseif nrc==2
  for k=1:N
    cgxu(k,:)=c(1,:).*gxu(k,:);
    cgyu(k,:)=c(2,:).*gyu(k,:);
  end
elseif nrc==3
  for k=1:N
    cgxu(k,:)=c(1,:).*gxu(k,:)+c(2,:).*gyu(k,:);
    cgyu(k,:)=c(2,:).*gxu(k,:)+c(3,:).*gyu(k,:);
  end
elseif nrc==4
  for k=1:N
    cgxu(k,:)=c(1,:).*gxu(k,:)+c(3,:).*gyu(k,:);
    cgyu(k,:)=c(2,:).*gxu(k,:)+c(4,:).*gyu(k,:);
  end
elseif nrc==N
  for k=1:N
    cgxu(k,:)=c(1+1*(k-1),:).*gxu(k,:);
    cgyu(k,:)=c(1+1*(k-1),:).*gyu(k,:);
  end
elseif nrc==2*N
  for k=1:N
    cgxu(k,:)=c(1+2*(k-1),:).*gxu(k,:);
    cgyu(k,:)=c(2+2*(k-1),:).*gyu(k,:);
  end
elseif nrc==3*N
  for k=1:N
    cgxu(k,:)=c(1+3*(k-1),:).*gxu(k,:)+c(2+3*(k-1),:).*gyu(k,:);
    cgyu(k,:)=c(2+3*(k-1),:).*gxu(k,:)+c(3+3*(k-1),:).*gyu(k,:);
  end
elseif nrc==4*N
  for k=1:N
    cgxu(k,:)=c(1+4*(k-1),:).*gxu(k,:)+c(3+4*(k-1),:).*gyu(k,:);
    cgyu(k,:)=c(2+4*(k-1),:).*gxu(k,:)+c(4+4*(k-1),:).*gyu(k,:);
  end
elseif nrc==2*N*(2*N+1)/2
  m=1;
  for l=1:N
    for k=1:l-1
      cgxu(k,:)=cgxu(k,:)+c(m,:).*gxu(l,:)+c(m+2,:).*gyu(l,:);
      cgyu(k,:)=cgyu(k,:)+c(m+1,:).*gxu(l,:)+c(m+3,:).*gyu(l,:);
      cgxu(l,:)=cgxu(l,:)+c(m,:).*gxu(k,:)+c(m+1,:).*gyu(k,:);
      cgyu(l,:)=cgyu(l,:)+c(m+2,:).*gxu(k,:)+c(m+3,:).*gyu(k,:);
      m=m+4;
    end
    cgxu(l,:)=cgxu(l,:)+c(m,:).*gxu(l,:)+c(m+1,:).*gyu(l,:);
    cgyu(l,:)=cgyu(l,:)+c(m+1,:).*gxu(l,:)+c(m+2,:).*gyu(l,:);
    m=m+3;
  end
elseif nrc==4*N*N
  for k=1:N
    for l=1:N
      cgxu(k,:)=cgxu(k,:)+c(1+4*(k-1+N*(l-1)),:).*gxu(k,:)+ ...
                c(3+4*(k-1+N*(l-1)),:).*gyu(k,:);
      cgyu(k,:)=cgyu(k,:)+c(2+4*(k-1+N*(l-1)),:).*gxu(k,:)+ ...
                c(4+4*(k-1+N*(l-1)),:).*gyu(k,:);
    end
  end
else
  error('PDE:pdenrmfl:NumRowsC', 'Wrong number of rows in c.')
end

% nhat'*c grad u
% edge unit normals : outwards positive if the nodes are in
% anti-clockwise order
% nhatx =   dy./s;
% nhaty = - dx./s;
ddncu = zeros(3*N,nel);
for k=1:N
  for l = 1:3
    ddncu(l+3*(k-1),:) = (dy(l,:).*cgxu(k,:) - dx(l,:).*cgyu(k,:))./sl(l,:);
  end
end

