function [F,exitflag,output] = funm(A,fun,options,varargin)
%FUNM  Evaluate general matrix function.
%   F = FUNM(A,FUN) evaluates the function FUN at the square matrix A.
%   FUN(X,K) must return the K'th derivative of the function represented
%   by FUN evaluated at the vector X.
%   The MATLAB functions EXP, LOG, COS, SIN, COSH, SINH can be passed
%   as FUN, i.e., FUNM(A,@EXP), FUNM(A,@LOG), FUNM(A,@COS), FUNM(A,@SIN),
%   FUNM(A,@COSH), FUNM(A,@SINH) are all allowed.
%   For matrix square roots use SQRTM(A) instead.
%   For matrix exponentials, either of EXPM(A) and FUNM(A,@EXP) may be
%   the more accurate, depending on A.
%
%   The function represented by FUN must have a Taylor series with an
%   infinite radius of convergence.
%
%   Example:
%   To compute the function EXP(X)+COS(X) at A with one call to FUNM, use
%       F = funm(A,@fun_expcos)
%   where
%       function f = fun_expcos(x,k)
%       % Return k'th derivative of EXP+COS at X.
%       g = mod(ceil(k/2),2);
%       if mod(k,2)
%          f = exp(x) + sin(x)*(-1)^g;
%       else
%          f = exp(x) + cos(x)*(-1)^g;
%       end
%
%   F = FUNM(A,FUN,options) sets the algorithm's parameters to the
%   values in the structure options.
%   options.Display:  Level of display
%                     [ {off} | on | verbose ]
%   options.TolBlk:   Tolerance for blocking Schur form
%                     [ positive scalar {0.1} ]
%   options.TolTay:   Termination tolerance for evaluating Taylor
%                     series of diagonal blocks
%                     [ positive scalar {eps} ]
%   options.MaxTerms: Maximum number of Taylor series terms
%                     [ positive integer {250} ]
%   options.MaxSqrt:  When computing logarithm, maximum number of
%                     square roots computed in inverse scaling and
%                     squaring method
%                     [ positive integer {100} ]
%   options.Ord:      A specified ordering of the Schur form, T.
%                     A vector of length LENGTH(A), with options.Ord(i)
%                     the index of the block into which T(i,i)
%                     should be placed,
%                     [ integer vector {[]} ]
%
%   F = FUNM(A,FUN,options,P1,P2,...) passes extra inputs
%   P1,P2,... to the function: FEVAL(FUN,X,K,P1,P2,...).
%   Use options = [] as a place holder if no options are set.
%
%   [F,EXITFLAG] = FUNM(...) returns a scalar EXITFLAG that describes
%   the exit condition of FUNM:
%   EXITFLAG = 0: successful completion of algorithm.
%   EXITFLAG = 1: one or more Taylor series evaluations did not converge.
%                 Computed F may still be accurate, however.
%   Note: this is different from R13 and earlier versions, which returned as
%   second output argument an expensive and often inaccurate error estimate.
%
%   [F,EXITFLAG,output] = FUNM(...) returns a structure output with
%   output.terms(i): the number of Taylor series terms used
%                    when evaluating the i'th block, or the number of
%                    square roots in the case of the logarithm,
%   output.ind(i):   cell array specifying the blocking: the (i,j)
%                    block of the re-ordered Schur factor T is
%                    T(output.ind{i},output.ind{j}),
%   output.ord:      the ordering, as passed to ORDSCHUR,
%   output.T:        the re-ordered Schur form.
%   If the Schur form is diagonal then
%   output = struct('terms',ones(n,1),'ind',{1:n})
%
%   See also EXPM, SQRTM, LOGM, @.

%   Reference:
%   P. I. Davies and N. J. Higham.                                        
%   A Schur-Parlett algorithm for computing matrix functions.             
%   SIAM J. Matrix Anal. Appl., 25(2):464-485, 2003. 
%
%   Nicholas J. Higham
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.17.4.3 $  $Date: 2004/03/09 16:16:43 $

