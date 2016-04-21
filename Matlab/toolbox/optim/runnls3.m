function runnls3
% RUNNLS3 demonstrates 'JacobMult' option for LSQNONLIN.
% This example demonstrates how to solve a structured
% nonlinear equation problem of the form F(x) = 0
% where F = G(y) and y is obtained by solving a sparse SPD
% symmetric positive definite system Ay = G(x). 
% F(x) has a tridiagonal Jacobian matrix.
% Components of the jacobian matrix are computed
% but the explicit Jacobian is never actually formed.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.2 $  $Date: 2004/02/07 19:13:52 $

% Initialization
  m = 20;
  n = m^2;
  fun = @nlsf3a; 
  xstart = 15*ones(n,1);
%  Get S the structure of the matrix A
 load nlsdat3
  
% Choose a custom-made Jacobian-multiply routine
  options = optimset('Display','iter','JacobMult',@nlsmm3,'Jacobian','on') ;
  [x,Resnorm,fval,exitflag,output] = lsqnonlin(fun,xstart,[],[],options,S);

%-----------------------------------------------------------------
function [Fvec,J] = nlsf3a(x,S);
%NLSF3A Objective function
%
%  Evaluate a structured vector function Fvec,
%
%     Fvec(x) = Fbar(y) where 
%       A(x)y = Fbar(x), i.e. y = inv(A)*Fbar(x)
%     i.e. Fvec(x) = Fbar(inv(A)*Fbar(x))
%  
%  where F is a nonlinear square mapping,
%  with tridiagonal Jacobian, and A = A(x)
%  is a symmetric positive definite matrix.
%
%  Fvec is the vector function evaluated at x,
%  The Jacobian of Fvec is J = Jbar*inv(A)*(Jtilde - JA)
%  where JA is the Jacobian of A(x)y, 
%  Jbar is the Jacobian of F(inv(A)*Fbar(x)) and 
%  Jtilde is the Jacobian of Fbar(x).
%  J is returned as an array containing the sparse Jacobian "components",
%  i.e. Jtilde-JA, Jbar, and the Cholesky factor R and permutation vector p
%  of A. The "components" array J can be used with function nlsmm3 to 
%  compute corresponding matrix-vector products. Note that the Jacobian 
%  of Fvec is never explicitly computed. inv(A) is also not computed, 
%  rather A*y = Fbar is solved using the Cholesky factors of A.
%  

   n=length(x);
%
%  Evaluate F(x) = nlsf3b(x), and the corresponding Jacobian matrix.
   [y1,Jtilda]=nlsf3b(x);
%
%  Evaluate matrix A, SPD
%  Evaluate A
   A=compa(x,S);
%  
%  Determine MDO of A, sparse Cholesky factor
   p = symamd(A); 
   p = p';
   R = chol(A(p,p));
%
%  Solve for A^{-1}*F(x).
   w = R'\y1(p); 
   y2(p,1) = R\w;
%
%  Compute the vector function Fvec and the Jacobian of F with respect to
%  the argument y2 (tri-diagonal) 
   [Fvec,Jbar]=nlsf3b(y2);
%  Compute the Jacobian of A(x).
   JA = jaca(x,y2,S);
%
%  Save the sparse components of the Jacobian of Fvec in array J.
   J = [Jtilda-JA, Jbar,R,p];

%-----------------------------------------------------------------------
function[fvec,A] = nlsf3b(x);
%
% Evaluate nonlinear equations example function.
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
% Evaluate the Jacobian if needed
  if nargout > 1
     d = -8*x.^3 + 3*ones(n,1); D = sparse(1:n,1:n,d,n,n);
     c = -2*ones(n-1,1); C = sparse(1:n-1,2:n,c,n,n);
     e = -ones(n-1,1); E = sparse(2:n,1:n-1,e,n,n);
     A = C + D + E;
  end
%-----------------------------------------------------------------------
function A=compa(x,S)
%COMPA  Matrix function (nlsf3)
%
% A has same sparsity as S. A is symmetric positive definite.
%
% A(i,j)=x(i)+x(j) if i ~= j
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
%-----------------------------------------------------------------------

function A=jaca(x,y,S)
%JACA   Sparse derivative matrix (nlsf3/compa) 
% Computes derivative matrix M_x*y where
% M is a sparse matrix with sparsity structure
% given by S. The nonzero elements of M
% are functions of x and defined as follows:
%
% M(i,j)=x(i)+x(j) if i~=j
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


  
%-----------------------------------------------------------------------
function[VV] = nlsmm3(A,UU,flag,S);
%NLSMM3 Structured matrix multiply (snlsf3)
%
% Components of the Jacobian matrix, Jac, are stored in array A.
%
% Compute VV = Jac'*Jac*UU (flag =0)
%         VV = Jac*UU      (flag > 0) .
%         VV = Jac'*UU     (flag < 0)
%
% S is not used but needed since its an additional argument for the objective function.
%
%*************************************************************************
  if nargin <= 3, flag = 0; end
  [n,m]  = size(UU);
  Jtil = A(:,1:n); 
  Jbar = A(:,n+1:2*n); 
  R = A(:,2*n+1:3*n); 
  p = A(:,3*n+1);
  VV = zeros(n,m);
  for k = 1: m
      y = UU(:,k);
      if flag == 0 % compute vec = Jac'*Jac*y
         w = Jtil*y; 
         ww = R'\w(p);
         w(p) = R\ww;
         y = Jbar*w;
         w = Jbar'*y;     
         ww = R'\w(p);
         w(p) = R\ww;
         vec = Jtil'*w;
      elseif flag > 0 % compute vec =  Jac*y
         w = Jtil*y; 
         ww = R'\w(p);
         w(p) = R\ww;
         vec = Jbar*w;
      else % compute vec = Jac'*y
         w = Jbar'*y;
         ww = R'\w(p);
         w(p) = R\ww;
         vec = Jtil'*w;
      end
      VV(:,k) = vec;
   end
