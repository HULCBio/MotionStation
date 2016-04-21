function [x,flag,relres,iter,resvec] = bicg(A,b,tol,maxit,M1,M2,x0,varargin)
%BICG   BiConjugate Gradients Method
%   X = BICG(A,B) attempts to solve the system of linear equations A*X=B
%   for X.  The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.  A may be a function AFUN such
%   that AFUN(X) returns A*X and AFUN(X,'transp') returns A'*X.
%
%   BICG(A,B,TOL) specifies the tolerance of the method.  If TOL is []
%   then BICG uses the default, 1e-6.
%
%   BICG(A,B,TOL,MAXIT) specifies the maximum number of iterations.  If
%   MAXIT is [] then BICG uses the default, min(N,20).
%
%   BICG(A,B,TOL,MAXIT,M) and BICG(A,B,TOL,MAXIT,M1,M2) use the preconditioner
%   M or M=M1*M2 and effectively solve the system inv(M)*A*X = inv(M)*B for X.
%   If M is [] then a preconditioner is not applied.  M may be a function MFUN
%   such that MFUN(X) returns M\X and MFUN(X,'transp') returns M'\X.
%
%   BICG(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If X0 is []
%   then BICG uses the default, an all zero vector.
%
%   BICG(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters P1,P2,...
%   to AFUN: AFUN(X,P1,P2,...) and AFUN(X,P1,P2,...,'transp') and
%   similarly to the preconditioner functions M1FUN and M2FUN.
%
%   [X,FLAG] = BICG(A,B,TOL,MAXIT,M1,M2,X0) also returns a convergence FLAG:
%    0 BICG converged to the desired tolerance TOL within MAXIT iterations
%    1 BICG iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 BICG stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during BICG became
%      too small or too large to continue computing.
%
%   [X,FLAG,RELRES] = BICG(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   relative residual NORM(B-A*X)/NORM(B).  If FLAG is 0, RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = BICG(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   iteration number at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = BICG(A,B,TOL,MAXIT,M1,M2,X0) also returns
%   a vector of the residual norms at each iteration including NORM(B-A*X0).
%
%   Example:
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); M2 = spdiags([4*on -on],0:1,n,n);
%   x = bicg(A,b,tol,maxit,M1,M2,[]);
%   Use this matrix-vector product function
%     function y = afun(x,n,transp_flag)
%     if (nargin > 2) & strcmp(transp_flag,'transp')
%       y = 4 * x;
%       y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%       y(2:n) = y(2:n) - x(1:n-1);
%     else
%       y = 4 * x;
%       y(2:n) = y(2:n) - 2 * x(1:n-1);
%       y(1:n-1) = y(1:n-1) - x(2:n);
%     end
%
%   as input to BICG
%   x1 = bicg(@afun,b,tol,maxit,M1,M2,[],n);
%
%   See also BICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.

%   Penny Anderson, 1996.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $ $Date: 2004/04/16 22:08:18 $

% Check for an acceptable number of input arguments
if nargin < 2
   error('MATLAB:bicg:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:bicg:NonSquareMatrix', 'Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      es = sprintf(['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
      error('MATLAB:bicg:RSHsizeMismatchCoeffMatrix', es);
   end
else
   m = size(b,1);
   n = m;
   if (size(b,2) ~= 1)
      error('MATLAB:bicg:RSHnotColumn',...
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
      itermsg('bicg',tol,maxit,0,flag,iter,NaN);
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
         error('MATLAB:bicg:WrongPrecondSize', es);
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
         error('MATLAB:bicg:WrongPrecondSize', es);
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
      error('MATLAB:bicg:WrongInitGuessSize', es);
   else
      x = x0;
   end
else
   x = zeros(n,1);
end

if ((nargin > 7) && isequal(atype,'matrix') && ...
      isequal(m1type,'matrix') && isequal(m2type,'matrix'))
   error('MATLAB:bicg:TooManyInputs', 'Too many input arguments.');
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
      itermsg('bicg',tol,maxit,0,flag,iter,relres);
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
         yt = M2' \ rt;
      else
         z = iterapp(m2fun,m2type,m2fcnstr,y,varargin{:});
         yt = iterapp(m2fun,m2type,m2fcnstr,rt,varargin{:},'transp');
      end
      if isinf(norm(z,inf)) || isinf(norm(yt,inf))
         flag = 2;
         break
      end
   else
      z = y;
      yt = rt;
   end
   if existM1
      if isequal(m1type,'matrix')
         zt = M1' \ yt;
      else
         zt = iterapp(m1fun,m1type,m1fcnstr,yt,varargin{:},'transp');
      end
      if isinf(norm(zt,inf))
         flag = 2;
         break
      end
   else
      zt = yt;
   end
   
   rho1 = rho;
   rho = rt' * z;
   if rho == 0 | isinf(rho)
      flag = 4;
      break
   end
   if i == 1
      p = z;
      pt = zt;
   else
      beta = rho / rho1;
      if beta == 0 | isinf(beta)
         flag = 4;
         break
      end
      p = z + beta * p;
      pt = zt + conj(beta) * pt;
   end
   
   if isequal(atype,'matrix')
      q = A * p;
      qt = (pt' * A)';
   else
      q = iterapp(afun,atype,afcnstr,p,varargin{:});         
      qt = iterapp(afun,atype,afcnstr,pt,varargin{:},'transp');
   end
   ptq = pt' * q;
   if ptq == 0
      flag = 4;
      break
   else
      alpha = rho / ptq;
   end   
   if isinf(alpha)
      flag = 4;
      break
   end
   if alpha == 0                    % stagnation of the method
      stag = 1;
   end
   
   % Check for stagnation of the method
   if stag == 0
      stagtest = zeros(n,1);
      ind = (x ~= 0);
      stagtest(ind) = p(ind) ./ x(ind);
      stagtest(~ind & p ~= 0) = Inf;
      if abs(alpha)*norm(stagtest,inf) < eps
         stag = 1;
      end
   end
   
   x = x + alpha * p;               % form the new iterate
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
   
   r = r - alpha * q;
   rt = rt - conj(alpha) * qt;
      
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
   itermsg('bicg',tol,maxit,i,flag,iter,relres);
end
