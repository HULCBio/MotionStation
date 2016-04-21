function [ x,flag,relres,iter,resvec ] = gmres(A,b,restart,tol,maxit,M1,M2,x0,varargin)
%GMRES  Generalized Minimum Residual Method.
%   X = GMRES(A,B) attempts to solve the system of linear equations A*X = B for
%   X.  The N-by-N coefficient matrix A must be square and the right hand side
%   column vector B must have length N.  A may be a function returning A*X. This
%   uses the unrestarted method with MIN(N,10) total iterations.
%
%   GMRES(A,B,RESTART) restarts the method every RESTART iterations.  If RESTART
%   is N or [] then GMRES uses the unrestarted method as above.
%
%   GMRES(A,B,RESTART,TOL) specifies the tolerance of the method.  If TOL is []
%   then GMRES uses the default, 1e-6.
%
%   GMRES(A,B,RESTART,TOL,MAXIT) specifies the maximum number of outer
%   iterations. Note: the total number of iterations is RESTART*MAXIT. If MAXIT
%   is [] then GMRES uses the default, MIN(N/RESTART,10). If RESTART is N or []
%   then the total number of iterations is MAXIT.
%
%   GMRES(A,B,RESTART,TOL,MAXIT,M) and GMRES(A,B,RESTART,TOL,MAXIT,M1,M2)
%   use preconditioner M or M=M1*M2 and effectively solve the
%   system inv(M)*A*X = inv(M)*B for X.  If M is [] then a preconditioner is
%   not applied.  M may be a function returning M\X.
%
%   GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) specifies the first initial
%   guess.  If X0 is [] then GMRES uses the default, an all zero vector.
%
%   GMRES(AFUN,B,RESTART,TOL,MAXIT,M1FUN,M2FUN,X0,P1,P2,...) passes parameters
%   to functions: AFUN(X,P1,P2,...), M1FUN(X,P1,P2,...), M2FUN(X,P1,P2,...).
% 
%   [X,FLAG] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) also returns a convergence
%   FLAG:
%    0 GMRES converged to the desired tolerance TOL within MAXIT iterations.
%    1 GMRES iterated MAXIT times but did not converge.
%    2 preconditioner M was ill-conditioned.
%    3 GMRES stagnated (two consecutive iterates were the same).
%
%   [X,FLAG,RELRES] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) also returns
%   the relative residual NORM(B-A*X)/NORM(B).  If FLAG is 0, 
%   RELRES <= TOL.  Note with preconditioners M1,M2, the residual is 
%   NORM(M2\(M1\(B-A*X))).
%
%   [X,FLAG,RELRES,ITER] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) also
%   returns both the outer and inner iteration numbers at which X was
%   computed: 0 <= ITER(1) <= MAXIT and 0 <= ITER(2) <= RESTART.
%
%   [X,FLAG,RELRES,ITER,RESVEC] = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0) also
%   returns a vector of the residual norms at each inner iteration, including
%   NORM(B-A*X0).  Note with preconditioners M1,M2, the residual is 
%   NORM(M2\(M1\(B-A*X))).
%
%   Example:
%      A = gallery('wilk',21);  b = sum(A,2);
%      tol = 1e-12;  maxit = 15; M1 = diag([10:-1:1 1 1:10]);
%      x = gmres(A,b,10,tol,maxit,M1,[],[]);
%   Alternatively, use this matrix-vector product function
%      function y = afun(x,n)
%      y = [0; x(1:n-1)] + [((n-1)/2:-1:0)'; (1:(n-1)/2)'] .*x + [x(2:n); 0];
%   and this preconditioner backsolve function
%      function y = mfun(r,n)
%      y = r ./ [((n-1)/2:-1:1)'; 1; (1:(n-1)/2)'];
%   as inputs to GMRES
%      x1 = gmres(@afun,b,10,tol,maxit,@mfun,[],[],21);
%
%   See also BICG, BICGSTAB, CGS, LSQR, MINRES, PCG, QMR, SYMMLQ, LUINC, @.
%
%   References
%   H.F. Walker, "Implemenation of the GMRES Method Using 
%   Householder Transformations", SIAM J. Sci. Comp. Vol 9. 
%   No 1. January 1988.
%
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.21.4.3 $ $Date: 2004/03/02 21:48:22 $

if (nargin < 2)
   error('MATLAB:gmres:NumInputs','Not enough input arguments.');
end

% Determine whether A is a matrix, a string expression,
% the name of a function or an inline object.
[atype,afun,afcnstr] = iterchk(A);
if isequal(atype,'matrix')
   % Check matrix and right hand side vector inputs have appropriate sizes
   [m,n] = size(A);
   if (m ~= n)
      error('MATLAB:gmres:SquareMatrix','Matrix must be square.');
   end
   if ~isequal(size(b),[m,1])
      es = sprintf(['Right hand side must be a column vector of' ...
            ' length %d to match the coefficient matrix.'],m);
      error('MATLAB:gmres:VectorSize',es);
   end
