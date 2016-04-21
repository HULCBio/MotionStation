function [ks,km,fm]=assema(p,t,c,a,f,u,time,sdl)
%ASSEMA Assembles area integral contributions in a PDE problem.
%
%       [K,M,F1]=ASSEMA(P,T,C,A,F) assembles the stiffness matrix K,
%       the mass matrix M, and the right-hand side vector F1.
%
%       The following call sequences are also allowed:
%       [K,M,F1]=ASSEMA(P,T,C,A,F,U0)
%       [K,M,F1]=ASSEMA(P,T,C,A,F,U0,TIME)
%       [K,M,F1]=ASSEMA(P,T,C,A,F,U0,TIME,SDL)
%       [K,M,F1]=ASSEMA(P,T,C,A,F,TIME)
%       [K,M,F1]=ASSEMA(P,T,C,A,F,TIME,SDL)
%
%       The input parameters P, T, C, A, F, U0, TIME, and SDL have the
%       same meaning as in ASSEMPDE.
%
%       See also ASSEMPDE

%       A. Nordmark 4-25-94, AN 8-01-94, AN 01-31-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/10/21 12:25:58 $

gotu=0;
gottime=0;
gotsdl=0;

if nargin==5
  % No action
elseif nargin==6
  if size(u,1)>1
    gotu=1;
  else
    time=u;
    gottime=1;
  end
elseif nargin==7
  if size(u,1)>1
    gotu=1;
    gottime=1;
  else
    sdl=time;
    time=u;
    gottime=1;
    gotsdl=1;
  end
elseif nargin==8,
  gotu=1;
  gottime=1;
  gotsdl=1;
else
  error('PDE:assema:nargin', 'Wrong number of input arguments.');
end

% Choose triangles to assemble
if gotsdl
  it=pdesdt(t,sdl);
  t=t(:,it);
end

if ~gottime
  time=[];
end

nt=size(t,2); % Number of triangles
np=size(p,2); % Number of points

% Corner point indices
it1=t(1,:);
it2=t(2,:);
it3=t(3,:);

% Triangle geometries:
[ar,g1x,g1y,g2x,g2y,g3x,g3y]=pdetrg(p,t);

% Find midpoints of triangles
x=(p(1,it1)+p(1,it2)+p(1,it3))/3;
y=(p(2,it1)+p(2,it2)+p(2,it3))/3;

sd=t(4,:);

if ~gotu,
  uu=[];
  u=[];
  ux=[];
  uy=[];
