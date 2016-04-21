function K=poiasma(n1,n2,h1,h2)
%POIASMA Boundary point matrix contributions for Poisson's equation.
%
%       K=POIASMA(N1,N2,H1,H2) assembles the contributions to the
%       stiffness matrix from boundary points. N1 and N2 are the numbers
%       of points in the first and second directions, and H1 and H2 are
%       the mesh spacings. K is a sparse N1*N2 by N1*N2 matrix.
%       The point numbering is the canonical for a rectangular mesh.
%
%       K=POIASMA(N1,N2) uses H1=H2 and K=POIASMA(N) uses N1=N2=N.
%
%       See also FASTIX, POISOLV.

%       A. Nordmark 10-25-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:22 $

if nargin<=2,
  h1=1;h2=1;
end
if nargin==1,
  n2=n1;
end

alpha=h2/h1;
beta=h1/h2;

K=sparse(n1*n2,n1*n2);
K=K+sparse(2:n1,1:n1-1,-0.5*alpha,n1*n2,n1*n2);
K=K+sparse(n1*n2-n1+2:n1*n2,n1*n2-n1+1:n1*n2-1,-0.5*alpha,n1*n2,n1*n2);
K=K+sparse(n1+1:n1:n1*n2-n1+1,1:n1:n1*n2-2*n1+1,-0.5*beta,n1*n2,n1*n2);
K=K+sparse(2*n1:n1:n1*n2,n1:n1:n1*n2-n1,-0.5*beta,n1*n2,n1*n2);
K=K+sparse(n1+2:2*n1-1,2:n1-1,-beta,n1*n2,n1*n2);
K=K+sparse(n1*n2-n1+2:n1*n2-1,n1*n2-2*n1+2:n1*n2-n1-1,-beta,n1*n2,n1*n2);
K=K+sparse(n1+2:n1:n1*n2-2*n1+2,n1+1:n1:n1*n2-2*n1+1,-alpha,n1*n2,n1*n2);
K=K+sparse(2*n1-1:n1:n1*n2-n1-1,2*n1:n1:n1*n2-n1,-alpha,n1*n2,n1*n2);
K=K+K';
K=K+sparse(2:n1-1,2:n1-1,alpha+beta,n1*n2,n1*n2);
K=K+sparse(n1*n2-n1+2:n1*n2-1,n1*n2-n1+2:n1*n2-1,alpha+beta,n1*n2,n1*n2);
K=K+sparse(n1+1:n1:n1*n2-2*n1+1,n1+1:n1:n1*n2-2*n1+1,alpha+beta,n1*n2,n1*n2);
K=K+sparse(2*n1:n1:n1*n2-n1,2*n1:n1:n1*n2-n1,alpha+beta,n1*n2,n1*n2);
K(1,1)=0.5*(alpha+beta);
K(n1,n1)=0.5*(alpha+beta);
K(n1*n2-n1+1,n1*n2-n1+1)=0.5*(alpha+beta);
K(n1*n2,n1*n2)=0.5*(alpha+beta);