if isequal(fun,@cos)  || isequal(fun,'cos'), fun = @fun_cos; end
if isequal(fun,@sin)  || isequal(fun,'sin'), fun = @fun_sin; end
if isequal(fun,@cosh) || isequal(fun,'cosh'), fun = @fun_cosh; end
if isequal(fun,@sinh) || isequal(fun,'sinh'), fun = @fun_sinh; end
if isequal(fun,@exp)  || isequal(fun,'exp'), fun = @fun_exp; end
if isequal(fun,@log)  || isequal(fun,'log'), fun = @fun_log; end

% Default parameters.
prnt = 0;
delta = 0.1;
tol = eps;
maxterms = 250;
maxsqrt = 100;
ord = [];
reord = 1;

if nargin > 2 && ~isempty(options)

   if isfield(options,'Display') && ~isempty(options.Display)
      switch lower(options.Display)
         case 'on',      prnt = 1;
         case 'verbose', prnt = 2;
      end
   end

   if isfield(options,'TolBlk') && ~isempty(options.TolBlk)
      delta = options.TolBlk;
      if delta <= 0, error('MATLAB:funm:NegTolBlk', 'TolBlk must be positive.'); end
   end

   if isfield(options,'TolTay') && ~isempty(options.TolTay)
      tol = options.TolTay;
      if tol <= 0, error('MATLAB:funm:NegTolTay', 'TolTay must be positive.'); end
   end

   if isfield(options,'MaxTerms') && ~isempty(options.MaxTerms)
      maxterms = options.MaxTerms;
      if maxterms <= 0 
        error('MATLAB:funm:NegMaxTerms', 'MaxTerms must be positive.'); 
      end
   end

   if isfield(options,'MaxSqrt') && ~isempty(options.MaxSqrt)
      maxterms = options.MaxSqrt;
      if maxsqrt <= 0
        error('MATLAB:funm:NegMaxSqrt', 'MaxSqrt must be positive.'); 
      end
   end

   if isfield(options,'Ord') && ~isempty(options.Ord)
      ord = options.Ord;
      if length(ord) ~= length(A)
        error('MATLAB:WrongDimOrd', 'Incorrect dimension for Ord.'); 
      end
   end

end

n = length(A);

% First form complex Schur form (if A not already upper triangular).
if isequal(A,triu(A))
   T = A; U = eye(n);
else
   [U,T] = schur(A,'complex');
end

if isequal(fun,@fun_log) && any( imag(diag(T)) == 0 & real(diag(T)) <= 0 )
    warning('MATLAB:funm:nonPosRealEig', ...
           ['Principal matrix logarithm is not defined for A with\n' ...
            '         nonpositive real eigenvalues. A non-principal matrix\n' ...
            '         logarithm is returned.'])
end

if isequal(T,tril(T)) % Handle special case of diagonal T.
   F = U*diag(feval(fun,diag(T),0,varargin{:}))*U';
   exitflag = 0; output = struct('terms',ones(n,1),'ind',{1:n});
   return
end

% Determine reordering of Schur form into block form.
if isempty(ord), ord = blocking(T,delta); end

[ord, ind] = swapping(ord);  % Gives the blocking.
ord = max(ord)-ord+1;        % Since ORDSCHUR puts highest index top left.
[U,T] = ordschur(U,T,ord);

m = length(ind);

% Calculate F(T)
F = zeros(n);

for col=1:m
   j = ind{col};
   if prnt == 2 && max(j) > min(j)
      fprintf('Evaluating function of block (%g:%g)\n', min(j), max(j))
   end
   if isequal(fun,@fun_log)
      [F(j,j), terms(col)] = logm_isst(T(j,j),maxsqrt,prnt>1);
   else
      [F(j,j), terms(col)] = funm_atom(T(j,j),fun,tol,maxterms,prnt>1,...
                                       varargin{:});
   end

   for row=col-1:-1:1
      i = ind{row};
      if length(i) == 1 && length(j) == 1
         % Scalar case.
         k = i+1:j-1;
         temp = T(i,j)*(F(i,i) - F(j,j)) + F(i,k)*T(k,j) - T(i,k)*F(k,j);
         F(i,j) = temp/(T(i,i)-T(j,j));
      else
         k = cat(2,ind{row+1:col-1});
         rhs = F(i,i)*T(i,j) - T(i,j)*F(j,j) + F(i,k)*T(k,j) - T(i,k)*F(k,j);
         F(i,j) = sylv_tri(T(i,i),-T(j,j),rhs);
      end
   end
