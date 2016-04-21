function [s,posdef,k,znrm,exitflag,lambda,msg,PT,LZ,UZ,pcolZ,PZ] = ...
    ppcgr(grad,H,Aeq,b,options,defaultopt,verb,computeLambda,tolA,PT, ...
          LZ,UZ,pcolZ,PZ,varargin);
%PPCGR	Preconditioned conjugate gradients with linear equalities.
%
% [s,posdef,k] = PPCGR(grad,H,A,b,options)  apply
% a preconditioned conjugate gradient procedure to the linearly
% constrained quadratic
%
%         q(s) = .5s'Hs + grad's: As = b.
%
% On output s is the computed direction, posdef = 1 implies
% only positive curvature (in H constrained to null(A))
% has been detected; posdef = 0
% implies s is a direction of negative curvature (for M in null(A)).
% Output parameter k is the number of CG-iterations used (which
% corresponds to the number of multiplications with H).
% A preconditioner will be based on the form
%
%            HH  AA'
%    M = 
%            AA  0
%
% where in general HH is a SPD banded approximation
% to H, the nonzeros of AA are a subset of the nonzeros of A (based
% on a stopping tolerance). Parameters in the named parameter
% list options can be used to overide default values to define M,
% including defining M (H) implicitly.
%
% [s,posdef,k] = PPCGR(grad,H,A,b,options,tolA) 
% Overide the dropping tolerance to define AA from A.
%
% [s,posdef,k] = PPCGR(grad,H,A,b,options,tolA,PT,LZ,UZ,pcolZ,PZ);
% PT is a permutation matrix such that A*PT has a leading nonsingular 
% m-by-m matrix, A_1, where m is the number of rows of A
% PZ*A_1(:,pcolZ) = LZ*UZ, the sparse LU-factorization on A_1.
%
% [s,posdef,k,znrm,exitflag,PT,LZ,UZ,pcolZ,PZ]=PPCGR(grad,H,A,b,options) 
% ouputs the sparse LU-factorization of A_1. znnrm is the scaled norm
% of the residual, exitflag is the termination code.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2004/02/01 22:09:33 $


if nargin < 3, 
   error('optim:ppcgr:NotEnoughInputs', ...
         'PPCGR requires at least 3 input arguments.'); 
end
[m,n] = size(Aeq); 
exitflag = [];
s = [];
posdef = [];
k = [];
znrm = [];

if m > n, 
   exitflag = -10; s = []; lambda = []; posdef = []; k = []; znrm = [];
   msg = [];
   % m > n not handled by ppcgr; abort
   return
end

if nargin < 4 | isempty(b), 
   b = zeros(m,1); 
end
[mm,nn] = size(b);

if mm ~= m, 
   error('optim:ppcgr:SizeMismatch', ...
         'The number of rows in Aeq is incompatible with the length of beq.'); 
end

if nargin < 7,
   computeLambda = 0;
   if nargin < 6, 
      verb = 0;
      if nargin < 5
         options = [];
      end, end, end

% Later Preconditioner and HessMult will be user-settable
pcmtx = optimget(options,'Preconditioner',@preaug); %no default, use slow optimget 
mtxmpy = optimget(options,'HessMult',defaultopt,'fast') ;
if isempty(mtxmpy)
    mtxmpy = @hmult;
end
pcf = optimget(options,'PrecondBandWidth',defaultopt,'fast') ;
if nargin >= 9 & ~isempty(tolA), 
   pcf(2,1) = tolA; % tolA not currently used 
end
tol = optimget(options,'TolPCG', defaultopt,'fast') ;
defaultopt.MaxPCGIter = n; % not the default so override
kmax = optimget(options,'MaxPCGIter', defaultopt,'fast') ; 
% In case the defaults were gathered from calling: optimset('quadprog'):
numberOfVariables = n;
if ischar(kmax)
	if isequal(lower(kmax),'max(1,floor(numberofvariables/2))')
		kmax = max(1,floor(numberOfVariables/2));
	elseif isequal(lower(kmax),'numberofvariables')
		kmax = numberOfVariables;
	else
		error('optim:ppcgr:InvalidMaxPCGIter', ...
                      'Option ''MaxPCGIter'' must be an integer value if not the default.')
	end
end
kmax = max(kmax,1);   % kmax must be at least 1

% save initial grad for computing Lagrange multipliers
gradsave = grad;

% Get feasible point
y = zeros(n,1);
if norm(b) > 1e-12
   [y, flag] = feasibl(Aeq,b);
   % We don't yet handle this case of dependent rows; abort
   if flag == -1
      exitflag = -10; s = []; lambda = []; posdef = []; k = []; znrm = [];
      msg = [];
      return
   end
   
   w = feval(mtxmpy,H,y,varargin{:});
   grad = grad + w;