else
  uu=u;
  N=length(uu)/np;
  uu=reshape(uu,np,N);
  u=(uu(it1,:).'+uu(it2,:).'+uu(it3,:).')/3;
  ux=uu(it1,:).'.*(ones(N,1)*g1x)+uu(it2,:).'.*(ones(N,1)*g2x)+ ...
     uu(it3,:).'.*(ones(N,1)*g3x);
  uy=uu(it1,:).'.*(ones(N,1)*g1y)+uu(it2,:).'.*(ones(N,1)*g2y)+ ...
     uu(it3,:).'.*(ones(N,1)*g3y);
  uu=reshape(uu,np*N,1);
end

if ~gotu,
  % The number of variables IS the number of rows in F
  N=size(f,1);
end

% Stiffness matrix
c=pdetfxpd(p,t,uu,time,c);

if any(c(:)),
  ks=sparse(N*np,N*np);

  nrc=size(c,1);

  if nrc>=1 && nrc<=4, % Block scalar c
    ks1=pdeasmc(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,g1x,g1y,g2x,g2y,g3x,g3y,c);
    [ii,jj,kss]=find(ks1);
    for k=1:N,
      ks=ks+sparse(ii+(k-1)*np,jj+(k-1)*np,kss,N*np,N*np);
    end
  elseif nrc==N || nrc==2*N || nrc==3*N || nrc==4*N, % Block diagonal c
    nb=nrc/N;
    m1=1;
    m2=nb;
    for k=1:N,
      ks1=pdeasmc(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,g1x,g1y,g2x,g2y,g3x,g3y,c(m1:m2,:));
      [ii,jj,kss]=find(ks1);
      ks=ks+sparse(ii+(k-1)*np,jj+(k-1)*np,kss,N*np,N*np);
      m1=m1+nb;
      m2=m2+nb;
    end
  elseif nrc==2*N*(2*N+1)/2, % Symmetric c
    m1=1;
    m2=4;
    for l=1:N,
      for k=1:l-1,
        ks1=pdeasmc(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,g1x,g1y,g2x,g2y,g3x,g3y,c(m1:m2,:));
        [ii,jj,kss]=find(ks1);
        ks=ks+sparse(ii+(k-1)*np,jj+(l-1)*np,kss,N*np,N*np);
        m1=m1+4;
        m2=m2+4;
      end
      m1=m1+3;
      m2=m2+3;
    end
    ks=ks+ks.';
    m1=1;
    m2=3;
    for k=1:N,
      ks1=pdeasmc(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,g1x,g1y,g2x,g2y,g3x,g3y,c(m1:m2,:));
      [ii,jj,kss]=find(ks1);
      ks=ks+sparse(ii+(k-1)*np,jj+(k-1)*np,kss,N*np,N*np);
      m1=m1+3+4*k;
      m2=m2+3+4*k;
    end
  elseif nrc==4*N*N, % General (unsymmetric) c
    m1=1;
    m2=4;
    for l=1:N,
      for k=1:N,
        ks1=pdeasmc(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,g1x,g1y,g2x,g2y,g3x,g3y,c(m1:m2,:));
        [ii,jj,kss]=find(ks1);
        ks=ks+sparse(ii+(k-1)*np,jj+(l-1)*np,kss,N*np,N*np);
        m1=m1+4;
        m2=m2+4;
      end
    end
  else
    error('PDE:assema:NumRowsC', 'Wrong number of rows of c.');
  end % nrc
  clear c ks1;
else
  clear c;
  ks=sparse(N*np,N*np);
end

% Mass matrix
a=pdetfxpd(p,t,uu,time,a);

if any(a(:)),
  km=sparse(N*np,N*np);

  nra=size(a,1);

  if nra==1, % Scalar a
    km1=pdeasma(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,a);
    [ii,jj,kmm]=find(km1);
    for k=1:N,
      km=km+sparse(ii+(k-1)*np,jj+(k-1)*np,kmm,N*np,N*np);
    end
  elseif nra==N, % Diagonal a
    for k=1:N,
      km1=pdeasma(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,a(k,:));
      [ii,jj,kmm]=find(km1);
      km=km+sparse(ii+(k-1)*np,jj+(k-1)*np,kmm,N*np,N*np);
    end
  elseif nra==N*(N+1)/2, % Symmetric a
    m=1;
    for l=1:N,
      for k=1:l-1,
        km1=pdeasma(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,a(m,:));
        [ii,jj,kmm]=find(km1);
        km=km+sparse(ii+(k-1)*np,jj+(l-1)*np,kmm,N*np,N*np);
        m=m+1;
      end
      m=m+1;
    end
    km=km+km.';
    m=1;
    for k=1:N,
      km1=pdeasma(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,a(m,:));
      [ii,jj,kmm]=find(km1);
      km=km+sparse(ii+(k-1)*np,jj+(k-1)*np,kmm,N*np,N*np);
      m=m+1+k;
    end
  elseif nra==N*N, % General (unsymmetric) a
    m=1;
    for l=1:N,
      for k=1:N,
        km1=pdeasma(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,a(m,:));
        [ii,jj,kmm]=find(km1);
        km=km+sparse(ii+(k-1)*np,jj+(l-1)*np,kmm,N*np,N*np);
        m=m+1;
      end
    end
  else
    error('PDE:assema:NumRowsA','Wrong number of rows of a.');
  end % nra
  clear a km1;
else
  clear a;
  km=sparse(N*np,N*np);
end

% RHS
f=pdetfxpd(p,t,uu,time,f);

if any(f(:)),
  fm=zeros(N*np,1);

  nrf=size(f,1);

  if nrf==1, % Scalar f
    fm1=pdeasmf(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,f);
    for k=1:N,
      fm((k-1)*np+1:k*np,:)=fm1;
    end
  elseif nrf==N, % Vector f
    for k=1:N,
      fm1=pdeasmf(it1,it2,it3,np,ar,x,y,sd,u,ux,uy,time,f(k,:));
      fm((k-1)*np+1:k*np,:)=fm1;
    end
  else
    error('PDE:assema:NumRowsF', 'Wrong number of rows of f.');
  end % size(f,1)
  clear f fm1;
else
  clear f;
  fm=zeros(N*np,1);
end


