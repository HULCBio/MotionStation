function [x,flag,relres,iter,resvec] = bicgstab(A,b,tol,maxit,M1,M2,x0,varargin)
%BICGSTAB BiConjugate Gradients Stabilized Method
%   X = BICGSTAB(A,B) attempts to solve the system of linear equations A*X=B
%   for X.  The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.  A may be a function returning A*X.
%
%   BICGSTAB(A,B,TOL) specifies the tolerance of the method.  If TOL is []
%   then BICGSTAB uses the default, 1e-6.
%
%   BICGSTAB(A,B,TOL,MAXIT) specifies the maximum number of iterations.  If
%   MAXIT is [] then BICGSTAB uses the default, min(N,20).
%
%   BICGSTAB(A,B,TOL,MAXIT,M) and BICGSTAB(A,B,TOL,MAXIT,M1,M2) use
%   preconditioner M or M=M1*M2 and effectively solve the system
%   inv(M)*A*X = inv(M)*B for X.  If M is [] then a preconditioner is not
%   applied.  M may be a function returning M\X.
%
%   BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If X0 is []
%   then BICGSTAB uses the default, an all zero vector.
%
%   BICGSTAB(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters P1,P2,...
%   to functions: AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...).
% 
%   [X,FLAG] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) also returns a convergence FLAG:
%    0 BICGSTAB converged to the desired tolerance TOL within MAXIT iterations.
%    1 BICGSTAB iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 BICGSTAB stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during BICGSTAB became
%      too small or too large to continue computing.
%
%   [X,FLAG,RELRES] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   relative residual NORM(B-A*X)/NORM(B).  If FLAG is 0, RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   iteration number at which X was computed: 0 <= ITER <= MAXIT.  ITER may
%   be an integer + 0.5, indicating convergence half way through an iteration.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0) also returns
%   a vector of the residual norms at each half iteration, including NORM(B-A*X0).
%
%   Example:
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%      x = bicgstab(A,b,tol,maxit,M1,[],[]);
%   Alternatively, use this matrix-vector product function
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + [x(2:n); 0];
%   and this preconditioner backsolve function
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%   as inputs to BICGSTAB
%      x1 = bicgstab(@afun,b,tol,maxit,@mfun,[],[],21);
%   Note that both afun and mfun had to accept BICGSTAB's extra input n=21.
%
%   See also BICG, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.

%   Penny Anderson, 1996.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.19.4.1 $ $Date: 2003/05/01 20:42:58 $