else
   m = size(b,1);
   n = m;
   if (size(b,2) ~= 1)
      error('MATLAB:gmres:Vector','Right hand side must be a column vector.');
   end
end

% Assign default values to unspecified parameters
if (nargin < 3) | isempty(restart) | (restart == n)
    restarted = 0;
else
    restarted = 1;
end
if (nargin < 4) || isempty(tol)
   tol = 1e-6;
end
if (nargin < 5) || isempty(maxit)
    if restarted
        maxit = min(ceil(n/restart),10);
    else
        maxit = min(n,10);
    end
end

if restarted
    outer = maxit;
    inner = restart;
else
    outer = 1;
    inner = maxit;
end

% Check for all zero right hand side vector => all zero solution
n2b = norm(b);                      % Norm of rhs vector, b
if (n2b == 0)                       % if    rhs vector is all zeros
   x = zeros(n,1);                  % then  solution is all zeros
   flag = 0;                        % a valid solution has been obtained
   relres = 0;                      % the relative residual is actually 0/0
   iter = [0 0];                    % no iterations need be performed
   resvec = 0;                      % resvec(1) = norm(b-A*x) = norm(0)      
   if (nargout < 2)
      itermsg('gmres',tol,maxit,0,flag,iter,NaN);
   end
   return
end

if ((nargin >= 6) && ~isempty(M1))
   existM1 = 1;
   [m1type,m1fun,m1fcnstr] = iterchk(M1);
   if isequal(m1type,'matrix')
      if ~isequal(size(M1),[m,m])
         es = sprintf(['Preconditioner must be a square matrix' ...
               ' of size %d to match the problem size.'],m);
         error('MATLAB:gmres:PreConditioner1Size',es);
      end      
   end   
else
   existM1 = 0;
   m1type = 'matrix';
end

if ((nargin >= 7) && ~isempty(M2))
   existM2 = 1;
   [m2type,m2fun,m2fcnstr] = iterchk(M2);
   if isequal(m2type,'matrix')
      if ~isequal(size(M2),[m,m])
         es = sprintf(['Preconditioner must be a square matrix' ...
               ' of size %d to match the problem size.'],m);
         error('MATLAB:gmres:PreConditioner2Size',es);
      end
   end
else
   existM2 = 0;
   m2type = 'matrix';
end

if ((nargin >= 8) && ~isempty(x0))
   if ~isequal(size(x0),[n,1])
      es = sprintf(['Initial guess must be a column vector of' ...
            ' length %d to match the problem size.'],n);
      error('MATLAB:gmres:XoSize',es);
   end
else
   x0 = zeros(n,1);
end
x = x0;

if ((nargin > 8) && isequal(atype,'matrix') && ...
      isequal(m1type,'matrix') && isequal(m2type,'matrix'))
   error('MATLAB:gmres:TooManyInputs','Too many input arguments.');
end

% Set up for the method
flag = 1;
xmin = x;                          % Iterate which has minimal residual so far
imin = 0;                          % "Outer" iteration at which xmin was computed
jmin = 0;                          % "Inner" iteration at which xmin was computed
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
   iter = [0 0];
   resvec = normr;
   if (nargout < 2)
      itermsg('gmres',tol,maxit,[0 0],flag,iter,relres);
   end
   return
end

if existM1
   if isequal(m1type,'matrix')
        r1 = M1 \ r;
   else
        r1 = iterapp(m1fun,m1type,m1fcnstr,r,varargin{:});
   end
   if ( isinf(norm(r1,inf)) || any(isnan(r1)) )
        flag = 2;
        x = xmin;
        relres = normr / n2b;
        iter = [0 0];
        resvec = normr;
        return
   end
else
   r1 = r;
end
    
if existM2
   if isequal(m2type,'matrix')
        r = M2 \ r1;
   else 
        r = iterapp(m2fun,m2type,m2fcnstr,r1,varargin{:});
   end
   if ( isinf(norm(r,inf)) || any(isnan(r)) )
        flag = 2;
        x = xmin;
        relres = normr / n2b;
        iter = [0 0];
        resvec = normr;
        return
   end
else
   r = r1;
end

normr = norm(r);
resvec = zeros(inner*outer+1,1); % Preallocate vector for norm of residuals
resvec(1) = normr;                 % resvec(1) = norm(b-A*x0)
normrmin = normr;                  % Norm of residual from xmin
rho = 1;
stag = 0;                          % stagnation of the method
    