end

% Transform to get fundamental null basis
if nargin < 10 | isempty(PT)
   PT = findp(Aeq);
end

A = Aeq*PT'; 
grad = PT*grad;

% Project grad
if nargin < 14 | isempty(LZ)% last 4 arguments are a group (excluding varargin)
   [g,LZ,UZ,pcolZ,PZ] = fzmult(A,grad,'transpose');
else
   g = fzmult(A,grad,'transpose',LZ,UZ,pcolZ,PZ);
end
r = -g; 

nz = length(g); 
s = zeros(nz,1); 
val = 0;

% Compute preconditioner
HH = [];
if isequal(size(H),[n,n])
   HH = PT*H*PT';
end
[L,U,P,pcol] = feval(pcmtx,HH,pcf,A,varargin{:});

% Precondition .
rr = [zeros(m,1);r];
rhs = [rr;zeros(m,1)];
zz = L\(P*rhs); 
zt(pcol,1) = U\zz; 
z = zt(m+1:n,1);
znrm = norm(z); 
stoptol = tol*znrm;
inner2 = 0; 
inner1 = r'*z; 
posdef = 1;

% PRIMARY LOOP.
for k = 1:kmax
   if k==1
      d = z;
   else
      beta = inner1/inner2; 
      d = z + beta*d;
   end
   dd = fzmult(A,d,'',LZ,UZ,pcolZ,PZ);
   dd = PT'*dd;
   w = feval(mtxmpy,H,dd,varargin{:});
   ww = PT*w; 
   w = fzmult(A,ww,'transpose',LZ,UZ,pcolZ,PZ);
   denom = d'*w;
   if denom <= 0
      if norm(d) > 0
         s = d/norm(d);
      else
         s = d;
      end
      s = y + PT'*fzmult(A,s,'',LZ,UZ,pcolZ,PZ);
      posdef = 0; 
      if computeLambda
         w = feval(mtxmpy,H,s,varargin{:}); 
         rhs = -gradsave-w;
         lambda.eqlin = Aeq'\rhs;
         lambda.ineqlin = []; lambda.lower = []; lambda.upper = [];
      else
         lambda = [];
      end
      if denom == 0 & sum(d)== 0 % No curvature left: we have a (singular) solution
         exitflag = 4;
         msg = sprintf('Optimization terminated: local minimum found; the solution is singular.');
         if verb > 0
            disp(msg)
         end 
      else % either denom < 0, or denom = 0 and sum(d) ~= 0   
         exitflag = -3;
         if denom < 0
           msg = sprintf(['Exiting: negative curvature direction detected.\n' ...
                          ' The solution is unbounded and at infinity;\n' ...
                          ' constraints are not restrictive enough.']);
         else
           msg = sprintf(['Exiting: zero curvature direction detected.\n' ...
                          ' The solution is unbounded and at infinity;\n' ...
                          ' constraints are not restrictive enough.']);
         end
         if verb > 0
           disp(msg)
         end
      end
      return
   else % denom > 0, continue
      alpha = inner1/denom;
      s = s+ alpha*d; 
      r = r - alpha*w;
   end
   
   % Precondition
   rr =[zeros(m,1);r];  
   rhs = [rr;zeros(m,1)];
   zz = L\(P*rhs); 
   zt(pcol,1) = U\zz; 
   z = zt(m+1:n,1);
   
   % Exit?
   znrm = norm(z);
   if znrm <= stoptol,
      s = y +  PT'*fzmult(A,s,'',LZ,UZ,pcolZ,PZ); 
      if computeLambda
         w = feval(mtxmpy,H,s,varargin{:}); 
         rhs = -gradsave-w;
         lambda.eqlin = Aeq'\rhs;
         lambda.ineqlin = []; lambda.lower = []; lambda.upper = [];
      else 
         lambda = [];
      end   
      exitflag = 1;
      msg = sprintf(['Optimization terminated: relative (projected) residual\n' ...
                     ' of PCG iteration <= OPTIONS.TolPCG.']);
      if verb > 0
         disp(msg)
      end
      return;
   end
   inner2 = inner1; 
   inner1 = r'*z;
end

if k >= kmax, 
   exitflag = 0;
   msg = sprintf(['Maximum number of PCG iterations exceeded;\n' ...
                  ' increase options.MaxPCGIter.']);
   if verb > 0
      disp(msg)
   end              
end
s = y +  PT'*fzmult(A,s,'',LZ,UZ,pcolZ,PZ);
if computeLambda
   w = feval(mtxmpy,H,s,varargin{:});  
   rhs = -gradsave-w;
   lambda = Aeq'\rhs;
   lambda.ineqlin = []; lambda.lower = []; lambda.upper = [];
else 
   lambda = [];
end


