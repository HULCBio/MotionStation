function [cgxu,cgyu]=pdecgrad(p,t,c,u,time,sdl)
%PDECGRAD Compute the flux, c*grad(u), of a PDE solution.
%
%       [CGXU,CGYU]=PDECGRAD(P,T,C,U) returns the flux, c*grad(u),
%       evaluated at the center of each triangle.
%
%       The geometry of the PDE problem is given by the triangle data P,
%       and T. Details under INITMESH.
%
%       The coefficient C of the PDE problem can be given in a wide
%       variety of ways. See ASSEMPDE for details.
%
%       The format for the solution vector U is described in ASSEMPDE.
%
%       [CGXU,CGYU]=PDECGRAD(P,T,C,U,TIME) is used if the C
%       coefficient is time dependent. TIME is the time.
%
%       [CGXU,CGYU]=PDECGRAD(P,T,C,U,TIME,SDL) restricts the computation
%       to the subdomains in the list SLD.
%
%       See also: ASSEMPDE, INITMESH, PDEGRAD

%       A. Nordmark 12-22-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:09 $

gottime=0;
gotsdl=0;

if nargin==4
  % No action
elseif nargin==5
  gottime=1;
elseif nargin==6
  gottime=1;
  gotsdl=1;
else
  error('PDE:pdecgrad:nargin', 'Wrong number of input arguments.');
end

if gotsdl
  it=pdesdt(t,sdl);
  if ~ischar(c) && size(c,2)==size(t,2)
    c=c(:,it);
  end
  t=t(:,it);
end

np=size(p,2);
nt=size(t,2);
N=size(u,1)/np;

if gottime
  c=pdetxpd(p,t,u,time,c);
else
  c=pdetxpd(p,t,u,c);
end

% grad u
[gxu,gyu]=pdegrad(p,t,u);

% c grad u
nrc=size(c,1);
cgxu=zeros(N,nt);
cgyu=zeros(N,nt);
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
  error('PDE:pdecgrad:NumRowsC', 'Wrong number of rows in c.')
end