for outiter = 1 : outer
    
    initer = 0; % counter
       
    u = r + sign(r(1))*normr*unit_vec(1,n); 
    u = u / norm(u);
    U = zeros(n,inner);
    Psol = zeros(n,inner);
    R = zeros(n,inner);
    U(:,1) = u;
    w = r - 2*u*(u'*r);
    
       
    for initer = 1 : inner
        
        v = unit_vec(initer,n) - 2*u*(u(initer)');
        for k = (initer-1):-1:1
            v = v - 2*U(:,k)*(U(:,k)'*v);
        end
        % give P1*P2*P3...Pm*em
        Psol(:,initer) = v;
        
        if isequal(atype,'matrix')
            v = A*v;
        else
            v = iterapp(afun,atype,afcnstr,v,varargin{:});
        end
        
        if existM1
            if isequal(m1type,'matrix')
                v1 = M1 \ v;
            else
                v1 = iterapp(m1fun,m1type,m1fcnstr,v,varargin{:});
            end
            if ( isinf(norm(v1,inf)) || any(isnan(v1)) )
                flag = 2;
                break
            end
        else
            v1 = v;
        end
        
                
        if existM2
            if isequal(m2type,'matrix')
                v = M2 \ v1;
            else
                v = iterapp(m2fun,m2type,m2fcnstr,v1,varargin{:});
            end
            if ( isinf(norm(v,inf)) || any(isnan(v)) )
                flag = 2;
                break
            end
        else
            v = v1;
        end
        
        for k = 1:initer
            v = v - 2*U(:,k)*(U(:,k)'*v);
        end
        % gives Pm*Pm-1*...P1*A*P1*P2*..Pm*em
        
        % determine Pm+1
        if ~(initer==length(v) || all( v(initer+1:end)==0) )
            u = zeros(n,1);
            alpha = -sign(v(initer+1))*norm( v(initer+1:end) );
            u(initer+1:end) = v(initer+1:end) - alpha*unit_vec(1,n-initer);
            u = u / norm(u);
            U(:,initer+1) = u;
            % apply Pm+1 to v
            v = v - 2*u*(u'*v);
        end
        
        if initer==1
            J = speye(n);
        else
            J = Jtemp*J;
            v = J*v;
        end
        
        % find Given's rotation Jm
        if ~(initer==length(v))
            if v(initer+1)==0
                Jtemp = speye(n);
            else
                Jtemp = speye(n);
                [Jhat,v(initer:initer+1)] = planerot( v(initer:initer+1) );
                Jtemp(initer:initer+1,initer:initer+1) = Jhat;
                w(initer:initer+1) = Jhat*w(initer:initer+1);
            end
        end
        
        R(:,initer) = v;
        
                
        if initer<inner
            normr = abs(w(initer+1));
            resvec( (outiter-1)*inner+initer+1 ) = normr;
        end
        
        if normr <= normrmin
            normrmin = normr;
            imin = outiter;
            jmin = initer;
        end
        
        if normr < tolb
            flag = 0;
            iter = [outiter, initer];
            break
        end
        
    end         % ends innner loop
    
    
    y = R(1:jmin,:) \ w(1:jmin);
    additive = Psol*y;
    x = x + additive;
    xmin = x;
        
    if isequal(atype,'matrix')
        r = b - A * x;
    else
        r = b - iterapp(afun,atype,afcnstr,x,varargin{:});
    end
    
    if existM1
        if isequal(m1type,'matrix')
            r1 = M1 \ r;
        else
            r1 = iterapp(m1fun,m1type,m1fcnstr,r,varargin{:});
        end
        if ( isinf(norm(r1,inf)) || any(isnan(r1)) )
            flag = 2;
            break
        end
    else
        r1 = r;
    end
    
    if existM2
        if isequal(m2type,'matrix')
            r = M2 \ r1;
        else 
            r = iterapp(m2fun,m2type,m2fcnstr,r1,varargin{:});
        end
        if ( isinf(norm(r,inf)) || any(isnan(r)) )
            flag = 2;
            break
        end
    else
        r = r1;
    end
    
    normr = norm(r);
    
    resvec((outiter-1)*inner+initer+1) = normr;
           
    if normr <= normrmin
        xmin = x;
        normrmin = normr;
    end
    
    %test for stagnation on outer iterate
    if flag~=2
        stagtest = zeros(n,1);
        ind = (x ~=0 );
        stagtest(ind) = additive(ind) ./ x;
        if ( norm(additive,inf) < eps )
        stag = 1;
        flag = 3;
        break;
        % no change in outer iterate
        end
    end
    
    if normr < tolb
        flag = 0;
        iter = [outiter, initer];
        break;
    end
end         % ends outer loop

 
 % returned solution is that with minimum residual
if flag == 0
   relres = normr / n2b;
else
   x = xmin;
   iter = [imin jmin];
   relres = normrmin / n2b;
end

% truncate the zeros from resvec
if flag <= 1 || flag == 3
   resvec = resvec(1:(outiter-1)*inner+initer+1);
   indices = resvec==0;
   resvec = resvec(~indices);
else
   if initer == 0
      resvec = resvec(1:(outiter-1)*inner+1);
   else
      resvec = resvec(1:(outiter-1)*inner+initer);
   end
end



% only display a message if the output flag is not used
if nargout < 2
    if restarted
        itermsg(sprintf('gmres(%d)',restart),tol,maxit,[i j],flag,iter,relres);
    else
        itermsg(sprintf('gmres'),tol,maxit,j,flag,iter(2),relres);
    end
end


function vec = unit_vec(k,n)
vec = zeros(n,1); vec(k) = 1;

