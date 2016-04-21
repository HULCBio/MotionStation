function [K,M,F,Q,G,H,R]=assempde(b,p,e,t,c,a,f,u,time,sdl)
%ASSEMPDE Assemble the stiffness matrix and right hand side a PDE problem.
%
%       U=ASSEMPDE(B,P,E,T,C,A,F) assembles and solves the PDE problem
%       -div(c*grad(u))+a*u=f, on a mesh described by P, E, and T,
%       with boundary conditions given by the function name B.
%       It eliminates the Dirichlet boundary conditions from the
%       system of linear equations when solving for U.
%
%       [K,F1]=ASSEMPDE(B,P,E,T,C,A,F) gives assembled matrices by
%       approximating the Dirichlet boundary condition with stiff springs.
%       K and F are the stiffness matrix and right-hand side vector
%       respectively. The solution to the FEM formulation of the PDE
%       problem is u=K\F1.
%
%       [K,F1,B1,UD]=ASSEMPDE(B,P,E,T,C,A,F) assembles the PDE problem by
%       eliminating the Dirichlet boundary conditions from the system of
%       linear equations. UN=K\F1 returns the solution on the non-Dirichlet
%       points.  The solution to the full PDE problem can be obtained by
%       the MATLAB command U=B1*UN+UD.
%
%       [K,M,F1,Q,G,H,R]=ASSEMPDE(B,P,E,T,C,A,F) gives a split
%       representation of the PDE problem.
%
%       U=ASSEMPDE(K,M,F,Q,G,H,R) collapses the split representation
%       into the single matrix/vector form, and then solves the PDE
%       problem by eliminating the Dirichlet boundary conditions
%       from the system of linear equations.
%
%       [K1,F1]=ASSEMPDE(K,M,F,Q,G,H,R) collapses the split representation
%       into the single matrix/vector form, by fixing the Dirichlet boundary
%       condition with large spring constants.
%
%       [K1,F1,B,UD]=ASSEMPDE(K,M,F,Q,G,H,R) collapses the split representation
%       into the single matrix/vector form by eliminating the Dirichlet
%       boundary conditions from the system of linear equations.
%
%       The geometry of the PDE problem is given by the triangle
%       data P, E, and T.  See either INITMESH or PDEGEOM for details.
%
%       For the scalar case the solution u is represented as a column
%       vector of solution values at the corresponding node points from
%       P.  For a system of dimension N with NP node points, the first
%       NP values of U describe the first component of u, the
%       following NP values of U describe the second component of u,
%       and so on.  Thus, the components of u are placed in the vector
%       U as N blocks of node point values.
%
%       B describes the boundary conditions of the PDE problem.  B
%       can either be a Boundary Condition Matrix or the name of Boundary
%       M-file. See PDEBOUND for details.
%
%       The following call sequences are also allowed:
%       U=ASSEMPDE(B,P,E,T,C,A,F,U0)
%       U=ASSEMPDE(B,P,E,T,C,A,F,U0,TIME)
%       U=ASSEMPDE(B,P,E,T,C,A,F,TIME)
%       [K,F1]=ASSEMPDE(B,P,E,T,C,A,F,U0)
%       [K,F1]=ASSEMPDE(B,P,E,T,C,A,F,U0,TIME)
%       [K,F1]=ASSEMPDE(B,P,E,T,C,A,F,U0,TIME,SDL)
%       [K,F1]=ASSEMPDE(B,P,E,T,C,A,F,TIME)
%       [K,F1]=ASSEMPDE(B,P,E,T,C,A,F,TIME,SDL)
%       [K,F1,B1,UD]=ASSEMPDE(B,P,E,T,C,A,F,U0)
%       [K,F1,B1,UD]=ASSEMPDE(B,P,E,T,C,A,F,U0,TIME)
%       [K,F1,B1,UD]=ASSEMPDE(B,P,E,T,C,A,F,TIME)
%       [K,M,F1,Q,G,H,R]=ASSEMPDE(B,P,E,T,C,A,F,U0)
%       [K,M,F1,Q,G,H,R]=ASSEMPDE(B,P,E,T,C,A,F,U0,TIME)
%       [K,M,F1,Q,G,H,R]=ASSEMPDE(B,P,E,T,C,A,F,U0,TIME,SDL)
%       [K,M,F1,Q,G,H,R]=ASSEMPDE(B,P,E,T,C,A,F,TIME,SDL)
%       The optional list of subdomain labels, SDL, restricts the
%       assembly process to the subdomains denoted by the labels
%       in the list. The optional input arguments U0 and TIME are used for
%       the nonlinear solver and time stepping algorithms respectively.
%       The tentative input solution vector U0 has the same
%       format as U.
%
%       PDE COEFFICIENTS FOR SCALAR CASE
%
%       The coefficients c, a and f of the PDE problem can
%       be given in a wide variety of ways:
%       - A constant.
%       - A row vector of representing values at the triangle centers
%       of mass. A MATLAB text expression for computing coefficient values
%       at the triangle centers of mass. The expression is evaluated in a
%       context where the variables X, Y, SD, U, UX, UY, and T are row
%       vectors representing values at the triangle centers of mass.
%       (T is a scalar). The row vectors contain x- and y-coordinates,
%       subdomain label, solution with x and y derivatives and
%       time. U, UX,  and UY can only be used if U0 have been  passed to
%       ASSEMPDE. The same applies to the scalar T, which is passed to
%       ASSEMPDE as TIME.
%       - A sequence of MATLAB text expressions separated by exclamation
%       marks !.  The syntax of each of the text expressions must
%       be according to the above item.  The number of expressions in
%       the sequence must equal the number of subdomain labels in the
%       triangle list t.
%       - The name of a user-defined MATLAB function that accepts the
%       arguments  (P,T,U,TIME). P and T are mesh data, U is the U0
%       input argument and T is the TIME input argument to ASSEMPDE.
%       U will be the empty matrix, and TIME will be NaN if the
%       corresponding parameter was not passed to ASSEMPDE.
%
%       If C contains two rows with data according to any of the above
%       items, they are the c(1,1), and c(2,2), elements of a 2-by-2
%       diagonal matrix. If c contains three rows with data according to
%       any of the above items, they are the c(1,1),  c(1,2),
%       and c(2,2) elements of a 2-by-2 symmetric matrix. If C contains four
%       rows with data according to any of the above items, they are the
%       c(1,1), c(2,1), c(1,2), and c(2,2) elements of a 2-by-2 matrix.
%
%       PDE COEFFICIENTS FOR SYSTEM CASE
%
%       Let N be the dimension of the PDE system. Now c
%       is a (N, N, 2, 2), a a (N,N) matrix, and f a column
%       vector of length N.  The elements c(I,J,K,L), a(I,J), and f(I)
%       from c, a and f are stored row-wise in the corresponding MATLAB
%       matrices C, A and F. Each row in these matrices are similar in
%       syntax to the scalar case. There is one difference however:
%       At the point of evaluation of the MATLAB text expressions,
%       the variables U, UX, and UY will contain matrices with N rows,
%       one row for each component. The case of identity, diagonal, and
%       symmetric matrices are handled as special cases.  For the tensor
%       c(I,J,K,L) this applies both to the indices I and J, and to the
%       indices K and L.
%
%       The number of rows in F determines the dimension N of the
%       PDE system.  Row I in F represent the component f(I).
%
%       The number of rows NA in A is related to the component a(I,J)
%       according to the following table.  For the symmetric case assume
%       that J>=I. All elements a(I,J) that can not be formed are assumed
%       to be zero:
%
%       -----------------------------------------------------------
%       | NA            | Symm. | a(I,J)          | Row in A      |
%       -----------------------------------------------------------
%       | 1             |       | a(I,I)          | 1             |
%       | N             |       | a(I,I)          | I             |
%       | N*(N+1)/2     | x     | a(I,J)          | J*(J-1)/2+I   |
%       | N^2           |       | a(I,J)          | N*(j-1)+I     |
%       -----------------------------------------------------------
%
%       The coding of c in the MATLAB matrix C is determined by the
%       dimension N and the number of rows in the matrix. The number of
%       rows NC are matched to the function of N in the first
%       column in the table below-sequentially from the first
%       line to the last line.  The first match determines the type of
%       coding of C. This actually means that for some small values,
%       2<=N<=4, the coding is only determined by the order in which
%       the tests are performed.  For the symmetric case assume that
%       J>=I, and L>=K.  All elements c(I,J,K,L) that can not be formed
%       are assumed to be zero:
%
%       -------------------------------------------------------------------
%       | NC            | Symm. | c(I,J,K,L)      | Row in C              |
%       -------------------------------------------------------------------
%       | 1             |       | c(I,I,L,L)      | 1                     |
%       | 2             |       | c(I,I,L,L)      | L                     |
%       | 3             |x      | c(I,I,K,L)      | L+K-1                 |
%       | 4             |       | c(I,I,K,L)      | 2*L+K-1               |
%       | N             |       | c(I,I,L,L)      | I                     |
%       | 2*N           |       | c(I,I,L,L)      | 2*I+K-2               |
%       | 3*N           |x      | c(I,I,K,L)      | 3*I+L+K-4             |
%       | 4*N           |       | c(I,I,K,L)      | 4*I+2*L+K-6           |
%       | 2*N*(2*N+1)/2 |x      | c(I,I,K,L)      | 2*I^2+I+L+K-4         |
%       |               |x      | c(I,J,K,L), I<J | 2*J^2-3*J+4*I+2*L+K-5 |
%       | N^2           |       | c(I,I,K,L)      | 4*N*(J-1)+4*I+2*L+K-6 |
%       -------------------------------------------------------------------
%
%       See also INITMESH, PDEGEOM, PDEBOUND, ASSEMA, ASSEMB