% Check for an acceptable number of input arguments
if nargin < 2
   error('MATLAB:bicgstab:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:bicgstab:NonSquareMatrix','Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      es = sprintf(['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
      error('MATLAB:bicgstab:RSHsizeMatchCoeffMatrix', es);
   end
else
   m = size(b,1);
   n = m;
   if (size(b,2) ~= 1)
      error('MATLAB:bicgstab:RSHnotColumn',...
            'Right hand side must be a column vector.');
   end
end

% Assign default values to unspecified parameters
if nargin < 3 || isempty(tol)
   tol = 1e-6;
end
if nargin < 4 || isempty(maxit)
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
   if (nargout < 2)
      itermsg('bicgstab',tol,maxit,0,flag,iter,NaN);
   end
   return
end

if ((nargin >= 5) && ~isempty(M1))
   existM1 = 1;
   [m1type,m1fun,m1fcnstr] = iterchk(M1);
   if isequal(m1type,'matrix')
      if ~isequal(size(M1),[m,m])
         es = sprintf(['Preconditioner must be a square matrix' ...
               ' of size %d to match the problem size.'],m);
         error('MATLAB:bicgstab:WrongPrecondSize', es);
      end      
   end   
else
   existM1 = 0;
   m1type = 'matrix';
end

if ((nargin >= 6) && ~isempty(M2))
   existM2 = 1;
   [m2type,m2fun,m2fcnstr] = iterchk(M2);
   if isequal(m2type,'matrix')
      if ~isequal(size(M2),[m,m])
         es = sprintf(['Preconditioner must be a square matrix' ...
               ' of size %d to match the problem size.'],m);
         error('MATLAB:bicgstab:WrongPrecondSize', es);
      end
   end
else
   existM2 = 0;
   m2type = 'matrix';
end

if ((nargin >= 7) && ~isempty(x0))
   if ~isequal(size(x0),[n,1])
      es = sprintf(['Initial guess must be a column vector of' ...
            ' length %d to match the problem size.'],n);
      error('MATLAB:bicgstab:WrongInitGuessSize', es);
   else
      x = x0;
   end
else
   x = zeros(n,1);
end

if ((nargin > 7) && isequal(atype,'matrix') && ...
      isequal(m1type,'matrix') && isequal(m2type,'matrix'))
   error('MATLAB:bicgstab:TooManyInputs', 'Too many input arguments.');
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
   if (nargout < 2)
      itermsg('bicgstab',tol,maxit,0,flag,iter,relres);
   end
   return
end

rt = r;                            % Shadow residual
resvec = zeros(2*maxit+1,1);       % Preallocate vector for norm of residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of residual from xmin
rho = 1;
omega = 1;
stag = 0;                          % stagnation of the method
alpha = [];                        % overshadow any functions named alpha

% loop over maxit iterations (unless convergence or failure)

for i = 1 : maxit
   rho1 = rho;
   rho = rt' * r;
   if rho == 0.0 | isinf(rho)
      flag = 4;
      resvec = resvec(1:2*i-1);
      break
   end
   if i == 1
      p = r;
   else
      beta = (rho/rho1)*(alpha/omega);
      if beta == 0 | ~isfinite(beta)
         flag = 4;
         break
      end
      p = r + beta * (p - omega * v);
   end
   if existM1
      if isequal(m1type,'matrix')
         ph1 = M1 \ p;
      else
         ph1 = iterapp(m1fun,m1type,m1fcnstr,p,varargin{:});
      end
      if isinf(norm(ph1,inf))
         flag = 2;
         resvec = resvec(1:2*i-1);
         break
      end
   else
      ph1 = p;
   end
   if existM2
      if isequal(m2type,'matrix')
         ph = M2 \ ph1;
      else
         ph = iterapp(m2fun,m2type,m2fcnstr,ph1,varargin{:});
      end
      if isinf(norm(ph,inf))
         flag = 2;
         resvec = resvec(1:2*i-1);
         break
      end
   else
      ph = ph1;
   end
   if isequal(atype,'matrix')
      v = A * ph;
   else
      v = iterapp(afun,atype,afcnstr,ph,varargin{:});         
   end
   rtv = rt' * v;
   if rtv == 0 | isinf(rtv)
      flag = 4;
      resvec = resvec(1:2*i-1);
      break
   end
   alpha = rho / rtv;
   if isinf(alpha)
      flag = 4;
      resvec = resvec(1:2*i-1);
      break
   end
   if alpha == 0                    % stagnation of the method
      stag = 1;
   end
   
   % Check for stagnation of the method
   if stag == 0
      stagtest = zeros(n,1);
      ind = (x ~= 0);
      stagtest(ind) = ph(ind) ./ x(ind);
      stagtest(~ind & ph ~= 0) = Inf;
      if abs(alpha)*norm(stagtest,inf) < eps
         stag = 1;
      end
   end
   
   xhalf = x + alpha * ph;          % form the "half" iterate
   if isequal(atype,'matrix')
      rhalf = b - A * xhalf;           % and its residual
   else
      rhalf = b - iterapp(afun,atype,afcnstr,xhalf,varargin{:});
   end
   normr = norm(rhalf);
   resvec(2*i) = normr;
   
   if normr <= tolb                 % check for convergence
      x = xhalf;
      flag = 0;
      iter = i - 0.5;
      resvec = resvec(1:2*i);
      break
   end
   
   if stag == 1
      flag = 3;
      resvec = resvec(1:2*i);
      break
   end
   
   if normr < normrmin              % update minimal norm quantities
      normrmin = normr;
      xmin = xhalf;
      imin = i - 0.5;
   end
   
   s = r - alpha * v;               % residual associated with xhalf
   if existM1
      if isequal(m1type,'matrix')
         sh1 = M1 \ s;
      else
         sh1 = iterapp(m1fun,m1type,m1fcnstr,s,varargin{:});
      end
		if isinf(norm(sh1,inf))
         flag = 2;
         resvec = resvec(1:2*i);
         break
      end
   else
      sh1 = s;
   end
   if existM2
		if isequal(m2type,'matrix')
         sh = M2 \ sh1;
      else
         sh = iterapp(m2fun,m2type,m2fcnstr,sh1,varargin{:});
      end
      if isinf(norm(sh,inf))
         flag = 2;
         resvec = resvec(1:2*i);
         break
      end
   else
      sh = sh1;
   end
   if isequal(atype,'matrix')
      t = A * sh;
   else
      t = iterapp(afun,atype,afcnstr,sh,varargin{:});
   end
   tt = t' * t;
   if tt == 0 | isinf(tt)
      flag = 4;
      resvec = resvec(1:2*i);
      break
   end
   omega = (t' * s) / tt;
   if isinf(omega)
      flag = 4;
      resvec = resvec(1:2*i);
      break
   end
   if omega == 0                    % stagnation of the method
      stag = 1;
   end
   
   % Check for stagnation of the method
   if stag == 0
      stagtest = zeros(n,1);
      ind = (xhalf ~= 0);
      stagtest(ind) = sh(ind) ./ xhalf(ind);
      stagtest(~ind & sh ~= 0) = Inf;
      if abs(omega)*norm(stagtest,inf) < eps
         stag = 1;
      end
   end
   
   x = xhalf + omega * sh;          % x = (x + alpha * ph) + omega * sh
   if isequal(atype,'matrix')
      normr = norm(b - A * x);
   else
      normr = norm(b - iterapp(afun,atype,afcnstr,x,varargin{:}));
   end
   resvec(2*i+1) = normr;
   
   if normr <= tolb                 % check for convergence
      flag = 0;
      iter = i;
      resvec = resvec(1:2*i+1);
      break
   end
   
   if stag == 1
      flag = 3;
      resvec = resvec(1:2*i+1);
      break
   end
   
   if normr < normrmin              % update minimal norm quantities
      normrmin = normr;
      xmin = x;
      imin = i;
   end
   
   r = s - omega * t;
   
end                                % for i = 1 : maxit

% returned solution is first with minimal residual
if flag == 0
   relres = normr / n2b;
else
   x = xmin;
   iter = imin;
   relres = normrmin / n2b;
end

% only display a message if the output flag is not used
if nargout < 2
   itermsg('bicgstab',tol,maxit,i,flag,iter,relres);
end
