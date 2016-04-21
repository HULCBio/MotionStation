function [zopt,epsslack,how,iter]=mpc_solve(MuKduINV,KduINV,Kx,Ku1,Kut,Kr,zmin,rhsc0,Mlim,Mx,Mu1,Mvv,...%Mdd
   rhsa0,TAB,Jm,DUFree,xk,uk1,utarget,r,vKv,...%dKd,
   nu,p,degrees,optimalseq,isunconstr,useslack,maxiter);

%MPC_SOLVE Compute the optimal input sequence by solving a QP problem or analytically
%
%   input flags: isunconstr=1 if problem is unconstrained
%                useslack=1 if problem has output constraints and needs a slack var (otherwise, useslack=0)

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:19 $   



if isunconstr,
   
   % Unconstrained MPC
   
   zopt=-KduINV*(Kx'*xk+Ku1'*uk1+Kut'*utarget+...
      Kr'*r+vKv');%+dKd');
   
   epsslack=0;
   
   how='feasible';
   iter=0;
   return
end

% Constrained MPC

% Form matrices for QPSOLVER routine (tableau)
rhsc=rhsc0+Mlim+Mx*xk+Mu1*uk1+Mvv;%+Mdd;
rhsa=rhsa0-[(xk'*Kx+r'*Kr+uk1'*Ku1+vKv+...%dkd+...
      utarget'*Kut),zeros(1,useslack)]';

basisi=[KduINV*rhsa;
   rhsc-MuKduINV*rhsa];

nc=size(rhsc,1);

ibi=-[1:degrees+useslack+nc]';
ili=-ibi;

% Solves QP
[basis,ib,il,iter]=qpsolver(TAB,basisi,ibi,ili,maxiter);

% TEST: compute max number of iterations
%global ITER
%ITER=max(ITER,iter);

if iter > maxiter,
   warning('mpc:mpc_solve:maxiter','Maximum number of iterations exceeded, solution is unreliable. Augment MAXITER. ');
   
elseif iter < 0
   % This should never happen, because there's a slack variable !!!
   % It's just for robustness of the code...
   
   how='infeasible';
   warning('mpc:mpc_solve:infeasible',sprintf('The constraints are overly stringent. No feasible solution.\nPrevious optimal sequence will be used.'));
   duold=Jm*optimalseq;
   zopt=[duold(1+nu:nu*p);zeros(nu,1)]; % shifts
   
   % Rebuilds optimalseq from zopt
   %free=find(kron(DUFree(:),ones(nu,1))); % Indices of free moves
   free=find(DUFree(:));
   epsslack=Inf; % Slack variable for soft output constraints
   zopt=zopt(free);
   return
end    

% Extract the solution to the QP problem
how='feasible';
zopt=zeros(degrees+useslack,1);
for j=1:degrees+useslack
   if il(j) <= 0
      zopt(j)=zmin(j);
   else
      zopt(j)=basis(il(j))+zmin(j);
   end
end
if useslack,
   epsslack=zopt(degrees+1); % Slack variable for soft output constraints
else
   epsslack=0;
end

zopt=zopt(1:degrees);

% end MPC_SOLVE.M