%       A. Nordmark 4-26-94, AN 8-01-94, AN 1-31-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.10.4.2 $  $Date: 2003/10/21 12:26:00 $

if nargin==7 && issparse(b)
  K=b;
  M=p;
  F=e;
  Q=t;
  G=c;
  H=a;
  R=f;
elseif nargin==7
  [K,M,F]=assema(p,t,c,a,f);
  [Q,G,H,R]=assemb(b,p,e);
elseif nargin==8
  [K,M,F]=assema(p,t,c,a,f,u);
  [Q,G,H,R]=assemb(b,p,e,u);
elseif nargin==9
  [K,M,F]=assema(p,t,c,a,f,u,time);
  [Q,G,H,R]=assemb(b,p,e,u,time);
elseif nargin==10,
  [K,M,F]=assema(p,t,c,a,f,u,time,sdl);
  [Q,G,H,R]=assemb(b,p,e,u,time,sdl);
else
  error('PDE:assempde:nargin', 'Wrong number of input arguments.');
end

if nargout==7,
  return
end

if nargout==2 % Spring constant case
  if nnz(H)==0 % No constraints
    K=K+M+Q;
    M=F+G;
    return
  end

  % Some scaling
  d1=full(diag(H*H'));
  l=find(d1==0);
  d1(l)=Inf*ones(size(l));
  id1=diag(sparse(1./d1));
  % Form normal equations
  R=H'*id1*R;
  H=H'*id1*H;

  % Incorporate constraints (Dirichlet conditions)
  % Find a positive spring constant of suitable size.

  np=size(p,2);
  tscale=1/sqrt(np); % Triangle size
  kscale=max(max(abs(K)));
  mscale=max(max(abs(M)));
  qscale=max(max(abs(Q)));
  hscale=1;

  % Spring constant
  spc=max(max(kscale*tscale^2,mscale),qscale*tscale)/(hscale*tscale^3);

  K=K+M+Q+spc*H;
  M=F+G+spc*R;

  return
end


[null,orth]=pdenullorth(H);
if size(orth,2)==0
  ud=zeros(size(K,2),1);
else
  ud=full(orth*((H*orth)\R));
end
KK=K+M+Q;
% Check for symmetry
if nnz(KK-KK')
  sym=0;
else
  sym=1;
end
FF=null'*((F+G)-KK*ud);
KK=null'*KK*null;
if sym
  KK=(KK+KK')/2;
end

if nargout==1
  if size(null,2)==0
    K=ud;
  else
    K=null*(KK\FF)+ud;
  end
  return
end

if size(null,2)==0
  fprintf('Warning: there are no interior points.\n');
  fprintf('K, F, and B are empty and ud contains the full solution.\n')
end

K=KK;
M=FF;
F=null;
Q=ud;


