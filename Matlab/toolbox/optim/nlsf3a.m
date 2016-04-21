function [Fvec,J] = nlsf3a(x,S);
%NLSF3A Test function
%
%  Evaluate a ``structured'' vector function Fvec,
%
%     Fvec = F(A^{-1}*F(x))
%  
%  where F is a nonlinear square mapping,
%  with tridiagonal Jacobian, and A = A(x)
%  is a symmetric positive definite matrix.
%
%
%  Fvec is the vector function evaluated at x, dx is the Newton step,
%  J is returned as an array containing the sparse Jacobian ``components''.
%  The array J can be used with function nlsmm3 to compute corresponding
%  matrix-vector products. Note that the Jacobian of Fvec is
%  never explicitly computed.
%

%   Copyright 1990-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.2 $  $Date: 2004/02/07 19:13:20 $
n=length(x);
%
%  Evaluate F(x) = nlsf1(x), and the corresponding Jacobian matrix.
[y1,Jtilda]=nlsf3b(x);
%
%  Evaluate matrix A, SPD
%
%  Evaluate A
A=compa(x,S);
%  
%  Determine MDO of A, sparse Cholesky factor
p = symamd(A);
R = chol(A(p,p));
%
%  Solve for A^{-1}*F(x).
w = R'\y1(p); y2(p,1) = R\w;
%
%  Compute the vector function Fvec and the Jacobian of F with respect to
%  the argument y2 (tri-diagonal) 
[Fvec,Jbar]=nlsf3b(y2);
%
%  Form the extended Jacobian matrix and sparse solve for the
%  Newton step.
JA = jaca(x,y2,S);
JE=[-Jtilda, eye(n,n), zeros(n,n);
   JA, -eye(n,n), A;
   zeros(n,n), zeros(n,n), -Jbar];
%
%  Save the sparse components of the Jacobian of Fvec in array J.
J = [Jtilda-JA, Jbar,R,p'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[fvec,A] = nlsf3b(x);
%
% Evaluate  nonlinear equations test function.
%
% INPUT:
%     x - The current point (column vector).
%
% OUTPUT:
%  fvec - The (vector) function value at x.
%  A    - The (sparse) rectangular Jacobian matrix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Evaluate the vector function
n = length(x);
i=2:(n-1);
fvec(i,1)= (3-2*x(i,1).^3).*x(i,1)-x(i-1,1)-2*x(i+1,1)+ones(n-2,1);
fvec(n,1)= (3-2*x(n,1).^3).*x(n,1)-x(n-1,1)+1;
fvec(1,1)= (3-2*x(1,1).^3).*x(1,1)-2*x(2,1)+1;
%
% Evaluate the Jacobian?
if nargout > 1
   d = -8*x.^3 + 3*ones(n,1); D = sparse(1:n,1:n,d,n,n);
   c = -2*ones(n-1,1); C = sparse(1:n-1,2:n,c,n,n);
   e = -ones(n-1,1); E = sparse(2:n,1:n-1,e,n,n);
   A = C + D + E;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A=jaca(x,y,S)
%JACA   Sparse derivative mtx (nlsf3/compa) 
 
% computes derivative matrix M_x*y where
% M is a sparse matrix with sparsity structure
% given by S. The nonzero elements of M
% are functions of x and defined as follows:
%
% M(i,j)=x(i)+x(j) if i\=j
% and M(i,i)=1+2*(sum of square nnz elements in row i)
%
% Initialization
  [row,col]=find(S);
  n=length(x);
  m =length(row);
  A=sparse(n,n);
%
% Evaluate A
  for k=1:m
      i=row(k);
      j=col(k);
      if i>j
              A(i,j) = 4*(x(i)+x(j))*y(i) + y(j);
              A(j,j) = A(j,j) + 4*(x(i)+x(j))*y(j) + y(i);
              A(j,i) = 4*(x(i)+x(j))*y(j) + y(i);
              A(i,i) = A(i,i) + 4*(x(i)+x(j))*y(i) + y(j);
      end
  end
  
  function A=compa(x,S)
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%COMPA  Matrix function (nlsf3)
%
% A has same sparsity as S. A is SPD.
%
% A(i,j)=x(i)+x(j) if i\=j
% and A(i,i)=1+2*(sum of square nnz elements in row i)
%
% Initialization
  [row,col]=find(S);
  n=length(x);
  m =length(row);
  A=sparse(1:n,1:n,ones(n,1));
%
% Evaluate  A
  for k=1:m
        i=row(k);
        j=col(k);
        if i>j
              A(i,j) = x(i)+x(j);
              A(j,i) = x(i)+x(j);
              A(i,i) = A(i,i) + 2*A(i,j)^2;
              A(j,j) = A(j,j) + 2*A(i,j)^2;
        end
  end
