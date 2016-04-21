function [x,flag,relres,iter,resvec,resveccg] = symmlq(A,b,tol,maxit,M1,M2,x0,varargin)
%SYMMLQ    Symmetric LQ Method
%   X = SYMMLQ(A,B) attempts to solve the system of linear equations A*X=B
%   for X.  The N-by-N coefficient matrix A must be symmetric but need not be
%   positive definite.  The right hand side column vector B must have
%   length N.  A may be a function returning A*X.
%
%   SYMMLQ(A,B,TOL) specifies the tolerance of the method.  If TOL is []
%   then SYMMLQ uses the default, 1e-6.
%
%   SYMMLQ(A,B,TOL,MAXIT) specifies the maximum number of iterations.  If
%   MAXIT is [] then SYMMLQ uses the default, min(N,20).
%
%   SYMMLQ(A,B,TOL,MAXIT,M) and SYMMLQ(A,B,TOL,MAXIT,M1,M2) use the
%   symmetric positive definite preconditioner M or M=M1*M2 and effectively
%   solve the system inv(sqrt(M))*A*inv(sqrt(M))*Y = inv(sqrt(M))*B for Y
%   and then return X = inv(sqrt(M))*Y.  If M is [] then a preconditioner is not
%   applied.  M may be a function returning M\X.
%
%   SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If X0 is []
%   then SYMMLQ uses the default, an all zero vector.
%
%   SYMMLQ(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters P1,P2,...
%   to functions: AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...).
%
%   [X,FLAG] = SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0) also returns a convergence FLAG:
%    0 SYMMLQ converged to the desired tolerance TOL within MAXIT iterations.
%    1 SYMMLQ iterated MAXIT times but did not converge.
%    2 preconditioner Mwas ill-conditioned.
%    3 SYMMLQ stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during SYMMLQ became
%      too small or too large to continue computing.
%    5 preconditioner M was not symmetric positive definite.
%
%   [X,FLAG,RELRES] = SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   relative residual NORM(B-A*X)/NORM(B).  If FLAG is 0, RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   iteration number at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0) also
%   returns a vector of estimates of the SYMMLQ residual norms at each
%   iteration, including NORM(B-A*X0).
%
%   [X,FLAG,RELRES,ITER,RESVEC,RESVECCG] = SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0) also
%   returns a vector of estimates of the Conjugate Gradients residual norms at
%   each iteration.
%
%   Example:
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -2*on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-10; maxit = 50; M1 = spdiags(4*on,0,n,n);
%   x = symmlq(A,b,tol,maxit,M1,[],[]);
%   Use this matrix-vector product function
%      function y = afun(x,n)
%         y = 4 * x;
%         y(2:n) = y(2:n) - 2 * x(1:n-1);
%         y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%
%   as input to SYMMLQ
%      x1 = symmlq(@afun,b,tol,maxit,M1,[],[],n);
%
%   See also BICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, QMR, @.

%   Penny Anderson, 1999.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $ $Date: 2003/05/01 20:43:20 $

