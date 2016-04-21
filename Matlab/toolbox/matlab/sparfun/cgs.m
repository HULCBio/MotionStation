function [x,flag,relres,iter,resvec] = cgs(A,b,tol,maxit,M1,M2,x0,varargin)
%CGS    Conjugate Gradients Squared Method
%   X = CGS(A,B) attempts to solve the system of linear equations A*X=B
%   for X.  The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.  A may be a function returning A*X.
%
%   CGS(A,B,TOL) specifies the tolerance of the method.  If TOL is []
%   then CGS uses the default, 1e-6.
%
%   CGS(A,B,TOL,MAXIT) specifies the maximum number of iterations.  If MAXIT
%   is [] then CGS uses the default, min(N,20).
%
%   CGS(A,B,TOL,MAXIT,M) and CGS(A,B,TOL,MAXIT,M1,M2) use the preconditioner
%   M or M=M1*M2 and effectively solve the system inv(M)*A*X = inv(M)*B for X.
%   If M is [] then a preconditioner is not applied.  M may be a function
%   returning M\X.
%
%   CGS(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If X0 is []
%   then CGS uses the default, an all zero vector.
%
%   CGS(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters P1,P2,...
%   to functions: AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...).
%
%   [X,FLAG] = CGS(A,B,TOL,MAXIT,M1,M2,X0) also returns a convergence FLAG:
%    0 CGS converged to the desired tolerance TOL within MAXIT iterations.
%    1 CGS iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 CGS stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during CGS became too
%      small or too large to continue computing.
%   Whenever FLAG is not 0, the solution X returned is that with
%   minimal norm residual computed over all the iterations.  No
%   messages are displayed if the FLAG output is specified.
%
%   [X,FLAG,RELRES] = CGS(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   relative residual NORM(B-A*X)/NORM(B).  If FLAG is 0, RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = CGS(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   iteration number at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = CGS(A,B,TOL,MAXIT,M1,M2,X0) also returns
%   a vector of the residual norms at each iteration, including NORM(B-A*X0).
%
%   Example:
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%      x = cgs(A,b,tol,maxit,M1,[],[]);
%   Alternatively, use this matrix-vector product function
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + [x(2:n); 0];
%   and this preconditioner backsolve function
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%   as inputs to CGS
%      x1 = cgs(@afun,b,tol,maxit,@mfun,[],[],21);
%   Note that both afun and mfun had to accept CGS's extra input n=21.
%
%   See also BICG, BICGSTAB, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.

%   Penny Anderson, 1996.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $ $Date: 2003/05/01 20:42:59 $

if (nargin < 2)
   error('MATLAB:cgs:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:cgs:NonSquareMatrix', 'Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      es = sprintf(['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
      error('MATLAB:cgs:RSHsizeMatchCoeffMatrix', es);
   end
else
   m = size(b,1);
   n = m;
   if (size(b,2) ~= 1)
      error('MATLAB:cgs:RSHnotColumn',...
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
      itermsg('cgs',tol,maxit,0,flag,iter,NaN);
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
         error('MATLAB:cgs:WrongPrecondSize', es);
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
         error('MATLAB:cgs:WrongPrecondSize', es);
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
      error('MATLAB:cgs:WrongInitGuessSize', es);
   else
      x = x0;
   end
else
   x = zeros(n,1);
end

if ((nargin > 7) && isequal(atype,'matrix') && ...
      isequal(m1type,'matrix') && isequal(m2type,'matrix'))
   error('MATLAB:cgs:TooManyInputs', 'Too many input arguments.');
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
      itermsg('cgs',tol,maxit,0,flag,iter,relres);
   end
   return
end

rt = r;                            % Shadow residual
resvec = zeros(maxit+1,1);         % Preallocate vector for norms of residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of residual from xmin
rho = 1;
stag = 0;                          % stagnation of the method

% loop over maxit iterations (unless convergence or failure)

for i = 1 : maxit
   rho1 = rho;
   rho = rt' * r;
   if rho == 0 | isinf(rho)
      flag = 4;
      break
   end
   if i == 1
      u = r;
      p = u;
   else
      beta = rho / rho1;
      if beta == 0 | isinf(beta)
         flag = 4;
         break
      end
      u = r + beta * q;
      p = u + beta * (q + beta * p);
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
      vh = A * ph;
   else     
      vh = iterapp(afun,atype,afcnstr,ph,varargin{:});         
   end
   rtvh = rt' * vh;
   if rtvh == 0
      flag = 4;
      break
   else
      alpha = rho / rtvh;
   end
   if isinf(alpha)
      flag = 4;
      break
   end
   if alpha == 0                    % stagnation of the method
      stag = 1;
   end
   q = u - alpha * vh;
   if existM1
      if isequal(m1type,'matrix')
         uh1 = M1 \ (u+q);
      else
         uh1 = iterapp(m1fun,m1type,m1fcnstr,u+q,varargin{:});
      end
      if isinf(norm(uh1,inf))
         flag = 2;
         break
      end
   else
      uh1 = u+q;
   end
   if existM2
      if isequal(m2type,'matrix')
         uh = M2 \ uh1;
      else
         uh = iterapp(m2fun,m2type,m2fcnstr,uh1,varargin{:});
      end
      if isinf(norm(uh,inf))
         flag = 2;
         break
      end
   else
      uh = uh1;
   end
   
   % Check for stagnation of the method
   if stag == 0
      stagtest = zeros(n,1);
      ind = (x ~= 0);
      stagtest(ind) = uh(ind) ./ x(ind);
      stagtest(~ind & uh ~= 0) = Inf;
      if abs(alpha)*norm(stagtest,inf) < eps
         stag = 1;
      end
   end
   
   x = x + alpha * uh;              % form the new iterate
   if isequal(atype,'matrix')
      normr = norm(b - A * x);
   else
      normr = norm(b - iterapp(afun,atype,afcnstr,x,varargin{:}));
   end
   resvec(i+1) = normr;
   
   if normr <= tolb                 % check for convergence
      flag = 0;
      iter = i;
      break
   end
   
   if stag == 1
      flag = 3;
      break
   end
   
   if normr < normrmin              % update minimal norm quantities
      normrmin = normr;
      xmin = x;
      imin = i;
   end
   if isequal(atype,'matrix')
      qh = A * uh;
   else
      qh = iterapp(afun,atype,afcnstr,uh,varargin{:});
   end
   r = r - alpha * qh;
   
end                                % for i = 1 : maxit

% returned solution is first with minimal residual
if flag == 0
   relres = normr / n2b;
else
   x = xmin;
   iter = imin;
   relres = normrmin / n2b;
end

% truncate the zeros from resvec
if flag <= 1 || flag == 3
   resvec = resvec(1:i+1);
else
   resvec = resvec(1:i);
end

% only display a message if the output flag is not used
if nargout < 2
   itermsg('cgs', tol,maxit,i,flag,iter,relres);
end
