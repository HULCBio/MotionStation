function [x,flag,relres,iter,resvec] = qmr(A,b,tol,maxit,M1,M2,x0,varargin)
%QMR    Quasi-Minimal Residual Method
%   X = QMR(A,B) attempts to solve the system of linear equations A*X=B
%   for X.  The N-by-N coefficient matrix A must be square and the right hand
%   side column vector B must have length N.  A may be a function AFUN such
%   that AFUN(X) returns A*X and AFUN(X,'transp') returns A'*X.
%
%   QMR(A,B,TOL) specifies the tolerance of the method.  If TOL is []
%   then QMR uses the default, 1e-6.
%
%   QMR(A,B,TOL,MAXIT) specifies the maximum number of iterations.  If
%   MAXIT is [] then QMR uses the default, min(N,20).
%
%   QMR(A,B,TOL,MAXIT,M) and QMR(A,B,TOL,MAXIT,M1,M2) use preconditioners M or
%   M=M1*M2 and effectively solve the system inv(M)*A*X = inv(M)*B for X.
%   If M is [] then a preconditioner is not applied.  M may be a function MFUN
%   such that MFUN(X) returns M\X and MFUN(X,'transp') returns M'\X.
%
%   QMR(A,B,TOL,MAXIT,M1,M2,X0) specifies the initial guess.  If X0 is []
%   then QMR uses the default, an all zero vector.
%
%   QMR(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters P1,P2,...
%   to AFUN: AFUN(X,P1,P2,...) and AFUN(X,P1,P2,...,'transp') and
%   similarly to the preconditioner functions M1FUN and M2FUN.
%
%   [X,FLAG] = QMR(A,B,TOL,MAXIT,M1,M2,X0) also returns a convergence FLAG:
%    0 QMR converged to the desired tolerance TOL within MAXIT iterations.
%    1 QMR iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 QMR stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during QMR became too
%      small or too large to continue computing.
%
%   [X,FLAG,RELRES] = QMR(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   relative residual NORM(B-A*X)/NORM(B).  If FLAG is 0, RELRES <= TOL.
%
%   [X,FLAG,RELRES,ITER] = QMR(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   iteration number at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = QMR(A,B,TOL,MAXIT,M1,M2,X0) also returns a
%   vector of the residual norms at each iteration, including NORM(B-A*X0).
%
%   Example:
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); M2 = spdiags([4*on -on],0:1,n,n);
%   x = qmr(A,b,tol,maxit,M1,M2,[]);
%   Use this matrix-vector product function
%      function y = afun(x,n,transp_flag)
%      if (nargin > 2) & strcmp(transp_flag,'transp')
%         y = 4 * x;
%         y(1:n-1) = y(1:n-1) - 2 * x(2:n);
%         y(2:n) = y(2:n) - x(1:n-1);
%      else
%         y = 4 * x;
%         y(2:n) = y(2:n) - 2 * x(1:n-1);
%         y(1:n-1) = y(1:n-1) - x(2:n);
%      end
%
%   as input to QMR
%   x1 = qmr(@afun,b,tol,maxit,M1,M2,[],n);
%
%   See also BICG, BICGSTAB, CGS, GMRES, LSQR, MINRES, PCG, SYMMLQ, LUINC, @.

%   Penny Anderson, 1996.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $ $Date: 2004/04/16 22:08:27 $

% Check for an acceptable number of input arguments
if nargin < 2
   error('MATLAB:qmr:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:qmr:NonSquareMatrix', 'Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      es = sprintf(['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
      error('MATLAB:qmr:RSHsizeMatchCoeffMatrix', es);
   end
else
   m = size(b,1);
   n = m;
   if (size(b,2) ~= 1)
      error('MATLAB:qmr:RSHnotColumn',...
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
      itermsg('qmr',tol,maxit,0,flag,iter,NaN);
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
         error('MATLAB:qmr:WrongPrecondSize', es);
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
         error('MATLAB:qmr:WrongPrecondSize', es);
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
      error('MATLAB:qmr:WrongInitGuessSize', es);
   else
      x = x0;
   end
else
   x = zeros(n,1);
end

if ((nargin > 7) && isequal(atype,'matrix') && ...
      isequal(m1type,'matrix') && isequal(m2type,'matrix'))
   error('MATLAB:qmr:TooManyInputs', 'Too many input arguments.');
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
      itermsg('qmr',tol,maxit,0,flag,iter,relres);
   end
   return
end

vt = r;
resvec = zeros(maxit+1,1);         % Preallocate vector for norm of residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of residual from xmin

if existM1
   if isequal(m1type,'matrix')
      y = M1 \ vt;
   else
      y = iterapp(m1fun,m1type,m1fcnstr,vt,varargin{:});
   end
   if isinf(norm(y,inf))
      flag = 2;
      relres = normr/n2b;
      iter = 0;
      resvec = normr;
      if nargout < 2
         itermsg('qmr',tol,maxit,0,flag,iter,relres);
      end
      return
   end
else
   y = vt;
end
rho = norm(y);
wt = r;
if existM2
   if isequal(m2type,'matrix')
      z = M2' \ wt;
   else
      z = iterapp(m2fun,m2type,m2fcnstr,wt,varargin{:},'transp');
   end
   if isinf(norm(z,inf))
      flag = 2;
      relres = normr/n2b;
      iter = 0;
      resvec = normr;
      if nargout < 2
         itermsg('qmr',tol,maxit,0,flag,iter,relres);
      end
      return
   end
else
   z = wt;
end
psi = norm(z);
gamm = 1;
eta = -1;
stag = 0;                          % stagnation of the method

% loop over maxit iterations (unless convergence or failure)

for i = 1 : maxit
   if rho == 0 || isinf(rho)
      flag = 4;
      break
   end
   if psi == 0 || isinf(psi)
      flag = 4;
      break
   end
   v = vt / rho;
   y = y / rho;
   w = wt / psi;
   z = z / psi;
   delta = z' * y;
   if delta == 0 | isinf(delta)
      flag = 4;
      break
   end
   if existM2
      if isequal(m2type,'matrix')
         yt = M2 \ y;
      else
         yt = iterapp(m2fun,m2type,m2fcnstr,y,varargin{:});
      end
      if isinf(norm(yt,inf))
         flag = 2;
         break
      end
   else
      yt = y;
   end
   if existM1
      if isequal(m1type,'matrix')
         zt = M1' \ z;
      else
         zt = iterapp(m1fun,m1type,m1fcnstr,z,varargin{:},'transp');
      end
      if isinf(norm(zt,inf))
         flag = 2;
         break
      end
   else
      zt = z;
   end
   if i == 1
      p = yt;
      q = zt;
   else
      pde = psi * delta / epsilon;
      if pde == 0 | ~isfinite(pde)
         flag = 4;
         break
      end
      rde = rho * conj(delta/epsilon);
      if rde == 0 | ~isfinite(rde)
         flag = 4;
         break
      end
      p = yt - pde * p;
      q = zt - rde * q;
   end
   if isequal(atype,'matrix')
      pt = A * p;
   else
      pt = iterapp(afun,atype,afcnstr,p,varargin{:});         
   end
   epsilon = q' * pt;
   if epsilon == 0 | isinf(epsilon)
      flag = 4;
      break
   end
   beta = epsilon / delta;
   if beta == 0 | isinf(beta)
      flag = 4;
      break
   end
   vt = pt - beta * v;
   if existM1
      if isequal(m1type,'matrix')
         y = M1 \ vt;
      else
         y = iterapp(m1fun,m1type,m1fcnstr,vt,varargin{:});
      end
      if isinf(norm(y,inf))
         flag = 2;
         break
      end
   else
      y = vt;
   end
   rho1 = rho;
   rho = norm(y);
   %  wt = A' * q - beta * w;
   if isequal(atype,'matrix')
      wt = (q' * A)';
   else
      wt = iterapp(afun,atype,afcnstr,q,varargin{:},'transp');
   end
   wt = wt - conj(beta) * w;
   if existM2
      if isequal(m2type,'matrix')
         z = M2' \ wt;
      else
         z = iterapp(m2fun,m2type,m2fcnstr,wt,varargin{:},'transp');
      end
      if isinf(norm(z,inf))
         flag = 2;
         break
      end
   else
      z = wt;
   end
   psi = norm(z);
   if i > 1
      thet1 = thet;
   end
   thet = rho / (gamm * abs(beta));
   gamm1 = gamm;
   gamm = 1 / sqrt(1 + thet^2);
   if gamm == 0
      flag = 4;
      break
   end
   eta = - eta * rho1 * gamm^2 / (beta * gamm1^2);
   if isinf(eta)
      flag = 4;
      break
   end
   if i == 1
      d = eta * p;
      s = eta * pt;
   else
      d = eta * p + (thet1 * gamm)^2 * d;
      s = eta * pt + (thet1 * gamm)^2 * s;
   end
   
   % Check for stagnation of the method
   stagtest = zeros(n,1);
   ind = (x ~= 0);
   stagtest(ind) = d(ind) ./ x(ind);
   stagtest(~ind & d ~= 0) = Inf;
   if norm(stagtest,inf) < eps
      stag = 1;
   end
   
   x = x + d;                       % form the new iterate
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
   
   r = r - s;
   
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
   itermsg('qmr',tol,maxit,i,flag,iter,relres);
end