if (nargin < 2)
   error('MATLAB:symmlq:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:symmlq:NonSquareMatrix', 'Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      es = sprintf(['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
      error('MATLAB:symmlq:RSHsizeMatchCoeffMatrix', es);
   end
else
   m = size(b,1);
   n = m;
   if (size(b,2) ~= 1)
      error('MATLAB:symmlq:RSHnotColumn', 'Right hand side must be a column vector.');
   end
end

% Assign default values to unspecified parameters
if (nargin < 3) || isempty(tol)
   tol = 1e-6;
end
if (nargin < 4) || isempty(maxit)
   maxit = min(n,20);
end

% Check for all zero right hand side vector => all zero solution
n2b = norm(b);                      % Norm of rhs vector, b
if (n2b == 0)                       % if    rhs vector is all zeros
   x = zeros(n,1);                  % then  solution is all zeros
   flag = 0;                        % a valid solution has been obtained
   relres = 0;                      % the relative residual is actually 0/0
   iter = 0;                        % no iterations need be performed
   resvec = 0;                      % resvec(1) = norm(b-A*x) = norm(0)
   resveccg = 0;                    % resveccg(1) = norm(b-A*xcg) = norm(0)
   if (nargout < 2)
      itermsg('symmlq',tol,maxit,0,flag,iter,NaN);
   end
   return
end

if ((nargin >= 5) && ~isempty(M1))
   existM1 = true;
   [m1type,m1fun,m1fcnstr] = iterchk(M1);
   if isequal(m1type,'matrix')
      if ~isequal(size(M1),[m,m])
         es = sprintf(['Preconditioner must be a square matrix' ...
               ' of size %d to match the problem size.'],m);
         error('MATLAB:symmlq:WrongPrecondSize', es);
      end      
   end   
else
   existM1 = false;
   m1type = 'matrix';
end

if ((nargin >= 6) && ~isempty(M2))
   existM2 = true;
   [m2type,m2fun,m2fcnstr] = iterchk(M2);
   if isequal(m2type,'matrix')
      if ~isequal(size(M2),[m,m])
         es = sprintf(['Preconditioner must be a square matrix' ...
               ' of size %d to match the problem size.'],m);
         error('MATLAB:symmlq:WrongPrecondSize', es);
      end
   end
else
   existM2 = false;
   m2type = 'matrix';
end

existM = existM1 || existM2;

if ((nargin >= 7) && ~isempty(x0))
   if ~isequal(size(x0),[n,1])
      es = sprintf(['Initial guess must be a column vector of' ...
            ' length %d to match the problem size.'],n);
      error('MATLAB:symmlq:WrongInitGuessSize', es);
   else
      x = x0;
   end
else
   x = zeros(n,1);
end

if ((nargin > 7) && isequal(atype,'matrix') && ...
      isequal(m1type,'matrix') && isequal(m2type,'matrix'))
   error('MATLAB:symmlq:TooManyInputs', 'Too many input arguments.');
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % Iteration at which xmin was computed
tolb = tol * n2b;                  % Relative tolerance
if isequal(atype,'matrix')
   r = b - A * x;                  % Zero-th residual
else
   r = b - iterapp(afun,atype,afcnstr,x,varargin{:});
end
normr = norm(r);                   % Norm of residual

if (normr <= tolb)                 % Initial guess is a good enough solution
   flag = 0;
   relres = normr / n2b;
   iter = 0;
   resvec = normr;
   resveccg = normr;
   if (nargout < 2)
      itermsg('symmlq',tol,maxit,0,flag,iter,relres);
   end
   return
end

resvec = zeros(maxit+1,1);         % Preallocate vector for SYMMLQ residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
resveccg = zeros(maxit+2,1);       % Preallocate vector for CG residuals
resveccg(1) = normr;               % resveccg(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of minimum residual

v = r;
vold = r;
if existM1
   if isequal(m1type,'matrix')
      u = M1 \ vold;
   else
      u = iterapp(m1fun,m1type,m1fcnstr,vold,varargin{:});
   end
   if isinf(norm(u,inf))
      flag = 2;
      relres = normr / n2b;
      iter = 0;
      resvec = resvec(1);
      resveccg = resveccg(1);
      if nargout < 2
         itermsg('symmlq',tol,maxit,0,flag,iter,relres);
      end
      return
   end
else % no preconditioner
   u = vold;
end
if existM2
   if isequal(m2type,'matrix')
      v = M2 \ u;
   else
      v = iterapp(m2fun,m2type,m2fcnstr,u,varargin{:});
   end
   if isinf(norm(v,inf))
      flag = 2;
      relres = normr / n2b;
      iter = 0;
      resvec = resvec(1);
      resveccg = resveccg(1);
      if nargout < 2
         itermsg('symmlq',tol,maxit,0,flag,iter,relres);
      end
      return
   end
else % no preconditioner
   v = u;
end
beta1 = vold' * v;
if (beta1 <= 0)
   flag = 5;
   relres = normr / n2b;
   iter = 0;
   resvec = resvec(1);
   resveccg = resveccg(1);
   if nargout < 2
      itermsg('symmlq',tol,maxit,0,flag,iter,relres);
   end
   return
end
beta1 = sqrt(beta1);
vv = v / beta1;
wbar = vv;
if isequal(atype,'matrix')
   v = A * vv;
else
   v = iterapp(afun,atype,afcnstr,vv,varargin{:});
end
alpha = vv' * v;
v = v - (alpha/beta1) * vold;

% Local reorthogonalization
numer = vv' * v;
denom = vv' * vv;
v = v - (numer/denom) * vv;
volder = vold;
vold = v;

if existM1
   if isequal(m1type,'matrix')
      u = M1 \ vold;
   else
      u = iterapp(m1fun,m1type,m1fcnstr,vold,varargin{:});
   end
   if isinf(norm(v,inf))
      flag = 2;
      relres = normr / n2b;
      iter = 0;
      resvec = resvec(1);
      resveccg = resveccg(1);
      if nargout < 2
         itermsg('symmlq',tol,maxit,0,flag,iter,relres);
      end
      return
   end
else % no preconditioner
   u = vold;
end
if existM2
   if isequal(m2type,'matrix')
      v = M2 \ u;
   else
      v = iterapp(m2fun,m2type,m2fcnstr,u,varargin{:});
   end
      if isinf(norm(v,inf))
      flag = 2;
      relres = normr / n2b;
      iter = 0;
      resvec = resvec(1);
      resveccg = resveccg(1);
      if nargout < 2
         itermsg('symmlq',tol,maxit,0,flag,iter,relres);
      end
      return
   end
else % no preconditioner
   v = u;
end
betaold = beta1;
beta = vold' * v;
if (beta < 0)
   flag = 5;
   relres = normr / n2b;
   iter = 0;
   resvec = resvec(1);
   resveccg = resveccg(1);
   if nargout < 2
      itermsg('symmlq',tol,maxit,0,flag,iter,relres);
   end
   return
end
beta = sqrt(beta);
gammabar = alpha;
deltabar = beta;
gamma = sqrt(gammabar^2 + beta^2);
cs = gammabar / gamma;
sn = beta / gamma;
zeta = beta1 / gamma;
epsilonzeta = 0;
% estimate norm of 1st CG iterate.
if existM
   resveccg(2,1) = norm((beta1/gammabar)*vold);
else
   normrcgcs = abs(beta1 * sn);
   % It's possible that this cs value is zero (CG iterate does not exist)
   if (cs == 0)
      normrcg = Inf;
   else
      normrcg = normrcgcs / abs(cs);
   end
   resveccg(2,1) = normrcg;
end

stag = 0;                          % stagnation of the method

% loop over maxit iterations (unless convergence or failure)

for i = 1 : maxit
   
   vv = v / beta;
   w = cs * wbar + sn * vv;
   % Check for stagnation of the method
   stagtest = zeros(n,1);
   ind = (x ~= 0);
   stagtest(ind) = w(ind) ./ x(ind);
   stagtest(~ind & (w ~= 0)) = Inf;
   if (zeta == 0) | (abs(zeta)*norm(stagtest,inf) < eps)
      % increment the number of consecutive iterates which are the same
      stag = stag + 1;
   else
      % this iterate is not the same as the previous one
      stag = 0;
   end
   x = x + zeta * w;
   wbar = sn * wbar - cs * vv;   
   if isequal(atype,'matrix')
      v = A * vv;
   else     
      v = iterapp(afun,atype,afcnstr,vv,varargin{:});
   end
   v = v - (beta / betaold) * volder;
   alpha = vv' * v;
   v = v - (alpha / beta) * vold;
   volder = vold;
   vold = v;
   if existM1
      if isequal(m1type,'matrix')
         u = M1 \ vold;
      else
         u = iterapp(m1fun,m1type,m1fcnstr,vold,varargin{:});
      end
      if isinf(norm(u,inf))
         flag = 2;
         break
      end
   else % no preconditioner
      u = vold;
   end
   if existM2
      if isequal(m2type,'matrix')
         v = M2 \ u;
      else
         v = iterapp(m2fun,m2type,m2fcnstr,u,varargin{:});
      end
      if isinf(norm(v,inf))
         flag = 2;
         break
      end
   else % no preconditioner
      v = u;
   end
   betaold = beta;
   beta = vold' * v;
   if (beta < 0)
      flag = 5;
      break
   end
   beta = sqrt(beta);
   delta = cs * deltabar + sn * alpha;
   deltazeta = - delta * zeta;
   gammabar = sn * deltabar - cs * alpha;
   epsilon = sn * beta;
   deltabar = - cs * beta;
   gamma = sqrt(gammabar^2 + beta^2);
   csold = cs;
   snzeta = sn * zeta;
   cs = gammabar / gamma;
   sn = beta / gamma;
   epszdelz = epsilonzeta + deltazeta;
   epsilonzeta = - epsilon * zeta;
   zeta = epszdelz / gamma;
   % estimate norm of i-th SYMMLQ iterate and (i+1)-st CG iterate.
   if existM
      normr = norm((zeta*gamma/betaold)*volder - snzeta*vold);
      normrcg = norm((csold*epszdelz/gammabar - snzeta)*vold);
   else
      normr = sqrt(epszdelz^2 + epsilonzeta^2);
      normrcgcs = normrcgcs * abs(sn);
      if (cs == 0)
         normrcg = Inf;
      else
         normrcg = normrcgcs / abs(cs);
      end
   end
   resvec(i+1,1) = normr;
   resveccg(i+2,1) = normrcg;
   if (normr <= tolb) % check for convergence
      % double check residual norm is less than tolerance
      if isequal(atype,'matrix')
         r = b - A * x;
      else
         r = b - iterapp(afun,atype,afcnstr,x,varargin{:});
      end
      normr = norm(r);
      if (normr <= tolb)
         flag = 0;
         iter = i;
         break
      end
   end
   if (normrcg <= tolb)
      % Conjugate Gradients solution
      xcg = x + (epszdelz/gammabar) * wbar;
      % double check CG residual norm is less than tolerance
      if isequal(atype,'matrix')
         r = b - A * xcg;                 % CG residual
      else
         r = b - iterapp(afun,atype,afcnstr,xcg,varargin{:});
      end
      normrcg = norm(r);
      if (normrcg <= tolb)
         x = xcg;
         flag = 0;
         iter = i;
         break
      end
   end
   if (stag >= 2)                  % 3 consecutive iterates are the same
      flag = 3;
      break
   end
   if (normr < normrmin)           % update minimal norm quantities
      normrmin = normr;
      xmin = x;
      imin = i;
   end
end                                % for i = 1 : maxit

% returned solution is first with minimal residual
if isequal(atype,'matrix')
   r = b - A * x;                 % residual
else
   r = b - iterapp(afun,atype,afcnstr,x,varargin{:});
end
normr = norm(r);                  % Norm of residual
if (flag == 0)
   relres = normr / n2b;
else
   x = xmin;
   iter = imin;
   relres = normrmin / n2b;
end

% truncate the zeros from resvec
if ((flag <= 1) || (flag == 3))
   resvec = resvec(1:i+1);
   resveccg = resveccg(1:i+2);
else
   resvec = resvec(1:i);
   resveccg = resveccg(1:i+1);
end

% only display a message if the output flag is not used
if (nargout < 2)
   itermsg('symmlq',tol,maxit,i,flag,iter,relres);
end
