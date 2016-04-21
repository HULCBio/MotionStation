function x=poicalc(f,h1,h2,n1,n2)
%POICALC Fast solver for Poisson's equation on a rectangular grid.
%
%       U=POICALC(F,H1,H2,N1,N2) calculates the solution of
%       Poisson's equation for the interior points of an
%       evenly spaced rectangular grid. The columns of U
%       contain the solutions corresponding to the columns
%       of the right-hand side F. H1 and H2 are the spacings
%       in the first and second direction, and N1 and N2 are
%       the number of points.
%
%       The number of rows in F must be N1*N2. If N1 and N2
%       are not given, the square root of the number of rows
%       of F is assumed. If H1 and H2 are not given, they are
%       assumed to be equal.
%
%       The ordering of the rows in U and F is the canonical
%       ordering of interior points, as returned by POIINDEX.
%
%       Solution is obtained by sine transforms in the first
%       direction and tridiagonal matrix solution in the second
%       direction. N1 should be 1 less than a power of 2 for best
%       performance.
%
%       See also POIINDEX, POIASMA, DST, IDST, POISOLV.

%       A. Nordmark 10-25-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $  $Date: 2004/01/16 20:06:38 $

nf=size(f,1);
m=size(f,2);
if nargin<=3,
  n1=fix(sqrt(nf));
  n2=n1;
end
if nf~=n1*n2,
  error('PDE:poicalc:NumRowsF', 'wrong number of rows in f.');
end
if nargin==1,
  h1=1;
  h2=1;
end
alpha=h2/h1;
beta=h1/h2;

ff=zeros(n1,m*n2);
for i=1:n2,
  ff(:,(i-1)*m+1:i*m)=f((i-1)*n1+1:i*n1,:);
end
c=idst(ff);

%In case sparse \ falls through to the v5-era solver that uses colmmd and symmmd:
%Tridiagonal is a good enough preordering!
ammd=spparms('autommd');
spparms('autommd',0);
l=2*(alpha+beta)-2*alpha*cos(pi*(1:n1)'/(n1+1));
v=zeros(n1,m*n2);
trid=sparse(1:n2-1,2:n2,-beta,n2,n2);
trid=trid+trid';
for i=1:n1,
  trid(1:n2+1:n2^2)=l(i)*ones(1,n2);
  cc=reshape(c(i,:)',m,n2)';
  vv=trid\cc;
  v(i,:)=reshape(vv',m*n2,1)';
end
spparms('autommd',ammd);
xx=dst(v);
x=zeros(nf,m);
for i=1:n2,
  x((i-1)*n1+1:i*n1,:)=xx(:,(i-1)*m+1:i*m);
end

