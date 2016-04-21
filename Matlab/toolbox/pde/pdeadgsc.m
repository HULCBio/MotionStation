function bt=pdeadgsc(p,t,c,a,f,u,errf,tol)
%PDEADGSC Select triangles using a relative tolerance criterion
%
%       BT=PDEADGSC(P,T,C,A,F,U,ERRF,TOL) returns indices of triangles
%       to be refined in BT.
%
%       The geometry of the PDE problem is given by the triangle data P,
%       and T. Details under INITMESH.
%
%       C, A, and F are PDE coefficients. See ASSEMPDE for details.
%
%       U is the current solution, given as a column vector.
%       See ASSEMPDE for details.
%
%       ERRF is the error indicator, as calculated by PDEJMPS.
%
%       TOL is a tolerance parameter.
%
%       Triangles are selected using the criterion
%       ERRF>TOL*SCALE, where SCALE is calculated as follows: Let
%       CMAX be the maximum of C.
%       AMAX be the maximum of A.
%       FMAX be the maximum of F.
%       UMAX be the maximum of U.
%       L be the side of the smallest axis-aligned square that contains
%       the geometry.
%
%       Then SCALE=MAX(FMAX*L^2,AMAX*UMAX*L^2,CMAX*UMAX). The scaling
%       makes the TOL parameter independent of the scaling of the equation
%       and the geometry.
%
%       See also ADAPTMESH, PDEJMPS

%       A. Nordmark 12-05-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.9.4.1 $  $Date: 2003/11/01 04:28:04 $

% Same mexp as in ADAPTMESH
mexp=1;

np=size(p,2);
nt=size(t,2);
N=length(u)/np;

x=p(1,:);
y=p(2,:);
lscale=max(max(x)-min(x),max(y)-min(y));

u=reshape(u,np,N);
uscale=max(abs(u)).';

c=abs(c);
if size(c,2)>1
  c=max(c')';
end
nrc=size(c,1);
if nrc>=1 && nrc<=4, % Block scalar c
  c=max(c);
  cscale=c*eye(N);
elseif nrc==N || nrc==2*N || nrc==3*N || nrc==4*N, % Block diagonal c
  nbc=nrc/N;
  for k=1:N,
    c(k)=max(c(1+(k-1)*nbc:k*nbc));
  end
  cscale=diag(c(1:N));
elseif nrc==2*N*(2*N+1)/2, % Symmetric c
  cscale=zeros(N,N);
  mm=cumsum(1:N);
  m=4*ones(1,N*(N+1)/2);
  m(mm)=3*ones(size(mm));
  m2=cumsum(m);
  for k=1:N*(N+1)/2
    c(k)=max(c(m2(k)-m(k)+1:m2(k)));
  end
  m=1;
  for k=1:N
    for l=1:k
      cscale(l,k)=c(m);
      m=m+1;
    end
  end
  cscale=max(cscale,cscale');
elseif nrc==4*N*N, % General (unsymmetric) c
  for k=1:N^2
    c(k)=max(c(1+(k-1)*4:k*4));
  end
  cscale=reshape(c(1:N*N),N,N);
else
  error('PDE:pdeadgsc:NumRowsC', 'Wrong number of rows of c.');
end % nrc

a=abs(a);
if size(a,2)>1
  a=max(a')';
end
nra=size(a,1);
if nra==1, % Scalar a
  ascale=a*eye(N);
elseif nra==N, % Diagonal a
  ascale=diag(a);
elseif nra==N*(N+1)/2, % Symmetric a
  m=1;
  for k=1:N
    for l=1:k
      ascale(l,k)=a(m);
      m=m+1;
    end
  end
  ascale=max(a,a');
elseif nra==N*N, % General (unsymmetric) a
  ascale=reshape(a,N,N);
else
  error('PDE:pdeadgsc:NumRowsA', 'Wrong number of rows of a.');
end % nra

f=abs(f);
if size(f,2)>1
  f=max(f')';
end
nrf=size(f,1);
if nrf==1,
  fscale=ones(N,1)*f;
elseif nrf==N,
  fscale=f;
else
  error('PDE:pdeadgsc:NumRowsF', 'Wrong number of columns in f.');
end %nrf

scale=max([fscale ascale*uscale cscale*uscale*lscale^(-2)]')'*lscale^(mexp+1);
bad=errf>tol*scale*ones(1,nt);
if N>1
  bad=max(bad);
end
bt=find(bad);

