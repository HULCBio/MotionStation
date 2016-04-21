function [x,flag,relres,iter,resvec] = pcg(A,b,tol,maxit,M1,M2,x0,varargin)
%PCG    Preconditioned Conjugate Gradients Method
%   X = PCG(A,B) attempts to solve the system of linear equations A*X=B
%   for X.  The N-by-N coefficient matrix A must be symmetric and positive
%   definite and the right hand side column vector B must have length N.
%   A may be a function returning A*X.
%
%   PCG(A,B,TOL) specifies the tolerance of the method.  If TOL is []
%   then PCG uses the default, 1e-6.
%
%   PCG(A,B,TOL,MAXIT) specifies the maximum number of iterations.  If
%   MAXIT is [] then PCG uses the default, min(N,20).
%
%   PCG(A,B,TOL,MAXIT,M) and PCG(A,B,TOL,MAXIT,M1,M2) use symmetric
%   positive definite preconditioner M or M=M1*M2 and effectively
%   solve the system inv(M)*A*X = inv(M)*B for X.  If M is [] then
%   a preconditioner is not applied.  M may be a function returning M\X.
%
%   PCG(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If X0 is []
%   then PCG uses the default, an all zero vector.
%
%   PCG(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters P1,P2,...
%   to functions: AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...).
%
%   [X,FLAG] = PCG(A,B,TOL,MAXIT,M1,M2,X0) also returns a convergence FLAG:
%    0 PCG converged to the desired tolerance TOL within MAXIT iterations
%    1 PCG iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 PCG stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during PCG became too
%      small or too large to continue computing.
%
%   [X,FLAG,RELRES] = PCG(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   relative residual NORM(B-A*X)/NORM(B).  If FLAG is 0, RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = PCG(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   iteration number at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = PCG(A,B,TOL,MAXIT,M1,M2,X0) also returns a
%   vector of the residual norms at each iteration including NORM(B-A*X0).
%
%   Example:
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15;  M = diag([10:-1:1 1 1:10]);
%      [x,flag,rr,iter,rv] = pcg(A,b,tol,maxit,M);
%   Alternatively, use this one-line matrix-vector product function
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'].*x + [x(2:n); 0];
%   and this one-line preconditioner backsolve function
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%   as inputs to PCG
%      [x1,flag1,rr1,iter1,rv1] = pcg(@afun,b,tol,maxit,@mfun,[],[],21);
%
%   See also BICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, QMR, SYMMLQ, CHOLINC, @.

%   Penny Anderson, 1996.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $ $Date: 2004/04/16 22:08:26 $

if (nargin < 2)
   error('MATLAB:pcg:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:pcg:NonSquareMatrix', 'Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      es = sprintf(['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
      error('MATLAB:pcg:RSHsizeMatchCoeffMatrix', es);
   end
else
   m = size(b,1);
   n = m;
   if (size(b,2) ~= 1)
      error('MATLAB:pcg:RSHnotColumn',...
            'Right hand side must be a column vector.');
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
   if (nargout < 2)
      itermsg('pcg',tol,maxit,0,flag,iter,NaN);
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
         error('MATLAB:pcg:WrongPrecondSize', es);
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
         error('MATLAB:pcg:WrongPrecondSize', es);
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
      error('MATLAB:pcg:WrongInitGuessSize', es);
   else
      x = x0;
   end
else
   x = zeros(n,1);
end

if ((nargin > 7) && isequal(atype,'matrix') && ...
      isequal(m1type,'matrix') && isequal(m2type,'matrix'))
   error('MATLAB:pcg:TooManyInputs', 'Too many input arguments.');
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
      itermsg('pcg',tol,maxit,0,flag,iter,relres);
   end
   return
end

resvec = zeros(maxit+1,1);         % Preallocate vector for norm of residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of minimum residual
rho = 1;
stag = 0;                          % stagnation of the method

% loop over maxit iterations (unless convergence or failure)

for i = 1 : maxit
   if existM1
      if isequal(m1type,'matrix')
         y = M1 \ r;
      else
         y = iterapp(m1fun,m1type,m1fcnstr,r,varargin{:});
      end
      if isinf(norm(y,inf))
         flag = 2;
         break
      end
   else % no preconditioner
      y = r;
   end
   
   if existM2
      if isequal(m2type,'matrix')
         z = M2 \ y;
      else
         z = iterapp(m2fun,m2type,m2fcnstr,y,varargin{:});
      end
      if isinf(norm(z,inf))
         flag = 2;
         break
      end
   else % no preconditioner
      z = y;
   end
   
   rho1 = rho;
   rho = r' * z;
   if ((rho == 0) | isinf(rho))
      flag = 4;
      break
   end
   if (i == 1)
      p = z;
   else
      beta = rho / rho1;
      if ((beta == 0) | isinf(beta))
         flag = 4;
         break
      end
      p = z + beta * p;
   end
   if isequal(atype,'matrix')
      q = A * p;
   else
      q = iterapp(afun,atype,afcnstr,p,varargin{:});         
   end
   pq = p' * q;
   if ((pq <= 0) | isinf(pq))
      flag = 4;
      break
   else
      alpha = rho / pq;
   end
   if isinf(alpha)
      flag = 4;
      break
   end
   if (alpha == 0)                  % stagnation of the method
      stag = 1;
   end
   
   % Check for stagnation of the method
   if (stag == 0)
      stagtest = zeros(n,1);
      ind = (x ~= 0);
      stagtest(ind) = p(ind) ./ x(ind);
      stagtest(~ind & p ~= 0) = Inf;
      if (abs(alpha)*norm(stagtest,inf) < eps)
         stag = 1;
      end
   end
   
   x = x + alpha * p;               % form new iterate
   if isequal(atype,'matrix')
      normr = norm(b - A * x);
   else
      normr = norm(b - iterapp(afun,atype,afcnstr,x,varargin{:}));
   end
   resvec(i+1) = normr;
   
   if (normr <= tolb)               % check for convergence
      flag = 0;
      iter = i;
      break
   end
   
   if (stag == 1)
      flag = 3;
      break
   end
   
   if (normr < normrmin)           % update minimal norm quantities
      normrmin = normr;
      xmin = x;
      imin = i;
   end
   
   r = r - alpha * q;
   
end                                % for i = 1 : maxit

% returned solution is first with minimal residual
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
else
   resvec = resvec(1:i);
end

% only display a message if the output flag is not used
if (nargout < 2)
   itermsg('pcg',tol,maxit,i,flag,iter,relres);   
end
