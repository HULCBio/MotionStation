function [x,flag,relres,iter,resvec,lsvec] = lsqr(A,b,tol,maxit,M1,M2,x0,varargin)
%LSQR    LSQR Implementation of Conjugate Gradients on the Normal Equations.
%   X = LSQR(A,B) attempts to solve the system of linear equations A*X=B
%   for X if A is consistent, otherwise it attempts to solve the least squares
%   solution X that minimizes norm(B-A*X).  The M-by-N coefficient matrix A
%   need not be square but the right hand side column vector B must have
%   length M.  A may be a function AFUN such that AFUN(X) returns A*X and
%   AFUN(X,'transp') returns A'*X.
%
%   LSQR(A,B,TOL) specifies the tolerance of the method.  If TOL is []
%   then LSQR uses the default, 1e-6.
%
%   LSQR(A,B,TOL,MAXIT) specifies the maximum number of iterations.  If
%   MAXIT is [] then LSQR uses the default, min([M,N,20]).
%
%   LSQR(A,B,TOL,MAXIT,M1) and LSQR(A,B,TOL,MAXIT,M1,M2) use N-by-N
%   preconditioner M or M = M1*M2 and effectively solve the system
%   A*inv(M)*Y = B for Y, where X = M*Y.  If M is [] then a preconditioner is
%   not applied.  M may be a function MFUN such that MFUN(X) returns M\X and
%   MFUN(X,'transp') returns M'\X.
%
%   LSQR(A,B,TOL,MAXIT,M1,M2,X0) specifies the N-by-1 initial guess.  If X0 is
%   [] then LSQR uses the default, an all zero vector.
%
%   LSQR(AFUN,B,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters P1,P2,...
%   to AFUN: AFUN(X,P1,P2,...) and AFUN(X,P1,P2,...,'transp') and
%   similarly to the preconditioner functions M1FUN and M2FUN.
%    
%   [X,FLAG] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) also returns a convergence FLAG:
%    0 LSQR converged to the desired tolerance TOL within MAXIT iterations.
%    1 LSQR iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 LSQR stagnated (two consecutive iterates were the same).
%    4 one of the scalar quantities calculated during LSQR became too
%      small or too large to continue computing.
%
%   [X,FLAG,RELRES] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) also returns estimates of
%   the relative residual NORM(B-A*X)/NORM(B). If RELRES <= TOL, then X is a
%   consistent solution to A*X=B. If FLAG is 0 but RELRES > TOL, then X is the
%   least squares solution which minimizes norm(B-A*X).
%
%   [X,FLAG,RELRES,ITER] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) also returns the
%   iteration number at which X was computed: 0 <= ITER <= MAXIT.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) also returns a
%   vector of estimates of the residual norm at each iteration including
%   NORM(B-A*X0).
%
%   [X,FLAG,RELRES,ITER,RESVEC,LSVEC] = LSQR(A,B,TOL,MAXIT,M1,M2,X0) also
%   returns a vector of least squares estimates at each iteration:
%   NORM((A*inv(M))'*(B-A*X))/NORM(A*inv(M),'fro'). Note that the estimate of
%   NORM(A*inv(M),'fro') changes, and hopefully improves, at each iteration.
%
%   Example:
%   n = 100; on = ones(n,1); A = spdiags([-2*on 4*on -on],-1:1,n,n);
%   b = sum(A,2); tol = 1e-8; maxit = 15;
%   M1 = spdiags([on/(-2) on],-1:0,n,n); M2 = spdiags([4*on -on],0:1,n,n);
%   x = lsqr(A,b,tol,maxit,M1,M2,[]);
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
%   as input to LSQR
%      x1 = lsqr(@afun,b,tol,maxit,M1,M2,[],n);
%
%   See also BICG, BICGSTAB, CGS, GMRES, MINRES, PCG, QMR, SYMMLQ, @.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $ $Date: 2004/04/16 22:08:23 $

% Check for an acceptable number of input arguments
if nargin < 2
    error('MATLAB:lsqr:NotEnoughInputs', 'Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
    % Check matrix and right hand side vector inputs have appropriate sizes
    [m,n] = size(A);
    if ~isequal(size(b),[m,1])
        es = sprintf(['Right hand side must be a column vector of' ...
                ' length %d to match the coefficient matrix.'],m);
        error('MATLAB:lsqr:RSHsizeMatchCoeffMatrix', es);
    end
else
    m = size(b,1);
    if (size(b,2) ~= 1)
        error('MATLAB:lsqr:RSHnotColumn', 'Right hand side must be a column vector.');
    end
    % How many columns does A have?  Same as entries of x = A'*b.
    x = iterapp(afun,atype,afcnstr,b,varargin{:},'transp');
    n = size(x,1);
end

% Assign default values to unspecified parameters
if nargin < 3 || isempty(tol)
    tol = 1e-6;
end

if nargin < 4 || isempty(maxit)
    maxit = min([m,n,20]);
end

if ((nargin >= 5) && ~isempty(M1))
    existM1 = 1;
    [m1type,m1fun,m1fcnstr] = iterchk(M1);
    if isequal(m1type,'matrix')
        if ~isequal(size(M1),[n,n])
            es = sprintf(['Preconditioner must be a square matrix' ...
                    ' of size %d to match the problem size.'],n);
            error('MATLAB:lsqr:WrongPrecondSize', es);
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
        if ~isequal(size(M2),[n,n])
            es = sprintf(['Preconditioner must be a square matrix' ...
                    ' of size %d to match the problem size.'],n);
            error('MATLAB:lsqr:WrongPrecondSize', es);
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
        error('MATLAB:lsqr:WrongInitGuessSize', es);
    else
        x = x0;
    end
else
    x = zeros(n,1);
end

if ((nargin > 7) && isequal(atype,'matrix') && ...
        isequal(m1type,'matrix') && isequal(m2type,'matrix'))
    error('MATLAB:lsqr:TooManyInputs','Too many input arguments.');
end

% Set up for the method
n2b = norm(b);                     % Norm of rhs vector, b
flag = 1;
tolb = tol * n2b;                  % Relative tolerance
if isequal(atype,'matrix')
   u = b - A * x;
else
   u = b - iterapp(afun,atype,afcnstr,x,varargin{:});
end
beta = norm(u);
% Norm of residual r=b-A*x is estimated well by prod_i abs(sin_i)
normr = beta;
if beta ~= 0
    u = u / beta;
end
c = 1;
s = 0;
phibar = beta;
d = zeros(n,1);
if isequal(atype,'matrix')
    v = A' * u;
else
    v = iterapp(afun,atype,afcnstr,u,varargin{:},'transp');
end
if existM1
    if isequal(m1type,'matrix')
        v = M1' \ v;
    else
        v = iterapp(m1fun,m1type,m1fcnstr,v,varargin{:},'transp');
    end
    if isinf(norm(v,inf))
        flag = 2;
        relres = normr/n2b;
        iter = 0;
        resvec = normr;
        lsvec = zeros(0,1);
        if nargout < 2
            itermsg('lsqr',tol,maxit,0,flag,iter,relres);
        end
        return
    end
end
if existM2
    if isequal(m2type,'matrix')
        v = M2' \ v;
    else
        v = iterapp(m2fun,m2type,m2fcnstr,v,varargin{:},'transp');
    end
    if isinf(norm(v,inf))
        flag = 2;
        relres = normr/n2b;
        iter = 0;
        resvec = normr;
        lsvec = zeros(0,1);
        if nargout < 2
            itermsg('lsqr',tol,maxit,0,flag,iter,relres);
        end
        return
    end
end
alpha = norm(v);
if alpha ~= 0
    v = v / alpha;
end

% norm((A*inv(M))'*r) = alpha_i * abs(sin_i * phi_i)
normar = alpha * beta;

% Check for all zero solution
if (normar == 0)                     % if alpha_1 == 0 | beta_1 == 0
    x = zeros(n,1);                  % then  solution is all zeros
    flag = 0;                        % a valid solution has been obtained
    relres = 0;                      % the relative residual is actually 0/0
    iter = 0;                        % no iterations need be performed
    resvec = beta;                   % resvec(1) = norm(b-A*x) = norm(0)      
    lsvec = zeros(0,1);              % no estimate for norm(A*inv(M),'fro') yet
    if (nargout < 2)
        itermsg('lsqr',tol,maxit,0,flag,iter,NaN);
    end
    return
end

% Poorly estimate norm(A*inv(M),'fro') by norm(B_{i+1,i},'fro')
% which is in turn estimated very well by sqrt(sum_i (alpha_i^2 + beta_{i+1}^2))
norma = 0;
% norm(inv(A*inv(M)),'fro') = norm(D,'fro')
% which is poorly estimated by sqrt(sum_i norm(d_i)^2)
sumnormd2 = 0;
resvec = zeros(maxit+1,1);         % Preallocate vector for norm of residuals
resvec(1) = normr;                 % resvec(1,1) = norm(b-A*x0)
lsvec = zeros(maxit,1);            % Preallocate vector for least squares estimates
stag = 0;                          % stagnation of the method
iter = maxit;                      % Assume lack of convergence until it happens

% loop over maxit iterations (unless convergence or failure)

for i = 1 : maxit
    if existM2
        if isequal(m2type,'matrix')
            z = M2 \ v;
        else
            z = iterapp(m2fun,m2type,m2fcnstr,v,varargin{:});
        end
        if isinf(norm(z,inf))
            flag = 2;
            iter = i-1;
            resvec = resvec(1:iter+1);
            lsvec = lsvec(1:iter);
            break
        end
    else
        z = v;
    end
    if existM1
        if isequal(m1type,'matrix')
            z = M1 \ z;
        else
            z = iterapp(m1fun,m1type,m1fcnstr,z,varargin{:});
        end
        if isinf(norm(z,inf))
            flag = 2;
            iter = i-1;
            resvec = resvec(1:iter+1);
            lsvec = lsvec(1:iter);
            break
        end
    end
    if isequal(atype,'matrix')
        u = A * z - alpha * u;
    else
        u = iterapp(afun,atype,afcnstr,z,varargin{:}) - alpha * u;
    end
    beta = norm(u);
    u = u / beta;
    norma = norm([norma alpha beta]);
    lsvec(i) = normar / norma;
    thet = - s * alpha;
    rhot = c * alpha;
    rho = sqrt(rhot^2 + beta^2);
    c = rhot / rho;
    s = - beta / rho;
    phi = c * phibar;
    if (phi == 0)                  % stagnation of the method
        stag = 1;
    end
    phibar = s * phibar;    
    d = (z - thet * d) / rho;
    sumnormd2 = sumnormd2 + (norm(d))^2;
    conda = norma * sqrt(sumnormd2);
    
    % Check for stagnation of the method
    if (stag == 0)
        stagtest = zeros(n,1);
        ind = (x ~= 0);
        stagtest(ind) = d(ind) ./ x(ind);
        stagtest(~ind & d ~= 0) = Inf;
        if norm(stagtest,inf) < eps
            stag = 1;
        end
    end
    
    if normar/(norma*normr) <= tol % check for convergence in min{|b-A*x|}
        flag = 0;
        iter = i-1;
        resvec = resvec(1:iter+1);
        lsvec = lsvec(1:iter+1);
        break
    end

    if normr <= tolb               % check for convergence in A*x=b
        flag = 0;
        iter = i-1;
        resvec = resvec(1:iter+1);
        lsvec = lsvec(1:iter+1);
        break
    end
    
    if stag == 1
        flag = 3;
        iter = i-1;
        resvec = resvec(1:iter+1);
        lsvec = lsvec(1:iter+1);
        break
    end
        
    x = x + phi * d;
    normr = abs(s) * normr;
    resvec(i+1) = normr;
    if isequal(atype,'matrix')
        vt = A' * u;
    else
        vt = iterapp(afun,atype,afcnstr,u,varargin{:},'transp');
    end
    if existM1
        if isequal(m1type,'matrix')
            vt = M1' \ vt;
        else
            vt = iterapp(m1fun,m1type,m1fcnstr,vt,varargin{:},'transp');
        end
        if isinf(norm(vt,inf))
            flag = 2;
            iter = i;
            resvec = resvec(1:iter+1);
            lsvec = lsvec(1:iter+1);
            break
        end
    end
    if existM2
        if isequal(m2type,'matrix')
            vt = M2' \ vt;
        else
            vt = iterapp(m2fun,m2type,m2fcnstr,vt,varargin{:},'transp');
        end
        if isinf(norm(vt,inf))
            flag = 2;
            iter = i;
            resvec = resvec(1:iter+1);
            lsvec = lsvec(1:iter);
            break
        end
    end
    v = vt - beta * v;
    alpha = norm(v);
    v = v / alpha;
    normar = alpha * abs( s * phi);
    
end                                % for i = 1 : maxit

relres = normr/n2b;

% only display a message if the output flag is not used
if nargout < 2
    itermsg('lsqr',tol,maxit,i,flag,iter,relres);
end
