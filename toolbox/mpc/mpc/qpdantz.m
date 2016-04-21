function [xopt,lambda,how] = qpdantz(H,f,A,b,xmin,maxiter)
%QPDANTZ solves a quadratic program using an active set method.
%
%   [x,lambda,status]=QPDANTZ(H,f,A,b,xmin,maxiter) solves the quadratic 
%   programming problem:
% 
%     min 0.5*x'Hx + f'x   subject to:  Ax <= b, x >= xmin
%      x    
%
%   using the MPC Toolbox QPSOLVER routine.
%
%   x = the optimal solution vector.
%   lambda = the dual variables (Lagrange multipliers) at the solution.
%   status = 'feasible' if x satisfies the constraints
%          = 'infeasible' if no feasible x could be found
%          = 'unreliable' if no solution could be found in QPSOLVER's 
%            maximum number of iterations allowed.
% 
%   See also QPSOLVER

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $  $Date: 2004/04/10 23:35:32 $


if nargin<6,
   maxiter=200;
end
if maxiter<1,
    error('mpc:qpdantz:negmaxiter','MAXITER must be greater than 0');
end

if nargin<5,
   xmin=-1e3*ones(size(f(:)));
   warning('mpc:qpdantz:xmin','Lower bounds not assigned. Assuming -1000 on each variable');
end
if nargin<4,
   error('mpc:qpdantz:nargin','At least H,f,A,b must be supplied');
end

mnu=length(f);
nc=length(b);

if size(H,1)~=mnu | size(H,2)~=mnu,
   error('mpc:qpdantz:costdim','Hessian matrix or linear cost have wrong dimensions');
end

if size(A,2)~=mnu,
   error('mpc:qpdantz:constrdim','Constraint matrix or linear cost have wrong dimensions');
end

if size(A,1)~=nc,
   error('mpc:qpdantz:constrrhs','Constraint matrix or rhs have wrong dimensions');
end


% H must be symmetric. Otherwise set H=(H+H')/2
if norm(H-H') > eps
   warning('mpc:qpdantz:Hessian','Your Hessian is not symmetric.  Resetting H=(H+H'')/2')
   H = (H+H')*0.5;
end

a=-H*xmin(:);    % This is a constant term that adds to the initial basis
                 % in each QP.
H=H\eye(mnu);

rhsc=b(:)-A*xmin(:);
rhsa=a-f(:);
TAB=[-H H*A';A*H -A*H*A'];
basisi=[H*rhsa;
       rhsc-A*H*rhsa];
ibi=-[1:mnu+nc]';
ili=-ibi;
[basis,ib,il,iter]=qpsolver(TAB,basisi,ibi,ili,maxiter);

if iter > maxiter,
    warning('mpc:qpdantz:maxiter','Maximum number of iterations exceeded, solution is unreliable. Augment MaxIter. ');
    how='unreliable';
    
elseif iter < 0
    
    how='infeasible';
    warning('mpc:qpdantz:infeasible','The constraints are overly stringent. No feasible solution.');
else
    % Extract the solution to the QP problem
    how='feasible';
end

xopt=zeros(mnu,1);

for j=1:mnu
   if il(j) <= 0
      xopt(j)=xmin(j);
   else
       xopt(j)=basis(il(j))+xmin(j);
   end
end

if nargout>=2,
    lambda=zeros(nc,1);
    for j=1:nc,
        if ib(mnu+j) <= 0
            lambda(j)=0;
        else
            lambda(j)=basis(ib(mnu+j));
        end
    end    
end