end

F = U*F*U';

if isreal(A) && norm(imag(F),1) <= 10*n*eps*norm(F,1)
   F = real(F);
end

if prnt
  fprintf('  Block   Number of Taylor series terms\n')
  fprintf('          (or square roots in case of log):\n')
  fprintf('  ----------------------------------------\n')
  for i = 1:length(ind)
      fprintf(' (%g:%g)      %g\n', min(ind{i}), max(ind{i}), terms(i))
  end
end

exitflag = 0;
if any(terms == -1)
   exitflag = 1;
   warning('MATLAB:funm:TaylorSeriesNotConverged',...
           ['Taylor series failed to converge.',...
            '\n         Possible that function does not have an infinite ',...
            'radius of convergence.\n',...
            '         Try decreasing options.TolBlk or increasing options.TolTay ',...
            'or options.MaxTerms.'])
end

if nargout >= 2
    warning('MATLAB:funm:obsoleteEstErr',...
           ['The second output changed from an error estimate',...
            ' to an exit flag.\n'...
            '         Please check the help for more information.'])   
end

if nargout >= 3
   output = struct('terms',terms,'ind',{ind},'ord',ord,'T',T);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_cos(x,k)
%FUN_COS Cosine function and its derivatives.
%        FUN_COS(X,K) is the k'th derivative of the cosine function at X.

g = mod(ceil(k/2),2);
if mod(k,2)
   f = sin(x)*(-1)^g;
else
   f = cos(x)*(-1)^g;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_sin(x,k)
%FUN_SIN Sine function and its derivatives.
%        FUN_SIN(X,K) is the k'th derivative of the sine function at X.

g = mod(ceil((k-1)/2),2);
if mod(k,2);
   f = cos(x)*(-1)^g;
else
   f = sin(x)*(-1)^g;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_cosh(x,k)
%FUN_COSH Hyperbolic cosine function and its derivatives.
%   FUN_COSH(X,K) is the k'th derivative of the hyperbolic cosine function
%   at X.

if mod(k,2);
   f = sinh(x);
else
   f = cosh(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_exp(x,k)
%FUN_EXP Exponential function and its derivatives.
%   FUN_EXP(X,K) is the k'th derivative of the exponential function at X.

f = exp(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_log(x,k)
%FUN_LOG  Logarithm function.
%   FUN_LOG(X,K) is the logarithm at X.
%   Only to be called for plain log evaluation, with k == 0.

f = log(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = fun_sinh(x,k)
%FUN_SINH Hyperbolic sine function and its derivatives.
%   FUN_SINH(X,K) is the k'th derivative of the hyperbolic sine function at X.

if mod(k,2);
   f = cosh(x);
else
   f = sinh(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F,n_terms] = funm_atom(T,fun,tol,maxterms,prnt,varargin)
%FUNM_ATOM  Function of triangular matrix with nearly constant diagonal.
%   [F, N_TERMS] = FUNM_ATOM(T, FUN, TOL, MAXTERMS, PRNT)
%   evaluates function FUN at the upper triangular matrix T,
%   where T has nearly constant diagonal.
%   A Taylor series is used, taking at most MAXTERMS terms.
%   The function represented by FUN must have a Taylor series with an
%   infinite radius of convergence.
%   FUN(X,K) must return the K'th derivative of
%   the function represented by FUN evaluated at the vector X.
%   TOL is a convergence tolerance for the Taylor series, defaulting to EPS.
%   If PRNT ~= 0 information is printed on the convergence of the
%   Taylor series evaluation.
%   N_TERMS is the number of terms taken in the Taylor series.
%   N_TERMS  = -1 signals lack of convergence.

%   Nicholas J. Higham

if nargin < 3 || isempty(tol), tol = eps; end
if nargin < 5, prnt = 0; end

n = length(T);
if n == 1, F = feval(fun,T,0,varargin{:}); n_terms = 1; return, end

lambda = sum(diag(T))/n;
f = feval(fun,lambda,0,varargin{:}); F = f*eye(n);
if prnt, fprintf('%3.0f: |f^(k)| = %5.0e\n', 1, abs(f)); end
f_deriv_max = zeros(maxterms+n-1,1);
N = T - lambda*eye(n);
mu = norm( (eye(n)-abs(triu(T,1)))\ones(n,1),inf );

P = N;
max_d = 1;

for k = 1:maxterms

    f = feval(fun,lambda,k,varargin{:});
    if isinf(f), error('MATLAB:funm:InfDeriv', 'Infinite derivative.'), end
    F_old = F;
    F = F + P*f;
    rel_diff = norm(F - F_old,inf)/(tol+norm(F_old,inf));
    if prnt
        fprintf('%3.0f: |f^(k)| = %5.0e', k+1, abs(f));
        fprintf('  ||N^k/k!|| = %7.1e', norm(P,inf));
        fprintf('  rel_diff = %5.0e',rel_diff);
        fprintf('  abs_diff = %5.0e',norm(F - F_old,inf));
    end
    P = P*N/(k+1);

    if rel_diff <= tol

      % Approximate the maximum of derivatives in convex set containing
      % eigenvalues by maximum of derivatives at eigenvalues.
      for j = max_d:k+n-1
          f_deriv_max(j) = norm(feval(fun,diag(T),j,varargin{:}),inf);
      end
      max_d = k+n;
      omega = 0;
      for j = 0:n-1
          omega = max(omega,f_deriv_max(k+j)/factorial(j));
      end

      trunc = norm(P,inf)*mu*omega;  % norm(F) moved to RHS to avoid / 0.
      if prnt
          fprintf('  [trunc,test] = [%5.0e %5.0e]', trunc, tol*norm(F,inf))
      end
      if prnt == -1, trunc = 0; end % Force simple stopping test.
      if trunc <= tol*norm(F,inf)
         n_terms = k+1;
         if prnt, fprintf('\n'), end
         return
      end
    end

    if prnt, fprintf('\n'), end

end
n_terms = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function X = sylv_tri(T,U,B)
%SYLV_TRI    Solve triangular Sylvester equation.
%   X = SYLV_TRI(T,U,B) solves the Sylvester equation
%   T*X + X*U = B, where T and U are square upper triangular matrices.

m = length(T);
n = length(U);
X = zeros(m,n);

% Forward substitution.
for i = 1:n
    X(:,i) = (T + U(i,i)*eye(m)) \ (B(:,i) - X(:,1:i-1)*U(1:i-1,i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X, iter] = logm_isst(T, maxlogiter, prnt)
%LOGM_ISST   Log of triangular matrix by inverse scaling and squaring method.
%   X = LOGM_ISST(A, MAXLOGITER) computes the (principal) logarithm of an
%   upper triangular matrix A, for a matrix with no nonpositive real
%   eigenvalues, using the inverse scaling and squaring method with Pade
%   approximation.  At most MAXLOGITER square roots are computed.
%   [X, ITER] = LOGM_ISST(A, MAXLOGITER, PRNT) returns the number
%   ITER of square roots computed and prints this information if
%   PRNT is nonzero.

%   References:
%   S. H. Cheng, N. J. Higham, C. S. Kenney, and A. J. Laub, Approximating the
%      logarithm of a matrix to specified accuracy, SIAM J. Matrix Anal. Appl.,
%      22(4):1112-1125, 2001.
%   N. J. Higham, Evaluating Pade approximants of the matrix logarithm,
%      SIAM J. Matrix Anal. Appl., 22(4):1126-1135, 2001.
%
%   Nicholas J. Higham

if nargin < 3, prnt = 0; end
n = length(T);

if n == 1, X = log(T); iter = 0; return, end

R = T;

for iter = 0:maxlogiter

    phi  = norm(T-eye(n),'fro');

    if phi <= 0.25
       if prnt, fprintf('LOGM_ISST computed %g square roots. \n', iter), end
       break
    end
    if iter == maxlogiter,
        error('MATLAB:funm:logm_isstr:tooManyIterations', ...
        'Too many square roots in LOGM_ISST.')
    end

    % Compute upper triangular square root R of T, a column at a time.
    for j=1:n
        R(j,j) = sqrt(T(j,j));
        for i=j-1:-1:1
            R(i,j) = (T(i,j) - R(i,i+1:j-1)*R(i+1:j-1,j))/(R(i,i) + R(j,j));
        end
    end
    T = R;
end

X = 2^(iter)*logm_pf(T-eye(n),8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = logm_pf(A,m)
%LOGM_PF   Pade approximation to matrix log by partial fraction expansion.
%          Y = LOGM_PF(A,m) approximates LOG(EYE(SIZE(A))+A) by an [m/m]
%          Pade approximation.

[nodes,wts] = gauss_legendre(m);
% Convert from [-1,1] to [0,1].
nodes = (nodes + 1)/2;
wts = wts/2;

n = length(A);
S = zeros(n);

for j=1:m
    S = S + wts(j)*(A/(eye(n) + nodes(j)*A));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,w] = gauss_legendre(n)
%GAUSS_LEGENDRE  Nodes and weights for Gauss-Legendre quadrature.
%                [X,W] = GAUSS_LEGENDRE(N) computes the nodes X and weights W
%                for N-point Gauss-Legendre quadrature.

% Reference:
% G. H. Golub and J. H. Welsch, Calculation of Gauss quadrature
% rules, Math. Comp., 23(106):221-230, 1969.

i = 1:n-1;
v = i./sqrt((2*i).^2-1);
[V,D] = eig( diag(v,-1)+diag(v,1) );
x = diag(D);
w = 2*(V(1,:)'.^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = blocking(A,delta)
%BLOCKING  Produce blocking pattern for block Parlett recurrence in FUNM.
%   M = BLOCKING(A, DELTA, SHOWPLOT) accepts an upper triangular matrix
%   A and produces a blocking pattern, specified by the vector M,
%   for the block Parlett recurrence.
%   M(i) is the index of the block into which A(i,i) should be placed,
%   for i=1:LENGTH(A).
%   DELTA is a gap parameter (default 0.1) used to determine the blocking.

%   For A coming from a real matrix it should be posible to take
%   advantage of the symmetry about the real axis.  This code does not.

a = diag(A); n = length(a);
m = zeros(1,n); maxM = 0;

if nargin < 2 || isempty(delta), delta = 0.1; end

for i = 1:n

    if m(i) == 0
        m(i) = maxM + 1; % If a(i) hasn`t been assigned to a set
        maxM = maxM + 1; % then make a new set and assign a(i) to it.
    end

    for j = i+1:n
        if m(i) ~= m(j)    % If a(i) and a(j) are not in same set.
            if abs(a(i)-a(j)) <= delta

                if m(j) == 0
                    m(j) = m(i); % If a(j) hasn`t been assigned to a
                                 % set, assign it to the same set as a(i).
                else
                    p = max(m(i),m(j)); q = min(m(i),m(j));
                    m(m==p) = q; % If a(j) has been assigned to a set
                                 % place all the elements in the set
                                 % containing a(j) into the set
                                 % containing a(i) (or vice versa).
                    m(m>p) = m(m>p) -1;
                    maxM = maxM - 1;
                                 % Tidying up. As we have deleted set
                                 % p we reduce the index of the sets
                                 % > p by 1.
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mm,ind] = swapping(m)
%SWAPPING  Choose confluent permutation ordered by average index.
%   [MM,IND] = SWAPPING(M) takes a vector M containing the integers
%   1:K (some repeated if K < LENGTH(M)), where M(J) is the index of
%   the block into which the element T(J,J) of a Schur form T
%   should be placed.
%   It constructs a vector MM (a permutation of M) such that T(J,J)
%   will be located in the MM(J)'th block counting from the (1,1) position.
%   The algorithm used is to order the blocks by ascending
%   average index in M, which is a heuristic for minimizing the number
%   of swaps required to achieve this confluent permutation.
%   The cell array vector IND defines the resulting block form:
%   IND{i} contains the indices of the i'th block in the permuted form.

mmax = max(m); mm = zeros(size(m));
g = zeros(1,mmax); h = zeros(1,mmax);

for i = 1:mmax
    p = find(m==i);
    h(i) = length(p);
    g(i) = sum(p)/h(i);
end

[x,y] = sort(g);
h = [0 cumsum(h(y))];

ind = cell(mmax,1);
for i = 1:mmax
    p = find(m==y(i));
    mm(p) = i;
    ind{i} = h(i)+1:h(i+1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
